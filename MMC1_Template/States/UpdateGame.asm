UpdateGame:

  LDA gamepadPressed
  BEQ .noInputDetected
  
  	JSR ResetMapper
	INC currentCHRBank
	LDA currentCHRBank
	CMP #$03
	BNE .dontMod
	
	LDA #$00
	
.dontMod:
	STA currentCHRBank 
	;8Kb chr switches- MMC1 mapper ignores lower bit in that case, so mult by 2 for the correct bank
	ASL A
	JSR LoadCHRBankA
 
.noInputDetected:
 
  RTS