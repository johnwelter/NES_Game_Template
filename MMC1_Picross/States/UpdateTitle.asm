UpdateTitle:

  LDA gamepad
  BEQ .noInputDetected
  
    LDA #GAME_IDX
	JSR ChangeGameMode
 
.noInputDetected:
 
  RTS