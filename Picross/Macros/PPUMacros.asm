;;macro to load a full name table
;; \1 = address to set
;; \2 = flags to set
;; all registers clobbered, as well as table_address
MACROSetPPUControl .macro

  LDA #\1  ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA PPU_CTRL
  LDA #\2   ; enable sprites, enable background, no clipping on left side
  STA PPU_MASK
	
  .endm
  
MACROSetPPUAddress .macro

  LDA PPU_STATUS             ; read PPU status to reset the high/low latch
  LDA #HIGH(\1)
  STA PPU_ADDR            ; write the high byte of $2000 address
  LDA #LOW(\1)
  STA PPU_ADDR           ; write the low byte of $2000 address
  
  .endm
  

MACROAddPPUStringEntryRawData .macro

  LDA #$01
  STA PPU_PendingWrite
  LDA \1
  JSR WriteToPPUString
  LDA \2
  JSR WriteToPPUString
  LDA \3
  JSR WriteToPPUString
  LDA \4
  JSR WriteToPPUString
  
  .endm
  
MACROAddPPUStringEntryTable .macro
 
  LDA #$01
  STA PPU_PendingWrite
  LDA \1
  JSR WriteToPPUString
  LDA \2
  JSR WriteToPPUString
  LDA #$40
  ORA \3
  JSR WriteToPPUString
  LDA #LOW(\4)
  JSR WriteToPPUString
  LDA #HIGH(\4)
  JSR WriteToPPUString
 
  .endm


