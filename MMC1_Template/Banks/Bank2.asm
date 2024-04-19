  .bank 4
  .org $8000
  
TestBankC:
	LDA #$03
	STA mapperDebugVar
	RTS

  .bank 5
  .org $A000
  LDA $03
