  .bank 4
  .org $8000
  
TestBankC:
	LDA #$03
	STA mapperDebugVar
	RTS

  .bank 5
  .org $A000
  LDA $03

  .org $BFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial