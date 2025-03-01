UpdateTitle:

  LDA NMI_locks
  BEQ .unlocked
  
  RTS
  
.unlocked:

  JSR DoUpdateTitle  
  RTS
  
DoUpdateTitle:

  LDA mode_state
  JSR Dynamic_Jump
    
UpdateTitleJumpTable:

  .word UpdateTitleInit
  .word UpdateBankSelection
  .word UpdateScroll
  .word UpdatePuzzleSelection
  .word UpdateScrollBack
  .word UpdateTitleExit

  
;;title should have two steps- the bank selection and the puzzle selection
;;top half of screen can be used as the title screen, and the bottom half will have the selectable options
;;
;;starting options list: BANK 0, BANK 1, BANK 2
;;select one, then scroll over to the right, with numbers for puzzles 

UpdateTitleInit:

  lda #$00
  sta current_song
  lda current_song
  jsr sound_load

  JSR TurnOnSprites
  
  LDA hasContinue
  BEQ .skipContinueText
  MACROAddPPUStringEntryTable #$2B, #$4D, #DRAW_HORIZONTAL, ContinueText
  
.skipContinueText:
  
  LDA #$00
  STA mouse_index
  LDA #$00
  STA mouse_index+1

.changeModeState:

  INC mode_state
.leave:
  RTS
  
UpdateBankSelection:

  JSR UpdateBankPointer
  
  LDA gamepadPressed
  AND #GAMEPAD_A
  BEQ .leave
  
  JSR PlayMenuCursorSound
  
.changeModeState:
  
  LDA mouse_index
  CMP #$03
  BNE .setBank
  
  INC mode_state
  INC mode_state
  INC mode_state
  
  ;;load bank
  JSR LoadBank
  JMP .goToNext
  
.setBank:
  STA tempBank
  LDA #$FF
  LDX #$01
  JSR SetSpriteImage
  
  JSR ResetMapper
  LDA tempBank
  JSR LoadPRGBank
  JSR ResetMapper
  LDA tempBank
  ASL A
  JSR LoadCHRBankA

.goToNext:
  INC mode_state

  JMP .leave


.leave:
  RTS
  
UpdateScroll:
  INC PPU_ScrollX
  INC PPU_ScrollX
  INC PPU_ScrollX
  INC PPU_ScrollX
  BNE .leave
  LDA PPU_ScrollNT
  EOR #%00000001
  STA PPU_ScrollNT
  
.changeModeState:
  LDA #$01
  LDX #$01
  JSR SetSpriteImage
  JSR InitPuzzlePointer
  INC mode_state
  LDA #$FF
  STA tempPuzz
.leave:
  RTS
  
UpdatePuzzleSelection:

  JSR UpdatePuzzlePointer
  
  LDA mouse_index
  ASL A
  ASL A
  ASL A
  CLC
  ADC mouse_index
  ADC mouse_index+1
  CMP tempPuzz
  BEQ .checkButtonPresses	;no change
  STA tempPuzz
  
  JSR UpdatePuzzleInfo
  
.checkButtonPresses:

  LDA gamepadPressed
  AND #GAMEPAD_B
  BNE .changeToScrollBack
  LDA gamepadPressed
  AND #GAMEPAD_CONFIRM
  BEQ .leave
  
  INC mode_state
  INC mode_state
  JMP .leave
  
.changeToScrollBack:
 
  LDA #$FF
  LDX #$01
  JSR SetSpriteImage
  JSR SetPuzzleDisplaySprite
  JSR InitBankPointer
  LDA tempBank
  STA mouse_index
  JSR SetBankPointerFromIndex
  
  LDA #$00
  STA PPU_ScrollY
  LDA #$FC
  STA PPU_ScrollX
  LDA PPU_ScrollNT
  AND #$FE
  STA PPU_ScrollNT
  
  INC mode_state
  
  JSR PlayMenuCursorSound
.leave:
  RTS
  
UpdateScrollBack:

  DEC PPU_ScrollX
  DEC PPU_ScrollX
  DEC PPU_ScrollX
  DEC PPU_ScrollX
  BNE .leave
  
.changeModeState:

  LDA #$01
  LDX #$01
  JSR SetSpriteImage
  DEC mode_state
  DEC mode_state
  DEC mode_state
  
.leave:
  RTS
  
UpdateTitleExit:
  
  LDA #$FF
  JSR SetPuzzleDisplaySprite
  
  lda #$00
  sta current_song
  lda current_song
  jsr sound_load
  
  ;;reset screen scroll
  LDA #$00
  STA PPU_ScrollX
  STA PPU_ScrollNT
  
  LDA #%00100000
  STA temp1
  
  LDA mouse_index
  CMP #$03
  BNE .loadPuzzle
  
  ASL temp1
  JMP .setupPuzzle
    
