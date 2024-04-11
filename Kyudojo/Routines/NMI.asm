 
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
  BEQ update_controllers
  JMP WakeUp

update_controllers:

  .include "Routines/ReadControllers.asm"
  
  
  
  ;;draw a debug tile at the top right corner
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$20
  STA $2006             ; write the high byte of $2000 address
  LDA #$42
  STA $2006             ; write the low byte of $2000 address
  
  LDX #$00

drawDebugMouseData:
  LDA mouseData+1, x
  LSR A
  LSR A
  LSR A
  LSR A
  STA $2007
  LDA mouseData+1, x
  AND #$0F
  STA $2007
  LDA #$24
  STA $2007
  INX
  CPX #$04
  BNE drawDebugMouseData
  
  
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
  
skip_graphics_updates:

  PLA                              ;restore the registers
  TAY 
  PLA
  TAX
  PLA

  RTI             ; return from interrupt