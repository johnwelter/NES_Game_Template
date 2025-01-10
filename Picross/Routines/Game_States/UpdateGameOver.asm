UpdateGameOver:

  JSR TurnOnSprites
  
  LDA NMI_locks
  BNE .noInputDetected

  LDA gamepadPressed
  BEQ .noInputDetected
  
    LDA #TITLE_IDX
	JSR ChangeGameMode
 
.noInputDetected:
 
  RTS