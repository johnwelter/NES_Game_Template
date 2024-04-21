  .inesprg 4  ; 1x 16KB PRG code
  .ineschr 4   ; 1x  8KB CHR data
  .inesmap 1   ; mapper 0 = NROM, no bank swapping
  ;.inesmir 1   ; background mirroring
  ;the mirroring doens't really matter with the MMC1- but we DO want SRAM... for the hell of ot!
  .inesmir 2
     