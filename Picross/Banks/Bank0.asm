  .bank 0
  .org $8000
  
  .include "Puzzles/house.asm" 
  .include "Puzzles/test.asm"

  .bank 1
  .org $A000
  
  .word house, test
  
  .org $BFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
