    include "rom/header.asm"
    include "bios.inc"
    include "graphics.asm"

TILES equ 6

main:
    ; set colors
    ld A, COL_WHITE
    ld (ADDR_FORCLR), A
    ld A, COL_TRANSPARENT
    ld (ADDR_BAKCLR), A
    ld (ADDR_BDRCLR), A
    call BIOS_CHGCLR

    ; set screen 2
    call BIOS_INIGRP

    call build_map

    ; load data into vram. Triplicating tiles and color definitions
    ; for screen 2
    ld hl, BRICKS
    ld de, SCR2_CHARPATTERN
    ld bc, 8*TILES
    call BIOS_LDIRVM
    ld hl, BRICKS
    ld de, SCR2_CHARPATTERN + 8*32*8
    ld bc, 8*TILES
    call BIOS_LDIRVM
    ld hl, BRICKS
    ld de, SCR2_CHARPATTERN + 16*32*8
    ld bc, 8*TILES
    call BIOS_LDIRVM    

    ld hl, BRICK_COLORS
    ld de, SCR2_PIXELCOLOR
    ld bc, 8*TILES
    call BIOS_LDIRVM    
    ld hl, BRICK_COLORS
    ld de, SCR2_PIXELCOLOR + 8*32*8
    ld bc, 8*TILES
    call BIOS_LDIRVM    
    ld hl, BRICK_COLORS
    ld de, SCR2_PIXELCOLOR + 16*32*8
    ld bc, 8*TILES
    call BIOS_LDIRVM    

    ld hl, SCREEN_MAP
    ld de, SCR2_CHARPOS
    ld bc, 32*24
    call BIOS_LDIRVM

loop:
    jp loop

    include "rom/tail.asm"
