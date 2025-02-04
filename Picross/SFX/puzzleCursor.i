puzzleCursor_header:
    .byte $01           ;1 stream
    
    .byte SFX_2         ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte TRIANGLE      ;which channel
    .byte $80           ;on
    .byte ve_hiHat_decay  ;volume envelope
    .word puzzleCursor_square2 ;pointer to stream
    .byte $80           ;tempo
    
    
puzzleCursor_square2:
    .byte sixteenth, C6
    .byte endsound