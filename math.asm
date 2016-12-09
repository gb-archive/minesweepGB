;---------------------------------------------------------------------------
;   Copyright (C) 2017 Lance Kindle
;   Original from <github.com/lancekindle/minesweepGB>
;   Licensed under GNU GPL v3 <http://www.gnu.org/licenses/>
;---------------------------------------------------------------------------
; module to hold math procedures. Included macros are to help set up registers
; and call the procedure.

include "syntax.asm"

	IF	!DEF(MATH_ASM)
MATH_ASM	SET	1
; multiply two 8-bit registers together
; final result will reside in HL. (a 16-bit register is required)
; The two numbers should be in registers A & C (B will be set to 0)
; when this procedure returns, it sets the carry flag if H > 0
; aka, the carry flag will be 0 if the resulting # is only 8bits large
; in that case, the L register would hold the number
math_MultiplyAC:
	ld	b, 0
	; shift a to right by 1. In this case, RRA (rotate "a" right) is the
	; same operation as SRA, but faster.
	; If 1 was rotated into the carry-flag, then we add BC to HL
	; then we multiply C by 2 (shift bc left)
	; do that 8 times, and you'll have multiplied 
	RRA	; 1
	if_flag	c, add	hl, bc
	shift_left	b, c
	RRA	; 2
	if_flag	c, add	hl, bc
	shift_left	b, c
	RRA	; 3
	if_flag	c, add	hl, bc
	shift_left	b, c
	RRA	; 4
	if_flag	c, add	hl, bc
	shift_left	b, c
	RRA	; 5
	if_flag	c, add	hl, bc
	shift_left	b, c
	RRA	; 6
	if_flag	c, add	hl, bc
	shift_left	b, c
	RRA	; 7
	if_flag	c, add	hl, bc
	shift_left	b, c
	RRA	; 8
	if_flag	c, add	hl, bc
	; Lastly, set carry flag if HL > 255
	ld	a, %11111111
	add	h	; will set carry flag if H > 0
	ret

; call this to write more readable "multiply" code
; math_Mult	a, 8
; result will reside in HL
; CANNOT CALL WITH TWO REGISTERS. 2nd argument must be a hard-coded integer
; if you wish to use two registers, load in A & C, and call math_MultiplyAC
math_Mult: MACRO
	IF (STRCMP(STRUPR("\1"), STRLWR("\1")) == 0)
		FAIL	"2nd arg must be hard-coded #. Use math_MultiplyAC"
	ENDC
	IF (STRCMP("\2", "32") == 0) || (STRCMP("\2", "16") == 0) || (STRCMP("\2", "8") == 0) || (STRCMP("\2", "4") == 0) || (STRCMP("\2", "2") == 0)
	; I'd like to instead call an optimization of shifting register \1
	; instead of multiplying if arg2 is a common power of 2: 2,4,8,16
	ld	l, \1
	ld	h, 0	; setup hl
	shift_left	h, l		; satisfies "\2" == "2"
	IF STRCMP("\2", "4") == 0
		shift_left	h, l	; to x4, only shift once more
	ENDC
	IF STRCMP("\2", "8") == 0
		shift_left	h, l	; to x8, only shift twice more
		shift_left	h, l
	ENDC
	IF STRCMP("\2", "16") == 0	; to x16, only shift thrice more
		shift_left	h, l
		shift_left	h, l
		shift_left	h, l
	ENDC
	IF STRCMP("\2", "32") == 0	; to x32, only shift 4 times more
		shift_left	h, l
		shift_left	h, l
		shift_left	h, l
		shift_left	h, l
	ENDC
	; set carry-flag if H > 0
	ld	a, %11111111
	add	h

	; below ELSE is for if \2 is not a common power of 2. NOT 2,4,8, or 16
	; then we call the general multiplication form
	ELSE
		ld	c, \1
		ld	a, \2
		call math_MultiplyAC
	ENDC
	ENDM

; in order to divide, we sample the most-significant-bit (MSB) of C,
; and compare to A. If A is larger, we sample the first 2 significant bits
; of C, and compare to A. Once A is <= sampled MSBs of C, then we subtract
; A from that sampled bits. The remainder stays, and we shift C over one again,
; and once again compare to A
math_Divide_C_by_B:
	ld	a, 0	; we will be shifting MSB's of C into A
	ld	d, 0	; we will store division result in D
	ld	e, 8	; # of times I will divide. Rounded-Down Integer
.start_divide_C_by_A:
	dec	e
	jr	z, .done_dividingCB
	shift_left	a, c	; take first MSB sample from C, place in A
	ifa	>=, b, jp .subtract_B_from_A
	SLA	d	; sampled bits still too small for B, we have not yet
			; divided the remainder by B
	jr .start_divide_C_by_A
.subtract_B_from_A:
	sub	b	; remainder is in A
	SCF
	RL	d	; sampled bits were larger than B, so we have divided
			; a portion of the register.
			; To indicate we've done this, shift and store 1 in D
	jr .start_divide_C_by_A
.done_dividingCB:





; 
math_Div: MACRO
	ENDM

	ENDC	; end math.asm defines