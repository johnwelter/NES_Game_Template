drawImg_header:
    .byte $04           ;4 streams
    
    .byte MUSIC_SQ1     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte SQUARE_1      ;which channel
    .byte $70           ;initial duty (01)
    .byte ve_tgl_2       ;volume envelope
    .word drawImg_square1 ;pointer to stream
    .byte $B9             ;tempo
    
    .byte MUSIC_SQ2     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte SQUARE_2      ;which channel
    .byte $70           ;initial duty (10)
    .byte ve_tgl_2     ;volume envelope
    .word drawImg_square2   ;pointer to stream
    .byte $B9           ;tempo
    
    .byte MUSIC_TRI     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte TRIANGLE      ;which channel
    .byte $80           ;initial volume (on)
    .byte ve_tgl_2      ;volume envelope
    .word drawImg_noise     ;pointer to stream
    .byte $B9         ;tempo
    
    .byte MUSIC_NOI     ;which stream
    .byte $00           ;enabled

    
drawImg_square1:
    .byte thirtysecond
    .byte rest
    .byte eighth
    .byte C4, D4, E4, Fs4, Gs4, As4
    .byte D4, E4, Fs4, Gs4, As4, C5
    .byte E4, Fs4, Gs4, As4, C5, D5
    .byte Fs4, Gs4, As4, C5, D5, E5
    .byte Gs4, As4, C5, D5, E5, Fs5
    .byte As4, C5, D5, E5, Fs5, Gs5
.loopPoint:
    .byte C5, D5, E5, Fs5, Gs5, As5
    .byte loop
	.word .loopPoint
    
    
drawImg_square2:
    .byte eighth
    .byte C4, D4, E4, Fs4, Gs4, As4
    .byte D4, E4, Fs4, Gs4, As4, C5
    .byte E4, Fs4, Gs4, As4, C5, D5
    .byte Fs4, Gs4, As4, C5, D5, E5
    .byte Gs4, As4, C5, D5, E5, Fs5
    .byte As4, C5, D5, E5, Fs5, Gs5
.loopPoint:
    .byte C5, D5, E5, Fs5, Gs5, As5
    .byte loop
    .word .loopPoint
    
drawImg_tri:

    .byte whole
	.byte rest
    .byte loop
    .word drawImg_tri
    
drawImg_noise:

    .byte whole
	.byte rest
    .byte loop
    .word drawImg_noise