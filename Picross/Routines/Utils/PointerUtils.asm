Dynamic_Jump:

  ASL A					;; double the index passed into A
  STX tempx
  STY tempy
  TAY
  INY  
  PLA
  STA jump_address
  PLA 
  STA jump_address+1		
  LDA [jump_address], y
  TAX
  INY
  LDA [jump_address], y
  STX jump_address
  STA jump_address+1
  LDX tempx
  LDY tempy
  JMP [jump_address]
  
GetTableAtIndex:

	LDA [table_address], y
	TAX
	INY
	LDA [table_address], y
	
SetTableAddress:
	
	;;A is hi, X is lo
	STX table_address
	STA table_address+1
	RTS