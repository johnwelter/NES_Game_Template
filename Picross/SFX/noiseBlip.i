noiseBlip_header:
    .byte $01           ;1 stream
    
	.byte SFX_2     ;which stream
    .byte $01           ;enabled
    .byte NOISE     
    .byte $30           ;initial duty_vol
    .byte ve_tinyDecy ;volume envelope
    .word noiseBlip_noise   ;pointer to stream
    .byte $80           ;tempo
    
noiseBlip_noise:
    .byte sixteenth, $04
    .byte endsound