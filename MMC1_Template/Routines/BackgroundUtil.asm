;;macro to load all pallets in 1 go
;; table_address should be set in the preceding macro
;; y is clobbered
loadAllPal_impl:
  LDA PPU_STATUS            ; read PPU status to reset the high/low latch
  LDA #$3F
  STA PPU_ADDR            ; write the high byte of $3F00 address
  LDA #$00
  STA PPU_ADDR             ; write the low byte of $3F00 address
  LDY #$00              ; start out at 0
loadPalettesLoop:
  LDA [table_address], y        ; load data from address (palette + the value in x)
  STA PPU_DATA            ; write to PPU
  INY                   ; X = X + 1
  CPY #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE loadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
  RTS

loadFullBackground_impl:

	LDA PPU_STATUS             ; read PPU status to reset the high/low latch
	LDA #$20
	STA PPU_ADDR            ; write the high byte of $2000 address
	LDA #$00
	STA PPU_ADDR           ; write the low byte of $2000 address
	
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
	
SetTableAddress:
	
	;;A is low, X is high
	STA table_address
	STX table_address+1
	RTS
	
ChangeGameMode:

  STA game_mode
  STA game_mode_switching
  LDA #$00
  STA PPU_MASK    ; disable rendering- reenable on NMI when not updating
  JSR LoadGameModeBackground
  LDA #$00
  STA game_mode_switching
  
  ;; load the CHR bank for this mode
  JSR ResetMapper
  ;;remember, we're loading the SECOND set in each chr bank
  ;;so we'll take the index from the game mode chr table and add one mult 2
  LDX game_mode
  LDA gameModeInitCHRROM, x
  ASL A
  CLC 
  ADC #$01
  JSR LoadCHRBankB
  
  RTS
	
	
LoadGameModeBackground:

	MACROLoadAllPal game_mode
	MACROLoadFullBackground game_mode
	RTS
	
  
gameModeInitCHRROM:
	.db $00, $02, $02
