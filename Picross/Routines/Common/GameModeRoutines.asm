ChangeGameMode:
  STA game_mode
  LDA #$00
  STA mode_state
  JSR ClearPPUString
  JSR LoadGameModeScreen
  RTS
  
LoadGameModeScreen:

  MACROSetFlags NMI_locks, BGLOAD_NMI_LOCK
  
  LDA #$00
  STA PPU_MASK    ; disable rendering- reenable on NMI when not updating

  JSR LoadGameModeBackground
  JSR LoadGameModeSprites

  MACROClearFlags NMI_locks, BGLOAD_NMI_LOCK

  
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
	
  MACROGetDoubleIndex game_mode
  STY temp1
	
  MACROGetLabelPointer Palettes, table_address
  JSR GetTableAtIndex

  JSR LoadFullPaletteFromTable
	
  LDY temp1
  MACROGetLabelPointer NameTables, table_address
  JSR GetTableAtIndex
	
  JSR LoadFullBackgroundFromTable
  
  RTS
  
LoadGameModeSprites:

  MACROGetDoubleIndex game_mode  
  MACROGetLabelPointer Sprites, table_address
  JSR GetTableAtIndex
  JSR LoadSprites_impl
  
  RTS
  
gameModeInitCHRROM:
	.db $00, $02, $02