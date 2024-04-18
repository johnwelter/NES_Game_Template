UpdateGame:

  LDA gamepad
  BEQ .noInputDetected
  
  	JSR ResetMapper
	INC currentCHRBank
	LDA currentCHRBank
	CMP #$03
	BNE .dontMod
	
	LDA #$00
	
.dontMod:
	STA currentCHRBank 
	JSR LoadCHRBankA
 
.noInputDetected:
 
  RTS