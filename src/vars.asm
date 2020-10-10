main_ram: equ 0xE000

brick_tiles: equ main_ram ; length: 8 * 8 bytes

next_var:  equ brick_tiles + 64