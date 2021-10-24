REG0_A_NOTE_L: EQU 0
REG1_A_NOTE_H: EQU 1
REG2_B_NOTE_L: EQU 2
REG3_B_NOTE_H: EQU 3
REG4_C_NOTE_L: EQU 4
REG5_C_NOTE_H: EQU 5
REG6_NOISE_FREQ: EQU 6
REG7_CHANNEL_SET:   EQU 7
REG8_A_VOLUME: EQU 8
REG9_B_VOLUME: EQU 9
REG10_C_VOLUME: EQU 10
REG11_ENV_CYCLE_L: EQU 11
REG12_ENV_CYCLE_H: EQU 12
REG13_ENV_PATTERN: EQU 13

// https://github.com/Konamiman/MSX2-Technical-Handbook/blob/master/md/Chapter5a.md#1-psg-and-sound-output

; enbles tone and disables noise
; argument: address of the variable containing channels data
channelSet: MACRO set
	ld	a, REG7_CHANNEL_SET
        ld      e, set
        CALL    BIOS_WRTPSG
ENDM
VolA: MACRO vol
        ld      a, REG8_A_VOLUME
        ld      e, vol
        call    BIOS_WRTPSG
ENDM
VolB: MACRO vol
        ld      a, REG9_B_VOLUME
        ld      e, vol
        call    BIOS_WRTPSG
ENDM
VolC: MACRO vol
        ld      a, REG10_C_VOLUME
        ld      e, vol
        call    BIOS_WRTPSG
ENDM
