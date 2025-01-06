;;macro to load a full name table
;; \1 = address to set
;; \2 = flags to set
;; all registers clobbered, as well as table_address
MACROCallDynamicJump .macro

  LDA \1
  JSR Dynamic_Jump
	
  .endm