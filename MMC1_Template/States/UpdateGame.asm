UpdateGame:

  LDA gamepadPressed
  BEQ .noInputDetected
  
  	JSR ResetMapper
	INC currentCHRBank
	LDA currentCHRBank
	CMP #$03
	BNE .dontModCHR
	
	LDA #$00
	
.dontModCHR:
	STA currentCHRBank 
	;4kb switches- all the banks are seqential, so we gotta add 1 and mult by 2 for BG tiles
	ASL A
	CLC 
	ADC #$01
	JSR LoadCHRBankB
	
	JSR ResetMapper
	INC currentPRGBank
	LDA currentPRGBank
	CMP #$03
	BNE .dontModPRG
	
	LDA #$00
	
.dontModPRG:
	STA currentPRGBank
	JSR LoadPRGBank
 
	JSR TestBankA
 
.noInputDetected:
 
  RTS