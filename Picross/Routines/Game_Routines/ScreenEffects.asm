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
  
DrawImage:

  ;;we have clueTableIndex, which should be at the image bytes now
  ;;clue line index will keep track of our place in a byte
   
  LDA #$00
  STA temp1
  
  LDA clueLineIndex
  AND #$03
  STA temp2

  LDY clueTableIndex
  LDA [clues_address], y

  LDX #$00
.loop:
  ASL A
  ROL temp1
  ASL A
  ROL temp1
  INX
  CPX temp2
  BCC .loop
  BEQ .loop
  
  LDA temp1
  AND #$03
  CLC
  ADC #$24
  STA temp1
  
  MACROAddPPUStringEntryRawData clue_draw_address+1, clue_draw_address, #DRAW_HORIZONTAL, #$01
  LDA temp1
  JSR WriteToPPUString
  
  INC clueOffsetShift
  INC clueLineIndex
  LDA clueLineIndex
  AND #$03
  BNE .incDrawIndex
  INC clueTableIndex
  
  
.incDrawIndex:  
  LDA clueOffsetShift
  CMP #$0F
  BNE .incOnly
  ;;add 32-15 = 17 to the draw address
  LDA clue_draw_address
  CLC
  ADC #18
  STA clue_draw_address
  LDA clue_draw_address+1
  ADC #$00
  STA clue_draw_address+1
  
  LDA #$00
  STA clueOffsetShift
  
  JMP .leave
  
.incOnly:

  INC clue_draw_address
  BNE .leave
  INC clue_draw_address+1
  
.leave:
  RTS

ClearLineDefTables:

  .word Clear15x15LineDefs

Clear15x15LineDefs:
  .db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
  .db $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
  .db $20, $20