TILES equ 6

BANK_PATTERN_0:
	DB 0, 0, 0, 0, 0, 0, 0, 0
	DB 127, 192, 159, 191, 255, 255, 240, 127
	DB 254, 15, 255, 255, 253, 249, 3, 254
    DB 0x7F,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x7F
    DB 0xFE,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFE
    DB 0x7E,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x7E

BANK_COLOR_0:
	DB 16, 16, 16, 16, 16, 16, 16, 16
	DB 64, 78, 78, 78, 64, 64, 69, 64
	DB 64, 78, 78, 78, 69, 69, 69, 64
    DB 64,0xE0,64,64,64,64,0x50,64
    DB 64,0xE0,64,64,64,64,0x50,64
    DB 64,0xE0,64,64,64,64,0x50,64


// TODO: usar DG
; A hyphen '-' (also '.' and '_') represents 0 and any other non-whitespace character represents 1.
; It ignores spaces, use them for formatting if you like.
; https://z00m128.github.io/sjasmplus/documentation.html#po_dg


SCREEN_MAP:
    DD 0b11111111111111111111111111111111
    DD 0b11110000000000000000000000111111
    DD 0b11100000000000000000000000011111
    DD 0b11111000000111111100000011111111
    DD 0b11100000000000000000000000111111
    DD 0b11111110000000000000011111111111
    DD 0b11111111000000000000111111111111
    DD 0b11111100000000000000001111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
    DD 0b11111111111111111111111111111111
