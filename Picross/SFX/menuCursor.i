menuCursor_header:
    .byte $01           ;1 stream
    
    .byte SFX_1         ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte SQUARE_2      ;which channel
    .byte $70           ;duty (01)
    .byte ve_hiHat_decay  ;volume envelope
    .word menuCursor_square2 ;pointer to stream
    .byte $80           ;tempo
    
    
menuCursor_square2:
    .byte sixteenth, C6
    .byte endsound