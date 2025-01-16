PopulateClues:

.getByte:
  LDY clueTableIndex
  LDA [clues_address], y
  BNE .checkNewLine
  INC clueTableIndex
  LDA #$00
  BEQ .drawClue
  ;was 0, set up a draw
.checkNewLine
  CMP #$FF
  BNE .getClue
  
  ;;was FF- need to inc stuff
  INC clueTableIndex
  LDA #$00
  STA clueParity
  
  INC clueLineIndex
  LDA clueLineIndex
  CMP #$0F
  ;CMP #$01
  BEQ .leave	;carry will be set
  
  JSR CreateOffsetFromIndex
 
  BNE .getByte
  
.getClue:
  ;;clues go from high nibble to low nibble
  PHA 
  LDA clueParity
  BNE .getSecondClue
  INC clueParity
  PLA
  LSR A
  LSR A
  LSR A
  LSR A		;move clue over to lower nibble
  BNE .drawClue
  
.getSecondClue:

  DEC clueParity
  INC clueTableIndex
  PLA 
  AND #$0F
  BNE .drawClue
  ;;if 0, skip
  BEQ .getByte
 
.drawClue:
  
  ORA #$40
  JSR WriteClueByteToPPUString
  CLC
  
.leave:
  RTS
  
WriteClueByteToPPUString:

  STA temp1 ;store off the tile value

  MACROAddPPUStringEntryRawData clue_draw_address+1, clue_draw_address, #DRAW_HORIZONTAL, #$01
  LDA temp1
  JSR WriteToPPUString
  
  ;;also copy to ... copy
  LDA clue_draw_address
  STA copy_address
  LDA clue_draw_address+1
  AND #$0F
  ORA #$60
  STA copy_address+1
  LDA temp1
  LDY #$00
  STA [copy_address],y
  
  LDA clueDrawAdd
  JSR SubFromClueDrawAddress
    
  RTS
  
ResetClueDrawAddress:

  MACROGetPointer clue_start_address, clue_draw_address
  
  RTS
  
AddToClueDrawAddress:

  STA temp1
  
  LDA clue_draw_address
  CLC
  ADC temp1
  STA clue_draw_address
  LDA clue_draw_address+1
  ADC #$00
  STA clue_draw_address+1
  
  RTS
    
SubFromClueDrawAddress:

  STA temp1
  
  LDA clue_draw_address
  SEC
  SBC temp1
  STA clue_draw_address
  LDA clue_draw_address+1
  SBC #$00
  STA clue_draw_address+1
  
  RTS
  
AddToClueDrawAddressHi:

  STA temp1
  
  LDA clue_draw_address+1
  ADC temp1
  STA clue_draw_address+1
  
  RTS
  
CreateOffsetFromIndex:

  ;;would be this, but we need to be able to go further- so we'll make a doulbe offset
  LDA clueLineIndex
  STA clueDrawOffset
  LDA #$00
  STA clueDrawOffset+1
  
  LDA clueOffsetShift	
  BEQ .addOffset
  
  LDX #$00
  
.loopShift:
  ASL clueDrawOffset
  ROL clueDrawOffset+1
  INX
  CPX clueOffsetShift
  BNE .loopShift
  
.addOffset:
  
  JSR ResetClueDrawAddress
  LDA clueDrawOffset
  JSR AddToClueDrawAddress 
  LDA clueDrawOffset+1
  JSR AddToClueDrawAddressHi
  
  RTS  
  
ClearPuzzle:

  ;we'll assume clue draw address has been set to the top of the 1st nametable
 
  MACROGetLabelPointer ClearLineDefTables, table_address
  LDY #$00
  JSR GetTableAtIndex
  
  
  LDY clueLineIndex
  LDA [table_address], y
  STA temp1
  MACROAddPPUStringEntryRepeat clue_draw_address+1, clue_draw_address, #DRAW_HORIZONTAL, temp1, #$24
  ;;no need to load anything else
  
  LDA clue_draw_address
  CLC
  ADC #32
  STA clue_draw_address
  LDA clue_draw_address+1
  ADC #$00
  STA clue_draw_address+1
  
  INC clueLineIndex
  RTS
  
LoadPauseScreen:

;;use clue indexes again
;;we want to draw one line at a time
;;we have control codes, but those don't matter since we have to build ou the strings before hand

;load pause table
;there are 6 lines of 13 tiles
;one byte for the 6 lines, one byte to keep track of our index
  ;STA clueLineIndex 
  ;STA clueOffsetShift

;;pause_address has the table we want
;;pause_draw_address will be the draw location

  MACROAddPPUStringEntryRawData pause_draw_address+1, pause_draw_address, #DRAW_HORIZONTAL, #13

  LDX #$00
  LDY clueLineIndex
