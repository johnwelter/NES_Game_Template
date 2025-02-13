ReadControllersSafe:
	TXA
	PHA
	TYA
	PHA

.firstRead:
	JSR ReadControllers
.reRead:
	LDA gamepad
	PHA
	JSR ReadControllers
	PLA 
	CMP gamepad
	BNE .reRead
	
	PLA
	TAY
	PLA
	TAX	
	RTS
	
ReadControllers:

	LDA #$01	;load 1
	STA $4016	; turn latch on
	;STA gamepad2
	LSR	A		; move acc it over for a 0 bit, better than loading 0 to the acc, I guess
	STA $4016	;turn latch off
	
	LDA #$80
	STA gamepad

.readControllerABytesLoop:
	LDA $4016		;acc: %00000001 c: 0
	AND #%00000011	;acc: %00000001 c: 0
	CMP #%00000001	;acc: %00000001 c: 1
	;ror shifts everything right one position: carry->bit 7, bit 0-> carry
	ROR gamepad		;gamepad: %11000000
	;eventually, the ROR sends out the 1 instead of all the leading 0s, BCC (branch carry clear) gets the 1 and does not loop
	BCC .readControllerABytesLoop

	
.finishARead:
	;;comapre last to current, find the pressed buttons this frame
	LDA gamepadLast
	EOR #$FF
	AND gamepad
	STA gamepadPressed
	
	
	LDA gamepad
	STA gamepadLast
	
	RTS