    include "rom/header.asm"
    include "bios.inc"
    include "math.asm"
    include "graphics.asm"
    include "amancio.asm"
    include "worker.asm"
    include "wagon.asm"
    include "vars.asm"

main:
    xor a
    ld (ADDR_CLIKSW), a ; disable keyboard click
    call init_vars
    call init_graphics

.loop:
    halt
    call refresh_graphics    
    call update_amancio_status
    call update_workers
    call wagon.Update

    jp .loop

    include "rom/tail.asm"
