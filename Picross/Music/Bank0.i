bank0_header:
    .byte $04           ;4 streams
    
    .byte MUSIC_SQ1     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte SQUARE_1      ;which channel
    .byte $70           ;initial duty (01)
    .byte ve_tgl_1      ;volume envelope
    .word bank0_square1 ;pointer to stream
    .byte $3A           ;tempo
    
    .byte MUSIC_SQ2     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte SQUARE_2      ;which channel
    .byte $70           ;initial duty (10)
    .byte ve_tgl_1      ;volume envelope
    .word bank0_square2 ;pointer to stream
    .byte $3A           ;tempo
    
    .byte MUSIC_TRI     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte TRIANGLE      ;which channel
    .byte $80           ;initial volume (on)
    .byte ve_tgl_1      ;volume envelope
    .word bank0_tri     ;pointer to stream
    .byte $3A           ;tempo
    
    .byte MUSIC_NOI     ;which stream
    .byte $01           ;enabled
    .byte NOISE     
    .byte $30           ;initial duty_vol
    .byte ve_hiHat_decay ;volume envelope
    .word bank0_noise   ;pointer to stream
    .byte $3A           ;tempo

    
bank0_square1:

    .byte whole
	.byte rest
    .byte loop
    .word bank0_square1

bank0_square2:

	.byte sixteenth, D2, G2, A2, D2 
	.byte eighth, D3
	.byte sixteenth, D2
	.byte d_quarter, C3
	.byte sixteenth, G2, A2, C3
	.byte D2, G2, A2, D2 
	.byte eighth, D3
	.byte sixteenth, D2
	.byte eighth, C3, Fs2, G2, Gs2
	.byte sixteenth, A2
    .byte loop
    .word bank0_square2
    
bank0_tri:

	.byte sixteenth, D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte d_quarter, C4
	.byte sixteenth, G3, A3, C4
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte eighth, C4, Fs3, G3, Gs3
	.byte sixteenth, A3
    .byte loop
    .word bank0_tri
    
bank0_noise:
    .byte sixteenth, $04, $04, $04, $04
	.byte volume_envelope, ve_drum_decay 
    .byte sixteenth, $04
	.byte volume_envelope, ve_hiHat_decay
    .byte sixteenth, $04, $04, $04, $04
    .byte volume_envelope, ve_drum_decay 
    .byte sixteenth, $04
	.byte volume_envelope, ve_hiHat_decay
    .byte sixteenth, $04, $04
	.byte volume_envelope, ve_drum_decay 
    .byte sixteenth, $04
	.byte volume_envelope, ve_hiHat_decay
	.byte sixteenth, $04, $04, $04
    .byte loop
    .word bank0_noise