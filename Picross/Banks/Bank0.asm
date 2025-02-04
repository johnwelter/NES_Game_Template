

  .bank 0
  .org $8000
  
  .include "Puzzles/house.asm" 
  .include "Puzzles/test.asm"
  .include "Puzzles/test5.asm"
  .include "Puzzles/test10.asm"
  .include "Puzzles/myGlyph.asm"

  .bank 1
  .org $A000
;puzzles
  .word test5, test10, myGlyph, test, test, test, test, test, test
  .word house, test, test, test, test, test, test, test, test
  .word house, test, test, test, test, test, test, test, test
;puzzle names
  .word test5Name, test10Name, myGlyphName, testName, testName, testName, testName, testName, testName
  .word houseName, testName, testName, testName, testName, testName, testName, testName, testName
  .word houseName, testName, testName, testName, testName, testName, testName, testName, testName
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
  .include "Music/Bank0.i"  ;holds the data for bank song

  .org $BFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
