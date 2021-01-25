; constants
_start_tile_top: equ 5
_start_tile_left: equ 10

; public vars
main_ram: equ 0xE000
amancio_sprite_attrs: equ main_ram
amancio_sprite_attrs_end: equ amancio_sprite_attrs + 12 ; 3 sprites
amancio_sprite_attrs_vals:
    DB _start_tile_top*8, _start_tile_left*8, 0, 9
    DB _start_tile_top*8, _start_tile_left*8, 4, 14
    ; whip sprite
    DB 0, 0, 0, 0
amancio_sprite_attrs_vals_end:

; pointer to the top-left tile map, corresponding to the amancio position
amancio_collision_ptr: equ amancio_sprite_attrs_end+1
amancio_collision_ptr_val:
    DW SCREEN_0_0 + _start_tile_top * 32 + _start_tile_left ; top-left

; timing of amancio animation
amancio_frame_timing: equ amancio_collision_ptr+1

amancio_frame_num: equ amancio_frame_timing+1

; workers array of structs
workers: equ amancio_frame_num+1
_workers_end: EQU workers+(workers_init_vals_end-workers_init_vals)

amancio_direction: equ _workers_end+1 ; down-right-up-left
AMANCIO_STATUS_DIR_DOWN       equ 0
AMANCIO_STATUS_DIR_RIGHT      equ 1
AMANCIO_STATUS_DIR_UP:        equ 2
AMANCIO_STATUS_DIR_LEFT       equ 3

amancio_status: equ amancio_direction+1
AMANCIO_STATUS_WHIP_BIT:      equ 0

whip_collision_box: equ amancio_status+1
next_var: equ whip_collision_box+4


BOX_X: equ 0
BOX_Y: equ 1
BOX_RX: equ 2
BOX_RY: equ 3
 
; Moves ROM read-only values to main RAM
init_vars:
    ld a, 0
    ld (amancio_frame_num), a
    ld (amancio_status), a

    ld a, AMANCIO_STATUS_DIR_DOWN
    ld (amancio_direction), a
    
    ld de, amancio_sprite_attrs
    ld hl, amancio_sprite_attrs_vals
    ld bc, amancio_sprite_attrs_end-amancio_sprite_attrs
    ldir
    
    ld de, (amancio_collision_ptr_val)
    ld (amancio_collision_ptr), de

    ld de, workers
    ld hl, workers_init_vals
    ld bc, workers_init_vals_end-workers_init_vals
    ldir
    ret
