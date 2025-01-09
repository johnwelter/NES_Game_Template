Palettes:

  .word Title_Palette, Game_Palette, GameOver_Palette

NameTables:

  .word Title_Screen, Game_Screen, GameOver_Screen
  
NameTables2:

  .word Title_Second, Blank_Screen, Blank_Screen

Title_Palette:

  .incbin "NameTables/Title_PAL.pal"
  .incbin "NameTables/Title_PAL.pal"
  
Game_Palette:

  .incbin "NameTables/Game_PAL.pal"
  .incbin "NameTables/Game_PAL.pal"
  
GameOver_Palette:

  .incbin "NameTables/GameOver_PAL.pal"
  .incbin "NameTables/GameOver_PAL.pal"
  
Title_Screen:

  .incbin "NameTables/Title_NT.nam"
  
Title_Second:

  .incbin "NameTables/Title_PuzzMen_NT.nam"
  
Game_Screen: 

  .incbin "NameTables/Game_NT.nam"
  
GameOver_Screen:

  .incbin "NameTables/GameOver_NT.nam"
  
Blank_Screen:

  .incbin "NameTables/Blank_NT.nam"

  

  
 
	