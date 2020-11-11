\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE I/O LOADER (PART 2) SOURCE
\
\ 6502 Second Processor Elite was written by Ian Bell and David Braben and is
\ copyright Acornsoft 1985
\
\ The code on this site is identical to the version released on Ian Bell's
\ personal website at http://www.elitehomepage.org/
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ ******************************************************************************

C% = &2000
L% = C%
D% = &D000
LC% = &8000-C%
OSWRCH = &FFEE
OSBYTE = &FFF4
OSWORD = &FFF1
SCLI = &FFF7
ZP = &90
P = &92
Q = &93
YY = &94
T = &95
Z1 = ZP
Z2 = P
FF = &FF

CODE% = &2000
LOAD% = &2000

ORG CODE%

\ ******************************************************************************
\       Name: MVE
\ ******************************************************************************

MACRO MVE S%, D%, PA%
  LDA #(S%MOD256)
  STA Z1
  LDA #(S%DIV256)
  STA Z1+1
  LDA #(D%MOD256)
  STA Z2
  LDA #(D%DIV256)
  STA Z2+1
  LDX #PA%
  JSR MVBL
ENDMACRO

\ ******************************************************************************
\       Name: Elite loader (Part 1 of 2)
\ ******************************************************************************

.ENTRY

 MVE DIALS, &7000, &E \Move Dials bit dump to screen
\MVE DATE, &6000, &1
 MVE ASOFT, &4200, &1
 MVE ELITE, &4600, &1
 MVE CpASOFT, &6C00, &1

 LDX #(MESS2 MOD256)
 LDY #(MESS2 DIV256)
 JSR SCLI \*RUN I-CODE

 LDX #(MESS3 MOD256)
 LDY #(MESS3 DIV256)
 JMP SCLI \*RUN P-CODE

\ ******************************************************************************
\       Name: MESS2
\ ******************************************************************************

.MESS2

 EQUS "R.I.CODE"
 EQUB 13

\ ******************************************************************************
\       Name: MESS3
\ ******************************************************************************

.MESS3

 EQUS "R.P.CODE"
 EQUB 13

\ ******************************************************************************
\       Name: MVBL
\ ******************************************************************************

.MVPG

 LDY #0

.MPL

 LDA (Z1),Y
 STA (Z2),Y
 DEY 
 BNE MPL
 RTS 

.MVBL

 JSR MVPG
 INC Z1+1
 INC Z2+1
 DEX 
 BPL MVBL
 RTS 

\ ******************************************************************************
\       Name: Elite loader (Part 2 of 2)
\ ******************************************************************************

.DIALS

INCBIN "binaries/P.DIALS2P.bin"

.DATE

INCBIN "binaries/P.DATE2P.bin"

.ASOFT

INCBIN "binaries/Z.ACSOFT.bin"

.ELITE

INCBIN "binaries/Z.ELITE.bin"

.CpASOFT

INCBIN "binaries/Z.(C)ASFT.bin"

\ ******************************************************************************
\
\ Save output/ELITEa.bin
\
\ ******************************************************************************

PRINT "S.ELITEa ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/ELITEa.bin", CODE%, P%, LOAD%
