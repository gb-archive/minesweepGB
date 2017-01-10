;---------------------------------------------------------------------------
;   Copyright (C) 2017 Lance Kindle
;   Original from <github.com/lancekindle/minesweepGB>
;   Licensed under GNU GPL v3 <http://www.gnu.org/licenses/>
;---------------------------------------------------------------------------
include "test_includes.asm"
include "vars.asm"
include "syntax.asm"
include "stack.asm"

; verify that pointer Inited in ram points to the stack
; exactly equal to our hard-coded value of "stack"
verify_stack_address_at_beginning: MACRO
	ld	hl,	\1_stack_topL	; HL points to LSB in ram
	ld	c, [hl]
	increment	hl
	ld	b, [hl]		; load BC with stack_pointer from ram
	ldpair	h,l,	b,c	; place stack_pointer (from ram) into hl
	if_not_hl	\1, .failed	; verify that HL (ptr from ram)
					; equals stack (ptr from compiler)
	ENDM

verify_stack_address_at_end: MACRO
	ld	hl,	\1_stack_topL	; HL points to LSB in ram
	ld	c, [hl]
	increment	hl
	ld	b, [hl]		; load BC with stack_pointer from ram
	ldpair	h,l,	b,c	; place stack_pointer (from ram) into hl
	; verify that HL (ptr from ram) == stack_end (ptr from compiler)
	if_not_hl	\1_stack_end, .failed	
	ENDM


; verify that stack declare doesn't throw syntax errors
; verify stack init sets stack ptr in ram
test_31_stack_DeclareInit:
	stack_Declare	stack, 5
	stack_Init	stack
	verify_stack_address_at_beginning	stack
.passed
	TestPassed	3, 1
.failed
	TestFailed	3, 1


; we use the previously Declared and Inited stack
; to test Push and Pop. Verify that values Pushed on are returned FILO-order
; First In, Last Out (FILO)
test_32_stack_PushPop:
	stack_Push	stack, 11	; push 11 onto stack
	stack_Pop	stack
	ifa	<>, 11, jr .failed	; verify 11 was popped from stack
	; verify ptr is back @ start
	verify_stack_address_at_beginning	stack
	stack_Push	stack, 1
	stack_Push	stack, 2
	stack_Push	stack, 3
	stack_Pop	stack
	ifa	<>, 3, jr .failed
	stack_Pop	stack
	ifa	<>, 2, jr .failed
	stack_Pop	stack
	ifa	<>, 1, jr .failed
.passed
	TestPassed	3, 2
.failed
	TestFailed	3, 2


; verify that stack won't go past start or end of defined ram-limits
; also verify that it throws false (Carry-flag=0) when popping or pushing
; past it's limits
; Finally, verify that pushing additional items on an already-full stack
; does not modify the stack
test_33_stack_Boundaries:
	verify_stack_address_at_beginning	stack
	stack_Pop	stack		; attempt to Pop from an empty stack
	if_flag	c, jp .failed		; pop from empty should throw CY=0
	verify_stack_address_at_beginning	stack
	stack_Push	stack, 5
	if_flag	nc, jp .failed		; carry flag == 1 for successful op
	stack_Push	stack, 4
	stack_Push	stack, 3
	stack_Push	stack, 2
	if_flag	nc, jp .failed
	stack_Push	stack, 1	; this should fill up stack
	if_flag	nc, jp .failed
	verify_stack_address_at_end	stack
	stack_Push	stack,	99	; attempt to Push to a full stack
	if_flag c, jp .failed		; CY=0 since we failed to push
	verify_stack_address_at_end	stack
	; attempt to trash stack by pushing values even though we're at
	; the end of the stack
	stack_Push	stack, 87
	stack_Push	stack, 23
	stack_Push	stack, 52
	; now we verify that values are untouched
	stack_Pop	stack
	if_flag	nc, jp .failed		; verify successful operation (CY=1)
	ifa	<>, 1, jp .failed
	stack_Pop	stack
	ifa	<>, 2, jp .failed
	stack_Pop	stack
	ifa	<>, 3, jp .failed
	stack_Pop	stack
	ifa	<>, 4, jp .failed
	stack_Pop	stack
	if_flag	nc, jp .failed		; again verify that a successful
					; operation throws true (carry-flag=1)
	ifa	<>, 5, jp .failed
	stack_Pop	stack
	if_flag	c, jp .failed		; pop empty should throw CY=0
.passed
	TestPassed	3, 3
.failed
	TestFailed	3, 3