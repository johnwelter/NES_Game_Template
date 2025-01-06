UpdateGame:

  LDA NMI_locks
  BEQ .unlocked
  
  RTS
  
.unlocked:

  JSR DoUpdateGame
  RTS
  
DoUpdateGame:

  LDA mode_state
  JSR Dynamic_Jump
  
UpdateGameJumpTable:

  .word UpdateGameIntro
  .word UpdateGamePlay
  .word UpdateGameExit

UpdateGameIntro:
  
  INC mode_state
  RTS
  
UpdateGamePlay:

  MACROAddPPUStringEntryRawData $2065, DRAW_HORIZONTAL, #$01
  LDA time
  JSR WriteToPPUString
  
  LDA gamepadPressed
  BEQ .leave
  AND #GAMEPAD_START
  BNE .changeModeState
  BEQ .leave
  

.changeModeState:

    INC mode_state

.leave:
 
  RTS
  
UpdateGameExit:

  LDA #GAMEOVER_IDX
  JSR ChangeGameMode
  RTS
	
  
  
  
;; 	JSR ResetMapper
;;	INC currentCHRBank
;;	LDA currentCHRBank
;;	CMP #$03
;;	BNE .dontModCHR
	
;;	LDA #$00

;;.dontModCHR:
;;	STA currentCHRBank 
;;	;4kb switches- all the banks are seqential, so we gotta add 1 and mult by 2 for BG tiles
;;	ASL A
;;	CLC 
;;	ADC #$01
;;	JSR LoadCHRBankB
;;	
;;	JSR ResetMapper
;;	INC currentPRGBank
;;	LDA currentPRGBank
;;	CMP #$03
;;	BNE .dontModPRG
	
;;	LDA #$00
	
;;.dontModPRG:
;;	 STA currentPRGBank
;;	 JSR LoadPRGBank
 
;;	 JSR TestBankA
;;	 LDA mapperDebugVar
;;	 STA $6000
;;	 JMP .noInputDetected
	 
  