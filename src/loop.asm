KEY_RIGHT:  equ  %10000000
KEY_DOWN:   equ  %01000000
KEY_UP:     equ  %00100000
KEY_LEFT:   equ  %00010000
KEY_SPACE:  equ  %00000001

CONTROLS_KEY_MATRIX: equ 8

MARGIN_TOP:     equ 5*8-2
MARGIN_BOTTOM:  equ 192-8
MARGIN_LEFT:    equ 8
MARGIN_RIGHT:   equ 256-8

; modifies a, c
move_amancio:
    ld a, CONTROLS_KEY_MATRIX
    call BIOS_SNSMAT
    ld c, a
    ; check space
    and KEY_SPACE
    jr nz, _check_up
    ; TODO: space action
    ret
_check_up:
    ld a, c
    and KEY_UP
    jr nz, _check_down
    ld bc, (amancio_sprite_attrs)
    dec c
    call check_collision_top
    ret z
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs + 4), bc
    ret
_check_down:
    ld a, c
    and KEY_DOWN
    jr nz, _check_left
    ld bc, (amancio_sprite_attrs)
    inc c
    call check_collision_bottom
    ret z
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs + 4), bc
    ret
_check_left:
    ld a, c
    and KEY_LEFT
    jr nz, _check_right
    ld bc, (amancio_sprite_attrs)
    dec b
    call check_collision_left
    ret z
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs + 4), bc
    ret
_check_right:
    ld a, c
    and KEY_RIGHT
    ret nz
    ld bc, (amancio_sprite_attrs)
    inc b
    call check_collision_right
    ret z
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs + 4), bc
    ret

; input
;   b: column (in pixels)
;   c: row    (in pixels)
; return
;   zero flag set if collision
; modifies: a
check_collision_top:
    ; checks margins
    ld a, c
    cp MARGIN_TOP
    ret z
    ; TODO: check tiles map
    ret
check_collision_bottom:
    ld a, c
    add a, 16
    cp MARGIN_BOTTOM
    ret z
    ; TODO: check tiles map
    ret
check_collision_left:
    ld a, b
    cp MARGIN_LEFT
    ret z
    ; TODO: check tiles map
    ret
check_collision_right:
    ld a, b
    add a, 16
    cp MARGIN_RIGHT
    ret z
    ; TODO: check tiles map
    ret




