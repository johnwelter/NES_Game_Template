bank1_header:
    .byte 8          ;6 streams
    
    .byte MUSIC_SQ1
    .byte $00
	
	.byte MUSIC_SQ2
	.byte $00
	
    .byte MUSIC_TRI    ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte TRIANGLE      ;which channel
    .byte $80           ;initial duty (01)
    .byte ve_hiHat_decay ;volume envelope
    .word bank1_triangle ;pointer to stream
    .byte $50           ;tempo
	
	.byte MUSIC_NOI
	.byte $00
	
	.byte SFX_1
	.byte $00
	
	.byte SFX_2
	.byte $00
	
	.byte MUSIC_DPMC
	.byte $00
	
	.byte SFX_DPMC
	.byte $00


    
    
bank1_triangle:

	.byte pitch_envelope, pe_bassKick
	.byte eighth
	.byte C5, C5
	.byte sixteenth
	.byte A4, A4, A4, rest
	.byte F4, F4, F4, rest
	.byte quarter
	.byte C4

	.byte loop
    .word bank1_triangle