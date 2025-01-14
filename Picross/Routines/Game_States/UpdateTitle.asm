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

  JSR TurnOnSprites
  
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
  
.changeModeState:

  LDA mouse_index
  STA bank_index
  LDA #$FF
  JSR SetPointerSprite
  
  INC mode_state
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
  JSR SetPointerSprite
  JSR InitPuzzlePointer
  INC mode_state
.leave:
  RTS
  
UpdatePuzzleSelection:

  JSR UpdatePuzzlePointer
  
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
  JSR SetPointerSprite
  JSR InitBankPointer
  
  LDA #$00
  STA PPU_ScrollY
  LDA #$FC
  STA PPU_ScrollX
  LDA PPU_ScrollNT
  AND #$FE
  STA PPU_ScrollNT
  
  INC mode_state
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
  JSR SetPointerSprite
  DEC mode_state
  DEC mode_state
  DEC mode_state
  
.leave:
  RTS
  
UpdateTitleExit:

  ;;reset screen scroll
  LDA #$00
  STA PPU_ScrollX
  STA PPU_ScrollNT
  
  ;;load bank

  JSR ResetMapper
  LDA bank_index
  STA currentPRGBank
  JSR LoadPRGBank

  ;; we can also pick out the puzzle index
  ;; we have the mouse indexes - one vert, one hori
  ;; take vert, mult by 9- alternatively, mult by 8, add index 
  ;; IE - ind = 1, mult 8 = 8, add 1 = 9
  ;; add X index
  LDA mouse_index
  ASL A
  ASL A
  ASL A
  CLC
  ADC mouse_index
  ADC mouse_index+1
  STA puzzle_index

  JSR TurnOffSprites

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
  JSR SetPointerYPosition
  PLA
  JSR SetPointerXPosition
 
  RTS
  
SetPointerYPosition:
  
  PHA
  LDA #SPRITE_YPOS
  JSR GetPointerDataIndexInX
  PLA
  STA SPRITE_DATA, x
  RTS
  
SetPointerXPosition:  
  
  PHA
  LDA #SPRITE_XPOS
  JSR GetPointerDataIndexInX
  PLA
  STA SPRITE_DATA, x 
  RTS

SetPointerSprite:

;; A has aprite we want
  PHA
  LDA #SPRITE_ID
  JSR GetPointerDataIndexInX
  PLA
  STA SPRITE_DATA, x
  RTS
  
GetPointerDataIndexInX:

  STA temp3
  LDA #$01
  ASL A
  ASL A
  CLC
  ADC temp3
  TAX
  
  RTS
  
  
UpdateBankPointer:
 
  ;;bank pointer is 1D, will loop between 0->3
  LDA gamepadPressed
  BEQ .leave 
  
  LDA #$00
  STA temp1
  
.parseInputs:
  LDA gamepadPressed
  AND #GAMEPAD_VERT
  BEQ .leave
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
  CMP #$02
  BEQ .skipMod
  BCC .skipMod
  LDA #$00
.skipMod:
  STA mouse_index
  ;; mult mouse_index by 16
  ASL A
  ASL A
  ASL A
  ASL A
  CLC
  ADC #$A0
  JSR SetPointerYPosition

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
  JSR SetPointerYPosition
  
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
  JSR SetPointerXPosition
  
.leave:
  
  RTS
