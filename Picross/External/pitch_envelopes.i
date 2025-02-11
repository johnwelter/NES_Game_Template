pitch_envelopes:
    .word se_pe_none
    .word se_pe_mod
	.word se_pe_sweep
	.word se_pe_bassKick

pe_loopLast = $80
pe_loopAll = $81
pe_loopPart = $82	;requires byte timer amount after
pe_delay = $83		;requires byte amount after - of negative, not yet reset. only allow if timer is currently 0

se_pe_none:
	.byte $00
	.byte pe_loopLast

se_pe_mod:

	.byte $00, pe_delay, $0A, $00, $00, $FE, $FE, $FC, $FC, $FE, $FE, $00, $00, $02, $02, $04, $04, $02, $02
	.byte pe_loopAll

se_pe_sweep:
	
	.byte $10, $0C, $08, $04, $00, $00, $FE, $FE, $FC, $FC, $FE, $FE, $00, $00, $02, $02, $04, $04, $02, $02
	.byte pe_loopPart, $10

se_pe_bassKick:
	.byte $90, $C0, $F0, $20, $50, $70
	.byte pe_loopLast

pe_none = $00
pe_mod = $01
pe_sweep = $02
pe_bassKick = $03

