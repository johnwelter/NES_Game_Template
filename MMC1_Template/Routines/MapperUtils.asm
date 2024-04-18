MAPPERCONTROL = $80
CHRBANK1 = $A0
CHRBANK2 = $C0
PRGBANK = $E0

ResetMapper:
  inc ResetMapper
  RTS
  
;;now, set up the controls for the mapper
;;4bit0
;;-----
;;CPPMM
;;|||||
;;|||++- Mirroring (0: one-screen, lower bank; 1: one-screen, upper bank;
;;|||               2: vertical; 3: horizontal)
;;|++--- PRG ROM bank mode (0, 1: switch 32 KB at $8000, ignoring low bit of bank number;
;;|                         2: fix first bank at $8000 and switch 16 KB bank at $C000;
;;|                         3: fix last bank at $C000 and switch 16 KB bank at $8000)
;;+----- CHR ROM bank mode (0: switch 8 KB at a time; 1: switch two separate 4 KB banks)
   
SetMapperControls:
  ;;A = controls
  TAX
  LDA #MAPPERCONTROL
  STA mapper_address+1
  TXA
  JSR SendMapperCommand
  RTS

LoadPRGBank:

	;;A is the desired PRG number
	TAX
	LDA #PRGBANK
	STA mapper_address+1
	TXA
	JSR SendMapperCommand
	RTS
	
LoadCHRBankA:
	;;A is the desired CHR bank
	TAX
	LDA #CHRBANK1
	STA mapper_address+1
	TXA
	JSR SendMapperCommand
	RTS
	
LoadCHRBankB:
	;;A is the desired CHR bank
	TAX
	LDA #CHRBANK2
	STA mapper_address+1
	TXA
	JSR SendMapperCommand
	RTS
	
SendMapperCommand:

	LDY #$00
	
	STA [mapper_address], y
	LSR A
	STA [mapper_address], y
	LSR A
	STA [mapper_address], y
	LSR A 
	STA [mapper_address], y
	LSR A
	STA [mapper_address], y
	
	RTS
	
  
