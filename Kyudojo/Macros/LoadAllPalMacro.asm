;;macro to load all pallets in 1 go
;; \1 = label to start at
;; A, X, and tableAddress are clobbered here, Y is clobbered in the implementation
MACROLoadAllPal .macro

	LDY \1
	TYA
	ASL A
	TAY
	LDA (Palettes), y
	INY
	LDX (Palettes), y
	JSR SetTableAddress
	JSR loadAllPal_impl
	
  .endm