    include "bios.inc"
    include "assets/map.asm"
    include "assets/tiles.asm"

init_graphics:
    ; load brick tiles definitions into vram (3 banks)
    ld hl, BANK_PATTERN_0
    ld de, SCR2_CHARPATTERN
    ld bc, 8*32*24
    call BIOS_LDIRVM
    ld hl, BANK_PATTERN_1
    ld de, SCR2_CHARPATTERN+32*8*8
    ld bc, 8*32*24
    call BIOS_LDIRVM
    ld hl, BANK_PATTERN_2
    ld de, SCR2_CHARPATTERN+32*16*8
    ld bc, 8*32*24
    call BIOS_LDIRVM

    ; brick colors
    ld hl, BANK_COLOR_0
    ld de, SCR2_PIXELCOLOR
    ld bc, 256*8
    call BIOS_LDIRVM
    ld hl, BANK_COLOR_1
    ld de, SCR2_PIXELCOLOR+256*8
    ld bc, 256*8
    call BIOS_LDIRVM
    ld hl, BANK_COLOR_2
    ld de, SCR2_PIXELCOLOR+512*8
    ld bc, 256*8
    call BIOS_LDIRVM

    ; load map
    ld hl, SCREEN_0_0
    ld de, SCR2_CHARPOS
    ld bc, 32*24
    call BIOS_LDIRVM
    ret 
    

