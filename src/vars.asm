main_ram: equ 0xE000

brick_tiles: equ main_ram ; length: 8 * 8 bytes
next_var:  equ brick_tiles + 64

amancio_sprite_attrs:
    DB 40, 40, 0, 9
    DB 40, 40, 4, 14    
amancio_sprite_attrs_end: