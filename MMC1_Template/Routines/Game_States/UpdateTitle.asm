UpdateTitle:

  LDA NMI_locks
  BNE .noInputDetected

  LDA gamepadPressed
  BEQ .noInputDetected
  
    LDA #GAME_IDX
	JSR ChangeGameMode
 
.noInputDetected:
 
  RTS