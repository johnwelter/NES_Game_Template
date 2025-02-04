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
  .word UpdateDrawMessage
  .word UpdateGameOverWaitInput
  .word UpdateGameOverFadeOut
  .word UpdateGameOverExit
  
UpdateGameOverInit:

  ;load the hasContinue flag
  ;choose the message to print based on the flag
  lda #$04
  sta current_song
  lda current_song
  jsr sound_load
  
  MACROGetLabelPointer EndScreens, table_address
  LDA hasContinue
  ASL A
  TAY
  JSR GetTableAtIndex
  MACROGetPointer table_address, clues_address
  
  ;this gets us the pointer to the table- now we'll set up the starting draw address
  LDY #$00
  LDA [clues_address], y
  STA clue_draw_address
  INY
  LDA [clues_address], y
  STA clue_draw_address+1 

  LDA clues_address
  CLC
  ADC #$02
  STA clues_address
  LDA clues_address+1
  ADC #$00
  STA clues_address+1
  
  LDA #$00
  STA clueLineIndex
  ;;table address is now at the first string to draw
    
  INC mode_state

;no RTS, just update a line immediately

UpdateDrawMessage:

  LDA hasContinue
  
  BEQ .drawClear
  
  JSR DrawSaveText

  JMP .checkLeave
  
.drawClear

  JSR DrawClearText 
  
.checkLeave:
  BCC .leave

.changeModeState:

  LDA hasContinue
  BNE .skipSpriteSet
  
  LDA #$01
  LDX #$00
  JSR SetSpriteImage
  
.skipSpriteSet:
  INC mode_state
  LDA #$00
  STA time
.leave:
  RTS
  
  
UpdateGameOverWaitInput:

  ;;if there was a record set, flash the time
  LDA recordSet
  BEQ .updateWait
  JSR FlashTime

.updateWait:
  LDA hasContinue
  BEQ .checkOption
  
  LDA gamepadPressed
  BNE .loadTitle
.leaveEarly:
  RTS
  
.checkOption:
  LDA gamepadPressed
  CMP #GAMEPAD_A
  BEQ .checkA
  
  ;;update pointer
  
  LDA gamepadPressed
  AND #GAMEPAD_HORI
  ;;binary system- left and right don't really matter, we'll just toggle the position
  BEQ .leaveEarly
  JSR PlayMenuCursorSound
  LDA #SPRITE_XPOS
  LDX #$00
  JSR GetSpriteData
  
  CMP #GO_YES
  BEQ .loadNo
  
  LDA #GO_YES
  JMP .setPosition
  
.loadNo:
  LDA #GO_NO

.setPosition:
  
  LDX #$00
  JSR SetSpriteXPosition  

  JMP .leave 
  
.checkA:
  
  LDA #SPRITE_XPOS
  LDX #$00
  JSR GetSpriteData
  
  CMP #GO_NO
  
  ;no? go to main menu
  ;yes? update puzzle index and go to game
  ;if puzzle index is the last of the bank, return to menu anyways- we'll polish with a different message later
  BNE .loadNext
  
  ;load the title as the next screen
.loadTitle:
  LDA #TITLE_IDX
  STA targetGameMode
  LDA #$00
  STA targetScreenLoad
  JMP .changeModeState
 
.loadNext:  

  INC puzzle_index
  CMP #$28
  BEQ .loadTitle
  
  MACROGetLabelPointer PUZZLE_TABLE, table_address
  MACROGetDoubleIndex puzzle_index
  JSR GetTableAtIndex
  MACROGetPointer table_address, puzzle_address
  
  MACROGetLabelPointer NAMES_TABLE, table_address
  MACROGetDoubleIndex puzzle_index
  JSR GetTableAtIndex
  MACROGetPointer table_address, title_address

  LDA #GAME_IDX
  STA targetGameMode
  
  LDY #$00
  LDA [puzzle_address], y
  ORA #%00100000
  STA targetScreenLoad

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

  LDA targetGameMode
  LDX targetScreenLoad
  JSR ChangeGameMode
  
.leave:
  RTS
  
DrawClearText:

  ;;for the clear, we draw multiple lines
  ;;table address location is the print loation
  MACROAddPPUStringEntryTablePtr clue_draw_address+1, clue_draw_address, #DRAW_HORIZONTAL, clues_address
  INC clueLineIndex
  LDA clueLineIndex
  CMP #$02
  BEQ .printTime
  CMP #$04
  BEQ .finish
  JMP .updateClueAddress
  
.printTime:

  LDA #$21
  LDX #$31  
  JSR ApplyGameTimeToPPUString

.updateClueAddress:
  LDA clue_draw_address
  CLC
  ADC #$40
  STA clue_draw_address
  LDA clue_draw_address+1
  ADC #$00
  STA clue_draw_address+1
  
  LDY #$00
  LDA [clues_address],y
  TAX
  INX
  TXA
  CLC
  ADC clues_address
  STA clues_address
  LDA clues_address+1
  ADC #$00
  STA clues_address+1
  
  CLC
  JMP .leave
.finish:

  SEC
.leave
  RTS
  
DrawSaveText:

  MACROAddPPUStringEntryTablePtr clue_draw_address+1, clue_draw_address, #DRAW_HORIZONTAL, clues_address
  SEC
  RTS
 
FlashTime:

  LDA time
  AND #$03
  BNE .leave
  
  MACROAddPPUStringEntryRawData #$3F, #$02, #DRAW_HORIZONTAL, #$01
  LDA time
  LSR A
  LSR A
  AND #$01
  TAX
  LDA FlashColors, x
  JSR WriteToPPUString
 
.leave
  RTS 

FlashColors:

  .db $2C, $16

   

GO_YES = $58
GO_NO = $80
