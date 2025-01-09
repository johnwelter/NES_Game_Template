UpdateTitleNMI:

  ;;load bank 0 for BG tiles, so we start with the right tile set
  ;JSR ResetMapper
  ;LDA #$01
  ;JSR LoadCHRBankB


  JSR DetectSprite0

  ;JSR ResetMapper
  ;LDA #$03
  ;JSR LoadCHRBankB
  
  LDA PPU_Control
  AND #$FC
  ORA PPU_ScrollNT
  STA PPU_CTRL
  
  LDA PPU_ScrollX     ;;tell the ppu there is no background scrolling
  STA PPU_SCROLL
  LDA #$00
  STA PPU_SCROLL

   
  RTS