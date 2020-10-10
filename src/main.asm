    include "rom/header.asm"
    include "bios.inc"
    include "graphics.asm"

    include "vars.asm"

main:
    ; initialize variables
    call build_bricks

    ; set colors
    ld A, COL_WHITE
    ld (ADDR_FORCLR), A
    ld A, COL_TRANSPARENT
    ld (ADDR_BAKCLR), A
    ld (ADDR_BDRCLR), A
    call BIOS_CHGCLR

    ; set screen 2
    call BIOS_INIGRP

    ; load brick tiles definitions into vram.
    ld hl, brick_tiles
    ld de, SCR2_CHARPATTERN
    ld bc, 8*8 ; 8 lines x 8 frames
    call BIOS_LDIRVM

    ; brick colors
    ld hl, BRICK_COLORS
    ld de, SCR2_PIXELCOLOR
    ld bc, 8*8
    call BIOS_LDIRVM    

    xor a
    // fills screen with characters
loop:
    halt
    halt
    halt
    halt
    ld hl, SCR2_CHARPOS
    ld bc, 32*24
    push af
    call BIOS_FILVRM
    pop af
    inc a
    and 0b111
    jp loop

BRIKAZOS: DB 0, 1, 2, 3, 4, 5, 6, 7
    include "rom/tail.asm"


