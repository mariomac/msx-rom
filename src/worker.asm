

WORKER_FLAG_FRAME_MACH: equ 0
WORKER_FLAG_FRAME_HEAD: equ 1
WORKER_FLAG_LEFTSIDE:   equ 2

; constants
WORKER_BOX_WIDTH: equ 16
WORKER_BOX_HEIGHT: equ 8
MINIMUM_HURRY_INCREASE: equ 1

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

WORKER_BOX_L_PIXELS: equ 16
WORKERS_PER_ROW: equ 4
WORKER_ROWS_NUM: equ 3
WORKERS_ROWS: db 8*8, 13*8, 18*8

; STRUCT WORKER (offsets)
WORKER_X: equ 0
WORKER_STEP: equ 1
WORKER_HURRY: equ 2
WORKER_MACH_SPEED: equ 3 ; 111-like to mask step
WORKER_FLAGS: equ 4
WORKER_LEN: equ 5
NUM_WORKERS: equ 12
workers_init_vals:
    DB 5*8, 0, 40, %11, 0  ; worker 1
    DB 12*8, 0, 90, %111, 0  ; worker 2 ; todo: move boxes left and down
    DB 19*8, 20, 40, %11, 0  ; worker 3
    DB 26*8, 0, 80, %111, 0  ; worker 4
    DB 4*8, 0, 40, %11, 1 << WORKER_FLAG_LEFTSIDE
    DB 11*8, 0, 128, %1111, 1 << WORKER_FLAG_LEFTSIDE
    DB 18*8, 0, 90, %11, 1 << WORKER_FLAG_LEFTSIDE
    DB 25*8, 0, 30, %1, 1 << WORKER_FLAG_LEFTSIDE
    DB 5*8, 0, 60, %111, 0  ; worker 9
    DB 12*8, 0, 250, %11111, 0  ; worker 10
    DB 19*8, 0, 50, %111, 0  ; worker 11
    DB 26*8, 0, 1, %1, 0  ; worker 12
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
    ld a, (ix+WORKER_FLAGS)
    xor 1<<WORKER_FLAG_FRAME_HEAD
    ld (ix+WORKER_FLAGS), a
    call _on_step_reached_hurry
__update_worker_mach:
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

; update worker hurry
; increase shirts
; ix: address of the worker
; modifies a
_on_step_reached_hurry:
    push bc
    xor a
    ld (ix+WORKER_STEP), a
    ld a, (ix+WORKER_HURRY) ; hurry is increased by 12.5% (or the minimum)
    ld b, a
    srl a
    srl a
    srl a
    call _set_hurry
    pop bc
    ret


; ix: pointer to the worker
; a : new hurry
; modifies b
_set_hurry:    
    cp MINIMUM_HURRY_INCREASE
    jp nc, __increase_hurry
    ld a, MINIMUM_HURRY_INCREASE
__increase_hurry:    
    add b
    cp b ; if a+b < b, it means overflow. Setting to 255 (max) ; todo: probably can be replaced by check carry flag
    jp nc, __update_machine_speed
    ld a, 255
__update_machine_speed:
    ld (ix+WORKER_HURRY), a
    ; machine frame is 8 times faster than head
    ld b, 0
__increase_machine_mask:
    sll b   ; shifts left and inserts 1 until mask is larger than hurry
    cp b
    jp z, __divide_mach_mask
    jp nc, __increase_machine_mask
__divide_mach_mask:    
    ; then divide machine speed by 16 (min 1)
    ld a, b
    srl a
    srl a
    srl a
    srl a
    cp 0
    jp nz, __store_machine_speed_mask:
    ld a, 1
__store_machine_speed_mask:
    ld (ix + WORKER_MACH_SPEED), a
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


; input: de coordinates x-y of a point
; if the point is inside a worker, it increases his hurry
check_whip:
    push ix ; worker struct data
    push hl ; verifying rows
    push bc
    call _check_whip_rows
    pop bc
    pop hl
    pop ix
    ret

; input: de coordinates x-y of a point
; modifies b, ix, hl
_check_whip_rows:
    ld ix, workers
    ld b, WORKER_ROWS_NUM   
    ld hl, WORKERS_ROWS
__check_top_margin:             ; if e >= rowy (a)
    ld a, (hl)
    cp e
    jp c, __check_bottom_margin ; a <= e: check bottom margin
    jp z, __check_bottom_margin
    inc hl                      ; else go to the next row 
    push bc                         ; also point to workers of such row
    ld b, 0
    ld c, WORKERS_PER_ROW*WORKER_LEN
    add ix, bc
    pop bc  
    djnz __check_top_margin
    ; all rows verified. ret
    ret
__check_bottom_margin:
    add a, WORKER_BOX_L_PIXELS  ; and if e <= rowy+16 (a)
    cp e
    jp nc, __check_workers_in_row  ; a >= e: check workers in row
    inc hl                          ; else go to the next row
    push bc                         ; also point to workers of such row
    ld b, 0
    ld c, WORKERS_PER_ROW*WORKER_LEN
    add ix, bc
    pop bc  
    djnz __check_top_margin
    ; all rows verified. ret
    ret
__check_workers_in_row:
    ld b, WORKERS_PER_ROW
__check_left_margin:    
    ld a, (ix + WORKER_X)         ; if d >= workerX (a)
    cp d
    jp c, __check_right_margin ; a <= d (true)
    jp z, __check_right_margin
    push bc             ; else go to the next worker
    ld b, 0
    ld c, WORKER_LEN
    add ix, bc
    pop bc
    djnz __check_left_margin
    ; all workers verified. ret
    ret               
__check_right_margin:
    add a, WORKER_BOX_L_PIXELS  ; and if d <= workerX+16 (a)
    cp d
    jp nc, __collision_detected ; a >= d. Collision found
                                ; else go to the next worker
    push bc             ; else go to the next worker
    ld b, 0
    ld c, WORKER_LEN
    add ix, bc
    pop bc
    djnz __check_left_margin
    ; all workers verified
    ret               
__collision_detected:
    xor a  ; reset worker frame
    ld (ix+WORKER_STEP), a
    ld a, 1 ; TODO: decrease as a function of current hurry
    call _set_hurry
    ret


    
