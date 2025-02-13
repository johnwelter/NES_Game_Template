sound_init:
    lda #$1F
    sta $4015   ;enable Square 1, Square 2, Triangle and Noise channels
    
    lda #$00
    sta sound_disable_flag  ;clear disable flag
    ;later, if we have other variables we want to initialize, we will do that here.
    lda #$FF
    sta sound_sq1_old   ;initializing these to $FF ensures that the first notes of the first song isn't skipped
    sta sound_sq2_old
se_silence:
    lda #$30
    sta soft_apu_ports      ;set Square 1 volume to 0
    sta soft_apu_ports+4    ;set Square 2 volume to 0
    sta soft_apu_ports+12   ;set Noise volume to 0
    lda #$80
    sta soft_apu_ports+8     ;silence Triangle
	lda #$00
	sta soft_apu_ports+17	 ;silence DPMC

    rts
    
sound_disable:
    lda #$00
    sta $4015   ;disable all channels
    lda #$01
    sta sound_disable_flag  ;set disable flag
    rts
    
;-------------------------------------
; load_sound will prepare the sound engine to play a song or sfx.
;   input:
;       A: song/sfx number to play
sound_load:
    sta sound_temp1         ;save song number
    asl a                   ;multiply by 2.  We are indexing into a table of pointers (words)
    tay
    lda song_headers, y     ;setup the pointer to our song header
    sta sound_ptr
    lda song_headers+1, y
    sta sound_ptr+1
    
    ldy #$00
    lda [sound_ptr], y      ;read the first byte: # streams
    sta sound_temp2         ;store in a temp variable.  We will use this as a loop counter: how many streams to read stream headers for
    iny
.loop:
    lda [sound_ptr], y      ;stream number
    tax                     ;stream number acts as our variable index
    iny
    
    lda [sound_ptr], y      ;status byte.  1= enable, 0=disable
    sta stream_status, x
    beq .next_stream        ;if status byte is 0, stream disabled, so we are done
    iny
    
    lda [sound_ptr], y      ;channel number
    sta stream_channel, x
    iny
    
    lda [sound_ptr], y      ;initial duty and volume settings
    sta stream_vol_duty, x
    iny
    
    lda [sound_ptr], y
    sta stream_ve, x
    iny
	
	;temp solution
	lda #pe_none
	sta stream_pe, x
	
	;temp solution
	lda #arp_none
	sta stream_arp, x
    
    lda [sound_ptr], y      ;pointer to stream data.  Little endian, so low byte first
    sta stream_ptr_LO, x
    iny
    
    lda [sound_ptr], y
    sta stream_ptr_HI, x
    iny
    
    lda [sound_ptr], y
    sta stream_tempo, x
    
    lda #$A0
    sta stream_ticker_total, x
    
    lda #$01
    sta stream_note_length_counter,x
    
    lda #$00
    sta stream_ve_index, x
	sta stream_pe_index, x
	sta stream_arp_index, x
    sta stream_loop1, x
    sta stream_note_offset, x
.next_stream:
    iny
    
    lda sound_temp1         ;song number
    sta stream_curr_sound, x
    
    dec sound_temp2         ;our loop counter
    bne .loop
    rts

;--------------------------
; sound_play_frame advances the sound engine by one frame
sound_play_frame:
    lda sound_disable_flag
    bne .done   ;if disable flag is set, don't advance a frame

    jsr se_silence  ;silence all channels.  se_set_apu will set volume later for all channels that are enabled.
                    ;the purpose of this subroutine call is to silence channels that aren't used by any streams.
    ldx #$00
.loop:
    lda stream_status, x
    and #$01    ;check whether the stream is active
    beq .endloop  ;if the stream isn't active, skip it
    
    ;add the tempo to the ticker total.  If there is a FF-> 0 transition, there is a tick
    lda stream_ticker_total, x
    clc
    adc stream_tempo, x
    sta stream_ticker_total, x
    bcc .set_buffer    ;carry clear = no tick.  if no tick, we are done with this stream
    
    dec stream_note_length_counter, x   ;else there is a tick. decrement the note length counter
    bne .set_buffer    ;if counter is non-zero, our note isn't finished playing yet
    lda stream_note_length, x   ;else our note is finished. reload the note length counter
    sta stream_note_length_counter, x
    
    jsr se_fetch_byte   ;read the next byte from the data stream
    
.set_buffer:
    jsr se_set_temp_ports   ;copy the current stream's sound data for the current frame into our temporary APU vars (soft_apu_ports)
.endloop:
    inx
    cpx #$08
    bne .loop
    jsr se_set_apu      ;copy the temporary APU variables (soft_apu_ports) to the real APU ports ($4000, $4001, etc)
.done:
    rts

;--------------------------
; se_fetch_byte reads one byte from a sound data stream and handles it
;   input: 
;       X: stream number    
se_fetch_byte:
    lda stream_ptr_LO, x
    sta sound_ptr
    lda stream_ptr_HI, x
    sta sound_ptr+1
    
    ldy #$00
.fetch:
    lda [sound_ptr], y
    bpl .note                ;if < #$80, it's a Note
    cmp #$A0
    bcc .note_length         ;else if < #$A0, it's a Note Length
.opcode:                     ;else it's an opcode
    ;do Opcode stuff
    jsr se_opcode_launcher
    iny                      ;next position in the data stream
    lda stream_status, x
    and #%00000001
    bne .fetch               ;after our opcode is done, grab another byte unless the stream is disabled
    rts                      ; in which case we quit  (explained below)
.note_length:
    ;do note length stuff
    and #%01111111          ;chop off bit7
    sty sound_temp1         ;save Y because we are about to destroy it
    tay
    lda note_length_table, y    ;get the note length count value
    sta stream_note_length, x
    sta stream_note_length_counter, x   ;stick it in our note length counter
    ldy sound_temp1         ;restore Y
    iny                     ;set index to next byte in the stream
    jmp .fetch              ;fetch another byte
.note:
    ;do Note stuff
    sta sound_temp2
    lda stream_channel, x
    cmp #NOISE
    bne .not_noise
    jsr se_do_noise
    jmp .reset_ve
.not_noise:
	cmp #DPMC
	bcc .not_dpmc
	jsr se_do_dpmc
	jmp .reset_ve
.not_dpmc:
    lda sound_temp2
    sty sound_temp1     ;save our index into the data stream
    clc
    adc stream_note_offset, x   ;add note offset
    asl a
    tay
	sta stream_note_idx, x
    lda note_table, y
    sta stream_note_LO, x
    lda note_table+1, y
    sta stream_note_HI, x
    ldy sound_temp1     ;restore data stream index
    
    ;check if it's a rest and modify the status flag appropriately

    jsr se_check_rest
.reset_ve:    
    lda #$00
    sta stream_ve_index, x  
	sta stream_pe_index, x
	sta stream_pe_delay, x
	sta stream_arp_index,x
.update_pointer:
    iny
    tya
    clc
    adc stream_ptr_LO, x
    sta stream_ptr_LO, x
    bcc .end
    inc stream_ptr_HI, x
.end:
    rts

se_do_noise:
    lda sound_temp2
    and #%00010000
    beq .mode0
    lda sound_temp2
    ora #%10000000      ;set bit 7 to set mode1
    sta sound_temp2
.mode0:
    lda sound_temp2
    sta stream_note_LO, x
    rts
	
se_do_dpmc:
	TXA
	PHA
	
	lda $4015
	AND #$0F
	sta $4015 ;DPCM disable
	
	lda sound_temp2		;load up sample index- we can cram in the pitch and keep ourselves to 6 samples (7 will be rest)
	CMP #$70
	BCS .leave

	AND #$0F
	sta $4010 ;pitch
	LDA #$7F
	sta $4011 ;temp = starting sample level
	lda sound_temp2
	AND #$F0
	LSR A
	LSR A
	LSR A
	LSR A
	TAX
	lda SampleStart,x
	sta $4012 ;X = sample number
	lda SampleLength,x
	sta $4013
	
	lda $4015
	AND #$0F
	ORA #$10
	STA $4015
.leave:
	PLA
	TAX

	rts
	
;--------------------------------------------------
; se_check_rest will read a byte from the data stream and
;       determine if it is a rest or not.  It will set or clear the current
;       stream's rest flag accordingly.
;       input:
;           X: stream number
;           Y: data stream index
se_check_rest:
    lda [sound_ptr], y  ;read the note byte again
    cmp #rest
    bne .not_rest
    lda stream_status, x
    ora #%00000010  ;set the rest bit in the status byte
    bne .store  ;this will always branch.  bne is cheaper than a jmp.
.not_rest:
    lda stream_status, x
    and #%11111101  ;clear the rest bit in the status byte
.store:
    sta stream_status, x
    rts
    
;-----------------------------------------
; se_opcode_launcher will read an address from the opcode jump table and indirect jump there.
;    input: A: opcode byte
;               Y: data stream position
;               X: stream number
se_opcode_launcher:
    sty sound_temp1         ;save y register, because we are about to destroy it
    sec
    sbc #$A0                ;turn our opcode byte into a table index by subtracting $A0
    asl a                   ;multiply by 2 because we index into a table of addresses (words)
    tay
    lda sound_opcodes, y    ;get low byte of subroutine address
    sta sound_ptr2
    lda sound_opcodes+1, y  ;get high byte
    sta sound_ptr2+1
    ldy sound_temp1         ;restore our y register
    iny                     ;set to next position in data stream (assume an argument)
    jmp [sound_ptr2]           ;indirect jump to our opcode subroutine    
    
