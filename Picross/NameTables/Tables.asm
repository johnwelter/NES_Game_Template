Palettes:

  .word Title_Palette, Game_Palette, GameOver_Palette

NameTables:

  .word Title_Screens, Game_Screens, GameOver_Screens
  
NameTables2:

  .word Title_Second, Blank_Screen, Blank_Screen
  
Title_Screens:

  .word Title_Screen
  
Game_Screens:

  .word Game_5, Game_10, Game_15
  
GameOver_Screens:

  .word GameOver_Screen

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
  
Game_5: 

  .incbin "NameTables/Game_NT_5.nam"
  
Game_10:
  .incbin "NameTables/Game_NT_10.nam"
  
Game_15:
  .incbin "NameTables/Game_NT.nam"
  
GameOver_Screen:

  .incbin "NameTables/GameOver_NT.nam"
  
Blank_Screen:

  .incbin "NameTables/Blank_NT.nam"

Pause_Menu:
  .db $28,$2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a,$2a,$29
  .db $2b,$24,$1c,$0a,$1f,$0e,$62,$0e,$21,$12,$1d,$24,$3b
  .db $2b,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$3b
  .db $2b,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$3b
  .db $2b,$24,$24,$22,$0e,$1c,$24,$24,$17,$18,$24,$24,$3b
  .db $38,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$3a,$39

EndScreens:

  .word PuzzleClearLines, PuzzleSavedLines
  
PuzzleClearLines:

  .db $EA, $20
  .db $0D, $19,$1e,$23,$23,$15,$0e,$24,$0c,$15,$0e,$0a,$1b,$64
  .db $07, $1d,$12,$16,$0e,$61,$24,$24 ;print the time here as a separate call, similar to how it's printed in update game at 2131
  .db $0C, $17,$0e,$21,$1d,$24,$19,$1e,$23,$23,$15,$0e,$63
  .db $09, $24,$24,$22,$0e,$1c,$24,$24,$17,$18

PuzzleSavedLines:
  
  .db $2A, $21 
  .db $0D, $19,$1e,$23,$23,$15,$0e,$24,$1c,$0a,$1f,$0e,$0d,$64
  
SelectDefaultName:
 
  .db $47, $26 
  .db $10, $63,$63,$63,$63,$63,$63,$63,$63,$63,$63,$63,$63,$63,$63,$63,$63

SelectDefaultTime:

  .db $8F, $26 
DefaultTimeString:
  .db $05, $60,$60,$61,$60,$60


 
	