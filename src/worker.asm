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
WORKER_FLAG_LEFTSIDE:   equ 2

; constants
WORKER_BOX_WIDTH: equ 16
WORKER_BOX_HEIGHT: equ 8

LWORKER_FRAME1_TILES: db 2, 3, 4, 5
LWORKER_FRAME2_TILES: DB 10, 11, 12, 13
RWORKER_FRAME1_TILES: db 6, 7, 8, 9
RWORKER_FRAME2_TILES: DB 14, 15, 16, 17

WORKER_VRAM_ADDRESSES:
    DW SCR2_CHARPOS+(64/8*32+24/8) ; worker 1
    DW SCR2_CHARPOS+(64/8*32+80/8) ; worker 
    DW SCR2_CHARPOS+(64/8*32+136/8) ; worker 
    DW SCR2_CHARPOS+(64/8*32+192/8) ; worker 
    DW SCR2_CHARPOS+(104/8*32+32/8) ; worker 
    DW SCR2_CHARPOS+(104/8*32+88/8) ; worker 
    DW SCR2_CHARPOS+(104/8*32+144/8) ; worker 
    DW SCR2_CHARPOS+(104/8*32+200/8) ; worker 
    DW SCR2_CHARPOS+(144/8*32+24/8) ; worker 
    DW SCR2_CHARPOS+(144/8*32+80/8) ; worker 
    DW SCR2_CHARPOS+(144/8*32+136/8) ; worker 
    DW SCR2_CHARPOS+(144/8*32+192/8) ; worker 12

NUM_WORKERS: equ 12
workers_init_vals:
    DB 24, 64, 0, 40, %11, 0  ; worker 1
    DB 80, 64, 0, 90, %111, 0  ; worker 2
    DB 136, 64, 20, 40, %11, 0  ; worker 3
    DB 192, 64, 0, 80, %111, 0  ; worker 4
    DB 32, 104, 0, 40, %11, 1 << WORKER_FLAG_LEFTSIDE  
    DB 88, 104, 0, 128, %1111, 1 << WORKER_FLAG_LEFTSIDE  
    DB 144, 104, 0, 90, %11, 1 << WORKER_FLAG_LEFTSIDE  
    DB 200, 104, 0, 30, %1, 1 << WORKER_FLAG_LEFTSIDE 
    DB 24, 144, 0, 60, %111, 0  ; worker 9
    DB 80, 144, 0, 250, %11111, 0  ; worker 10
    DB 136, 144, 0, 50, %111, 0  ; worker 11
    DB 192, 144, 10, 40, %11, 0  ; worker 12
workers_init_vals_end:

update_workers:
    push ix
    push de
    push hl
    ld ix, workers
    ld b, NUM_WORKERS
    ld hl, WORKER_VRAM_ADDRESSES
__worker_loop:
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
    ld e, (hl)  ; load next worker vram address
    inc hl
    ld d, (hl)
    inc hl
    ld a, (ix+WORKER_FLAGS)
    bit WORKER_FLAG_LEFTSIDE, a
    jp nz, _is_rightworker    
    call _update_lworker_image
    jp _nextworker
_is_rightworker:
    call _update_rworker_image
_nextworker:    
    ; go to the next worker
    ld de, WORKER_LEN
    add ix, de
    djnz __worker_loop
    pop hl
    pop de
    pop ix
    ret

; input: ix: address to the worker
;        de: vram destination
; modifies ALL registers
_update_lworker_image:
    push hl
    push bc
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
    pop bc
    pop hl
    ret

_update_rworker_image:
    push hl
    push bc
    push de
    bit WORKER_FLAG_FRAME_HEAD, (ix+WORKER_FLAGS) ;update head
    jp z, __set_frame2_rworker_head
    ld hl, RWORKER_FRAME1_TILES
    jp __rworker_update_head
__set_frame2_rworker_head:
    ld hl, RWORKER_FRAME2_TILES
__rworker_update_head:    
    ld bc, 2
    call BIOS_LDIRVM
    bit WORKER_FLAG_FRAME_MACH, (ix+WORKER_FLAGS) ; update machine
    jp z, __set_frame2_rworker_mach
    ld hl, RWORKER_FRAME1_TILES+2
    jp __rworker_copy
__set_frame2_rworker_mach:    
    ld hl, RWORKER_FRAME2_TILES+2
__rworker_copy:
    ld bc, 2
    pop de
    inc de ; machine offset +2
    inc de
    call BIOS_LDIRVM
    pop bc
    pop hl
    ret

