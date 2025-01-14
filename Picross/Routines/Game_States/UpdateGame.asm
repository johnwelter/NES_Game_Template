;;VERT_CLUES = $206E
;;HORI_CLUES = $2145

VERT_CLUES = $214E
HORI_CLUES = $218C
BANK_LEVEL = $20A8
TIMER_LOC = $20E5

;;this will change with puzzle sizes
VERT_MIN = $5A ;12 - 1
VERT_MAX = $DA
HORI_MIN = $6A ;14 - 1
HORI_MAX = $EA

MOUSE_START = $618E

HOLD_TIME = $10
HOLD_FREQ = $04

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
  .word UpdateClearPuzzle
  .word UpdateMoveScreen
  .word UpdateDrawImage
  .word UpdateWaitInput
  .word UpdateGameExit

UpdateGameInit:

  ;; get the puzzle table in the puzzle address
  MACROGetLabelPointer $A000, table_address
  MACROGetDoubleIndex puzzle_index
  JSR GetTableAtIndex
  MACROGetPointer table_address, puzzle_address
  MACROGetLabelPointer MOUSE_START, mouse_location
  
  ;;for clues, we need to get past the header- for a 15x15 puzzle, that's 34 bytes ahead
  LDA puzzle_address
  CLC
  ADC #34
  STA clues_address
  LDA #$00
  ADC puzzle_address+1
  STA clues_address+1

  LDA #$00
  STA clueTableIndex
  STA clueLineIndex
  STA clueParity
  STA clueOffsetShift
  STA mouse_index
  STA mouse_index+1
  STA solutionCount
  STA nonSolutionCount
    
  LDA #$20
  STA clueDrawAdd
   
  MACROGetLabelPointer VERT_CLUES, clue_start_address
  JSR ResetClueDrawAddress
  
  MACROAddPPUStringEntryRawData #HIGH(BANK_LEVEL), #LOW(BANK_LEVEL), #DRAW_HORIZONTAL, #$03
  LDA bank_index
  JSR WriteToPPUString
  LDA #$60
  JSR WriteToPPUString
  LDX puzzle_index
  INX
  TXA 
  JSR WriteToPPUString
  
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
  JSR TurnOnSprites
  
  ;;set the timer to 00
  MACROAddPPUStringEntryRawData #HIGH(TIMER_LOC), #LOW(TIMER_LOC), #DRAW_HORIZONTAL, #$05
  LDA #$00
  JSR WriteToPPUString
  LDA #$00
  JSR WriteToPPUString
  LDA #$61
  JSR WriteToPPUString
  LDA #$00
  JSR WriteToPPUString
  LDA #$00
  JSR WriteToPPUString
  
  ;;reset time
  LDA #$00
  STA time
  
  INC mode_state
.leave:
  RTS
  
UpdateGamePlay:
    
  JSR UpdateTimeDisplay
	
  LDA #$00
  STA temp1
  STA temp2
  STA temp3
  
.checkPressed:  

  LDA gamepadPressed
  AND #GAMEPAD_MOVE
  BEQ .checkHeld
  
  LDA #HOLD_TIME
  STA holdTimer 
  LDA gamepadPressed
  JMP .parseInputs
  
.checkHeld:
  
  LDA gamepad
  AND #GAMEPAD_MOVE
  BEQ .checkPaintPress
  
  ;;decrement the hold timer
  DEC holdTimer
  BNE .checkPaintPress
  LDA #HOLD_FREQ
  STA holdTimer
  LDA gamepad

.parseInputs:

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
  JSR UpdateMouseScreenPos
  
.checkPaintPress:

  LDA gamepadPressed
  AND #GAMEPAD_AB
  BEQ .updatePaint
  ;;A or B pressed, get current tile
  
  STA temp1
  
  LDY #$00
  LDA [mouse_location], y
  STA temp2
  
    ;;A treats X and Clear as clear
	;;B treats mark and clear as clear
	;;clear->mark->x
	

  CMP #$7C	;check if this is a marked tile
  BCS .getClearTile
  ;;cleared tile- store off marked tile to paint with instead
  ;;not a clear tile- a mark or an x - check A or B  
  LSR temp1
  BCS .getMarkTile
  
.getXTile:
  LDA #$80
  JMP .finishGetTile
  
.getMarkTile:
  LDA #$70
  JMP .finishGetTile

.getClearTile:
  
  LSR temp1
  BCC .checkB
  LDA temp2
  CMP #$8C			;; check if in X tiles - will be if >=
  BCC .clearTile
  JMP .getMarkTile
  
.checkB:
  
 LDA temp2
 CMP #$8C
 BCS .clearTile
 JMP .getXTile
  
.clearTile:
  LDA #$60
  JMP .finishGetTile
  
.finishGetTile:
  STA currentPaintTile
  JMP .setTile

;;we'll keep a copy of the puzzle tiles in memory, since we can't easily access tiles in the PPU
;;might be best to just keep an entire copy of the nametable instead of trying to index it and deal with 16 bit math
;;we can load the nametable into memory as we draw it

.updatePaint:

  LDA gamepad
  AND #GAMEPAD_AB
  BNE .setTile
  RTS  
  
.setTile:

  ;;take Y position, mult by 2 to get starting index in puzzle solution
  LDA mouse_index+1
  ASL A
  CLC
  ADC #$04 ;; add to get past header
  STA temp1
  
  ;;div X position by 8 to get the byte index
  LDA mouse_index
  LSR A
  LSR A
  LSR A
  BEQ .getMask
  
  INC temp1
  
.getMask:
  
  LDA mouse_index
  AND #$07
  TAX
  LDA #$80
  CPX #$00
  BEQ .storeMask

.maskLoop:
  LSR A
  DEX
  BNE .maskLoop
.storeMask:
  STA temp2

  LDY temp1
  LDA [puzzle_address], y
  AND temp2
  STA temp1	;get the 0/non zero solution flag 

  LDY #$00
  LDA [mouse_location], y
  STA temp3
  AND #$F0
  CMP currentPaintTile
  BNE .diffTiles
  RTS
  
.diffTiles:
  ;;tiles are different- check if the current tile is marked as a solution tile
  CMP #$70
  BNE .checkNewMark
  ;;if erasing a mark, check if the tile was part of the solution
  LDA temp1
  BNE .antiMark
  DEC nonSolutionCount
  JMP .overwriteTile
  
.checkNewMark:

  LDA currentPaintTile
  CMP #$70
  BNE .overwriteTile
  
  LDA temp1
  BNE .proMark
  INC nonSolutionCount 
  JMP .overwriteTile  
  
.antiMark:
  DEC solutionCount
  JMP .overwriteTile
.proMark:   
  
  INC solutionCount
  
.overwriteTile:
  ;;overwrite tile
  LDA temp3
  AND #$0F
  ORA currentPaintTile
  LDY #$00
  STA [mouse_location], y
  STA temp1
  
  LDA mouse_location+1
  AND #$3F
  STA temp2
    
  MACROAddPPUStringEntryRawData temp2, mouse_location, #DRAW_HORIZONTAL, #$01
  LDA temp1
  JSR WriteToPPUString
  
.checkSolution: 

  LDY #$01
  LDA [puzzle_address], y
  CMP solutionCount
  BNE .leave
  LDA nonSolutionCount
  BEQ .changeModeState
  
  JMP .leave
  
  ;;update the painting
.changeModeState:
 
  JSR TurnOffSprites
   
  LDA #$00
  STA clue_draw_address
  STA clueLineIndex
  LDA #$20
  STA clue_draw_address+1
  
  INC mode_state

.leave:
 
  RTS
  
UpdateClearPuzzle:

  JSR ClearPuzzle
  LDA clueLineIndex
  CMP #30
  BNE .leave
  
.changeModeState:

  LDA #$00
  STA clueLineIndex ;using this as a scroller
  INC mode_state

.leave:
 
  RTS
UpdateMoveScreen:
  
  ;for 15x15, move 5 tiles left and 5 tiles up- let's do 1 at a time
  ;we'll take the lower nibble of the clue line index as our scroll counter, and the higher nibble as the x/y flag
  
  LDA clueLineIndex
  AND #$10
  BNE .scrollY
  
  ;;scroll X over
  LDA clueLineIndex
  AND #$0F
  ASL A
  ASL A
  ASL A	;mult by 8
  STA PPU_ScrollX
  
  INC clueLineIndex
  LDA clueLineIndex
  CMP #$06
  BNE .leave
  LDA #$10
  STA clueLineIndex
  JMP .leave
  
.scrollY:

  LDA clueLineIndex
  AND #$0F
  ASL A
  ASL A
  ASL A	;mult by 8
  STA PPU_ScrollY

  INC clueLineIndex
  LDA clueLineIndex
  AND #$0F
  CMP #$05
  BNE .leave
  
.changeModeState:

  LDA #$8E
  STA clue_draw_address
  LDA #$21
  STA clue_draw_address+1
  
  LDA clues_address
  CLC
  ADC clueTableIndex
  STA clues_address
  LDA clues_address+1
  ADC #$00
  STA clues_address+1
  
  LDA #$00
  STA clueTableIndex
  STA clueLineIndex
  STA clueOffsetShift

  INC mode_state

.leave:
 
  RTS
UpdateDrawImage:
  JSR DrawImage
  LDA clueLineIndex
  CMP #225
  BNE .leave
  
.changeModeState:

  ;;do a palette draw
  ;;puzzle address + 03 has the desired palette offset

  LDY #$03
  LDA [puzzle_address],y
  AND #$0F
  TAX
  
  LDA [puzzle_address],y
  AND #$10
  BNE .storeBottomVals
  
  TXA
  ORA #$10
  STA temp1
  TXA
  ORA #$20
  STA temp2
  TXA
  ORA #$30
  STA temp3

  JMP .loadPalToPPUStr
  
.storeBottomVals:

  TXA
  ORA #$00
  STA temp1
  TXA
  ORA #$10
  STA temp2
  TXA
  ORA #$20
  STA temp3
  
.loadPalToPPUStr:
  
  MACROAddPPUStringEntryRawData #$3F, #$01, #DRAW_HORIZONTAL, #03
  LDA temp1
  JSR WriteToPPUString
  LDA temp2
  JSR WriteToPPUString
  LDA temp3
  JSR WriteToPPUString
  
  INC mode_state

.leave:
 
  RTS
UpdateWaitInput:

  LDA gamepadPressed
  BEQ .leave
  
.changeModeState:

  INC mode_state

.leave:
 
  RTS
  
UpdateGameExit:

  LDA #$00
  STA PPU_ScrollX
  STA PPU_ScrollY
  STA PPU_ScrollNT
  
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

  LDX #$00
  LDA SPRITE_DATA, x;ypos	;yyyy y...
  LSR A						;0yyy yy..
  LSR A						;00yy yyy.
  LSR A						;000y yyyy
  STA temp1
  STA mouse_index+1
  INX
  INX
  INX	
  LDA SPRITE_DATA, x ;xpos  ;  xxxx x...
  AND #$F8			 ;		;  xxxx x000
  STA temp2			 ;      ;  
  LSR temp1			 ;		;  0000 yyyy y
  ROR temp2			 ;      ;  yxxx xx00
  LSR temp1			 ;		;  0000 0yyy y
  ROR temp2			 ;		;  yyxx xxx0
  LSR temp1 		 ;		;  0000 00yy y
  ROR temp2			 ;		;  yyyx xxxx
  LDA temp2
  AND #$1F
  STA mouse_index
  
  LDA mouse_index
  SEC 
  SBC #$0E
  STA mouse_index
  
  LDA mouse_index+1
  SEC 
  SBC #$0C
  STA mouse_index+1
  
  ;subtract starting offsets for mouse index
  
  LDA temp1			 ;		;  0000 00yy
  ORA #$60			 ; 		;  0110 00yy
  
  STA mouse_location+1
  LDA temp2
  STA mouse_location
  
.leave:
  RTS
  
UpdateTimeDisplay:

  LDA time
  CMP #60
  BNE .leave
  
  LDA #$00
  STA time
  
  INC GameTime
  LDA GameTime
  CMP #10
  BNE .printTime
  
  LDA #$00
  STA GameTime
  INC GameTime+1
  LDA GameTime+1
  CMP #6
  BNE .printTime
  
  LDA #$00
  STA GameTime+1
  INC GameTime+2
  LDA GameTime+2
  CMP #10
  BNE .printTime
  
  LDA #$00
  STA GameTime+2
  INC GameTime+3
  LDA GameTime+3
  CMP #10
  BNE .printTime
  
  LDA #$00
  STA GameTime+3
  
.printTime:

  MACROAddPPUStringEntryRawData #HIGH(TIMER_LOC), #LOW(TIMER_LOC), #DRAW_HORIZONTAL, #$05
  LDA GameTime+3
  JSR WriteToPPUString
  LDA GameTime+2
  JSR WriteToPPUString
  LDA #$61
  JSR WriteToPPUString
  LDA GameTime+1
  JSR WriteToPPUString
  LDA GameTime
  JSR WriteToPPUString
  
  
  
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


  