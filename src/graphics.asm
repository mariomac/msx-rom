
SCREEN_WIDTH equ 32
SCREEN_HEIGHT equ 24

BRICKS:
    ; Border, unique brick
    DB 0x7E,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x7E
    ; Border left brick
    DB 0x7F,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x7F
    ; Border right brick
    DB 0xFE,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFE
    ; Inner left brick
	DB 127, 192, 159, 191, 255, 255, 240, 127
    ; Inner right brick
	DB 254, 15, 255, 255, 253, 249, 3, 254

BRICK_COLORS:
    DB 64,0xE0,64,64,64,64,0x50,64
    DB 64,0xE0,64,64,64,64,0x50,64
    DB 64,0xE0,64,64,64,64,0x50,64
	DB 64, 78, 78, 78, 64, 64, 69, 64
	DB 64, 78, 78, 78, 69, 69, 69, 64

; high 4 bytes are the left brick index (from the BRICKS array) - 1
; low 4 bytes are the right brick index (from the BRICKS array) - 1
; zero is empty brick
BRICK_JUCTIONS:
JN_EE:      DB 0x00     ; Empty - empty
JN_UE:      DB 0x10     ; Unique brick - empty
JN_UIL:     DB 0x14     ; Unique brick - inner left brick
JN_BLIR:    DB 0x25     ; Border left brick - inner right brick
JN_BLBR:    DB 0x23     ; border left brick - border right brick
JN_ILIR:    DB 0x45     ; inner left brick - inner right brick
JN_ILBR:    DB 0x43     ; inner left brick - border right brick
JN_BRE:     DB 0x30     ; border right brick - empty
JN_IRU:     DB 0x51     ; inner right brick - unique brick
JN_IRIL:    DB 0x54     ; inner right brick - inner left brick
JN_EU:      DB 0x

; bitmap to map brick status
CLOSES_LEFT     equ 1
CLOSES_RIGHT    equ 1<<1
HAS_LEFT        equ 1<<2
HAS_RIGHT       equ 1<<3
HAS_RIGHT_BRDR  equ 1<<4

; each of the possible above flags combinations is an index, pointing to the
; index of a byte junction above
; (see bricks_and_junctions.jpg in this repo)
BRICK_CODE_TO_JUNCTIONS:
    DB 0,0,0                    ; [0,1,2] Impossible
    DB JN_UE-BRICK_JUCTIONS     ; [3] CLOSES_LEFT | CLOSES_RIGHT -> JN_UE (1)
    DB 0
    DB JN_BRE-BRICK_JUCTIONS    ; [5] CLOSES_LEFT | HAS_LEFT -> JN_BRE (7)
    DB 0,0,0                    ; [6,7,8] Impossible
    DB JN_BLIR-BRICK_JUCTIONS   ; [9]
    DB 0
    DB JN_UIL                   ; [11]
    DB 0
    DB JN_ILIR-BRICK_JUCTIONS   ; [13]
    DB JN_IRIL-BRICK_JUCTIONS   ; [14]
    BLOCK 11
    DB JN_BLBR-BRICK_JUCTIONS   ; [25]
    DB 0,0,0
    DB JN_ILBR-BRICK_JUCTIONS   ; [29]
    DB JN_IRU-BRICK_JUCTIONS    ; [30]

// TODO: usar DG
; A hyphen '-' (also '.' and '_') represents 0 and any other non-whitespace character represents 1.
; It ignores spaces, use them for formatting if you like.
; https://z00m128.github.io/sjasmplus/documentation.html#po_dg
BITMAP:
    DD 0b11111111111111111111111111111111
    DD 0b11110000000000000000000000111111
    DD 0b11100000000000100000000000011111
    DD 0b11111000000111111100000011111111
    DD 0b11100000000000110000000000111111
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

SCREEN_MAP: BLOCK SCREEN_WIDTH*SCREEN_HEIGHT


; modifies: a
build_screen_map:

build_screen_line:
    ; a: status of the current brick
    ; b: status of the previous brick
    ld a, HAS_LEFT


build_odd: ; par
    
build_even: ; impar

    

