;this is our pointer table.  Each entry is a pointer to a song header                
song_headers:
	
    .word song0_header
	.word BankSong
	.word menu_header
    .word drawImg_header  ;The Guardian Legend Boss song
	.word endScreen_header
	.word menuCursor_header
	.word puzzleCursor_header
	.word noiseBlip_header
		
    .include "External/song0.i"  ;holds the data for song 0 (header and data streams)
	.include "Music/Menu.i"  ;holds the data for song 1
    .include "Music/puzzleSolvedDrawImage.i"  ;holds the data for song 1
	.include "Music/EndScreen.i"
	.include "SFX/menuCursor.i"  ;holds the data for song 1
	.include "SFX/puzzleCursor.i"  ;holds the data for song 1
	.include "SFX/noiseBlip.i" 