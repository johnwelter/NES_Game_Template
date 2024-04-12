 
NMI:

  PHA                              ;protect the registers
  TXA
  PHA
  TYA
  PHA
  
nmi_started:
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, start the transfer
  
  LDA game_mode_switching
  BEQ update_NMI
  JMP WakeUp

update_NMI:

  .include "Routines/ReadControllers.asm"
    
  ;;This is the PPU clean up section, so rendering the next frame starts properly.
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  LDA #$00        ;;tell the ppu there is no background scrolling
  STA $2005
  STA $2005
  
WakeUp:
  LDA #$00
  STA sleeping
  
  PLA                              ;restore the registers
  TAY 
  PLA
  TAX
  PLA

  RTI             ; return from interrupt