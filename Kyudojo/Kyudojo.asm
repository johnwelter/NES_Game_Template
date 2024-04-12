;;**************************;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  KYUDOJO - CATFORT2024   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;**************************;;

;;;; iNES header info ;;;;

 .include "Defines/Header.asm"
  LIST

;;;; Variables and Macros ;;;;

  .include "Defines/Constants.asm"
  .include "Defines/RamDefines.asm"
  .include "Macros/Macros.asm"

;;**************************;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;       PRG ROM            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;**************************;; 

  .bank 0
  .org $C000 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     Initialization       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .include "Routines/Init.asm"


  LDA #TITLE_IDX
  JSR ChangeGameMode

LoadSprites:
  LDX #$00              ; start at 0
LoadSpritesLoop:
  LDA Pointer, x        ; load data from address (sprites +  x)
  STA SPRITE_DATA, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$05              ; Compare X to hex $10, decimal 16
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 16, keep going down   

  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000

  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     Main Program         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Forever:

  INC sleeping

.loop
  LDA sleeping
  BNE .loop

  JSR Dynamic_Jump
  JSR CallDynamicSubroutine

  JMP Forever     ;jump back to Forever, infinite loop
  
;; dynamic jump table

JumpTable:

  .word UpdateTitle
  .word UpdateGame
  .word UpdateGameOver
  
Dynamic_Jump:

  ;;load up the label from the table above
  LDA game_mode
  ASL A
  TAY
  LDX (JumpTable), y
  INY
  LDA (JumpTable), y
  STX jump_address
  STA jump_address+1
  RTS
  
CallDynamicSubroutine:
  JMP [jump_address]
  ;;RTS is called in the subroutine

  
  .include "States/UpdateTitle.asm"
  .include "States/UpdateGame.asm"
  .include "States/UpdateGameOver.asm"
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     Routines             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  
  .include "Routines/BackgroundUtil.asm"
  
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     NMI                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .include "Routines/NMI.asm"
  
;;**************************;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;       PRG ROM DATA       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;**************************;; 
  
  .bank 1
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
  
  .bank 2
  .org $0000
  .incbin "CHRROM/Kyudojo.chr"   ;includes 8KB graphics file from SMB1