.loop:
 
  TXA
  PHA
  LDA [pause_address],y
  JSR WriteToPPUString
  PLA
  TAX
  INY
  INX 
  CPX #13
  BNE .loop
  
  STY clueLineIndex
  
  LDA pause_draw_address
  CLC
  ADC #$20
  STA pause_draw_address
  LDA pause_draw_address+1
  ADC #$00
  STA pause_draw_address+1
  
  INC clueOffsetShift
  RTS
  
  


ClearPauseScreen:  

  MACROAddPPUStringEntryRawData pause_draw_address+1, pause_draw_address, #DRAW_HORIZONTAL, #13

  LDX #$00
  LDY #$00
.loop:
 
  TXA
  PHA
  LDA [pause_address],y
  JSR WriteToPPUString
  PLA
  TAX
  INY
  INX 
  CPX #13
  BNE .loop
  
  
  LDA pause_draw_address
  CLC
  ADC #$20
  STA pause_draw_address
  LDA pause_draw_address+1
  ADC #$00
  STA pause_draw_address+1
  
  LDA pause_address
  CLC
  ADC #$20
  STA pause_address
  LDA pause_address+1
  ADC #$00
  STA pause_address+1
  
  INC clueOffsetShift
 RTS
DrawImage:

  ;;we have clueTableIndex, which should be at the image bytes now
  ;;clue line index will keep track of our place in a byte
   
  LDA #$00
  STA temp1
  STA temp2
  STA temp3
  STA temp4
  STA temp6
  
  LDA #$04
  STA temp5
  
  LDY clueTableIndex
  LDA [clues_address], y

  ASL A
  ROL temp1
  ASL A
  ROL temp1
  ASL A
  ROL temp2
  ASL A
  ROL temp2
  ASL A
  ROL temp3
  ASL A
  ROL temp3
  ASL A
  ROL temp4
  ASL A
  ROL temp4
  

  LDX #$00
.moveUpTiles:
  LDA temp1, x
  ORA #$24
  STA temp1, x
  INX
  CPX #$04
  BNE .moveUpTiles
  
  
  LDA clueOffsetShift
  CLC
  ADC #$04

  STA clueOffsetShift
  ;;clue offset shift + 4, check if we went over 15
  SEC
  SBC #15 ;;subtract 15
  BCC .makeStrings
  BEQ .makeStrings
  
  STA clueOffsetShift ;loop offset over
  STA temp6 ; length of second string
  LDA temp5
  SEC
  SBC temp6 
  STA temp5 ;length of first string 
  
.makeStrings:
  
  LDX #$00
  
  LDA temp5
  BEQ .makeSecondString
  TXA
  PHA
  MACROAddPPUStringEntryRawData clue_draw_address+1, clue_draw_address, #DRAW_HORIZONTAL, temp5
  PLA
  TAX
  
.firstStringLoop:
  
  TXA 
  PHA
  LDA temp1, x
  JSR WriteToPPUString
  
  INC clueLineIndex
  LDA clueLineIndex
  CMP #225
  BNE .continueLoop
  PLA 
  JMP .leave
  
.continueLoop:
  PLA
  TAX
  INX
  CPX temp5
  BNE .firstStringLoop
  
  LDA clue_draw_address
  CLC
  ADC temp5
  STA clue_draw_address
  LDA clue_draw_address+1
  ADC #$00
  STA clue_draw_address+1
  
.makeSecondString:

  LDA temp6
  BEQ .leave
  
  ;;loop draw address to next line
  LDA clue_draw_address
  CLC
  ADC #17
  STA clue_draw_address
  LDA clue_draw_address+1
  ADC #$00
  STA clue_draw_address+1
  TXA
  PHA
  MACROAddPPUStringEntryRawData clue_draw_address+1, clue_draw_address, #DRAW_HORIZONTAL, temp6
  PLA 
  TAX
  
.secondStringLoop:

  TXA
  PHA 
  LDA temp1, x
  JSR WriteToPPUString
  
  INC clueLineIndex
  LDA clueLineIndex
  CMP #225
  BNE .continueSecondLoop
  
  PLA 
  JMP .leave
  
.continueSecondLoop:
  PLA
  TAX
  INX
  CPX #$04
  BNE .secondStringLoop
  
  LDA clue_draw_address
  CLC
  ADC temp6
  STA clue_draw_address
  LDA clue_draw_address+1
  ADC #$00
  STA clue_draw_address+1
  
.leave:
  INC clueTableIndex
  RTS

ClearLineDefTables:

  .word Clear15x15LineDefs

Clear15x15LineDefs:
  .db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
  .db $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
  .db $20, $20