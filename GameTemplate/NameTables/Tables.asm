sprites:
     ;vert tile attr horiz
  .db $80, $32, $00, $80   ;sprite 0
  .db $80, $33, $00, $88   ;sprite 1
  .db $88, $34, $00, $80   ;sprite 2
  .db $88, $35, $00, $88   ;sprite 3


TITLE_IDX = $00
GAME_IDX = $01
GAMEOVER_IDX = $02


Palettes:

  .word Title_Palette, Game_Palette, GameOver_Palette

NameTables:

  .word Title_Screen, Game_Screen, GameOver_Screen

Title_Palette:

  .incbin "NameTables/Title_PAL.pal"
  
Game_Palette:

  .incbin "NameTables/Game_PAL.pal"
  
GameOver_Palette:

  .incbin "NameTables/GameOver_PAL.pal"
  
Title_Screen:

  .incbin "NameTables/Title_NT.nam"
  
Game_Screen: 

  .incbin "NameTables/Game_NT.nam"
  
GameOver_Screen:

  .incbin "NameTables/Game_NT.nam"
  

  
 
	