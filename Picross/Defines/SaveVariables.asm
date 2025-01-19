hasContinue .rs 1
solutionCount		.rs 1
nonSolutionCount	.rs 1
GameTime			.rs 4	;in order - second, ten second, minute, 10 minute - max out at 99 minutes
bank_index	.rs 1
puzzle_index .rs 1
;we can save these for the continue
;on a continue- we just need to load the back ground as it was
;we'll save out data for the puzzles- just need to know if it's 1) complete and 2) the time
;we can do that in 4 bytes each, so 324 bytes
puzzle_clear_bank0 .rs 108
puzzle_clear_bank1 .rs 108
puzzle_clear_bank2 .rs 108

