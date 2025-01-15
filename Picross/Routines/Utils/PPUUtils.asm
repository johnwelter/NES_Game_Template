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

    ;;use A as an index for which nametable to write to
	JSR SetNametableFromIndex
	TXA
	LSR A
	AND #$01
	BNE .copyScreenB
	MACROGetLabelPointer Screen_Copy, pointer_address
	JMP .setCounters
	
.copyScreenB:
	MACROGetLabelPointer ScreenB_Copy, pointer_address
	
	;;set pointer
	;; set counters
.setCounters:
	LDY #$00
	LDX #$00
	
	;;start loop

.outerloop:

.innerloop:

	LDA [table_address], y
	STA PPU_DATA
	STA [pointer_address],y
	INY
	CPY #$00
	BNE .innerloop

	INC pointer_address+1
	INC table_address+1
	
	INX
	CPX #$04
	BNE .outerloop
	RTS
	

DATA_LEN = temp1
WRITE_SETTINGS = temp2
	
ProcessPPUString:

	LDA PPU_PendingWrite
	BNE .continueProcess
	RTS
	
.continueProcess:
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
	
	LDA WRITE_SETTINGS	;check horizontal or vertical write
	AND #%10000000
	BEQ .checkRepeat
	ORA PPU_CTRL 
	STA PPU_CTRL 
	
	
.checkRepeat:
  LDA WRITE_SETTINGS
  AND #%01000000
  BEQ .checkTable
  
  LDA WRITE_SETTINGS
  AND #$3F
  STA DATA_LEN
  ;;the usual data length byte is now the repeatable byte
  LDX #$00
  
.repeatLoop:
  LDA [pointer_address], y
  STA PPU_DATA
  INX 
  CPX DATA_LEN
  BNE .repeatLoop
  INY
  JMP .outerloop
	
.checkTable:
	LDA WRITE_SETTINGS
	AND #%00100000
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
  ;;A will be the amount of sprites to load
  STA DATA_LEN
  ASL DATA_LEN
  ASL DATA_LEN
  
  LDY #$00              ; start at 0
  
.loop:
  LDA [table_address], y; load data from address (sprites +  x)
  STA SPRITE_DATA, y    ; store into RAM address ($0200 + x)
  INY                   ; X = X + 1
  CPY DATA_LEN             ; Compare X to hex $10, decimal 16
  BNE .loop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 16, keep going down   
  RTS


WriteToPPUString:

	LDX PPU_StringIdx
	CPX #PPU_STRINGMAX
	BEQ .finish
	
	STA PPU_String, x
	INC PPU_StringIdx
	INX
	LDA #$00
	STA PPU_String, x
		
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


SetNametableFromIndex:

  PHA
  LDA PPU_STATUS
  PLA
  ASL A
  TAX
  LDA NameTableMemList+1, x
  STA PPU_ADDR
  LDA NameTableMemList, x
  STA PPU_ADDR
  RTS
  
TurnOnSprites:
 
  LDA PPU_Mask
  ORA #%00010000
  STA PPU_Mask
  RTS
  
TurnOffSprites:
  
  LDA PPU_Mask
  AND #%11101111
  STA PPU_Mask
  RTS

UpdatePPUControl:

  LDA PPU_Control
  AND #$FC
  ORA PPU_NT
  STA PPU_CTRL
  LDA PPU_Mask
  STA PPU_MASK
  RTS
  
InitPPUControl:
  
  ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  ; enable sprites, enable background, no clipping on left side
  LDA #%10010000
  STA PPU_CTRL
  STA PPU_Control
  LDA #%00011110
  STA PPU_MASK
  STA PPU_Mask
  RTS
  
FadeOutPalettes:

;;take the current values, and decrement the lower nibbles
;;we can access from the palette copy 
;;we'll make this fade out one level per call
;;once all the palettes are blacked out we'll return true, so we'll keep the carry flag as a return result

;;go through the palette copy, decrement, make a raw data PPU string and add all the bytes into it
;;for any palette color already in the 0x range, change it to 0f to get black

  MACROGetLabelPointer Palette_Copy, table_address
;;palette copy address is now X accessable

  LDY #$00
  MACROAddPPUStringEntryRawData #$3F, #$00, #DRAW_HORIZONTAL, #$20  

  LDA #$00
  STA temp1
  
.loop:

  LDA [table_address], y
  CMP #$0F
  BEQ .addToString
  CMP #$10
  BCC .setBlack
  
  LDA #$80
  STA temp1
  
  LDA [table_address], y
  SEC
  SBC #$10
  JMP .setColor

.setBlack:

  LDA #$0F

.setColor:
  STA [table_address], y

.addToString:

  JSR WriteToPPUString

.incY:
  
  INY
  CPY #$20
  BNE .loop

  ASL temp1	;get carry out, if we have one

  RTS
  
FadeInPalettes:

;;need to be able to store off a target palette first
;;we can use the palette copy we make during the game mode change as the target
  RTS

NameTableMemList:
  .word $2000, $2400, $2800, $2C00
PalettesMemList:
  .word $3F00, $3F04, $3F08, $3F0C
  .word $3F10, $3F14, $3F18, $3F1C  
  
BLANK_TILE = $24
