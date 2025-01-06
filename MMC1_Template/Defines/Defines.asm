;; define 0 page stuff here, and SRAM stuff if we have it

  .rsset $0000
  .include "Defines/GeneralVars.asm"
  .include "Defines/ControllerVars.asm"
  .include "Defines/PPUVariables.asm"
  .include "Defines/MapperVars.asm"
;; 0100 is the stack
;; 0200 is sprite ram
  .rsset $0300
  .rsset $0400
  .rsset $0500
  .rsset $0600
  .rsset $0700
  .rsset $6000
  .include "Defines/SaveVariables.asm"
  .include "Defines/ScreenStateVariables.asm"

