;;macro to load a full name table
;; \1 = index to double
;; all registers clobbered, as well as table_address
MACROGetDoubleIndex .macro

	LDA \1
	ASL A
	TAY
	
  .endm