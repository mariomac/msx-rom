    include "rom/header.asm"
    include "bios.inc"
    include "graphics.asm"

    include "vars.asm"

main:
    ; set colors
    ld A, COL_WHITE
    ld (ADDR_FORCLR), A
    ld A, COL_BLACK
    ld (ADDR_BAKCLR), A
    ld (ADDR_BDRCLR), A
    call BIOS_CHGCLR

    ; set screen 2

    call BIOS_INIGRP
    call init_graphics

loop:
    ;halt
    jp loop

    include "rom/tail.asm"


