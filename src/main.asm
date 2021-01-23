    include "rom/header.asm"
    include "bios.inc"
    include "graphics.asm"
    include "amancio.asm"
    include "worker.asm"
    include "vars.asm"

main:
    xor a
    ld (ADDR_CLIKSW), a ; disable keyboard click
    call init_vars
    call init_graphics

loop:
    halt
    call refresh_graphics    
    call move_amancio
    call update_workers
    jp loop

    include "rom/tail.asm"
