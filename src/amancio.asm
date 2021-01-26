KEY_RIGHT:  equ  %10000000
KEY_DOWN:   equ  %01000000
KEY_UP:     equ  %00100000
KEY_LEFT:   equ  %00010000
KEY_SPACE:  equ  %00000001

CONTROLS_KEY_MATRIX: equ 8

; timing masks for amancio_frame_timing variable
AMANCIO_FRAME_TIMING_MASK: equ %111          ; walking frame
AMANCIO_WHIP_PREPARE_TIME_MASK: equ %11
AMANCIO_WHIP_TIME_MASK:  equ %1111
WHIP_COLOR: equ 6
WHIP_COLLIDES_FRAME: equ 1
WHIP_COLLIDES_TIME: equ 1

WHIP_ANIMATION_RIGHT:
    ; frame 0
    db -16, 0
    db AMANCIO_WHIP_RIGHT_PATTERN_BODY_1
    db AMANCIO_WHIP_RIGHT_PATTERN_WHIP_1
    db AMANCIO_WHIP_PREPARE_TIME_MASK
    ; frame 1
    db 16, 0
    db AMANCIO_WHIP_RIGHT_PATTERN_BODY_2
    db AMANCIO_WHIP_RIGHT_PATTERN_WHIP_2
    db AMANCIO_WHIP_TIME_MASK
WHIP_ANIMATION_LEFT:
    ; frame 0
    db 16, 0
    db AMANCIO_WHIP_LEFT_PATTERN_BODY_1
    db AMANCIO_WHIP_LEFT_PATTERN_WHIP_1
    db AMANCIO_WHIP_PREPARE_TIME_MASK
    ; frame 1
    db -16, 0
    db AMANCIO_WHIP_LEFT_PATTERN_BODY_2
    db AMANCIO_WHIP_LEFT_PATTERN_WHIP_2
    db AMANCIO_WHIP_TIME_MASK
WHIP_ANIMATION_DOWN:
    ; frame 0
    db 0, -16
    db AMANCIO_WHIP_DOWN_PATTERN_BODY_1
    db AMANCIO_WHIP_DOWN_PATTERN_WHIP_1
    db AMANCIO_WHIP_PREPARE_TIME_MASK
    ; frame 1
    db 0, 16
    db AMANCIO_WHIP_DOWN_PATTERN_BODY_2
    db AMANCIO_WHIP_DOWN_PATTERN_WHIP_2
    db AMANCIO_WHIP_TIME_MASK
WHIP_ANIMATION_UP:
    ; frame 0
    db 16, 8
    db AMANCIO_WHIP_UP_PATTERN_BODY_1
    db AMANCIO_WHIP_UP_PATTERN_WHIP_1
    db AMANCIO_WHIP_PREPARE_TIME_MASK
    ; frame 1
    db 0, -16
    db AMANCIO_WHIP_UP_PATTERN_BODY_2
    db AMANCIO_WHIP_UP_PATTERN_WHIP_2
    db AMANCIO_WHIP_TIME_MASK


; above structs fields (as offsets)
WHIP_OFFSET_X:  equ 0
WHIP_OFFSET_Y:  equ 1
BODY_PATTERN: equ 2
WHIP_PATTERN: equ 3
FRAME_TIMING: equ 4
ANIM_STRUCT_LENGTH: equ 5

update_amancio_status:
    ld a, (amancio_status)
    bit AMANCIO_STATUS_WHIP_BIT, a ; if whip is inactive, move amancio normally
    jp nz, __whip_active
    call move_amancio
    ret
__whip_active:
    ; if whip is active, check whip collision in time 0 of frame 1
    call verify_whip_collision
    push ix
    ld a, (amancio_direction)
__case_whip_down:    
            cp AMANCIO_STATUS_DIR_DOWN
            jp nz, __case_whip_right
            ld ix, WHIP_ANIMATION_DOWN
            call animate_amancio_whip
            jp _update_amancio_status_end
