temp1  			.rs 1
temp2  			.rs 1
temp3  			.rs 1
temp4  			.rs 1
temp5			.rs 1
temp6			.rs 1
tempx 			.rs 1
tempy 			.rs 1
time 			.rs 1
sleeping 		.rs 1
game_mode  		.rs 1
mode_state		.rs 1
NMI_locks 		.rs 1
game_locks 		.rs 1
pointer_address .rs 2
table_address  	.rs 2
jump_address  	.rs 2

;game modes
TITLE_IDX = $00
GAME_IDX = $01
GAMEOVER_IDX = $02

;locks for input and rendering
BGLOAD_NMI_LOCK = %00000001
EFFECT_GAME_LOCK = %00000001



