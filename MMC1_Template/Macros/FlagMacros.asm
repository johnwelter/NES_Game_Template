;;macro to load a full name table
;; \1 = address to set
;; \2 = flags to set
;; all registers clobbered, as well as table_address
MACROSetFlags .macro

  LDA \1
  ORA #\2
  STA \1
	
  .endm
  
MACROClearFlags .macro

  LDA #\2
  EOR #$FF
  AND \1  
  STA \1

  .endm