;----------------------------------------------------
; se_set_temp_ports will copy a stream's sound data to the temporary apu variables
;      input:
;           X: stream number
se_set_temp_ports:

	cpx #MUSIC_DPMC
	bcc .contTempPorts
	rts
.contTempPorts:
    lda stream_channel, x
    asl a
    asl a
    tay
    
    jsr se_set_stream_volume
	
    
    lda #$08
    sta soft_apu_ports+1, y     ;sweep
    
	
	LDA stream_arp, x
	BEQ .updatePitch
	
	JSR se_set_stream_arpeggio
	JMP .leaveTempSet
	
.updatePitch:
    lda stream_note_LO, x
    sta soft_apu_ports+2, y     ;period LO
    
    lda stream_note_HI, x
    sta soft_apu_ports+3, y     ;period HI
	

	jsr se_set_stream_pitch

.leaveTempSet:
    rts    

;----------------------------------
;    
se_set_stream_volume:
	
    sty sound_temp1             ;save our index into soft_apu_ports (we are about to destroy y)
    
    lda stream_ve, x            ;which volume envelope?
    asl a                       ;multiply by 2 because we are indexing into a table of addresses (words)
    tay
    lda volume_envelopes, y     ;get the low byte of the address from the pointer table
    sta sound_ptr               ;put it into our pointer variable
    lda volume_envelopes+1, y   ;get the high byte of the address
    sta sound_ptr+1
    
.read_ve:
    ldy stream_ve_index, x      ;our current position within the volume envelope.
    lda [sound_ptr], y          ;grab the value.
    cmp #$FF
    bne .set_vol                ;if not FF, set the volume
    dec stream_ve_index, x      ;else if FF, go back one and read again
    jmp .read_ve                ;  FF essentially tells us to repeat the last
                                ;  volume value for the remainder of the note
.set_vol:
    sta sound_temp2             ;save our new volume value (about to destroy A)
    
    cpx #TRIANGLE               
    bne .squares                ;if not triangle channel, go ahead
    lda sound_temp2
    bne .squares                ;else if volume not zero, go ahead (treat same as squares)
    lda #$80
    bmi .store_vol              ;else silence the channel with #$80
.squares:
    lda stream_vol_duty, x      ;get current vol/duty settings
    and #$F0                    ;zero out the old volume
    ora sound_temp2             ;OR our new volume in.

.store_vol:
    ldy sound_temp1             ;get our index into soft_apu_ports
    sta soft_apu_ports, y       ;store the volume in our temp port
    inc stream_ve_index, x      ;set our volume envelop index to the next position

.rest_check:
    ;check the rest flag. if set, overwrite volume with silence value 
    lda stream_status, x
    and #%00000010
    beq .done                   ;if clear, no rest, so quit
    lda stream_channel, x
    cmp #TRIANGLE               ;if triangle, silence with #$80
    beq .tri                    ;else, silence with #$30
    lda #$30        
    bne .store                  ;this always branches.  bne is cheaper than a jmp
.tri:
    lda #$80
.store:    
    sta soft_apu_ports, y
.done:
    rts   
	
;---------------------------------------
;
se_set_stream_arpeggio:
    
	lda stream_status, x
    and #%00000010
	beq .continue
	rts
	
.continue:
    sty sound_temp1             ;save our index into soft_apu_ports (we are about to destroy y)
    
    lda stream_arp, x            ;which volume envelope?
    asl a                       ;multiply by 2 because we are indexing into a table of addresses (words)
    tay
    lda arpeggios, y     ;get the low byte of the address from the pointer table
    sta sound_ptr               ;put it into our pointer variable
    lda	arpeggios+1, y   ;get the high byte of the address
    sta sound_ptr+1
    
.read_arp:
    ldy stream_arp_index, x      ;our current position within the volume envelope.
    lda [sound_ptr], y          ;grab the value.
    cmp #$FF
    bne .set_arp                ;if not FF, set the volume
	LDA #$00
    STA stream_arp_index, x      ;else if FF, go back one and read again
    jmp .read_arp                ;  FF essentially tells us to repeat the last
                                ;  volume value for the remainder of the note
.set_arp:
    STA sound_temp2             ;save our new volume value (about to destroy A)
	LDA stream_note_idx, x
	CLC
	ADC sound_temp2
	STA sound_temp2
	
	
	LDY sound_temp1
	STX sound_temp1
	TAX 

	LDA note_table, x
	STA soft_apu_ports+2, y
	LDA note_table+1, x
	STA soft_apu_ports+3, y
	
	LDX sound_temp1
	
    inc stream_arp_index, x      ;set our volume envelop index to the next position
	
	TYA
	STA sound_temp1

    rts 
