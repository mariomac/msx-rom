    include "rom/header.asm"
    include "bios.inc"
    include "graphics.asm"

    include "vars.asm"

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

    call init_graphics

loop:
    halt
    jp loop

BRIKAZOS: DB 0, 1, 2, 3, 4, 5, 6, 7
    include "rom/tail.asm"


