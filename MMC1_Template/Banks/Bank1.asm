  .bank 2
  .org $8000
  
TestBankB:
	LDA #$02
	STA mapperDebugVar
	RTS

  .bank 3
  .org $A000
  LDA $02
