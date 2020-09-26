    include "rom/header.asm"
    

main:
    call $c0
    jp main

    include "rom/tail.asm"
