UpdateGame:
  ;;move the mouse cursor around

	LDA mouseData+1
	AND #$70
	BNE .leaveEarly
	
  
.leaveEarly:

  RTS