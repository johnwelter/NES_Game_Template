PPU_Control			.rs 1
PPU_Mask			.rs 1
PPU_ScrollX			.rs 1
PPU_ScrollY			.rs 1
PPU_ScrollNT		.rs 1	;first two bits
PPU_NT				.rs 1

PPU_PendingWrite	.rs 1
PPU_StringIdx 		.rs 1
PPU_String 			.rs 128

PPU_STRINGMAX = $4F ;up to size of a full nametable, I think

SPRITE_YPOS = $00
SPRITE_ID   = $01
SPRITE_XPOS = $03
SPRITE_DATA = $0200

PPU_CTRL = $2000
PPU_MASK = $2001
PPU_STATUS = $2002
OAM_LO = $2003
OAM_DATA = $2004
PPU_SCROLL = $2005
PPU_ADDR = $2006
PPU_DATA = $2007
OAM_HI = $4014

DRAW_VERTICAL = $80
DRAW_HORIZONTAL = $00

SPRITE_0_MASK = %01000000