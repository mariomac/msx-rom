    include "rom/header.asm"
    include "msx.inc"

main:
    call BIOS_BEEP
    jp main

    include "rom/tail.asm"
