  .bank 4
  .org $8000
  
  .include "Puzzles/cat.asm"

  .bank 5
  .org $A000
  
;puzzles
  .word cat, cat, cat, cat, cat, cat, cat, cat, cat 
  .word cat, cat, cat, cat, cat, cat, cat, cat, cat 
  .word cat, cat, cat, cat, cat, cat, cat, cat, cat
;puzzle names
  .word catName, catName, catName, catName, catName, catName, catName, catName, catName 
  .word catName, catName, catName, catName, catName, catName, catName, catName, catName 
  .word catName, catName, catName, catName, catName, catName, catName, catName, catName
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
;bank song, A0D8
  .include "Music/Bank2.i"  ;holds the data for bank song
  .org $BFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial