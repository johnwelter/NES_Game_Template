;;VERT_CLUES = $206E
;;HORI_CLUES = $2145

VERT_CLUES = $214E
HORI_CLUES = $218C
BANK_LEVEL = $20A8
TIMER_LOC = $20E5

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
  .word UpdateGameFadeOut
  .word UpdateGameExit

UpdateGameInit:

  ;;start bank song
  
  lda #$01
  sta current_song
  lda current_song
  jsr sound_load
  
  ;; get the puzzle table in the puzzle address
  MACROGetLabelPointer PUZZLE_TABLE, table_address
  MACROGetDoubleIndex puzzle_index
  JSR GetTableAtIndex
  MACROGetPointer table_address, puzzle_address
  MACROGetLabelPointer MOUSE_START, mouse_location

  ;;for clues, we need to get past the header- for a 15x15 puzzle, that's 34 bytes ahead
  LDY #$00
  LDA [puzzle_address], y
  TAX
  LDA PuzzleHeaderSkips, x
  STA temp1
  
  LDA puzzle_address
  CLC
  ADC temp1
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
  
  LDA #$01
  STA pauseInputLock 
 
  LDA hasContinue
  BNE .skipSolutionReset
  
  LDA #$00
  STA solutionCount
  STA nonSolutionCount
  STA GameTime
  STA GameTime+1
  STA GameTime+2
  STA GameTime+3
  
.skipSolutionReset:	
  
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
  
  LDA hasContinue
  BNE .changeModeState
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

  LDA hasContinue
  BNE .changeModeState
  JSR PopulateClues
  LDA clueTableIndex
  STA image_table_offset
  BCC .leave

.changeModeState:
  JSR TurnOnSprites
  
  ;;set the timer to 00
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
  
  ;;reset time
  LDA #$00
  STA time
  STA scaledTime
  
  ;;clear has continue
  LDA #$00
  STA hasContinue 
  
  
  INC mode_state
.leave:
  RTS
  
UpdateGamePlay:
    
  LDA pauseState
  BEQ .checkPause
  JSR UpdatePause
  RTS
  
.checkPause:
  
  LDA gamepadPressed
  AND #GAMEPAD_START
  BEQ .updatePlay
  LDA #$01
  STA pauseState
  LDA #$00
  STA clueLineIndex 
  STA clueOffsetShift	

  LDA #$FF
  LDX #$00
  JSR SetSpriteImage

  ;;we need the pause screen table loaded
  MACROGetLabelPointer Pause_Menu, pause_address
  MACROGetLabelPointer $210A, pause_draw_address
  
  
  RTS

.updatePlay:

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
  BNE .checkInputLock
  
  LDA #$00
  STA pauseInputLock
  
.leaveEarly:
  RTS  

.checkInputLock:

  ;;check if the input lock is on
  AND pauseInputLock
  BNE .leaveEarly
  
.setTile:
  
  LDA mouse_index
  ORA mouse_index+1
  AND #$10
  BEQ .getPuzzleTile
  
  LDA gamepadPressed ; only draw on click
  AND #GAMEPAD_AB
  BEQ .leaveEarly
  
  LDY #$00
  LDA [mouse_location], y
  CMP #$40
  BCC .leaveEarly
  CMP #$5F
  BEQ .toggleClue
  BCS .leaveEarly

.toggleClue:
  STA temp3
  AND #$F0
  EOR #$10
  STA currentPaintTile
  JMP .overwriteTile
  
.getPuzzleTile:
  JSR CheckAgainstSolution
  
.overwriteTile:
  ;;overwrite tile
   
  LDA temp3		;tile taken from current mouse location
  AND #$F0
  CMP currentPaintTile
  BEQ .skipSound
  JSR PlayMenuCursorSound
.skipSound:
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
  
  ;;also copy to save copy
  LDA mouse_location
  STA copy_address
  LDA mouse_location+1
  AND #$0F
  ORA #$60
  CLC
  ADC #$08
  STA copy_address+1
  
  LDA temp1
  LDY #$00
  STA [copy_address],y
  
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
  
  lda #$00
  sta current_song
  lda current_song
  jsr sound_load
  
  ;;the puzzle is solved, store the time and solved bit in memory
  ;;if the puzzle was solved before, only update the time
  
  MACROGetLabelPointer PuzzleSaveLocations, table_address
  LDA bank_index
  ASL A
  TAY
  JSR GetTableAtIndex
  
  JSR CheckNewBestTime
  
  LDA recordSet
  BEQ .leave
  
  LDA puzzle_index
  ASL A
  ASL A
  TAY
  LDA GameTime
  ORA #$80
  STA [table_address], y
  INY
  LDA GameTime+1
  STA [table_address], y
  INY
  LDA GameTime+2
  STA [table_address], y
  INY
  LDA GameTime+3
  STA [table_address],y

 
  
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
  
  LDY #$00
  LDA [puzzle_address], y
  TAX
  LDA PuzzleScrollHori, x
  STA temp1
  LDA PuzzleScrollVert, x
  STA temp2
  
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
  CMP temp1
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
  CMP temp2
  BNE .leave
  
.changeModeState:

  LDA #$8E
  STA clue_draw_address
  LDA #$21
  STA clue_draw_address+1
  
  LDA clues_address
  CLC
  ADC image_table_offset
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

  ;run it twice for a faster draw
  LDA time
  AND #$01
  BNE .leaveEarly
  JSR DrawImage
  LDA clueTableIndex
  CMP tempy

  BEQ .changeModeState
.leaveEarly:
  RTS
  
.changeModeState:

  ;;do a palette draw
  ;;puzzle address + 03 has the desired palette offset

  MACROAddPPUStringEntryRawData #$3F, #$01, #DRAW_HORIZONTAL, #03
  LDY #$03
  LDA [puzzle_address],y
  STA Palette_Copy-2, y
  JSR WriteToPPUString
  INY
  LDA [puzzle_address],y
  STA Palette_Copy-2, y
  JSR WriteToPPUString
  INY
  LDA [puzzle_address],y
  STA Palette_Copy-2, y
  JSR WriteToPPUString
  
  LDY #$00
  LDA [puzzle_address], y
  ASL A
  TAX
  LDA ImageTitleLowerHalfPos, x
  STA title_draw_address
  INX
  LDA ImageTitleLowerHalfPos, x
  STA title_draw_address+1
  
  JSR DrawTitle
  
  INC mode_state

.leave:
 
  RTS
  
UpdateWaitInput:

  LDA gamepadPressed
  BEQ .leave
  
.changeModeState:
  LDA #$00
  STA time
  STA scaledTime
  LDA #GAMEOVER_IDX
  STA targetGameMode
  INC mode_state

.leave:
 
  RTS
  
UpdateGameFadeOut:

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
  
  ;;don't need to turn all the sprites off, just need to
  ;;clear them out   
  LDA #$FF
  LDX #$00
  JSR SetSpriteImage
  
  LDA #$FF
  LDX #$01
  JSR SetSpriteImage
  
  JSR TurnOnSprites	;turn sprite rendering back on
  
.leave:
  RTS  

UpdateGameExit:

  ;JSR famistudio_music_stop
  LDA time
  AND #$0F
  BNE .leave

  LDA #$00
  STA PPU_ScrollX
  STA PPU_ScrollY
  STA PPU_ScrollNT
  
  LDA targetGameMode
  LDX #$00
  JSR ChangeGameMode
.leave:
  RTS
  
MoveMouse:

  JSR PlayPuzzleCursorSound

  LDA temp1				;horizontal move 
  ASL temp1
  ASL temp1
  ASL temp1
  
  LDA temp2				;vertical move
  ASL temp2 
  ASL temp2
  ASL temp2
  
  
  LDY #$00
  LDA [puzzle_address], y ;puzzle size 0 = 5, 1 = 10, 2 = 15  
  ASL A
  TAX

  LDA mouse_index+1		;horizontal index
  AND #$10				;check clue flag
  STA tempy				;store clue flag
  LDA mouse_index		;horizontal index
  AND #$10				;check clue flag
  STA tempx				;store clue flag
  
  BEQ .puzzleHoriMin
  LDA #HORI_CLUE_MIN
  STA temp3 
  LDA #HORI_CLUE_MAX
  STA temp4
  JMP .checkHoriBorder
  
.puzzleHoriMin:
  LDA MouseMinimums, x
  STA temp3 
  LDA MouseMaximums, x
  STA temp4
  
.checkHoriBorder:
  TXA
  PHA
  
  LDA #$00
  STA temp7
  
  LDX #SPRITE_XPOS
  LDA SPRITE_DATA, x
  CLC
  ADC temp1
  ;;check against borders
  CMP temp3
  BNE .checkHoriMax
  ;;equal - check if mouse index is in clue area
  STA temp6
  LDA tempx
  ORA tempy
  BNE .moveVert
  INC temp7
  LDA temp6
  CLC
  ADC temp1
  JMP .moveSpriteHori
  
.checkHoriMax:
  CMP temp4
  BNE .moveSpriteHori
  
  STA temp6
  LDA tempx
  BEQ .moveVert
  INC temp7
  LDA temp6
  CLC
  ADC temp1
  
.moveSpriteHori:
  STA SPRITE_DATA, x

.moveVert:

  PLA
  TAX
  INX
  
  LDA tempy
  BEQ .puzzleVertMin
  LDA #VERT_CLUE_MIN
  STA temp3 
  LDA #VERT_CLUE_MAX
  STA temp4
  JMP .checkVertBorder
  
.puzzleVertMin:
  LDA MouseMinimums, x
  STA temp3
  LDA MouseMaximums, x
  STA temp4


.checkVertBorder:

  LDA #$00
  STA temp8

  LDX #SPRITE_YPOS
  LDA SPRITE_DATA, x
  CLC
  ADC temp2
  ;;check against borders
  CMP temp3
  BNE .checkVertMax
  ;;equal - check if mouse index is in clue area
  STA temp6
  LDA tempy
  ORA tempx
  BNE .leave
  INC temp8
  LDA temp6
  CLC
  ADC temp2
  JMP .moveSpriteVert
  
.checkVertMax:
  CMP temp4
  BNE .moveSpriteVert
  STA temp6
  LDA tempy
  BEQ .leave
  INC temp8
  LDA temp6
  CLC
  ADC temp2
  
.moveSpriteVert:
  STA SPRITE_DATA, x

.leave:
  RTS
	
UpdateMouseScreenPos:

  LDA temp7
  BEQ .skipHoriFlip
  
  LDA tempx
  EOR #$10
  STA tempx
  
.skipHoriFlip:

  LDA temp8
  BEQ .skipVertFlip

  LDA tempy
  EOR #$10
  STA tempy

.skipVertFlip:


  LDX #$00
  LDA SPRITE_DATA, x;ypos	;yyyy y...
  LSR A						;0yyy yy..
  LSR A						;00yy yyy.
  LSR A						;000y yyyy
  STA temp1
  STA mouse_index+1			;vertical
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
  STA mouse_index			;horizontal
  
  LDA mouse_index
  SEC 
  SBC #$0E
  ORA tempx
  STA mouse_index
  
  LDA mouse_index+1
  SEC 
  SBC #$0C
  ORA tempy
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

  LDA scaledTime
  CMP #60
  BNE .leave
  
  LDA #$00
  STA scaledTime
  
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

  LDA #HIGH(TIMER_LOC)
  LDX #LOW(TIMER_LOC)

  JSR ApplyGameTimeToPPUString
  
  
.leave: 
  RTS  
  
UpdatePause:

;;load screen
;;update selection
;; close - remove screen, then upause
;; quit - jump to fade out
  LDA pauseState
  JSR Dynamic_Jump

UpdatePauseJumpTable:  

  .word ExitPause			;fail safe
  .word UpdateLoadPauseScreen
  .word UpdatePauseScreen
  .word UpdateUnloadPauseScreen
  
UpdateLoadPauseScreen:
  
  JSR LoadPauseScreen
  LDA clueOffsetShift
  CMP #$06
  BNE .leave
  
.changePauseState:

  LDA #PAUSE_YES
  LDX #$01
  JSR SetSpriteXPosition  
  LDA #$01
  LDX #$01
  JSR SetSpriteImage
  
  INC pauseState
.leave:
  RTS
  
UpdatePauseScreen:
  
  LDA gamepadPressed
  CMP #GAMEPAD_START
  BEQ .unPause
  CMP #GAMEPAD_B
  BEQ .unPause
  CMP #GAMEPAD_A
  BEQ .checkA
  
  ;;update pointer
  
  LDA gamepadPressed
  AND #GAMEPAD_HORI
  ;;binary system- left and right don't really matter, we'll just toggle the position
  BEQ .leave
  
  JSR PlayMenuCursorSound
  
  LDA #SPRITE_XPOS
  LDX #$01
  JSR GetSpriteData
  
  CMP #PAUSE_YES
  BEQ .loadNo
  
  LDA #PAUSE_YES
  JMP .setPosition
  
.loadNo:
  LDA #PAUSE_NO

.setPosition:
  
  LDX #$01
  JSR SetSpriteXPosition  

  JMP .leave 

.unPause:

  LDA #$00
  STA clueLineIndex
  STA clueOffsetShift
  
  LDA #$FF
  LDX #$01
  JSR SetSpriteImage

  MACROGetLabelPointer $610A, pause_address
  MACROGetLabelPointer $210A, pause_draw_address
    
  INC pauseState
  JMP .leave
 
.checkA:
  
  LDA #SPRITE_XPOS
  LDX #$01
  JSR GetSpriteData
  
  CMP #PAUSE_NO
  BEQ .unPause
   
.quit:
	
  LDA #$01
  STA hasContinue
  LDA #$00
  STA pauseState
  LDA #$00
  STA time
  LDA #GAMEOVER_IDX
  STA targetGameMode
  LDA #$08
  STA mode_state
  
.leave:
  RTS
  
UpdateUnloadPauseScreen:
  
  JSR ClearPauseScreen
  LDA clueOffsetShift
  CMP #$06
  BNE .leave
.changePauseState:

  LDA #$02
  LDX #$00
  JSR SetSpriteImage
  
  LDA #GAMEPAD_AB
  STA pauseInputLock 
  
  LDA #$00
  STA pauseState
.leave:
  RTS
  
ExitPause:
  RTS
  
CheckNewBestTime:

  ;let's say we already have the save data in the table address
  LDA #$00
  STA recordSet
  
  
  LDA puzzle_index
  ASL A
  ASL A
  TAY
  LDA [table_address], y
  AND #$80
  BEQ .updateTime
  ;MACROGetLabelPointer PuzzleSaveLocations, table_address
  ;LDA bank_index
  ;ASL A
  ;TAY
  ;JSR GetTableAtIndex

  INY 
  INY
  INY 	;start at highest time loc
  LDA GameTime+3
  CMP [table_address], y
  BCC .updateTime
  BCS .leave
  DEY
  LDA GameTime+2
  CMP [table_address], y
  BCC .updateTime
  BCS .leave
  DEY
  LDA GameTime+1
  CMP [table_address], y
  BCC .updateTime
  BCS .leave
  DEY
  LDA [table_address], y
  AND #$0F
  STA temp1
  LDA GameTime
  CMP temp1
  BCC .updateTime
  JMP .leave
  
.updateTime:

  INC recordSet
  
.leave:
  RTS
    

CheckAgainstSolution:
  ;;take Y position, mult by 2 to get starting index in puzzle solution
  LDA mouse_index+1
;;if the puzzle is a 5x5, we only have one byte per row, so no need to double this
  STA temp1
  LDY #$00
  LDA [puzzle_address], y
  BEQ .skipDouble
  ASL temp1
.skipDouble:
  LDA temp1
  CLC
  ADC #$06 ;; add to get past header
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
  JMP .leave
  
.checkNewMark:

  LDA currentPaintTile
  CMP #$70
  BNE .leave
  
  LDA temp1
  BNE .proMark
  INC nonSolutionCount 
  JMP .leave 
  
.antiMark:
  DEC solutionCount
  JMP .leave
.proMark:   
  
  INC solutionCount
.leave:
  RTS	

;hori, vert
MouseMinimums:
  .db $6A, $5A
  .db $6A, $5A
  .db $6A, $5A
MouseMaximums:
  .db $9A, $8A
  .db $C2, $B2
  .db $EA, $DA
  
VERT_CLUE_MIN = $12
HORI_CLUE_MIN = $22
HORI_CLUE_MAX = $6A
VERT_CLUE_MAX = $5A
  
PuzzleScrollHori:
  .db $01, $04, $06
PuzzleScrollVert:
  .db $01, $03, $05
  
PuzzleHeaderSkips:

  .db $0B, $1A, $24
  
PuzzleSaveLocations:
  .word puzzle_clear_bank0, puzzle_clear_bank1, puzzle_clear_bank2

  
PAUSE_YES = $60
PAUSE_NO = $88

  