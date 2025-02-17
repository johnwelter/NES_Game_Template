  .bank 2
  .org $8000
  
  .include "Puzzles/B1.asm"

  .bank 3
  .org $A000
 
  .include "Puzzles/B1Tables.asm"
;puzzle sprites
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00
  .db $00, $00, $00, $00

  .incbin "SoundEnginePreComp.nes"
  .include "Music/Bank1.i"  ;holds the data for bank song
  
  .org $BFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial