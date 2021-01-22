KEY_RIGHT:  equ  %10000000
KEY_DOWN:   equ  %01000000
KEY_UP:     equ  %00100000
KEY_LEFT:   equ  %00010000
KEY_SPACE:  equ  %00000001

CONTROLS_KEY_MATRIX: equ 8

; modifies a, c
; checks:
; summing 16 to the direction we are going
; summing 15 to the normal of the direction
; firs subtracting 1 when going left or up
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
    ; check collision in top-left and top-right corner
    ld bc, (amancio_sprite_attrs)
    dec c
    call is_tile_collision
    ret nz
    ld a, b
    add 15
    ld b, a
    call is_tile_collision
    ret nz
    ; no collision, we can move
    ld bc, (amancio_sprite_attrs)
    dec c
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs+4), bc
    ret
_check_down:
    ld a, c
    and KEY_DOWN
    jr nz, _check_left
    ; check collision in bottom-left and bottom-right corner
    ld bc, (amancio_sprite_attrs)
    ld a, c
    add 17
    ld c, a
    call is_tile_collision
    ret nz
    ld a, b
    add 15
    ld b, a
    call is_tile_collision
    ret nz
    ; no collision, we can move
    ld bc, (amancio_sprite_attrs)
    inc c
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs+4), bc
    ret
_check_left:
    ld a, c
    and KEY_LEFT
    jr nz, _check_right
    ; check collision in top-left and bottom-left corner
    ld bc, (amancio_sprite_attrs)
    dec b
    call is_tile_collision
    ret nz
    ld a, c
    add 15
    ld c, a
    call is_tile_collision
    ret nz
    ; no collision, we can move
    ld bc, (amancio_sprite_attrs)
    dec b
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs+4), bc
    ret
_check_right:
    ld a, c
    and KEY_RIGHT
    ret nz
    ; check collision in top-right and bottom-right corner
    ld bc, (amancio_sprite_attrs)
    ld a, b
    add 16
    ld b, a
    call is_tile_collision
    ret nz
    ld a, c
    add 15
    ld c, a
    call is_tile_collision
    ret nz
    ; no collision, we can move
    ld bc, (amancio_sprite_attrs)
    inc b
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs+4), bc
    ret



; input: bc, cols, rows coordinates
; output: nz flag is there is collision
is_tile_collision:
    push hl
    push bc
    ; divide cols/rows (pixels) to coordinates
    srl b
    srl b
    srl b
    srl c
    srl c
    srl c
    ; calculate pointer to coordinates: screen+c*32+b
    ld h, c
    srl h
    srl h
    srl h
    ld l, c
    sla l
    sla l
    sla l
    sla l
    sla l
    ld c, b
    ld b, 0
    add hl, bc
    ld bc, SCREEN_0_0
    add hl, bc
    ld a, (hl)
    cp 0
    pop bc
    pop hl
    ret

