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
  LDA gameModeInitCHRROMB, x
  ASL A
  CLC 
  ADC #$01
  JSR LoadCHRBankB
  
  JSR ResetMapper
  LDX game_mode
  LDA gameModeInitCHRROMA, x
  ASL A
  JSR LoadCHRBankA
  
  
  
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
	
  LDA #$00
  JSR LoadFullBackgroundFromTable
  
  LDY temp1
  MACROGetLabelPointer NameTables2, table_address
  JSR GetTableAtIndex
  
  LDA #$01
  JSR LoadFullBackgroundFromTable
  
  RTS
  
LoadGameModeSprites:

  MACROGetDoubleIndex game_mode  
  MACROGetLabelPointer Sprites, table_address
  JSR GetTableAtIndex
  LDY #$00
  LDA [table_address],y
  INC table_address
  JSR LoadSprites_impl
  
  RTS
  
gameModeInitCHRROMB:
	.db $00, $02, $02
gameModeInitCHRROMA:
	.db $00, $02, $02
	