__case_whip_right:
            cp AMANCIO_STATUS_DIR_RIGHT
            jp nz, __case_whip_left
            ld ix, WHIP_ANIMATION_RIGHT
            call animate_amancio_whip
            jp _update_amancio_status_end
__case_whip_left:
            cp AMANCIO_STATUS_DIR_LEFT
            jp nz, __default
            ld ix, WHIP_ANIMATION_LEFT
            call animate_amancio_whip
            jp _update_amancio_status_end
__default:
            ld ix, WHIP_ANIMATION_UP
            call animate_amancio_whip
_update_amancio_status_end:
    pop ix
    ret


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
    ld a, (amancio_status)            ; set animation to whip, and reset frame
    set AMANCIO_STATUS_WHIP_BIT, a
    ld (amancio_status), a
    xor a
    ld (amancio_frame_num), a
    ld (amancio_frame_timing), a
    ret
_check_up:
    ld a, c
    and KEY_UP
    jr nz, _check_down
    call _try_up
    ld c, AMANCIO_UP_PATTERN
    call animate_amancio    
    ld a, AMANCIO_STATUS_DIR_UP                ; set amancio direction
    ld (amancio_direction), a
    ret
_check_down:
    ld a, c
    and KEY_DOWN
    jr nz, _check_left
    call _try_down
    ld c, AMANCIO_DOWN_PATTERN
    call animate_amancio
    ld a, AMANCIO_STATUS_DIR_DOWN              ; set amancio direction
    ld (amancio_direction), a
    ret
_check_left:
    ld a, c
    and KEY_LEFT
    jr nz, _check_right
    call _try_left
    ld c, AMANCIO_LEFT_PATTERN
    call animate_amancio
    ld a, AMANCIO_STATUS_DIR_LEFT              ; set amancio direction
    ld (amancio_direction), a
    ret
_check_right:
    ld a, c
    and KEY_RIGHT
    ret nz
    call _try_right
    ld c, AMANCIO_RIGHT_PATTERN
    call animate_amancio
    ld a, AMANCIO_STATUS_DIR_RIGHT              ; set amancio direction
    ld (amancio_direction), a
    ret

; input c: amancio direction base frame
animate_amancio:
    ld a, (amancio_frame_timing)                    ; check timing for updating animation
    inc a
    ld (amancio_frame_timing), a
    and AMANCIO_FRAME_TIMING_MASK
    ret nz
    ld a, (amancio_frame_num)                       ; update offset frame
    add AMANCIO_FRAME_PATTERNS
    and AMANCIO_FRAMES*AMANCIO_FRAME_PATTERNS-1 
    ld (amancio_frame_num), a
    add c                                           ; add offset to base and write attrs
    ld (amancio_sprite_attrs + 2), a
    add 4
    and AMANCIO_FRAMES*AMANCIO_FRAME_PATTERNS-1 
    add c
    ld (amancio_sprite_attrs + 6), a
    ret

; input ix, frames structs array start (e.g. WHIP_ANIMATION_RIGHT)
animate_amancio_whip:
    push bc
    ; update ix to the current frame (only 2 possibilities)
    ld a, (amancio_frame_num)
    cp 0
    jp z, __update_animation_whip
    ld bc, ANIM_STRUCT_LENGTH
    add ix, bc    ; TODO: probar add ixl, ANIM_STRUCT_LENGTH; adc ixh, 0 y ver si nos podemos ahorrar el push bx
__update_animation_whip:
    ; update animation (if reached last time of frame 1, whip status is over)
    ld a, (amancio_frame_timing)
    inc a
    and (ix+FRAME_TIMING)
    ld (amancio_frame_timing), a
    cp 0                                        ; TODO: creo que es redundante, quitar
    jp nz, __draw_sprites
    ; increment frame
    ld a, (amancio_frame_num)
    inc a
    and 1 ; if frame turns back to 0, animation is over
    ld (amancio_frame_num), a
    cp 0                                        ; TODO: creo que es redundante, quitar
    jp nz, __draw_sprites
    ld a, (amancio_status)              ; animation is over. Come back to standing
    res AMANCIO_STATUS_WHIP_BIT, a
    ld (amancio_status), a
    call reset_stand_position
    jp __animate_amancio_whip_return
