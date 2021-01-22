KEY_RIGHT:  equ  %10000000
KEY_DOWN:   equ  %01000000
KEY_UP:     equ  %00100000
KEY_LEFT:   equ  %00010000
KEY_SPACE:  equ  %00000001

CONTROLS_KEY_MATRIX: equ 8

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
    call _try_moving_up
    ret
_check_down:
    ld a, c
    and KEY_DOWN
    jr nz, _check_left
    call _try_moving_down
    ret
_check_left:
    ld a, c
    and KEY_LEFT
    jr nz, _check_right
    ret
_check_right:
    ld a, c
    and KEY_RIGHT
    ret nz
    
    ret

; input
;   b: column (in pixels)
;   c: row    (in pixels)
; modifies: a, bc, de, hl
_try_moving_up:
    ld bc, (amancio_sprite_attrs)
    dec c
    ; each 8 points, we update the colision pointer
    and 7
    ret nz
    ld de, (amancio_collision_ptr)
    push de
    ld hl, -32
    add hl, de
    ld (amancio_collision_ptr), hl
    call _check_tile_map
    pop de
    bit _COLLID_TOP_LEFT, l
    jp z, __undo_up
    bit _COLLID_TOP_RIGHT, l
    jp z, __undo_up
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs + 4), bc
    ret
__undo_up:
    ld (amancio_collision_ptr), de
    ret

_try_moving_down:
    ld bc, (amancio_sprite_attrs)
    inc c
    ; each 8 points, we update the colision pointer
    and 7
    ret nz
    ld de, (amancio_collision_ptr)
    push de
    ld hl, 32
    add hl, de
    ld (amancio_collision_ptr), hl
    call _check_tile_map
    pop de
    bit _COLLID_BOTTOM_LEFT, l
    jp z, __undo_down
    bit _COLLID_BOTTOM_RIGHT, l
    jp z, __undo_down
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs + 4), bc
    ret
__undo_down:
    ld (amancio_collision_ptr), de
    ret

; checks which corners are touching a non-empty tile
; modifies L bits MSB -- LSB 
;          de, a
_COLLID_TOP_LEFT: equ 0
_COLLID_TOP_RIGHT: equ 1
_COLLID_BOTTOM_LEFT: equ 2
_COLLID_BOTTOM_RIGHT: equ 3
_check_tile_map:
    ld l, 0
    ld de, (amancio_collision_ptr) ; check top-left
    ld a, (de)
    cp 0  ; verificar si se puede quitar
    jp z, __ctr
    set _COLLID_TOP_LEFT, l
__ctr:    
    inc de              ; check top-right
    ld a, (de)
    cp 0  ; verificar si se puede quitar
    jp z, __cbr
    set _COLLID_TOP_RIGHT, l
__cbr:    
    add e, 32           ; check bottom-right
    adc d, 0
    ld a, (de)
    cp 0  ; verificar si se puede quitar
    jp z, __cbl
    set _COLLID_BOTTOM_RIGHT, l
__cbl:
    dec de              ; check bottom-left
    ld a, (de)
    cp 0  ; verificar si se puede quitar
    ret z
    set _COLLID_BOTTOM_LEFT, l
    ret