;--------------------------------------
;
se_set_stream_pitch:
    sty sound_temp1             ;save our index into soft_apu_ports (we are about to destroy y)
    
    lda stream_pe, x            ;which volume envelope?
    asl a                       ;multiply by 2 because we are indexing into a table of addresses (words)
    tay
    lda pitch_envelopes, y     ;get the low byte of the address from the pointer table
    sta sound_ptr               ;put it into our pointer variable
    lda pitch_envelopes+1, y   ;get the high byte of the address
    sta sound_ptr+1
	
	LDA stream_pe_delay, x
	;if not 0, decrement
	AND #$7F			;check if, without minus flag, the delay is 0
	BEQ .read_pe
	DEC stream_pe_delay, x
	RTS
    
.read_pe:
    ldy stream_pe_index, x      ;our current position within the volume envelope.
    lda [sound_ptr], y          ;grab the value.
    cmp #pe_loopLast
	BNE .notLoopLast
	dec stream_pe_index, x      ;else if loop last, go back one and read again
	jmp .read_pe 

.notLoopLast:
	cmp #pe_loopAll
	BNE .notLoopAll
	LDA #$00
	STA stream_pe_index, x
	jmp .read_pe
	
.notLoopAll:
	cmp #pe_loopPart
	BNE .notLoopPart
	iny
	lda stream_pe_index, x
	SEC
	SBC [sound_ptr], y
	STA stream_pe_index, x
	jmp .read_pe

.notLoopPart:
	cmp #pe_delay
	BNE .notLoopDelay
	LDA stream_pe_delay, x
	BMI .delayUsed	;negative, delay was already used this time
	iny
	lda [sound_ptr], y
	ORA #$80
	STA stream_pe_delay, x
	inc stream_pe_index, x
	jmp .finish_pitchShift
.delayUsed:
	inc stream_pe_index, x
	inc stream_pe_index, x
	jmp .read_pe
	
.notLoopDelay:
.set_pitch:

    sta stream_pe_offset, x      ;get current vol/duty settings
	STA sound_temp2
	LDY sound_temp1
	LDA sound_temp2
	BPL .add_pitch
	
.sub_pitch:
	
	EOR #$FF	;flip bits
	CLC
	ADC #$01	;add one - two's compliment
	STA sound_temp2
	
	LDA soft_apu_ports+2, y       
	SEC
	SBC sound_temp2
	STA soft_apu_ports+2, y
	LDA soft_apu_ports+3, y
	SBC #$00
	STA soft_apu_ports+3, y
	
	JMP .finish_pitchShift

.add_pitch:

    LDA soft_apu_ports+2, y       
	CLC
	ADC sound_temp2
	STA soft_apu_ports+2, y
	LDA soft_apu_ports+3, y
	ADC #$00
	STA soft_apu_ports+3, y
	
.finish_pitchShift:
    inc stream_pe_index, x      ;set our volume envelop index to the next position

.rest_check:
    ;check the rest flag. if set, overwrite volume with silence value 
    lda stream_status, x
    and #%00000010
    beq .done                   ;if clear, no rest, so quit
   
    LDA #$00
	STA stream_pe_offset, x
.done:
    rts    

;--------------------------
; se_set_apu copies the temporary RAM ports to the APU ports
se_set_apu:
.square1:
    lda soft_apu_ports+0
    sta $4000
    lda soft_apu_ports+1
    sta $4001
    lda soft_apu_ports+2
    sta $4002
    lda soft_apu_ports+3
    cmp sound_sq1_old       ;compare to last write
    beq .square2            ;don't write this frame if they were equal
    sta $4003
    sta sound_sq1_old       ;save the value we just wrote to $4003
.square2:
    lda soft_apu_ports+4
    sta $4004
    lda soft_apu_ports+5
    sta $4005
    lda soft_apu_ports+6
    sta $4006
    lda soft_apu_ports+7
    cmp sound_sq2_old
    beq .triangle
    sta $4007
    sta sound_sq2_old       ;save the value we just wrote to $4007
.triangle:
    lda soft_apu_ports+8
    sta $4008
    lda soft_apu_ports+10   ;there is no $4009, so we skip it
    sta $400A
    lda soft_apu_ports+11
    sta $400B
.noise:
    lda soft_apu_ports+12
    sta $400C
    lda soft_apu_ports+14   ;there is no $400D, so we skip it
    sta $400E
    lda soft_apu_ports+15
    sta $400F
    rts
    
   

	.include "External/sound_SongTable.asm"    ;our opcode subroutines, jump table and aliases
    
    .include "External/sound_opcodes.asm"    ;our opcode subroutines, jump table and aliases
    .include "External/note_table.i" ;period lookup table for notes
	.include "External/sound_EffectTables.asm"

BankSong:	;;label for bank song
