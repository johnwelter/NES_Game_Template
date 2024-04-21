;;macro to load a full name table
;; \1 = label to start at
;; all registers clobbered, as well as table_address
MACROLoadFullBackground .macro

	LDY \1
	TYA
	ASL A
	TAY
	LDA (NameTables), y
	INY
	LDX (NameTables), y
	JSR SetTableAddress
	JSR loadFullBackground_impl
  
  .endm