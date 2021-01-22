; constants
_start_tile_top: equ 5
_start_tile_left: equ 10

; public vars
main_ram: equ 0xE000
amancio_sprite_attrs: equ main_ram
amancio_sprite_attrs_end: equ amancio_sprite_attrs + 8
amancio_sprite_attrs_vals:
    DB _start_tile_top*8, _start_tile_left*8, 0, 9
    DB _start_tile_top*8, _start_tile_left*8, 4, 14    
amancio_sprite_attrs_vals_end:
; pointer to the top-left tile map, corresponding to the amancio position
amancio_collision_ptr: equ amancio_sprite_attrs_end+1
amancio_collision_ptr_val:
    DW SCREEN_0_0 + _start_tile_top * 32 + _start_tile_left ; top-left

; Moves ROM read-only values to main RAM
init_vars:
    ld de, amancio_sprite_attrs
    ld hl, amancio_sprite_attrs_vals
    ld bc, amancio_sprite_attrs_end-amancio_sprite_attrs
    ldir
    ld de, (amancio_collision_ptr_val)
    ld (amancio_collision_ptr), de
    ret
