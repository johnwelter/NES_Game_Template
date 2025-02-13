bank0_header:
    .byte $05           ;4 streams
    
    .byte MUSIC_SQ1     ;which stream
    .byte $01           ;status byte (stream enabled)
    .byte SQUARE_1      ;which channel
    .byte $70           ;initial duty (01)
    .byte ve_long_decay ;volume envelope
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
	
	.byte MUSIC_DPMC
	.byte $01
	.byte DPMC
	.byte $30
	.byte ve_hiHat_decay
	.word bank0_dpcm  ;pointer to stream
    .byte $3A           ;tempo

    
bank0_square1:

	.byte pitch_envelope, pe_sweep
	.byte volume_envelope, ve_long_decay 
    .byte quarter, rest
	.byte d_eighth, D5
	.byte pitch_envelope, pe_mod
	.byte d_half_d_eight, C5
	.byte sixteenth, B4, C5
	.byte eighth, B4
	.byte sixteenth, Fs4
	.byte eighth, G4,  A4
	.byte sixteenth, B4
	.byte pitch_envelope, pe_sweep
	.byte d_eighth, Fs4
	.byte pitch_envelope, pe_mod
	.byte whole_quarter_sixteenth, A4
	.byte sixteenth, rest
	.byte Fs3, G3, Gs3, A3, Gs3, G3, Fs3
	
	.byte pitch_envelope, pe_sweep
	.byte quarter, rest
	.byte d_eighth, D5
	.byte pitch_envelope, pe_mod
	.byte d_half_d_eight, C5
	.byte sixteenth, B4, C5
	.byte eighth, B4
	.byte sixteenth, Fs4
	.byte eighth, G4,  E5
	.byte pitch_envelope, pe_sweep
	.byte sixteenth, G5
	.byte pitch_envelope, pe_mod
	.byte d_whole, Fs5
	.byte sixteenth, rest
	.byte Fs3, G3, A3, G3, A3, D4, Fs4
    
	.byte pitch_envelope, pe_sweep
	.byte quarter, rest
	.byte d_eighth, G5
	.byte pitch_envelope, pe_mod
	.byte d_half_d_eight, F5
	.byte sixteenth, E5, F5
	.byte eighth, E5
	.byte sixteenth, B4
	.byte eighth, C5,  D5
	.byte sixteenth, E5, D5 
	.byte eighth, B4, C5, A4, B4, G4 
	.byte sixteenth, C5, B4, G4, F4, D4
	.byte pitch_envelope, pe_sweep
	.byte eighth, F4
	.byte pitch_envelope, pe_mod
	.byte sixteenth, A4
	.byte pitch_envelope, pe_sweep
	.byte eighth, G4
	.byte pitch_envelope, pe_mod
	.byte sixteenth, C5
	.byte five_eighths, B4
	
	.byte pitch_envelope, pe_sweep
	.byte quarter, rest
	.byte d_eighth, D5
	.byte pitch_envelope, pe_mod
	.byte d_half_d_eight, C5
	.byte sixteenth, B4, C5
	.byte eighth, B4
	.byte sixteenth, Fs4
	.byte eighth, G4
	.byte pitch_envelope, pe_sweep
	.byte A4
	.byte pitch_envelope, pe_mod
	.byte sixteenth, G4
	.byte d_whole, Fs4
	.byte sixteenth, rest
	.byte Fs3, G3, A3, G3, A3, D4, Fs4
	
	;;bridge
	
	.byte d_eighth, A4, G4, Fs4
	.byte thirtysecond, Fs2, A5, G2, G5, Gs2, Fs5, A2
	.byte D5, Gs2, C5, G2, A4, Fs2, G4
	.byte d_eighth, F4, E4, D4, A3
	.byte eighth, C4
	.byte sixteenth, G3
	.byte whole_sixteenth, Fs3
	.byte half, rest
	.byte sixteenth, rest
	.byte sixteenth, Fs3, G3, A3, G3, A3, D4, Fs4
	
	.byte d_eighth, A4, G4, Fs4
	.byte thirtysecond, Fs2, A5, G2, G5, Gs2, Fs5, A2
	.byte D5, Gs2, C5, G2, A4, Fs2, G4
	.byte d_eighth, F4, E4, D4, A3
	.byte eighth, C4
	.byte sixteenth, G4
	.byte whole_sixteenth, Fs4
	.byte half, rest
	.byte sixteenth, rest
	.byte sixteenth, Fs3, G3, A3, G3, A3, D4, Fs4

	;; reach-around
	.byte pitch_envelope, pe_sweep
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, G4, G4
	.byte pitch_envelope, pe_mod
	.byte volume_envelope, ve_tgl_2
	.byte eighth, A4
	.byte volume_envelope, ve_tgl_1
	.byte thirtysecond, rest, F6
	.byte sixteenth, Fs6, D6, C6, A5, G5, Fs5, A5
	.byte eighth, G5
	.byte sixteenth, C5
	.byte eighth, F5
	.byte sixteenth, D5
	.byte eighth, G5
	.byte sixteenth, Fs5
	.byte eighth, A5
	.byte sixteenth, C5, G5, Fs5, C6, A5
	
	.byte pitch_envelope, pe_sweep
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, G4, G4
	.byte pitch_envelope, pe_mod
	.byte volume_envelope, ve_tgl_2
	.byte eighth, A4
	.byte volume_envelope, ve_tgl_1
	.byte thirtysecond, rest, Cs4
	.byte sixteenth, D4, Fs4, D5, A4, D5, Fs5
	.byte sixteenth, C6, A5, E5, A4, F5, C5, Fs4
	.byte sixteenth, G5, D5, A4, D5, A4, E4, G5, Fs5, C6, D6
	
	.byte pitch_envelope, pe_sweep
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, G4, G4
	.byte pitch_envelope, pe_mod
	.byte volume_envelope, ve_tgl_2
	.byte eighth, A4
	.byte volume_envelope, ve_tgl_1
	.byte thirtysecond, rest, F6
	.byte sixteenth, Fs6, D6, C6, A5, G5, Fs5, A5
	.byte eighth, G5
	.byte sixteenth, C5
	.byte eighth, F5
	.byte sixteenth, D5
	.byte eighth, G5
	.byte sixteenth, Fs5
	.byte eighth, A5
	.byte sixteenth, C5, G5, Fs5, C6, A5
	
	.byte pitch_envelope, pe_sweep
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, G4, G4
	.byte pitch_envelope, pe_mod
	.byte volume_envelope, ve_tgl_2
	.byte eighth, A4
	.byte volume_envelope, ve_long_decay 
	.byte d_quarter, rest
	.byte five_eighths, A4
	.byte volume_envelope, ve_tgl_1
	.byte sixteenth, rest
	.byte eighth, Fs4, G4, Gs4
	.byte sixteenth, A4

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
	.byte sixteenth, D2, G2, A2, D2 
	.byte eighth, D3
	.byte sixteenth, D2
	.byte d_quarter, C3
	.byte sixteenth, G2, A2, C3
	.byte D2, G2, A2, D2 
	.byte eighth, D3
	.byte sixteenth, D2
	.byte eighth, C3 
	.byte sixteenth, Fs2, G2, Gs2, A2, Gs2, G2, Fs2
	
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
	.byte D2, G2, A2, D2 
	.byte eighth, D3
	.byte sixteenth, D2
	.byte d_quarter, C3
	.byte sixteenth, G2, A2, C3
	.byte D2, G2, A2, D2 
	.byte eighth, D3
	.byte sixteenth, D2
	.byte eighth, C3 
	.byte sixteenth, Fs2, G2, A2, G2, A2, D3, Fs3 
	
	.byte G2, C3, D3, G2 
	.byte eighth, G3
	.byte sixteenth, G2
	.byte d_quarter, F3
	.byte sixteenth, C3, D3, F3
	.byte sixteenth, G2, C3, D3, G2 
	.byte eighth, G3
	.byte sixteenth, G2
	.byte d_quarter, F3
	.byte sixteenth, F3, E3, D3
	.byte G2, C3, D3, G2 
	.byte eighth, G3
	.byte sixteenth, G2
	.byte d_quarter, F3
	.byte sixteenth, C3, D3, F3
	.byte sixteenth, G2, C3, D3, G2 
	.byte eighth, G3
	.byte sixteenth, G2
	.byte d_quarter, F3
	.byte sixteenth, F3, E3, D3

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
	.byte D2, G2, A2, D2 
	.byte eighth, D3
	.byte sixteenth, D2
	.byte d_quarter, C3
	.byte sixteenth, G2, A2, C3
	.byte D2, G2, A2, D2 
	.byte eighth, D3
	.byte sixteenth, D2
	.byte eighth, C3 
	.byte sixteenth, Fs2, G2, A2, G2, A2, D3, Fs3 
	
	;;bridge
	
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, C4, B3, A3
	.byte sixteenth, Fs2, G2, Gs2, A2, Gs2, G2, Fs2
	.byte d_eighth, A3, G3, Fs3, D3
	.byte eighth, F3
	.byte sixteenth, D3
	.byte d_half_eighth, C3
	.byte volume_envelope, ve_tgl_1
	.byte sixteenth, G2, A2, C3
	.byte D2, G2, A2, D2 
	.byte eighth, D3
	.byte sixteenth, D2
	.byte eighth, C3 
	.byte sixteenth, Fs2, G2, A2, G2, A2, D3, Fs3
	
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, C4, B3, A3
	.byte sixteenth, Fs2, G2, Gs2, A2, Gs2, G2, Fs2
	.byte d_eighth, A3, G3, Fs3, D3
	.byte eighth, F3
	.byte sixteenth, C4
	.byte d_half_eighth, D4
	.byte volume_envelope, ve_tgl_1
	.byte sixteenth, G2, A2, C3
	.byte D2, G2, A2, D2 
	.byte eighth, D3
	.byte sixteenth, D2
	.byte eighth, C3 
	.byte sixteenth, Fs2, G2, A2, G2, A2, D3, Fs3
	
	;; reach-around
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, E4, E4
	.byte volume_envelope, ve_tgl_2
	.byte eighth, Fs4
	.byte volume_envelope, ve_battlekid_2
	.byte d_sixteenth, rest
	.byte thirtysecond, F6
	.byte sixteenth, Fs6, D6, C6, A5, G5, Fs5, A5
	.byte eighth, G5
	.byte sixteenth, C5
	.byte eighth, F5
	.byte sixteenth, D5
	.byte eighth, G5
	.byte sixteenth, Fs5
	.byte eighth, A5
	.byte sixteenth, C5, G5, Fs5, C6 
	
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, E4, E4
	.byte volume_envelope, ve_tgl_2
	.byte eighth, Fs4
	.byte volume_envelope, ve_battlekid_2
	.byte d_sixteenth, rest
	.byte thirtysecond, Cs4
	.byte sixteenth, D4, Fs4, D5, A4, D5, Fs5
	.byte sixteenth, C6, A5, E5, A4, F5, C5, Fs4
	.byte sixteenth, G5, D5, A4, D5, A4, E4, G5, Fs5, C6
	
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, E4, E4
	.byte volume_envelope, ve_tgl_2
	.byte eighth, Fs4
	.byte volume_envelope, ve_battlekid_2
	.byte d_sixteenth, rest
	.byte thirtysecond, F6
	.byte sixteenth, Fs6, D6, C6, A5, G5, Fs5, A5
	.byte eighth, G5
	.byte sixteenth, C5
	.byte eighth, F5
	.byte sixteenth, D5
	.byte eighth, G5
	.byte sixteenth, Fs5
	.byte eighth, A5
	.byte sixteenth, C5, G5, Fs5, C6 
	
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, E4, E4
	.byte volume_envelope, ve_tgl_2
	.byte eighth, Fs4
	.byte volume_envelope, ve_long_decay 
	.byte d_quarter, rest
	.byte arpeggio, arp_lowerThird
	.byte five_eighths, C5
	.byte volume_envelope, ve_tgl_1
	.byte arpeggio, arp_none
	.byte sixteenth, rest
	.byte eighth, Fs2, G2, Gs2
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
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte d_quarter, C4
	.byte sixteenth, G3, A3, C4
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte eighth, C4
	.byte sixteenth, Fs3, G3, Gs3, A3, Gs3, G3, Fs3
	
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte d_quarter, C4
	.byte sixteenth, G3, A3, C4
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte eighth, C4, Fs3, G3, Gs3
	.byte sixteenth, A3
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte d_quarter, C4
	.byte sixteenth, G3, A3, C4
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte eighth, C4
	.byte sixteenth, Fs3, G3, A3, G3, A3, D4, Fs4
	
	.byte G3, C4, D4, G3 
	.byte eighth, G4
	.byte sixteenth, G3
	.byte d_quarter, F4
	.byte sixteenth, C4, D4, F4
	.byte sixteenth, G3, C4, D4, G3 
	.byte eighth, G4
	.byte sixteenth, G3
	.byte d_quarter, F4
	.byte sixteenth, F4, E4, D4
	.byte G3, C4, D4, G3 
	.byte eighth, G4
	.byte sixteenth, G3
	.byte d_quarter, F4
	.byte sixteenth, C4, D4, F4
	.byte sixteenth, G3, C4, D4, G3 
	.byte eighth, G4
	.byte sixteenth, G3
	.byte d_quarter, F4
	.byte sixteenth, F4, E4, D4

	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte d_quarter, C4
	.byte sixteenth, G3, A3, C4
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte eighth, C4, Fs3, G3, Gs3
	.byte sixteenth, A3
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte d_quarter, C4
	.byte sixteenth, G3, A3, C4
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte eighth, C4
	.byte sixteenth, Fs3, G3, A3, G3, A3, D4, Fs4
	
	;;bridge
	
	.byte sixteenth
	.byte C5, G4, C4, G4, D4, G3, A3, D4, A4
	.byte A6, G6, Fs6, D6, C6, A5, G5
	.byte F4, C4, F3, E4, A3, Ds3, D4, A3, D3
	.byte D3, D4, D3, A3, D3, F3, C3
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte d_quarter, C4
	.byte sixteenth, G3, A3, C4
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte eighth, C4
	.byte sixteenth, Fs3, G3, A3, G3, A3, D4, Fs4
	.byte C5, G4, C4, G4, D4, G3, A3, D4, A4
	.byte A6, G6, Fs6, D6, C6, A5, G5
	.byte F4, C4, F3, E4, A3, Ds3, D4, A3, D3
	.byte D3, D4, D3, A3, D3, F3, C3
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte d_quarter, C4
	.byte sixteenth, G3, A3, C4
	.byte D3, G3, A3, D3 
	.byte eighth, D4
	.byte sixteenth, D3
	.byte eighth, C4
	.byte sixteenth, Fs3, G3, A3, G3, A3, D4, Fs4
	
	;; reach-around
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, C3, C3
	.byte volume_envelope, ve_tgl_2
	.byte eighth, D3
	.byte volume_envelope, ve_tgl_1
	.byte d_eighth, rest
	.byte sixteenth, D3, D3, D4
	.byte five_sixteenths, rest
	.byte sixteenth, D3, D3, D4
	.byte five_sixteenths, rest
	.byte sixteenth, D3, D3, D4
	.byte eighth, rest
	
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, C3, C3
	.byte volume_envelope, ve_tgl_2
	.byte eighth, D3
	.byte volume_envelope, ve_tgl_1
	.byte d_eighth, rest
	.byte sixteenth, D3, D3, D4
	.byte five_sixteenths, rest
	.byte sixteenth, D3, D3, D4
	.byte five_sixteenths, rest
	.byte sixteenth, D3, D3, D4
	.byte eighth, rest
		
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, C3, C3
	.byte volume_envelope, ve_tgl_2
	.byte eighth, D3
	.byte volume_envelope, ve_tgl_1
	.byte d_eighth, rest
	.byte sixteenth, D3, D3, D4
	.byte five_sixteenths, rest
	.byte sixteenth, D3, D3, D4
	.byte five_sixteenths, rest
	.byte sixteenth, D3, D3, D4
	.byte eighth, rest
	
	.byte volume_envelope, ve_long_decay 
	.byte d_eighth, C3, C3
	.byte volume_envelope, ve_tgl_2
	.byte eighth, D3
	.byte volume_envelope, ve_long_decay
	.byte d_quarter, rest
	.byte five_eighths, A2
	.byte volume_envelope, ve_tgl_1
	.byte sixteenth, rest
	.byte eighth, Fs3, G3, Gs3
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

bank0_dpcm:
	.byte quarter, $0B, $1B, $0B, $1B
	.byte $0B, d_eighth, $1B, sixteenth, $1B 
	.byte eighth, $0B, $0B, quarter, $1B
	.byte loop
	.word bank0_dpcm