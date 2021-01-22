main_ram: equ 0xE000

amancio_sprite_attrs: equ main_ram
amancio_sprite_attrs_end: equ amancio_sprite_attrs + 8
amancio_sprite_attrs_vals:
    DB 40, 40, 0, 9
    DB 40, 40, 4, 14    
amancio_sprite_attrs_vals_end:

; Moves ROM read-only values to main RAM
init_vars:
    ld de, amancio_sprite_attrs
    ld hl, amancio_sprite_attrs_vals
    ld bc, amancio_sprite_attrs_end-amancio_sprite_attrs
    ldir
    ret
