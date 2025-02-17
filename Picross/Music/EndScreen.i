endScreen_header:
    .byte $05           ;5 streams
    
    .byte MUSIC_SQ1     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte SQUARE_1      ;which channel
    .byte $70           ;initial duty (01)
    .byte ve_blip_echo  ;volume envelope
    .word endScreen_square1 ;pointer to stream
    .byte $3A           ;tempo
    
    .byte MUSIC_SQ2     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte SQUARE_2      ;which channel
    .byte $B0           ;initial duty (10)
    .byte ve_blip_echo  ;volume envelope
    .word endScreen_square2 ;pointer to stream
    .byte $3A           ;tempo
    
    .byte MUSIC_TRI     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte TRIANGLE      ;which channel
    .byte $80           ;initial volume (on)
    .byte ve_tgl_1      ;volume envelope
    .word endScreen_tri     ;pointer to stream
    .byte $3A           ;tempo
    
    .byte MUSIC_NOI     ;which stream
    .byte $01           ;enabled
    .byte NOISE     
    .byte $30           ;initial duty_vol
    .byte ve_hiHat_decay ;volume envelope
    .word endScreen_noise   ;pointer to stream
    .byte $3A           ;tempo
	
	.byte MUSIC_DPMC
	.byte $00

    
endScreen_square1:

    .byte quarter
	.byte Gs4
	.byte eighth
	.byte Gs4, Fs4
	.byte half, rest
	.byte quarter
	.byte E4
	.byte eighth
	.byte E4, Fs4
	.byte half, rest
	
	.byte quarter
	.byte As4
	.byte eighth
	.byte As4, Gs4
	.byte half, rest
	.byte eighth
	.byte Fs4, Gs4, Fs4, F4
	.byte Cs3, Gs3, F4, Gs4
	
    
    .byte loop                              ;infinite loop
    .word endScreen_square1

    
endScreen_square2:

    .byte eighth
	.byte F4, Gs3, F4, Ds4
	.byte half, rest
	.byte eighth
	.byte Cs4, Fs3, Cs4, Ds4
	.byte half, rest

	.byte eighth
	.byte Cs5, Fs4, Cs5, B4
	.byte half, rest
	.byte eighth
	.byte A4, B4, A4, Gs4
	.byte Gs3, Ds4, Gs4, C5
    .byte loop
    .word endScreen_square2
    
endScreen_tri:

	.byte quarter
	.byte Cs4
	.byte eighth
	.byte Cs4, B3, rest
	.byte B2, B3, B2
	.byte quarter
	.byte A3
	.byte eighth
	.byte A3, B3, rest
	.byte B2, B3, B2
	
	.byte quarter
	.byte Ds4
	.byte eighth
	.byte Ds4, Cs4, rest
	.byte Cs3, Cs4, Cs3
	.byte quarter
	.byte B3
	.byte eighth
	.byte B3, Cs4, rest
	.byte Cs3, Cs4, Cs3
	
	.byte loop
    .word endScreen_tri
    
endScreen_noise:

    .byte eighth, $04, $04
	.byte volume_envelope, ve_drum_decay 
    .byte eighth, $04
	.byte volume_envelope, ve_hiHat_decay
	.byte eighth, $04

    .byte loop
    .word endScreen_noise