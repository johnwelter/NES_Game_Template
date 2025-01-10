UpdateTitleNMI:

  ;;load bank 0 for BG tiles, so we start with the right tile set
  ;JSR ResetMapper
  ;LDA #$01
  ;JSR LoadCHRBankB


  JSR DetectSprite0

  ;JSR ResetMapper
  ;LDA #$03
  ;JSR LoadCHRBankB
  

   
  RTS