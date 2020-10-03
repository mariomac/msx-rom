
SCREEN_WIDTH equ 32
SCREEN_HEIGHT equ 24

BRICKS:
    ; [0] Empty
    DB 0,0,0,0,0,0,0,0
    ; [1] Border, unique brick
    DB 0x7E,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x7E
    ; [2] Border left brick
    DB 0x7F,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x7F
    ; [3] Border right brick
    DB 0xFE,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFE
    ; [4] Inner left brick
	DB 127, 192, 159, 191, 255, 255, 240, 127
    ; [5] Inner right brick
	DB 254, 15, 255, 255, 253, 249, 3, 254

BRICK_COLORS:
    DB 0,0,0,0,0,0,0,0
    DB 64,0xE0,64,64,64,64,0x50,64
    DB 64,0xE0,64,64,64,64,0x50,64
    DB 64,0xE0,64,64,64,64,0x50,64
	DB 64, 78, 78, 78, 64, 64, 69, 64
	DB 64, 78, 78, 78, 69, 69, 69, 64

MAP_NO_PROCESSED:
    DH "54545454545454545454545454545454"
    DH "45454545454545454545454545454545"
    DH "54545454545100000000245454545454"
    DH "45454510000000000000000001454545"
    DH "54543000000000000000000000025454"
    DH "45430000000000000000000000014545"
    DH "54300000000000000000000000000254"
    DH "45100000000000000000000000000025"
    DH "51000000000000000000000000000014"
    DH "43000000000000000000000000000025"
    DH "51000000000000000000000000000014"
    DH "43000000000000000000000000000025"
    DH "51000000000000000000000000000014"
    DH "43000000000000000000000000000025"
    DH "51000000000000000000000000000014"
    DH "43000000000000000000000000000025"
    DH "51000000000000000000000000000014"
    DH "43000000000000010000000000000025"
    DH "51000000000014545430000000000014"
    DH "00000000014545454545430000000000"
    DH "00000002545454545454545100000000"
    DH "00000025454545454545454510000000"
    DH "54545454545454545454545454545454"
    DH "45454545454545454545454545454545"

; high 4 bytes are the left brick index (from the BRICKS array)
; low 4 bytes are the right brick index (from the BRICKS array)
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
JN_EU:      DB 0x01
JN_EBL:     DB 0x02


// TODO: this is currently in rom. This won't work until we move this to some
// RAM address
// https://www.msx.org/wiki/Develop_a_program_in_cartridge_ROM#Search_for_RAM
SCREEN_MAP: 
    DB 0,2,3,4,5
    BLOCK SCREEN_WIDTH*SCREEN_HEIGHT



// separates the nibbles from MAP_NO_PROCESSED into bytes in MAP
build_map:
    ld b, SCREEN_HEIGHT
    ld ix, MAP_NO_PROCESSED
    ld iy, SCREEN_MAP
_check_line:
    djnz _build_line
    ret
_build_line:
    push bc
    ld b, SCREEN_WIDTH
_build_brick: ; unpacks a byte into two bytes
    ld a, (ix)
    ld c, a
    and 0b1111
    srl c
    srl c
    srl c
    srl c
    ld (iy), c
    inc iy
    ld (iy), a
    inc iy
    inc ix
    djnz _build_brick
    pop bc
    jp _check_line   

    

