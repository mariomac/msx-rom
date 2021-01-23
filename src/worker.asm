; STRUCT WORKER (offsets)
WORKER_X: equ 0
WORKER_Y: equ 1
WORKER_STEP: equ 2
WORKER_HURRY: equ 3
WORKER_MACH_SPEED: equ 4 ; 111-like to mask step
WORKER_FLAGS: equ 5
WORKER_LEN: equ 6

WORKER_FLAG_FRAME_MACH: equ 0
WORKER_FLAG_FRAME_HEAD: equ 1
;WORKER_FLAG_LEFTSIDE:   equ 1

; constants
WORKER_BOX_WIDTH: equ 16
WORKER_BOX_HEIGHT: equ 8

LWORKER_FRAME1_TILES: db 2, 3, 4, 5
LWORKER_FRAME2_TILES: DB 10, 11, 12, 13

WORKER_VRAM_ADDRESSES:
    DW SCR2_CHARPOS+(64/8*32+24/8) ; worker 1

workers_init_vals
    DB 24, 64, 0, 40, %11, 0  ; worker 1
workers_init_vals_end:

update_workers:
    push ix
    push de
    ld ix, workers
    ; invert frame of the head when the step reaches the hurry
    ld a, (ix+WORKER_STEP)
    inc a
    ld (ix+WORKER_STEP), a
    cp (ix+WORKER_HURRY)
    jp nz, __update_worker_mach
    xor a                   ; reset step to 0
    ld (ix+WORKER_STEP), a
    ld a, (ix+WORKER_FLAGS)
    xor 1<<WORKER_FLAG_FRAME_HEAD
    ld (ix+WORKER_FLAGS), a
__update_worker_mach:
    ; machine frame is 8 times faster than head
    ld a, (ix+WORKER_STEP)
    and (ix+WORKER_MACH_SPEED)
    jp nz, __update_worker
    ld a, (ix+WORKER_FLAGS)
    xor 1<<WORKER_FLAG_FRAME_MACH
    ld (ix+WORKER_FLAGS), a
__update_worker:
    ld de, (WORKER_VRAM_ADDRESSES)
    call _update_lworker_image
    pop de
    pop  ix
    ret

; input: ix: address to the worker
;        de: vram destination
; modifies ALL registers
_update_lworker_image:
    push de
    bit WORKER_FLAG_FRAME_MACH, (ix+WORKER_FLAGS) ;update machine
    jp z, __set_frame2_lworker_mach
    ld hl, LWORKER_FRAME1_TILES
    jp __worker_update_mach
__set_frame2_lworker_mach:
    ld hl, LWORKER_FRAME2_TILES
__worker_update_mach:    
    ld bc, 2
    call BIOS_LDIRVM
    bit WORKER_FLAG_FRAME_HEAD, (ix+WORKER_FLAGS) ; update heade
    jp z, __set_frame2_lworker_head
    ld hl, LWORKER_FRAME1_TILES+2
    jp __worker_copy
__set_frame2_lworker_head    
    ld hl, LWORKER_FRAME2_TILES+2
__worker_copy:
    ld bc, 2
    pop de
    inc de ; head offset +2
    inc de
    call BIOS_LDIRVM
    ret    