__draw_sprites:
    ; body sprites
    ld a, (ix+BODY_PATTERN)
    ld (amancio_sprite_attrs+2), a
    add 4   ; 4 patters to the next sprite
    ld (amancio_sprite_attrs+6), a
    ; whip sprites
    ld a, (amancio_sprite_attrs)
    add (ix+WHIP_OFFSET_Y)
    ld (amancio_sprite_attrs+8), a
    ld a, (amancio_sprite_attrs+1)
    add (ix+WHIP_OFFSET_X)
    ld (amancio_sprite_attrs+9), a
    ld a, (ix+WHIP_PATTERN)
    ld (amancio_sprite_attrs+10), a
    ld a, WHIP_COLOR
    ld (amancio_sprite_attrs+11), a
__animate_amancio_whip_return:
    pop bc
    ret


reset_stand_position:
    ld a, (amancio_direction)
    cp AMANCIO_STATUS_DIR_RIGHT
    jp nz, __reset_check_left
    ld a, AMANCIO_RIGHT_PATTERN
    jp __reset_sprites
__reset_check_left:
    cp AMANCIO_STATUS_DIR_LEFT
    jp nz, __reset_check_up
    ld a, AMANCIO_LEFT_PATTERN
    jp __reset_sprites
__reset_check_up:
    cp AMANCIO_STATUS_DIR_UP
    jp nz, __reset_check_down
    ld a, AMANCIO_UP_PATTERN
    jp __reset_sprites
__reset_check_down: ; default case   
    ld a, AMANCIO_DOWN_PATTERN
__reset_sprites:
    ; update body sprites
    ld (amancio_sprite_attrs+2), a
    add 4   ; clothes are always 4 patterns after the skin
    ld (amancio_sprite_attrs+6), a
    ; remove whip
    xor a
    ld (amancio_sprite_attrs+8), a
    ld (amancio_sprite_attrs+9), a
    ld (amancio_sprite_attrs+11), a
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


_try_up:
    res 0, e ; set to 1 if topleft corner collides
    ; check collision in top-left and top-right corner
    ld bc, (amancio_sprite_attrs)
    call is_tile_collision
    jp nz, __try_up_top_right
    set 0, e
__try_up_top_right:
    ld a, b
    add 15
    ld b, a
    call is_tile_collision
    jp nz, __try_up_topleft_point
    bit 0, e
    jp nz, __try_up_free_move ; topleft and topright are free
    call _try_right           ; topright free, topleft collides
    ret
__try_up_topleft_point:
    bit 0, e
    ret z                ; topleft ant topright collide, don't move
    call _try_left     ; topleft free, topright collides
    ret
__try_up_free_move:    
    ; no collision, we can move
    ld bc, (amancio_sprite_attrs)
    dec c
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs+4), bc
    ret

_try_down:
    res 0, e 
    ; check collision in bottom-left and bottom-right corner
    ld bc, (amancio_sprite_attrs)
    ld a, c
    add 17
    ld c, a
    call is_tile_collision
    jp nz, __try_down_bottom_right
    set 0, e
__try_down_bottom_right:
    ld a, b
    add 15
    ld b, a
    call is_tile_collision
    jp nz, __try_down_bottomleft_point
    bit 0, e
    jp nz, __try_down_free_move ; topleft and topright are free
    call _try_right           ; topright free, topleft collides
    ret
__try_down_bottomleft_point:
    bit 0, e
    ret z                ; topleft ant topright collide, don't move
    call _try_left     ; topleft free, topright collides
    ret
__try_down_free_move:    
    ; no collision, we can move
    ld bc, (amancio_sprite_attrs)
    inc c
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs+4), bc
    ret

