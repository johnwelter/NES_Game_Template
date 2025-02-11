bank1_header:
    .byte $01           ;4 streams
    
    .byte MUSIC_TRI    ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte TRIANGLE      ;which channel
    .byte $80           ;initial duty (01)
    .byte ve_hiHat_decay ;volume envelope
    .word bank1_square1 ;pointer to stream
    .byte $50           ;tempo
    
    
bank1_square1:

	.byte pitch_envelope, pe_bassKick
	.byte eighth
	.byte C5, C5
	.byte sixteenth
	.byte A4, A4, A4, rest
	.byte F4, F4, F4, rest
	.byte quarter
	.byte C4

	.byte loop
    .word bank1_square1