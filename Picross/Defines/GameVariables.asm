PUZZLE_TABLE = $A000
NAMES_TABLE = $A01B
SPRITES_TABLE = $A036

puzzle_address		.rs 2
clues_address		.rs 2
pause_address		.rs 2
copy_address	    .rs 2
pause_draw_address  .rs 2
clue_start_address	.rs 2
clue_draw_address 	.rs 2
clueTableIndex 		.rs 1
clueLineIndex 		.rs 1
clueOffsetShift		.rs 1
clueDrawAdd		  	.rs 1
clueDrawOffset		.rs 2
clueDrawDecSize		.rs 1
clueParity 			.rs 1
mouse_location		.rs 2
mouse_index			.rs 2
currentPaintTile	.rs 1
solutionCount		.rs 1
nonSolutionCount	.rs 1
pauseState			.rs 1
holdTimer			.rs 1
GameTime			.rs 4	;in order - second, ten second, minute, 10 minute - max out at 99 minutes
