	MODULE wagon

; draw constants
TILES_TOP: equ 22
TILES_WHEELS: equ 30
TILES_WIDTH: equ 2
FILL_LEVELS: equ 4

; status constants
STATUS_EMPTYING:	equ 0
STATUS_SEEKING:	equ 1
STATUS_GOING:	equ 2
STATUS_COLLECTING:	equ 3
STATUS_RETURNING:	equ 4

MAX_SHIRTS: 	equ 128

; same order as vars.asm definition 
INITIAL_VARS: db STATUS_EMPTYING, MAX_SHIRTS, 15, 3, 0, 0
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
	jp nz, .going
	call _on_seeking
	ret
.going:	cp STATUS_GOING
	jp nz, .collecting
	call _on_going
	ret
.collecting: cp STATUS_COLLECTING
	jp nz, .returning
	call _on_collecting
	ret
.returning:	cp STATUS_SEEKING
	ret nz		; if status is inconsistent, wagon will block
	call _on_seeking
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
	cp 0
	ret z ; todo move to next status
	ld (wagon_shirts), a
	ret
_on_seeking:
	ret
_on_going:
	ret
_on_collecting:
	ret
_on_returning:
	ret

	ENDMODULE