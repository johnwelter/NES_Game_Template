
;;Byte0
;;Y position of top of sprite
;;Sprite data is delayed by one scanline; 
;;you must subtract 1 from the sprite's 
;;Y coordinate before writing it here. 
;;Hide a sprite by moving it down offscreen, 
;;by writing any values between #$EF-#$FF here. 
;;Sprites are never displayed on the first line of the picture, 
;;and it is impossible to place a sprite partially off the top of the screen.

;;Byte 1
;;Tile index number
;;For 8x8 sprites, this is the tile number of this sprite within the pattern table selected in bit 3 of PPUCTRL ($2000).
;;For 8x16 sprites (bit 5 of PPUCTRL set), the PPU ignores the pattern table selection and selects a pattern table from bit 0 of this number.
;;76543210
;;||||||||
;;|||||||+- Bank ($0000 or $1000) of tiles
;;+++++++-- Tile number of top of sprite (0 to 254; bottom half gets the next tile)

;;Byte 2
;;Attributes
;;76543210
;;||||||||
;;||||||++- Palette (4 to 7) of sprite
;;|||+++--- Unimplemented (read 0)
;;||+------ Priority (0: in front of background; 1: behind background)
;;|+------- Flip sprite horizontally
;;+-------- Flip sprite vertically

;;Byte 3
;;X position of left side of sprite.
;;X-scroll values of $F9-FF results in parts of the 
;;sprite to be past the right edge of the screen, thus invisible.
;;It is not possible to have a sprite partially visible on the left edge. 
;;Instead, left-clipping through PPUMASK ($2001) can be used to simulate this effect.
Sprites:
	.word Title_Sprites, Game_Sprites, GameOver_Sprites

Title_Sprites:
	.db $85,$00,$00,$E8
Game_Sprites:
	.db $62,$00,$03,$72
GameOver_Sprites:
	.db $00,$00,$00,$00