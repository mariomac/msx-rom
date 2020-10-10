BRICK:
    DG ###_####
    DG ###_####
    DG ###_####
    DG ________
    DG #######_
    DG #######_
    DG #######_
    DG ________

BRICK_COLORS:
    DB 0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0
    DB 0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0
    DB 0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0
    DB 0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0
    DB 0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0
    DB 0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0
    DB 0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0
    DB 0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,0xf0

// from the above brick, builds the brick animations
build_bricks:
    ; first, copies the original brick
    ld bc, 8
    ld hl, BRICK
    ld de, brick_tiles
    ldir   ; ld (hl), (de) ; incs hl & de, and dec bc until bc = 0
    
    ; now, let's build the brick rotating frames
    ld b, 8
    ld ix, BRICK         ; ix source, iy dest
    ld iy, brick_tiles+8
_next_brick_frame:
    djnz _build_brick_frame
    ret
_build_brick_frame:
    push bc
    ld b, 8
_build_brick_line:    
    ld a, (ix) ; loads a brick line and rotates it
    rlca
    ld (iy), a
    inc ix
    inc iy
    djnz _build_brick_line
    ; for the next brick animation, we set the source
    ; as the last written brick (current iy - 8)
    push iy
    pop  ix
    dec ix
    dec ix
    dec ix
    dec ix
    dec ix
    dec ix
    dec ix
    dec ix

    pop bc
    jp _next_brick_frame   

    

