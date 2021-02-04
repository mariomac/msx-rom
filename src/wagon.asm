	MODULE wagon

; draw constants
TILES_TOP: equ 22
TILES_WHEELS: equ 30
TILES_WIDTH: equ 2
FILL_LEVELS: equ 4

; status constants
STATUS_EMPTYING:	equ 0
STATUS_SEEKING:	equ 1
STATUS_MOVING:	equ 2
STATUS_COLLECTING:	equ 3

MAX_SHIRTS: 	equ 128

; position of the empty door
DOOR_X:	equ 15
DOOR_Y:	equ 3

; same order as vars.asm definition 
INITIAL_VARS: db STATUS_EMPTYING, MAX_SHIRTS, DOOR_X, DOOR_Y, 0, 0
	  dw 0, SCR2_CHARPOS+DOOR_Y*32+DOOR_X, 0, 0	;vram addresses to redraw wagon
INITIAL_VARS_END:


Update:	call _update
	call _draw
	ret

_update:	ld a, (wagon_status)
	cp STATUS_EMPTYING
	jp nz, .seeking
	call _on_emptying
	ret
.seeking:	cp STATUS_SEEKING
	jp nz, .moving
	call _on_seeking
	ret
.moving:	cp STATUS_MOVING
	jp nz, .collecting
	call _on_moving
	ret
.collecting: cp STATUS_COLLECTING
	ret nz		; if status is inconsistent, wagon will block
	call _on_collecting 
	ret

_draw:	push hl
	push bc
	push de
	ld hl, [wagon_vram_addr]
	; draw top of the wagon
	; tile: TILES_TOP + 2*(shirts/MAX_SHIRTS)*FILL_LEVELS
	ld a, (wagon_shirts)
	; the number of srls will change depending on MAX_SHIRTS & FILL_LEVELS
	srl a
	srl a
	srl a
	srl a
	res 0, a		; clears bit 0. Equivalent to divide and multiply by 2
	add a, TILES_TOP
	push af
	call BIOS_WRTVRM
	pop af
	inc a
	inc hl
	call BIOS_WRTVRM	
	; draw bottom of the wagon
	; dest pos: previous dest post + 31
	ld bc, 31
	add hl, bc
	ld a, TILES_WHEELS
	call BIOS_WRTVRM
	inc hl
	ld a, TILES_WHEELS+1
	call BIOS_WRTVRM
	; draw trail. TODO: add nonzero value to door empty
	xor a
	ld hl, [wagon_trl_vram_addr_1]
	call BIOS_WRTVRM
	xor a
	ld hl, [wagon_trl_vram_addr_2]
	call BIOS_WRTVRM

	pop de
	pop bc
	pop hl
	ret

_on_emptying:
	ld a, (wagon_shirts)
	dec a
	jp m, .seek		; if sign, we already had 0 shirts
	ld (wagon_shirts), a
	ret nz
.seek:	; wagon empty. Moving to the next status
	ld a, STATUS_SEEKING
	ld (wagon_status), a
	ret

_on_seeking:
	push ix
	push de
	push bc
	; looks for any worker with the shirts box completed
	ld c, 0
	ld ix, workers
.loop:	ld a, (ix+WORKER_SHIRTS)
	cp MAX_WORKER_SHIRTS
	jp z, .found
	ld de, WORKER_LEN	; go to next worker, until all workers have been found
	add ix, de		
	ld a, c
	inc c
	cp NUM_WORKERS
	jp nz, .loop
	ld a, DOOR_X	; no worker found. Going to door
	ld (wagon_dest_x), a
	ld a, DOOR_Y
	ld (wagon_dest_y), a
	jp .return
.found: 	; if we are in the home door, we first move two rows below
	; we'll re-seek later
	ld a, (wagon_y)
	cp DOOR_Y
	jp nz, .go_wrkr	; seek the worker
	ld a, DOOR_Y+2	; move to an open space
	ld (wagon_dest_y), a
	ld a, DOOR_X
	ld (wagon_dest_x), a
	xor a		; dst worker ptr needs to be null
	ld (wagon_dest_worker_ptr), a
	jp .return
