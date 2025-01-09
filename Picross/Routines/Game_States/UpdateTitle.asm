UpdateTitle:

  LDA NMI_locks
  BEQ .unlocked
  
  RTS
  
.unlocked:

  JSR DoUpdateTitle
  
  LDA gamepadPressed
  AND #GAMEPAD_START
  BNE .loadGame
  RTS
  
.loadGame:
  LDA #GAME_IDX
  JSR ChangeGameMode
  
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

  
;;title should have two steps- the bank selection and the puzzle selection
;;top half of screen can be used as the title screen, and the bottom half will have the selectable options
;;
;;starting options list: BANK 0, BANK 1, BANK 2, BANK3
;;select one, then scroll over to the right, with numbers for puzzles 

UpdateTitleInit:
.changeModeState:

  INC mode_state
.leave:
  RTS
  
UpdateBankSelection:

  LDA gamepadPressed
  BEQ .leave
  
.changeModeState:

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

  INC mode_state
.leave:
  RTS
  
UpdatePuzzleSelection:

  LDA gamepadPressed
  BEQ .leave
  
.changeModeState:
  
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

  DEC mode_state
  DEC mode_state
  DEC mode_state
  
.leave:
  RTS