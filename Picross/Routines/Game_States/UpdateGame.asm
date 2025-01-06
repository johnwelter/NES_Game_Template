;;VERT_CLUES = $206E
;;HORI_CLUES = $2145

VERT_CLUES = $214E
HORI_CLUES = $218C

UpdateGame:

  LDA NMI_locks
  BEQ .unlocked
  
  RTS
  
.unlocked:

  JSR DoUpdateGame
  RTS
  
DoUpdateGame:

  LDA mode_state
  JSR Dynamic_Jump
  
UpdateGameJumpTable:

  .word UpdateGameInit
  .word UpdateDrawVertClues
  .word UpdateDrawHoriClues
  .word UpdateGamePlay
  .word UpdateGameExit

UpdateGameInit:

  ;; get the puzzle table in the puzzle address
  MACROGetLabelPointer $A000, table_address
  MACROGetDoubleIndex #$00
  JSR GetTableAtIndex
  MACROGetPointer table_address, puzzle_address

  ;;for clues, we need to get past the header- for a 15x15 puzzle, that's 34 bytes ahead
  LDA puzzle_address
  CLC
  ADC #34
  STA puzzle_address
  LDA #$00
  ADC puzzle_address+1
  STA puzzle_address+1

  LDA #$00
  STA clueTableIndex
  STA clueLineIndex
  STA clueParity
  STA clueOffsetShift
  
  LDA #$20
  STA clueDrawAdd
   
  MACROGetLabelPointer VERT_CLUES, clue_start_address
  JSR ResetClueDrawAddress
    
  INC mode_state

UpdateDrawVertClues:
  
  JSR PopulateClues
  BCC .leave
  
.changeModeState:

  LDA #$00
  STA clueLineIndex
  STA clueParity
  
  LDA #$05
  STA clueOffsetShift
  
  LDA #$01
  STA clueDrawAdd
   
  MACROGetLabelPointer HORI_CLUES, clue_start_address
  JSR ResetClueDrawAddress

  INC mode_state
.leave:
  RTS
  
UpdateDrawHoriClues:

  JSR PopulateClues
  BCC .leave

.changeModeState:
  INC mode_state
.leave:
  RTS
  
UpdateGamePlay:

  MACROAddPPUStringEntryRawData #$20, #$65, #DRAW_HORIZONTAL, #$01
  
  LDA time
  AND #$07
  JSR WriteToPPUString
  
  LDA gamepadPressed
  BEQ .leave
  AND #GAMEPAD_START
  BNE .changeModeState
  BEQ .leave
  

.changeModeState:

  INC mode_state

.leave:
 
  RTS
  
UpdateGameExit:

  LDA #GAMEOVER_IDX
  JSR ChangeGameMode
  RTS
	


;;using the line index and a given count based on the direction, 
  
;; 	JSR ResetMapper
;;	INC currentCHRBank
;;	LDA currentCHRBank
;;	CMP #$03
;;	BNE .dontModCHR
	
;;	LDA #$00

;;.dontModCHR:
;;	STA currentCHRBank 
;;	;4kb switches- all the banks are seqential, so we gotta add 1 and mult by 2 for BG tiles
;;	ASL A
;;	CLC 
;;	ADC #$01
;;	JSR LoadCHRBankB
;;	
;;	JSR ResetMapper
;;	INC currentPRGBank
;;	LDA currentPRGBank
;;	CMP #$03
;;	BNE .dontModPRG
	
;;	LDA #$00
	
;;.dontModPRG:
;;	 STA currentPRGBank
;;	 JSR LoadPRGBank
 
;;	 JSR TestBankA
;;	 LDA mapperDebugVar
;;	 STA $6000
;;	 JMP .noInputDetected


  