_try_left:
    res 0, e 
    ; check collision in top-left and bottom-left corner
    ld bc, (amancio_sprite_attrs)
    call is_tile_collision
    jp nz, __try_left_bottom_left
    set 0, e
__try_left_bottom_left:
    ld a, c
    add 15
    ld c, a
    call is_tile_collision
    jp nz, __try_left_topleft_point
    bit 0, e
    jp nz, __try_left_free_move 
    call _try_down           
    ret
__try_left_topleft_point:
    bit 0, e
    ret z                
    call _try_up     
    ret
__try_left_free_move:    
    ; no collision, we can move
    ld bc, (amancio_sprite_attrs)
    dec b
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs+4), bc
    ret


_try_right:
    res 0, e 
    ; check collision in top-right and bottom-right corner
    ld bc, (amancio_sprite_attrs)
    ld a, b
    add 16
    ld b, a
    call is_tile_collision
    jp nz, __try_right_bottom_right
    set 0, e
__try_right_bottom_right:
    ld a, c
    add 15
    ld c, a
    call is_tile_collision
    jp nz, __try_right_topright_point
    bit 0, e
    jp nz, __try_right_free_move 
    call _try_down           
    ret
__try_right_topright_point:
    bit 0, e
    ret z                
    call _try_up     
    ret
__try_right_free_move:    
    ; no collision, we can move
    ld bc, (amancio_sprite_attrs)
    inc b
    ld (amancio_sprite_attrs), bc
    ld (amancio_sprite_attrs+4), bc
    ret

verify_whip_collision:
    ; we only verify whip collision in a given time of a given frame
    ld a,(amancio_frame_timing)
    cp WHIP_COLLIDES_TIME
    ret nz
    ld a, (amancio_frame_num)
    cp WHIP_COLLIDES_FRAME
    ret nz
    push de
    ; if not, we just entered the first time of frame 1 (whip extended): check collision
    
    ld d, 6*8  ; pointing to first worker. TODO: put whip point coords
    ld e, 9*8
    call check_whip  ; if frame 1 started, check whip at this point
    ld d, 13*8  ; pointing to first worker. TODO: put whip point coords
    ld e, 9*8
    call check_whip  ; if frame 1 started, check whip at this point
    ld d, 20*8  ; pointing to first worker. TODO: put whip point coords
    ld e, 9*8
    call check_whip  ; if frame 1 started, check whip at this point
    ld d, 27*8  ; pointing to first worker. TODO: put whip point coords
    ld e, 9*8
    call check_whip  ; if frame 1 started, check whip at this point
    ld d, 6*8  ; pointing to first worker. TODO: put whip point coords
    ld e, 19*8
    call check_whip  ; if frame 1 started, check whip at this point
    ld d, 13*8  ; pointing to first worker. TODO: put whip point coords
    ld e, 19*8
    call check_whip  ; if frame 1 started, check whip at this point
    ld d, 20*8  ; pointing to first worker. TODO: put whip point coords
    ld e, 19*8
    call check_whip  ; if frame 1 started, check whip at this point
    ld d, 27*8  ; pointing to first worker. TODO: put whip point coords
    ld e, 19*8
    call check_whip  ; if frame 1 started, check whip at this point
    
    ld d, 5*8  ; pointing to first worker. TODO: put whip point coords
    ld e, 14*8
    call check_whip  ; if frame 1 started, check whip at this point
    
    ld d, 12*8  ; pointing to first worker. TODO: put whip point coords
    ld e, 14*8
    call check_whip  ; if frame 1 started, check whip at this point
    ld d, 19*8  ; pointing to first worker. TODO: put whip point coords
    ld e, 14*8
    call check_whip  ; if frame 1 started, check whip at this point
    ld d, 26*8  ; pointing to first worker. TODO: put whip point coords
    ld e, 19*8  ; should not collide
    call check_whip  ; if frame 1 started, check whip at this point    
    
    pop de
    ret