.go_wrkr:	ld (wagon_dest_worker_ptr), ix
	ld a, (ix+WORKER_X) ; worker position is in pixels, we convert to blocks
	sra a
	sra a
	sra a
	bit WORKER_FLAG_LEFTSIDE, (ix+WORKER_FLAGS)
	jp nz, .isright
	sub 4	 	; if left-side worker, decrease dest column
	jp .set_dst_x
.isright:	add 4		; if right-side worker, increase dest column
.set_dst_x:	ld (wagon_dest_x), a
	ld a, (ix+WORKER_Y) ; convert pixels to blocks
	sra a
	sra a
	sra a
	ld (wagon_dest_y), a
.return:	ld a, STATUS_MOVING
	ld (wagon_status), a	
	pop bc
	pop de
	pop ix
	ret

_on_moving: push hl ; if wagon reached destination, goes to the next state
	ld hl, (wagon_x) ; h: wagon_y, l: wagon_x (contiguous positions)
	ld a, (wagon_dest_x)
	cp l
	jp nz, .move_step
	ld a, (wagon_dest_y)
	cp h
	jp nz, .move_step
	cp DOOR_Y	; if destination is in door's row, status is emptying
	jp nz, .isopen
	ld a, STATUS_EMPTYING
	ld (wagon_status), a
	pop hl
	ret
.isopen:	; if we are in an open space (no destination worker), re-seek
	ld a, (wagon_dest_worker_ptr)
	cp 0
	jp nz, .iscollect
	ld a, STATUS_SEEKING
	ld (wagon_status), a
	pop hl
	ret
.iscollect:	ld a, STATUS_COLLECTING	; otherwise, status is collecting
	ld (wagon_status), a
	pop hl
	ret
.move_step:	; if we haven't reached the destination but we are in the same row,
	; we change our destination two rows down
	ld a, (wagon_dest_y)
	cp h
	jp nz, .mv_horiz
	ld a, (wagon_x)
	inc a
	inc a
	ld (wagon_dest_x), a
	ld a, (wagon_y)
	ld (wagon_dest_y), a
	pop hl
	ret	
.mv_horiz:	; first, move horizontal to align with the destination column
	ld a, (wagon_dest_x)
	ld l, a
	ld a, (wagon_x)
	cp l
	jp z, .mv_vert
	jp c, .mv_right
	dec a		; update position
	ld (wagon_x), a
	ld hl, [wagon_vram_addr] ; update vram and trail vram
	dec hl
	ld [wagon_vram_addr], hl
	inc hl
	inc hl
	ld [wagon_trl_vram_addr_1], hl
	push de
	ld de, 32
	add hl, de
	ld [wagon_trl_vram_addr_2], hl
	pop de
	pop hl
	ret
.mv_right:	inc a		; update position
	ld (wagon_x), a	
	ld hl, [wagon_vram_addr]	; update vram and trail vram
	ld [wagon_trl_vram_addr_1], hl
	inc hl
	ld [wagon_vram_addr], hl
	push de
	ld de, 31
	add hl, de
	ld [wagon_trl_vram_addr_2], hl
	pop de
	pop hl
	ret
.mv_vert:	; move up or down
	ld a, (wagon_dest_y)
	ld l, a
	ld a, (wagon_y)
	cp l
	jp c, .mv_down
	dec a			; update position
	ld (wagon_y), a
	ld hl, [wagon_vram_addr]	; update vram and trail
	push de
	ld de, -32
	add hl, de
	ld [wagon_vram_addr], hl
	ld de, 64
	add hl, de
	ld [wagon_trl_vram_addr_1], hl 
	inc hl
	ld [wagon_trl_vram_addr_2], hl
	pop de
	pop hl
	ret
.mv_down:	inc a			; update position
	ld (wagon_y), a
	ld hl, [wagon_vram_addr]	; update vram and trail
	ld [wagon_trl_vram_addr_1], hl
	inc hl
	ld [wagon_trl_vram_addr_2], hl
	push de
	ld de, 31
	add hl, de
	ld [wagon_vram_addr], hl
	pop hl
	ret

.updt_ret:	pop hl
	ret


_on_collecting:
	ret
_on_returning:
	ret

	ENDMODULE