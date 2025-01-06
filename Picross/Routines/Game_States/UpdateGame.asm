;;VERT_CLUES = $206E
;;HORI_CLUES = $2145

VERT_CLUES = $214E
HORI_CLUES = $218C

;;this will change with puzzle sizes
VERT_MIN = $5A
VERT_MAX = $DA
HORI_MIN = $6A
HORI_MAX = $EA

MOUSE_START = $618E

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
  MACROGetLabelPointer MOUSE_START, mouseLocation
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
    
  LDA #$00
  STA temp1
  STA temp2
  STA temp3

  
  LDA gamepadPressed
  BEQ .leave
  AND #GAMEPAD_MOVE
  BEQ .checkPaintPress
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
 
  JSR MoveMouse
  
.updateMousePos:

  JSR UpdateMouseScreenPos
  
.checkPaintPress:

  LDA gamepadPressed
  AND #GAMEPAD_A
  BNE .leave
  
  ;;A pressed, get tile
  
  ;LDA [pointer_address], y
  LDA pointer_address+1
  AND #$3F
  STA pointer_address+1
  
  MACROAddPPUStringEntryRawData pointer_address+1, pointer_address, DRAW_HORIZONTAL, #$01
  LDA #$32
  JSR WriteToPPUString
  
  
;;we'll keep a copy of the puzzle tiles in memory, since we can't easily access tiles in the PPU
;;might be best to just keep an entire copy of the nametable instead of trying to index it and deal with 16 bit math
;;we can load the nametable into memory as we draw it


.updatePaint:

.checkMarkPress:
    
  JMP .leave

.changeModeState:

  INC mode_state

.leave:
 
  RTS
  
UpdateGameExit:

  LDA #GAMEOVER_IDX
  JSR ChangeGameMode
  RTS
  
MoveMouse:

  LDA temp1
  ASL temp1
  ASL temp1
  ASL temp1
  
  LDA temp2
  ASL temp2 
  ASL temp2
  ASL temp2
  
  LDX #SPRITE_XPOS
  LDA SPRITE_DATA, x
  CLC
  ADC temp1
  ;;check against borders
  CMP #HORI_MIN
  BEQ .moveVert
  CMP #HORI_MAX
  BEQ .moveVert
  STA SPRITE_DATA, x

.moveVert:

  LDX #SPRITE_YPOS
  LDA SPRITE_DATA, x
  CLC
  ADC temp2
  ;;check against borders
  CMP #VERT_MIN
  BEQ .leave
  CMP #VERT_MAX
  BEQ .leave
  STA SPRITE_DATA, x

.leave:
  RTS
	
UpdateMouseScreenPos:

  LDA temp3
  BEQ .leave
  DEC temp3

  LDX #$00
  LDA SPRITE_DATA, x	;ypos
  LSR A
  LSR A
  LSR A
  STA temp1
  INX
  INX
  INX
  LDA SPRITE_DATA, x ;xpos
  AND #$F8
  ASL A
  ROL temp3
  ASL A
  ROL temp3
  STA temp2
  
  LDA mouseLocation
  CLC
  ADC temp1
  STA pointer_address
  LDA mouseLocation+1
  ADC #$00
  STA pointer_address+1

  LDA pointer_address
  CLC
  ADC temp2
  STA pointer_address
  LDA pointer_address+1
  ADC temp3
  STA pointer_address+1
.leave:
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


  