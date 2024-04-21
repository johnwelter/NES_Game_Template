 
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
  
  
  LDA #$00        ;;tell the ppu there is no background scrolling
  STA $2005
  STA $2005
  
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001

  LDA game_mode
  CMP #TITLE_IDX
  BNE NotTitle
	;;load bank 0 for BG tiles
  JSR ResetMapper
  LDA #$01
  JSR LoadCHRBankB
		
WaitNotSprite0:
  lda $2002
  and #%01000000
  bne WaitNotSprite0   ; wait until sprite 0 not hit

WaitSprite0:
  lda $2002
  and #%01000000
  beq WaitSprite0      ; wait until sprite 0 is hit

  ldx #$05				;do a scanline wait
WaitScanline:
  dex
  bne WaitScanline

  JSR ResetMapper
  LDA #$03
  JSR LoadCHRBankB
		

NotTitle:


WakeUp:
  LDA #$00
  STA sleeping
  
  PLA                              ;restore the registers
  TAY 
  PLA
  TAX
  PLA

  RTI             ; return from interrupt