;---------------------------------------------------------------------------
;   Copyright (C) 2017 Lance Kindle
;   Original from <github.com/lancekindle/minesweepGB>
;   Licensed under GNU GPL v3 <http://www.gnu.org/licenses/>
;---------------------------------------------------------------------------
; Newest Test is on bottom of file
	IF !DEF(RUNNING_MAIN_TEST)
RUNNING_MAIN_TEST	SET	1	; (Used to detect when user compiles
					; a test module rather than this
					; test_main.asm file)

include "gbhw.inc"
include "ibmpc1.inc"

section "Vblank", HOME[$0040]
	reti
section "LCDC", HOME[$0048]
	reti
section "Timer_Overflow", HOME[$0050]
	reti
section "Serial", HOME[$0058]
	reti
section "joypad_p1_p4", HOME[$0060]
	jp	JoypadInterrupt
section "start", HOME[$0100]
	nop
	jp begin

	NINTENDO_LOGO
	ROM_HEADER ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBIT

include "joypad.asm"
include "memory.asm"
include "lcd.asm"
include "syntax.inc"
include "test_includes.asm"
include "test_syntax.asm"
include "test_math.asm"
include "test_matrix.asm"
include "test_stack.asm"

begin:
	di    ; disable interrupts
	ld	sp, $ffff  ; init stack pointer to be at top of memory
	call	SetupGameboy
	call	test_01_lda			; begin test_syntax.asm
	call	test_03_ldpair
	call	test_04_if
	call	test_05_if_not
	call	test_06_if_flag
	call	test_07_if_not_flag
	call	test_08_truefalse
	call	test_09_ifa
	call	test_0A_if_flags
	call	test_0B_shifts
	call	test_0C_increment_decrement
	call	test_0D_ifa_not
	call	test_0E_negate
	call	test_11_math_MultiplyAC		; begin test_math.asm
	call	test_12_math_Mult_Shortcuts
	call	test_13_math_Divide_A_by_C
	call	test_14_math_Mod
	call	test_21_matrix_DeclareInit	; begin test_matrix.asm
	call	test_22_matrix_IterDeclareInit
	call	test_23_matrix_SubmatrixIter
	call	test_24_matrix_IterYX
	call	test_31_stack_DeclareInit	; begin test_stack.asm
	call	test_32_stack_PushPop
	call	test_33_stack_Boundaries
	call	test_34_stack_PushPop_Word
	call	test_35_stack_PushPop_WordBoundaries
	call	test_36_stack_PushPop_3bytes_and_Boundaries
	call	test_37_stack_PushFail_PreservesPushingRegisters
; ===============================[ End calling tests ]====================
.mainloop:
	halt
	nop
	jr	.mainloop
	

SetupGameboy:
	call	lcd_Stop
	call	lcd_ScreenInit	; set up pallete and (x,y)=(0,0)
	call	LoadFont
	call	ClearBackground
	call	lcd_On
	call	lcd_ShowBackground
	call	JoypadInterrupt	; enables it
	ret

LoadFont:
	ld	hl, ASCII_TILES_LOC
	ld	de, _VRAM
	ld	bc, ASCII_TILES_END - ASCII_TILES_LOC
	call	mem_CopyMono  ; copy a Monochrome font to ram. (our is monochrome?)
	ret

ClearBackground:
	; sets background tiles to empty space
	ld	a, 32
	ld	hl, _SCRN0
	ld	bc, SCRN_VX_B * SCRN_VY_B
	call	mem_SetVRAM
	ret

; call this to enable joypad interrupts. Additionally, this gets called
; each time there is a joypad interrupt, which acknowledges the interrupt
; and then returns, keeping the joypad interrupt enabled. Allows for you to
; halt the cpu for debugging purposes. Then you can press a button to continue
; execution
JoypadInterrupt:
	push	af
	ld	a, 0
	ld	[rIF], a	; acknowledge any current interrupts by setting
				; all Interrupt Flags to 0
	ld	a, %00010000	; bit 4 (in bits 7-0) is joypad interrupt
	ld	[rIE], a	; set Interrupt-Enable flags
	pop	af
	reti

; makes use of include "ibmpc1.inc"
ASCII_TILES_LOC:
	chr_IBMPC1 1,8  ; arguments 1,8 cause all 256 characters to be loaded
ASCII_TILES_END:


	ENDC	; end RUNNING_MAIN_TEST DEFINES
