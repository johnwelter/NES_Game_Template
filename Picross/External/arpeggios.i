arpeggios:
	.word se_arp_none
    .word se_arp_lowerThird

se_arp_none:
	.byte $00
	.byte $FF

se_arp_lowerThird:
	.byte $00, $00, $01, $01
	.byte $FF

arp_none = $00
arp_lowerThird = $01



