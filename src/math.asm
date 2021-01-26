BOX_X: equ 0
BOX_Y: equ 1
BOX_RX: equ 2
BOX_RY: equ 3

; input ix: pointer to collision box 1
;       iy: pointer to collision box 2
; output: carry flag set if collision
collision:
    push bc
    ; collision? abs(x1-x2) <= rx1+rx2 && abs(y1-y2) <= ry1+ry2
    ld a, (ix+BOX_X)
    sub (iy+BOX_X)
    call abs
    ld b, a
    ld a, (ix+BOX_RX)
    add (iy+BOX_RX)
    cp b
    jp c, __no_collide ; If A ((rx1+rx2)) >= B (abs(x1-x2)), then C flag is 0, then collision
    ld a, (ix+BOX_Y)
    sub (iy+BOX_Y)
    call abs
    ld b, a
    ld a, (ix+BOX_RY)
    add (iy+BOX_RY)
    cp b
    jp c, __no_collide
    pop bc
    scf ; set carry flag and return
    ret
__no_collide:
    pop bc
    ; unset zero flag and return
    ccf
    ret


; input-output: a
abs:
    bit 7, a
    ret nz
    neg
    ret