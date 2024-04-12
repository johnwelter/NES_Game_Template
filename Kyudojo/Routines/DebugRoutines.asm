DebugDraws:
  ;;draw a debug tile at the top right corner
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$20
  STA $2006             ; write the high byte of $2000 address
  LDA #$42
  STA $2006             ; write the low byte of $2000 address
  
  LDX #$00

drawDebugMouseData:
  LDA mouseData+1, x
  LSR A
  LSR A
  LSR A
  LSR A
  STA $2007
  LDA mouseData+1, x
  AND #$0F
  STA $2007
  LDA #$24
  STA $2007
  INX
  CPX #$04
  BNE drawDebugMouseData
  
  RTS
  