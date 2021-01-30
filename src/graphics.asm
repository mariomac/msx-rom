    include "bios.inc"
    include "assets/sprites.asm"
    include "assets/map.asm"
    include "assets/tiles.asm"

init_graphics:
    ; set colors
    ld A, COL_WHITE
    ld (ADDR_FORCLR), A
    ld A, COL_BLACK
    ld (ADDR_BAKCLR), A
    ld (ADDR_BDRCLR), A
    call BIOS_CHGCLR

    ; set screen 2
    call BIOS_INIGRP
    ; inhibit screen display
    call BIOS_DISSCR

    ; load brick tiles definitions into vram (3 banks)
    ld hl, BANK_PATTERN_0
    ld de, SCR2_CHARPATTERN
    ld bc, 8*32*24
    call BIOS_LDIRVM
    ld hl, BANK_PATTERN_0
    ld de, SCR2_CHARPATTERN+32*8*8
    ld bc, 8*32*24
    call BIOS_LDIRVM
    ld hl, BANK_PATTERN_0
    ld de, SCR2_CHARPATTERN+32*16*8
    ld bc, 8*32*24
    call BIOS_LDIRVM

    ; brick colors
    ld hl, BANK_COLOR_0
    ld de, SCR2_PIXELCOLOR
    ld bc, 256*8
    call BIOS_LDIRVM
    ld hl, BANK_COLOR_0
    ld de, SCR2_PIXELCOLOR+256*8
    ld bc, 256*8
    call BIOS_LDIRVM
    ld hl, BANK_COLOR_0
    ld de, SCR2_PIXELCOLOR+512*8
    ld bc, 256*8
    call BIOS_LDIRVM

    ; load map
    ld hl, SCREEN_0_0
    ld de, SCR2_CHARPOS
    ld bc, 32*24
    call BIOS_LDIRVM

    ; set sprite mode
    ld b, 11100010b ; ver control register en bios.inc
    ld c, 1 ; registro 1 (es más eficiente hacer ld bc, ...)
    call BIOS_WRTVDP

    ; load sprite attributes
    ld hl, AMANCIO
    ld de, SCR2_SPRPATTERN
    ld bc, AMANCIO_END-AMANCIO
    call BIOS_LDIRVM

    call refresh_graphics

    ; re-enable screen display
    call BIOS_ENASCR
    ret 

refresh_graphics:
    ld hl, amancio_sprite_attrs
    ld de, SCR2_SPRATTRIB
    ld bc, amancio_sprite_attrs_end-amancio_sprite_attrs
    call BIOS_LDIRVM
    ret

