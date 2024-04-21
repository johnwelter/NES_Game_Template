  .bank 0
  .org $8000
  
TestBankA:
	LDA #$01
	STA mapperDebugVar
	RTS

  .bank 1
  .org $A000
  LDA $01
