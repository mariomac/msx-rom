    include "rom/header.asm"
    include "bios.inc"
    include "vars.asm"
    include "psg.asm"
    
    

;----- program start -----
main:
        ; set channel A as tone and B as noise
	channelSet 0b101110
        
        VolA 0xF
        VolB 0xE

        LD      A,0             ;Set Fine Tune Channel A
        LD      E,0FEH          ;Data 0FEH
        CALL    BIOS_WRTPSG

        LD      A,1             ;Set Coarse Tune Channel A
        LD      E,0             ;Data 0H
        CALL    BIOS_WRTPSG

        ld a, 6
        ld e, 0xff
        CALL    BIOS_WRTPSG

stuff:  jp stuff

    include "rom/tail.asm"
