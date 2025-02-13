;;********************************;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  MMC1 Template - CATFORT2024   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;********************************;;

;;;; iNES header info ;;;;

 .include "Defines/Header.asm"
  LIST	  ;; compiler directive- creates a useful file that shows relation between ASM and ROM, ophis21 wishes

;;;; Variables and Macros ;;;;

  .include "Defines/Defines.asm"
  .include "Macros/Macros.asm"

;;**************************;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;       PRG ROM            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;**************************;; 

  .include "Banks/Bank0.asm"
  .include "Banks/Bank1.asm"
  .include "Banks/Bank2.asm"

  .bank 6
  .org $C000 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     Initialization       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .include "Routines/Common/Init.asm"

  jsr sound_init
    
  LDA #TITLE_IDX
  LDX #$00
  JSR ChangeGameMode
  JSR InitPPUControl
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     Main Program         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Forever:

  INC sleeping

.loop
  LDA sleeping
  BNE .loop

  INC time  
  LDA pauseState
  BNE .skipScaleUpdate
  INC scaledTime
.skipScaleUpdate:
  JSR GameLoop


  JMP Forever     ;jump back to Forever, infinite loop
  
;; dynamic jump table

GameLoop:

  MACROCallDynamicJump game_mode
  ;; we'll pop the return address here as the table index, so 
  ;; the routine we pick will return us to whatever called Game Loop
  ;; when it returns

GameLoopJumpTable:

  .word UpdateTitle
  .word UpdateGame
  .word UpdateGameOver
  

  ;;RTS is called in the subroutine

  
  .include "Routines/Game_States/UpdateTitle.asm"
  .include "Routines/Game_States/UpdateGame.asm"
  .include "Routines/Game_States/UpdateGameOver.asm"
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     Routines             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  .include "Routines/Common/GameModeRoutines.asm"
  .include "Routines/Utils/PointerUtils.asm"
  .include "Routines/Utils/PPUUtils.asm"
  .include "Routines/Utils/MapperUtils.asm"
  .include "Routines/Game_Routines/ScreenEffects.asm"
  
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     NMI                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .include "Routines/Common/NMI.asm"
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    AUDIO                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;.include "External/sound_engine.asm"
	;;test out DPCM here?

	.ds (64-*)&63
sample0:						;MOTHER bass kick
	.incbin "DMC/sample0.dmc"
sample0End:
	.ds (64-*)&63
sample1:						;MOTHER snare
	.incbin "DMC/sample1.dmc"
sample1End:

SampleStart:
	.db low(sample0 >> 6)
	.db low(sample1 >> 6)

SampleLength:
	.db low((sample0End - sample0) >> 4)
	.db low((sample1End - sample1) >> 4)

;;**************************;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;       PRG ROM DATA       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;**************************;; 
  
  .bank 7
  .org $E000

  .include "NameTables/Tables.asm"
  .include "Sprites/Sprites.asm"

  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
  
;;**************************;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      CHR ROM DATA        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;**************************;; 
  
  .bank 8
  .org $0000
  .incbin "CHRROM/Bank0.chr"   ;includes 8KB graphics file from SMB1
  
  .bank 9
  .org $0000
  .incbin "CHRROM/Bank1.chr"
  
  .bank 10
  .org $0000
  .incbin "CHRROM/Bank2.chr"
  
  .bank 11
  .org $0000
  .incbin "CHRROM/Bank3.chr"