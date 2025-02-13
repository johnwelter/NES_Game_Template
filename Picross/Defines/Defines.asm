;; define 0 page stuff here, and SRAM stuff if we have it

  .rsset $0000
  .include "Defines/GeneralVars.asm"
  .include "Defines/ControllerVars.asm"
  .include "Defines/PPUVariables.asm"
  .include "Defines/MapperVars.asm"
  .include "Defines/TitleVariables.asm"
  .include "Defines/GameVariables.asm"
  .include "External/SoundVariables_ZP.asm"

;; 0100 is the stack
;; 0200 is sprite ram
  .rsset $0300
  .include "External/SoundVariables.asm"
  .rsset $0400
  .rsset $0500
  .rsset $0600
  .rsset $0700
  .rsset $6000
  .include "Defines/ScreenStateVariables.asm"
  .rsset $7000
  .include "Defines/SaveVariables.asm"


;precompiled labels

  .include "SoundEnginePreComp.fns"
  ;.include "Picross.fns"
  