.loadPuzzle:
  ;; we can also pick out the puzzle index
  ;; we have the mouse indexes - one vert, one hori
  ;; take vert, mult by 9- alternatively, mult by 8, add index 
  ;; IE - ind = 1, mult 8 = 8, add 1 = 9
  ;; add X index
  LDA tempBank
  STA bank_index
  JSR LoadBank
  
  LDA tempPuzz
  STA puzzle_index
  LDA #$00
  STA hasContinue


.setupPuzzle:
  MACROGetLabelPointer PUZZLE_TABLE, table_address
  MACROGetDoubleIndex puzzle_index
  JSR GetTableAtIndex
  MACROGetPointer table_address, puzzle_address
  
  MACROGetLabelPointer NAMES_TABLE, table_address
  MACROGetDoubleIndex puzzle_index
  JSR GetTableAtIndex
  MACROGetPointer table_address, title_address

  LDY #$00
  LDA [puzzle_address], y
  ORA temp1
  
  TAX
  

  LDA #GAME_IDX
  JSR ChangeGameMode
  
.leave
  RTS
  
InitBankPointer:

  LDX #$A0
  LDA #$60
  JSR InitPointer
  
  RTS  
  
InitPuzzlePointer:
  
  LDX #$AE
  LDA #$10
  JSR InitPointer
  
  RTS

ResetMouseIndex:

  LDA #$00
  STA mouse_index
  LDA #$00
  STA mouse_index+1
  RTS

InitPointer:

  JSR SetPointerPosition
  JSR ResetMouseIndex
  RTS  
  
SetPointerPosition:

  PHA
  TXA
  LDX #$01
  JSR SetSpriteYPosition
  PLA
  LDX #$01
  JSR SetSpriteXPosition
 
  RTS
  
SetSpriteYPosition:
  
  PHA
  LDA #SPRITE_YPOS
  JSR GetSpriteDataIndexInX
  PLA
  STA SPRITE_DATA, x
  RTS
  
SetSpriteXPosition:  
  
  PHA
  LDA #SPRITE_XPOS
  JSR GetSpriteDataIndexInX
  PLA
  STA SPRITE_DATA, x 
  RTS

SetSpriteImage:

;; A has sprite image index we want
;; X has the sprite index
  PHA
  LDA #SPRITE_ID
  JSR GetSpriteDataIndexInX
  PLA
  STA SPRITE_DATA, x
  RTS
  
GetSpriteDataIndexInX:

  ;; A has data index we want to get
  ;; X has sprite index
  STA temp3
  TXA
  ASL A
  ASL A
  CLC
  ADC temp3
  TAX
  
  RTS  
GetSpriteData:

  ;;A is data we want
  ;;X is Sprite
  JSR GetSpriteDataIndexInX
  LDA SPRITE_DATA, x
  RTS
  
UpdateBankPointer:
 
  ;;bank pointer is 1D, will loop between 0->3
  LDA gamepadPressed
  BNE .continue
.leaveEarly:
  RTS
  
.continue:
  LDA #$00
  STA temp1
  
  LDA #$02
  STA temp2
  
  LDA hasContinue
  BEQ .parseInputs
  LDA #$03
  STA temp2
  
.parseInputs:
  LDA gamepadPressed
  AND #GAMEPAD_VERT
  BEQ .leaveEarly
  ASL A
  ASL A
.checkDown:
  ASL A
  BCC .checkUp
  INC temp1
.checkUp:
  ASL A
  BCC .move
  DEC temp1
.move:
  
  LDA mouse_index
  CLC
  ADC temp1
  CMP temp2
  BEQ .skipMod
  BCC .skipMod
  LDA #$00
.skipMod:
  STA mouse_index
  ;; mult mouse_index by 16
SetBankPointerFromIndex:

  ASL A
  ASL A
  ASL A
  ASL A
  CLC
  ADC #$A0
  LDX #$01
  JSR SetSpriteYPosition
  
  JSR PlayMenuCursorSound

.leave:
  
  RTS
  
UpdatePuzzlePointer:

  ;;puzzle pointer is 2D, will loop between 0-9 and 0-2
  LDA gamepadPressed
  BEQ .leave 
  
  LDA #$00
  STA temp1
  STA temp2
  
.parseInputs:
  LDA gamepadPressed
  AND #GAMEPAD_MOVE
  BEQ .leave
  ASL A
  BCC .checkLeft
  INC temp1
.checkLeft:
  ASL A
  BCC .checkDown
  DEC temp1
