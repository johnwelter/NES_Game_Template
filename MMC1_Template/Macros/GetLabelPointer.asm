;;macro to load a full name table
;; \1 = label we want address of
;; \2 = address to store address to
;; all registers clobbered, as well as table_address
MACROGetLabelPointer .macro

	LDA #HIGH(\1)
	LDX #LOW(\1)
	
	STX \2
	STA \2+1
	
  .endm