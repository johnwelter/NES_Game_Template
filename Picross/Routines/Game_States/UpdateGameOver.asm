UpdateGameOver:

  LDA NMI_locks
  BEQ .unlocked
  
  RTS
  
.unlocked:

  JSR DoUpdateGameOver 
  RTS
  
DoUpdateGameOver:

  LDA mode_state
  JSR Dynamic_Jump
    
UpdateGameOverJumpTable:

  .word UpdateGameOverInit
  .word UpdateGameOverWaitInput
  .word UpdateGameOverFadeOut
  .word UpdateGameOverExit
  
UpdateGameOverInit:

  JSR TurnOnSprites
  INC mode_state
  RTS

UpdateGameOverWaitInput:

  LDA gamepadPressed
  BEQ .leave

.changeModeState:

  LDA #$00
  STA time
  INC mode_state
.leave:
  RTS

UpdateGameOverFadeOut:

  LDA time
  AND #$07
  BNE .leave
  ;;every 8 frames, decrement the palettes
  JSR FadeOutPalettes
  BCS .leave

.changeModeState:
  LDA #$00
  STA time
  INC mode_state
.leave:
  RTS

UpdateGameOverExit:

  LDA time
  AND #$0F
  BNE .leave

  LDA #TITLE_IDX
  LDX #$00
  JSR ChangeGameMode
  
.leave:
  RTS
