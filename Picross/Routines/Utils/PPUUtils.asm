LoadFullPaletteFromTable:

  MACROSetPPUAddress $3F00
  LDY #$00              ; start out at 0
  LDX #$00
.loop:
  LDA [table_address], y        ; load data from address (palette + the value in x)
  STA PPU_DATA            ; write to PPU
  STA Palette_Copy, x
  INY                   ; X = X + 1
  INX
  CPY #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE .loop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
  RTS

LoadFullBackgroundFromTable:

	MACROSetPPUAddress $2000
	
	;;set pointer
	;; set counters
	LDY #$00
	LDX #$00
	
	;;start loop

.outerloop:

.innerloop:

	LDA [table_address], y
	STA PPU_DATA
	INY
	CPY #$00
	BNE .innerloop

	INC table_address+1
	
	INX
	CPX #$04
	BNE .outerloop
	RTS
	

DATA_LEN = temp1
WRITE_SETTINGS = temp2
	
ProcessPPUString:

	LDA PPU_PendingWrite
	BEQ .leave
	LDY #$00
	
	LDA #LOW(PPU_String)
	STA pointer_address
	LDA #HIGH(PPU_String)
	STA pointer_address + 1

.outerloop:
	LDA PPU_STATUS
	LDA [pointer_address], y
	BEQ .finish
	STA PPU_ADDR
	INY
	LDA [pointer_address], y
	STA PPU_ADDR
    INY 
	LDA [pointer_address], y
	STA WRITE_SETTINGS
	INY
	
	LDA PPU_CTRL
	AND #$FB
	STA PPU_CTRL
	
	LDA WRITE_SETTINGS
	AND #%10000000
	BEQ .checkTable
	ORA PPU_CTRL 
	STA PPU_CTRL 
	
.checkTable:
	LDA WRITE_SETTINGS
	AND #%01000000
	BEQ .rawData
	
	LDA [pointer_address], y
	STA table_address
	INY 
	LDA [pointer_address], y
	STA table_address + 1
	INY
	TYA 
	PHA
	JSR WriteToPPUFromTable
	PLA
	TAY
	JMP .outerloop

.rawData:

	LDA [pointer_address], y
	INY
	STA DATA_LEN

	LDX #$00

.innerloop:
	
	LDA [pointer_address], y
	STA PPU_DATA
	INY
	INX
	CPX DATA_LEN
	BNE .innerloop
	JMP .outerloop
	
.finish:
	JSR ClearPPUString
.leave:
	RTS
	
WriteToPPUFromTable:
	LDY #$00
	LDA [table_address], y
	INY
	STA DATA_LEN
.innerloop:
	LDA [table_address], y
	STA PPU_DATA
	INY
	CPY DATA_LEN
	BCC .innerloop ;table should have the size in it, but since we count the byte count, we'll want to wait till we go over it
	BEQ .innerloop
	RTS
  
LoadSprites_impl:
  LDY #$00              ; start at 0
  
.loop:
  LDA [table_address], y; load data from address (sprites +  x)
  STA SPRITE_DATA, y    ; store into RAM address ($0200 + x)
  INY                   ; X = X + 1
  CPY #$05              ; Compare X to hex $10, decimal 16
  BNE .loop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 16, keep going down   
  RTS


WriteToPPUString:

	LDX PPU_StringIdx
	CPX #PPU_STRINGMAX
	BEQ .finish
	
	STA PPU_String, x
	INC PPU_StringIdx
		
.finish:
	RTS

ClearPPUString:
	
	LDA #$00
	STA PPU_StringIdx
	STA PPU_String
	STA PPU_PendingWrite
	RTS


	

DetectSprite0:
WaitNotSprite0:
  lda PPU_STATUS
  and #SPRITE_0_MASK
  bne WaitNotSprite0   ; wait until sprite 0 not hit

WaitSprite0:
  lda $2002
  and #SPRITE_0_MASK
  beq WaitSprite0      ; wait until sprite 0 is hit

  ldx #$05				;do a scanline wait
WaitScanline:
  dex
  bne WaitScanline
  RTS

NameTableMemList:
  .word $2000, $2400, $2800, $2C00
PalettesMemList:
  .word $3F00, $3F04, $3F08, $3F0C
  .word $3F10, $3F14, $3F18, $3F1C  
