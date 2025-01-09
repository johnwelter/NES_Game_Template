UpdateTitle:

  LDA NMI_locks
  BNE .leave

  INC PPU_ScrollX
  INC PPU_ScrollX
  BNE .updateBankSelection
  ;;flip bit in our PPU scroll loop thingy
  LDA PPU_ScrollNT
  EOR #%00000001
  STA PPU_ScrollNT
  
;;title should have two steps- the bank selection and the puzzle selection
;;top half of screen can be used as the title screen, and the bottom half will have the selectable options
;;
;;starting options list: BANK 0, BANK 1, BANK 2, BANK3
;;select one, then scroll over to the right, with numbers for puzzles 

.updateBankSelection:
.updateScroll:
.updatePuzzleSelection:


  LDA gamepadPressed
  BEQ .leave
  
    LDA #GAME_IDX
	JSR ChangeGameMode
 
.leave:
 
  RTS