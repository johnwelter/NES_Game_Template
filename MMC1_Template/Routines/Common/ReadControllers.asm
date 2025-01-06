
    TXA
	PHA
	TYA
	PHA

	LDX #$00

GamePadCheck:
	LDA #$01	;load 1
	STA $4016	; turn latch on
	;STA gamepad2
	LSR	A		; move acc it over for a 0 bit, better than loading 0 to the acc, I guess
	STA $4016	;turn latch off
	
	;do a ring counter technique- load %10000000 into both
	LDA #$80
	STA gamepad

ReadControllerABytesLoop:
	LDA $4016		;acc: %00000001 c: 0
	AND #%00000011	;acc: %00000001 c: 0
	CMP #%00000001	;acc: %00000001 c: 1
	;ror shifts everything right one position: carry->bit 7, bit 0-> carry
	ROR gamepad		;gamepad: %11000000
	;eventually, the ROR sends out the 1 instead of all the leading 0s, BCC (branch carry clear) gets the 1 and does not loop
	BCC ReadControllerABytesLoop
	
	;;comapre last to current, find the pressed buttons this frame
	LDA gamepadLast
	EOR #$FF
	AND gamepad
	STA gamepadPressed
	
	
	LDA gamepad
	STA gamepadLast
	
	;return x and y... before resetting them all over again- always good to make sure we're clean
	PLA
	TAY
	PLA
	TAX	