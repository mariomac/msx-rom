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
VARS_LENGTH:	equ 6


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
	ld b, 0
	; dest pos: scr2_charpos + y * 32 + x
	ld hl, SCR2_CHARPOS
	ld a, (wagon_y)
	ld c, a
	sla c
	sla c
	sla c
	sla c
	sla c
	add hl, bc
	ld a, (wagon_x)
	ld c, a
	add hl, bc
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
	ld a, STATUS_MOVING
	ld (wagon_status), a
	jp .return
.found: 	ld (wagon_dest_worker_ptr), ix
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
	ld a, STATUS_MOVING
	ld (wagon_status), a	
.return:	pop bc
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
	jp nz, .iscollect
	ld a, STATUS_EMPTYING
	ld (wagon_status), a
	pop hl
	ret 
.iscollect:	ld a, STATUS_COLLECTING	; otherwise, status is collecting
	ld (wagon_status), a
	pop hl
	ret
.move_step:	push de	; just puts a tile in the destination. change by a proper step-by-step algorithm
	push hl
	push bc
	push ix
	ld ix, (wagon_dest_worker_ptr) ; messes worker just to test pointer
	ld a, 1 << WORKER_FLAG_LEFTSIDE
	ld (ix+WORKER_FLAGS), a
	ld hl, SCR2_CHARPOS
	ld a, (wagon_dest_y)
	ld b, 5	; multiplying "de" 16 bit register by 32 (2^5)
	ld d, 0
	ld e, a
.mul32:	sla d
	sla e
	jp nc, .mulcont
	set 0, d
.mulcont:	djnz .mul32	
	add hl, de
	ld a, (wagon_dest_x)
	ld d, 0
	ld e, a
	add hl, de
	ld a, 3
	call BIOS_WRTVRM
	pop ix
	pop bc	
	pop hl
	pop de
	ret

_on_collecting:
	ret
_on_returning:
	ret

	ENDMODULE