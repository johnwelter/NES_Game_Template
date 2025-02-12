SQUARE_1 = $00 ;these are channel constants
SQUARE_2 = $01
TRIANGLE = $02
NOISE = $03

MUSIC_SQ1 = $00 ;these are stream # constants
MUSIC_SQ2 = $01 ;stream # is used to index into variables
MUSIC_TRI = $02
MUSIC_NOI = $03
SFX_1     = $04
SFX_2     = $05
    
sound_disable_flag  .rs 1   ;a flag variable that keeps track of whether the sound engine is disabled or not. 
sound_temp1 .rs 1           ;temporary variables
sound_temp2 .rs 1
sound_sq1_old .rs 1  ;the last value written to $4003
sound_sq2_old .rs 1  ;the last value written to $4007
soft_apu_ports .rs 16

;reserve 6 bytes, one for each stream
stream_curr_sound .rs 6     ;current song/sfx loaded
stream_status .rs 6         ;status byte.   bit0: (1: stream enabled; 0: stream disabled)
stream_channel .rs 6        ;what channel is this stream playing on?
stream_ptr_LO .rs 6         ;low byte of pointer to data stream
stream_ptr_HI .rs 6         ;high byte of pointer to data stream
stream_ve .rs 6             ;current volume envelope
stream_ve_index .rs 6       ;current position within the volume envelope
stream_vol_duty .rs 6       ;stream volume/duty settings
stream_note_idx .rs 6
stream_note_LO .rs 6        ;low 8 bits of period for the current note on a stream
stream_note_HI .rs 6        ;high 3 bits of period for the current note on a stream 
stream_tempo .rs 6          ;the value to add to our ticker total each frame
stream_ticker_total .rs 6   ;our running ticker total.
stream_note_length_counter .rs 6
stream_note_length .rs 6
stream_loop1 .rs 6          ;loop counter
stream_note_offset .rs 6
stream_pe .rs 6             ;current volume envelope
stream_pe_index .rs 6       ;current position within the volume envelope
stream_pe_offset .rs 6
stream_pe_delay .rs 6
stream_arp .rs 6
stream_arp_index .rs 6
stream_arp_offset .rs 6