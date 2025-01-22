song1_header:
    .byte $04           ;4 streams
    
    .byte MUSIC_SQ1     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte SQUARE_1      ;which channel
    .byte $70           ;initial duty (01)
    .byte ve_tgl_1      ;volume envelope
    .word song1_square1 ;pointer to stream
    .byte $53           ;tempo
    
    .byte MUSIC_SQ2     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte SQUARE_2      ;which channel
    .byte $B0           ;initial duty (10)
    .byte ve_tgl_2      ;volume envelope
    .word song1_square2 ;pointer to stream
    .byte $53           ;tempo
    
    .byte MUSIC_TRI     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte TRIANGLE      ;which channel
    .byte $80           ;initial volume (on)
    .byte ve_tgl_2      ;volume envelope
    .word song1_tri     ;pointer to stream
    .byte $53           ;tempo
    
    .byte MUSIC_NOI     ;which stream
    .byte $01           ;enabled
    .byte NOISE     
    .byte $30           ;initial duty_vol
    .byte ve_drum_decay ;volume envelope
    .word song1_noise   ;pointer to stream
    .byte $53           ;tempo

    
song1_square1:

    .byte whole    
    .byte rest
	.byte loop
	.word song1_square1
    
    
song1_square2:
    .byte eighth
    .byte C4, D4, E4, Fs4, Gs4, As4
    .byte D4, E4, Fs4, Gs4, As4, C5
    .byte E4, Fs4, Gs4, As4, C5, D5
    .byte Fs4, Gs4, As4, C5, D5, E5
    .byte Gs4, As4, C5, D5, E5, Fs5
    .byte As4, C5, D5, E5, Fs5, Gs5
    .byte C5, D5, E5, Fs5, Gs5, As4
    .byte loop
    .word song1_square2
    
song1_tri:

    .byte whole
	.byte rest
    .byte loop
    .word song1_tri
    
song1_noise:

    .byte whole
	.byte rest
    .byte loop
    .word song1_noise