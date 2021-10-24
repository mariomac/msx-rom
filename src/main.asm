    include "rom/header.asm"
    include "bios.inc"
    include "vars.asm"
    include "psg.asm"
    
    

;----- program start -----
main:
        ; set channel A as tone and B as noise
	channelSet 0b111110
        
        volA 0xF
        ;envelope        0x2FF, 0b1101
        ;envelopeA

        ld hl, 0xFFF

loop:   noteA h, l
        halt
        dec hl
        jp loop

stuff:  jp stuff

    include "rom/tail.asm"
