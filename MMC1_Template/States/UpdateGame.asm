UpdateGame:

  LDA gamepad
  BEQ .noInputDetected
  
	INC currentCHRBank
	LDA currentCHRBank
	CMP #$03
	BNE .dontMod
	
	LDA #$00
	
.dontMod:
	STA currentCHRBank 
	JSR LoadCHRBankB
 
.noInputDetected:
 
  RTS