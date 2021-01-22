    include "rom/header.asm"
    include "bios.inc"
    include "graphics.asm"
    include "loop.asm"
    include "vars.asm"

main:
    ld a, 0
    ld (ADDR_CLIKSW), a
    call init_vars
    call init_graphics

loop:
    halt
    call refresh_graphics    
    call move_amancio
    jp loop

    include "rom/tail.asm"
