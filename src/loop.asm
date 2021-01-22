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
    call _try_moving_up
    ret z
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs + 4), bc
    ret
_check_down:
    ld a, c
    and KEY_DOWN
    jr nz, _check_left
    ld bc, (amancio_sprite_attrs)
    call _try_moving_down
    ret z
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs + 4), bc
    ret
_check_left:
    ld a, c
    and KEY_LEFT
    jr nz, _check_right
    ld bc, (amancio_sprite_attrs)
    call _try_moving_left
    ret z
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs + 4), bc
    ret
_check_right:
    ld a, c
    and KEY_RIGHT
    ret nz
    ld bc, (amancio_sprite_attrs)
    call _try_moving_right
    ret z
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs + 4), bc
    ret

; input
;   b: column (in pixels)
;   c: row    (in pixels)
; modifies: a, bc, de, hl
_try_moving_up:
    ; checks margins
    dec c
    ld a, c    
    cp MARGIN_TOP
    ret z
    ; each 8 points, we update the colision pointer
    and 7 
    jp nz, __continue_up
    ld de, (amancio_collision_ptr)
    ld hl, -32
    add hl, de
    ld (amancio_collision_ptr), hl
__continue_up:    
    ; TODO: check tiles map
    ; check tiles map
    call _check_tile_map
    jp _invert_zflag_ret
_try_moving_down:
    inc c
    ld a, c
    add a, 16
    cp MARGIN_BOTTOM
    ret z
    ; each 8 points, we update the colision pointer
    and 7 
    jp nz, __continue_down
    ld de, (amancio_collision_ptr)
    ld hl, 32
    add hl, de
    ld (amancio_collision_ptr), hl
__continue_down:    
    ; check tiles map
    call _check_tile_map
    jp _invert_zflag_ret
    
_try_moving_left:
    dec b
    ld a, b
    cp MARGIN_LEFT
    ret z
    ; each 8 points, we update the colision pointer
    and 7 
    jp nz, __continue_left
    ld de, (amancio_collision_ptr)
    dec de
    ld (amancio_collision_ptr), de
__continue_left:    
    ; check tiles map
    call _check_tile_map
    jp _invert_zflag_ret

_try_moving_right:
    inc b
    ld a, b
    add a, 16
    cp MARGIN_RIGHT
    ret z
    ; each 8 points, we update the colision pointer
    and 7 
    jp nz, __continue_right
    ld de, (amancio_collision_ptr)
    inc de
    ld (amancio_collision_ptr), de
__continue_right:        
    ; check tiles map
    call _check_tile_map
    jp _invert_zflag_ret

_invert_zflag_ret:
    ret
    jp z, __invert_zflag_ret_nz
    cp a ; set cf=0
    ret
__invert_zflag_ret_nz:
    ld a, 1 ; set cf=1 TODO: hay una mejor formula de hacerlo, seguro
    cp 0
    ret

_check_tile_map:
    ld de, (amancio_collision_ptr) ; check top-left
    ld a, (de)
    cp 0  ; verificar si se puede quitar
    ret ; quita esto
    ret nz
    inc de              ; check top-right
    ld a, (de)
    cp 0  ; verificar si se puede quitar
    ret nz
    add e, 32           ; check bottom-right
    adc d, 0
    ld a, (de)
    cp 0  ; verificar si se puede quitar
    ret nz
    dec de              ; check bottom-left
    ld a, (de)
    cp 0  ; verificar si se puede quitar
    ret

