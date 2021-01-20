    include "bios.inc"
    include "assets/sprites.asm"
    include "assets/map.asm"
    include "assets/tiles.asm"

init_graphics:
    ; inhibit screen display
    ;call BIOS_DISSCR
/*
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


    ; set sprite size (read control port 1, modify it, and write back)
    di
    ld	a,(ADDR_VDPDR)	; read port 1
    inc a
    ld c, a
    in a, (c)
    or 10b ; set sprites to 16x16

    out (VDPSTATUS), a
    ld a, 1+128 ; port 1 to choose
    out (VDPSTATUS), a
    ei
*/
    ; lo anterior, mejormente es
    ld b, 11100010b ; ver control register en bios.inc
    ld c, 1 ; registro 1 (es más eficiente hacer ld bc, ...)
    call BIOS_WRTVDP

    ; load sprite attributes (TODO: move to a refresh function)
    ld hl, AMANCIO
    ld de, SCR2_SPRPATTERN
    ld bc, 32
    call BIOS_LDIRVM
    ld hl, amancio_sprite_attrs
    ld de, SCR2_SPRATTRIB
    ld bc, 4
    call BIOS_LDIRVM

    ; re-enable screen display
    ;call BIOS_ENASCR
    ret 
    

