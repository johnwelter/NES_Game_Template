 
NMI:

  PHA                              ;protect the registers
  TXA
  PHA
  TYA
  PHA
  
nmi_started:
  LDA #$00
  STA OAM_LO      ; set the low byte (00) of the RAM address
  LDA #$02
  STA OAM_HI       ; set the high byte (02) of the RAM address, start the transfer

  LDA NMI_locks
  BEQ update_controllers
  JMP WakeUp

update_controllers:

  .include "Routines/Common/ReadControllers.asm"
  
  JSR ProcessPPUString
  
  
  LDA #$00        ;;tell the ppu there is no background scrolling
  STA PPU_SCROLL
  STA PPU_SCROLL
  
  ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  ; enable sprites, enable background, no clipping on left side	
  JSR UpdatePPUControl

NMIUpdate:

  JSR StateNMIUpdate
  
  LDA PPU_Control
  AND #$FC
  ORA PPU_ScrollNT
  STA PPU_CTRL
  
  LDA PPU_ScrollX     ;;tell the ppu there is no background scrolling
  STA PPU_SCROLL
  LDA PPU_ScrollY
  STA PPU_SCROLL
  
  jsr sound_play_frame 
  JMP WakeUp

StateNMIUpdate:

  MACROCallDynamicJump game_mode

NMIJumpTable:

  .word UpdateTitleNMI
  .word UpdateGameNMI
  .word UpdateGameOverNMI

WakeUp:
  LDA #$00
  STA sleeping
  
  PLA             ;restore the registers
  TAY 
  PLA
  TAX
  PLA

  RTI             ; return from interrupt
  
  .include "Routines/NMI_States/UpdateTitleNMI.asm"
  .include "Routines/NMI_States/UpdateGameNMI.asm"
  .include "Routines/NMI_States/UpdateGameOverNMI.asm"