.checkDown:
  ASL A
  BCC .checkUp
  INC temp2
.checkUp:
  ASL A
  BCC .move
  DEC temp2
  
.move:

  LDA mouse_index
  CLC
  ADC temp2
  CMP #$02
  BEQ .skipYMod
  BCC .skipYMod
  LDA #$00
.skipYMod:
  STA mouse_index
  ;; mult mouse_index by 16
  ASL A
  ASL A
  ASL A
  ASL A
  CLC
  ADC #$AE
  LDX #$01
  JSR SetSpriteYPosition
  
  LDA mouse_index+1
  CLC
  ADC temp1
  CMP #$08
  BEQ .skipXMod
  BCC .skipXMod
  LDA #$00
.skipXMod:
  STA mouse_index+1
  ;; we need to move 3 tiles each- so index * 3 * 8,
  CLC
  ADC mouse_index+1
  ADC mouse_index+1
  ASL A
  ASL A
  ASL A
  CLC
  ADC #$10
  LDX #$01
  JSR SetSpriteXPosition
  JSR PlayMenuCursorSound
  
.leave:
  
  RTS

LoadBank:

  ;;load bank
  JSR ResetMapper
  LDA bank_index
  STA currentPRGBank
  JSR LoadPRGBank
  RTS
  
UpdatePuzzleInfo:


  MACROGetLabelPointer PuzzleSaveLocations, table_address
  LDA tempBank
  ASL A
  TAY
  JSR GetTableAtIndex
  
  ;;load title/time
  ;;time first, we haven't done titles
  LDX #$00
  LDA SelectDefaultTime,x
  STA temp2
  INX
  LDA SelectDefaultTime,x
  STA temp1
  
  LDA tempPuzz
  ASL A
  ASL A
  TAY
  LDA [table_address], y
  BPL .loadDefaultTime
  
  ;;time exists!
  AND #$0F
  STA temp3
  INY
  INY
  INY
  MACROAddPPUStringEntryRawData temp1, temp2, #DRAW_HORIZONTAL, #$05
  LDA [table_address], y
  JSR WriteToPPUString
  DEY
  LDA [table_address], y
  JSR WriteToPPUString
  LDA #$61
  JSR WriteToPPUString
  DEY
  LDA [table_address], y
  JSR WriteToPPUString
  DEY
  LDA temp3
  JSR WriteToPPUString  
  JMP .drawTitle

.loadDefaultTime:
  
  MACROAddPPUStringEntryRepeat #$26, #$47, #DRAW_HORIZONTAL, #$10, #$63
  MACROAddPPUStringEntryTable temp1, temp2, #DRAW_HORIZONTAL, DefaultTimeString
  ;;also set the display sprite to all FF
  LDA #$FF
  JSR SetPuzzleDisplaySprite
  JMP .leave

.drawTitle:
  MACROAddPPUStringEntryRepeat #$26, #$47, #DRAW_HORIZONTAL, #$10, #$24
  
  MACROGetLabelPointer NAMES_TABLE, table_address
  MACROGetDoubleIndex tempPuzz
  JSR GetTableAtIndex
  MACROGetPointer table_address, title_address

  ;draw title at 264F
  LDA #$4F 
  STA title_draw_address
  LDA #$26
  STA title_draw_address+1
  
  JSR DrawTitle

  LDA tempPuzz
  ASL A
  ASL A
  CLC 
  ADC #$10
  JSR SetPuzzleDisplaySprite
 
.leave:
  RTS

PlayMenuCursorSound:
    
  LDA #$05
  STA current_song
  JSR sound_load
  RTS 

PlayPuzzleCursorSound:
  LDA #$06
  STA current_song
  JSR sound_load
  RTS 
  
PlayNoiseBlipSound:
 
  LDA #$07
  STA current_song
  JSR sound_load
  RTS 
  
SetPuzzleDisplaySprite:

  ;;A has starting sprite index, will never go over FF
  LDX #$02
  PHA
  LDA #SPRITE_ID
  JSR GetSpriteDataIndexInX
  PLA
  STA SPRITE_DATA, x 
  LDY #$01
	
.loop:
  CPY #$04
  BEQ .leave
  CMP #$FF
  BEQ .skipSpriteInc
  CLC
  ADC #1
.skipSpriteInc:
  ;;increment to the next sprite data, by adding 4 to x
  INX
  INX
  INX
  INX
  STA SPRITE_DATA, x
  INY
  BNE .loop	;;should never get to 0 again
  
.leave:
  RTS

ContinueText:

  .db $08, $0C, $18, $17, $1D, $12, $17, $1E, $0E