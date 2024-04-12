UpdateGame:
  ;;move the mouse cursor around

	LDA mouseData+1
	AND #$0E
	BEQ .hasMouse
	
	LDA #$00
	STA mouseData+2
	STA mouseData+3
	
.hasMouse:
	;;the first byte has only one of two options- 8x or FF. so if it's 8, we know the mouse is
	;;plugged in
	
	;;now, use the top nibble of the next two bytes for the Y and X speed respectively
	
	LDA mouseData+2
	AND #$0F
	STA mouseVelocity
	
	LDA mouseData+3
	AND #$0F
	STA mouseVelocity+1
	
	LDA mouseData+2
	AND #$80
	BEQ .addVert
	LDX #SPRITE_YPOS
	LDA SPRITE_DATA, x
	SEC
	SBC mouseVelocity
	JMP .completeVertMove
	
.addVert:
	LDX #SPRITE_YPOS
	LDA SPRITE_DATA, x
	CLC
	ADC mouseVelocity
	
.completeVertMove:
	STA SPRITE_DATA, x

	LDA mouseData+3
	AND #$80
	BEQ .addHori
	LDX #SPRITE_XPOS
	LDA SPRITE_DATA, x
	SEC
	SBC mouseVelocity+1
	JMP .completeHoriMove
	
.addHori:
	LDX #SPRITE_XPOS
	LDA SPRITE_DATA, x
	CLC
	ADC mouseVelocity+1
.completeHoriMove:
	STA SPRITE_DATA, x
  

  RTS