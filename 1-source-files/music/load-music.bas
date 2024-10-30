MODE7
tstaddr = &8008
values = &90
unique = &80
RomSel = &FE30
romNumber = &8E : REM Set to address of .musicRomNumber
fromAddr = &80  : REM We can reuse unique block by this point

PRINT"6502 Co-pro Elite (Compendium version)"
PRINT"======================================"
PRINT'"Based on the Acornsoft SNG45 release"
PRINT"of Elite by Ian Bell and David Braben"
PRINT"Copyright (c) Acornsoft 1985"
PRINT'"Flicker-free routines, bug fixes and"
PRINT"music integration by Mark Moxon"
PRINT'"Sound routines by Kieran Connell and"
PRINT"Simon Morris"
PRINT'"Original music by Aidan Bell and Julie"
PRINT"Dunn (c) D. Braben and I. Bell 1985,"
PRINT"ported from the C64 by Negative Charge"
PRINT'"Sideways RAM detection and loading"
PRINT"routines by Tricky and J.G.Harston"

REM Find 16 values distinct from the 16 rom values and each other and save the original rom values
DIM CODE &1000
FOR P = 0 TO 2 STEP 2
P%=CODE
[OPT P
SEI
JSR ldaF4               \\ LDA &F4 \\ Store &F4 on stack
PHA
LDY #15                 \\ Unique values (-1) to find
TYA                     \\ A can start anywhere less than 256-64 as it just needs to allow for enough numbers not to clash with rom, tst and uninitialised tst values
.next_val
LDX #15                 \\ Sideways bank
ADC #1                  \\ Will inc mostly by 2, but doesn't matter
.next_slot
JSR stxF4               \\ STX &F4
JSR stxRomSel           \\ STX RomSel
JSR cmpTstaddr          \\ CMP tstaddr
BEQ next_val
CMP unique,X            \\ Doesn't matter that we haven't checked these yet as it just excludes unnecessary values, but is safe
BEQ next_val
DEX
BPL next_slot
STA unique,Y
JSR ldxTstaddr          \\ LDX tstaddr
STX values,Y
DEY
BPL next_val
LDX #0                  \\ Try to swap each rom value with a unique test value
.swap
JSR stxF4               \\ STX &F4
JSR stxRomSel           \\ STX RomSel set RomSel as it will be needed to read, but is also sometimes used to select write
LDA unique,X
JSR staTstaddr          \\ STA tstaddr
INX
CPX #16
BNE swap
LDY #16                 \\ Count matching values and restore old values - reverse order to swapping is safe
LDX #15
.tst_restore
JSR stxF4               \\ STX &F4
JSR stxRomSel           \\ STX RomSel
JSR ldaTstaddr          \\ LDA tstaddr
CMP unique,X            \\ If it has changed, but is not this value, it will be picked up in a later bank
BNE not_swr
LDA values,X
JSR staTstaddr          \\ STA tstaddr
DEY
STX values,Y
.not_swr
DEX
BPL tst_restore
STY values
PLA                     \\ Restore original value of &F4
JSR staF4               \\ STA &F4
JSR staRomSel           \\ STA RomSel \\ Restore original ROM
CLI
RTS

.stxRomSel              \\ STX RomSel in I/O
STX romSelBlock+4
PHA
TXA:PHA
TYA:PHA
LDA #6
LDX #romSelBlock MOD256
LDY #romSelBlock DIV256
JSR &FFF1
PLA:TAY
PLA:TAX
PLA
RTS

.staRomSel              \\ STA RomSel in I/O
STA romSelBlock+4
PHA
TXA:PHA
TYA:PHA
LDA #6
LDX #romSelBlock MOD256
LDY #romSelBlock DIV256
JSR &FFF1
PLA:TAY
PLA:TAX
PLA
RTS

.staTstaddr             \\ Write A to tstaddr in I/O
STA tstaddrBlock+4
PHA
TXA:PHA
TYA:PHA
LDA #6
LDX #tstaddrBlock MOD256
LDY #tstaddrBlock DIV256
JSR &FFF1
PLA:TAY
PLA:TAX
PLA
RTS

.ldaTstaddr             \\ LDA tstaddr in I/O
PHA
TXA:PHA
TYA:PHA
LDA #5
LDX #tstaddrBlock MOD256
LDY #tstaddrBlock DIV256
JSR &FFF1
PLA:TAY
PLA:TAX
PLA
LDA tstaddrBlock+4
RTS

.ldxTstaddr             \\ LDX tstaddr in I/O
PHA
TXA:PHA
TYA:PHA
LDA #5
LDX #tstaddrBlock MOD256
LDY #tstaddrBlock DIV256
JSR &FFF1
PLA:TAY
PLA:TAX
PLA
LDX tstaddrBlock+4
RTS

.cmpTstaddr             \\ LDX tstaddr in I/O
PHA
TXA:PHA
TYA:PHA
LDA #5
LDX #tstaddrBlock MOD256
LDY #tstaddrBlock DIV256
JSR &FFF1
PLA:TAY
PLA:TAX
PLA
CMP tstaddrBlock+4
RTS

.ldaF4                  \\ LDA &F4 in I/O
PHA
TXA:PHA
TYA:PHA
LDA #5
LDX #f4Block MOD256
LDY #f4Block DIV256
JSR &FFF1
PLA:TAY
PLA:TAX
PLA
LDA f4Block+4
RTS

.staF4                  \\ STA &F4 in I/O
STA f4Block+4
PHA
TXA:PHA
TYA:PHA
LDA #6
LDX #f4Block MOD256
LDY #f4Block DIV256
JSR &FFF1
PLA:TAY
PLA:TAX
PLA
RTS

.stxF4                  \\ STX &F4 in I/O
STX f4Block+4
PHA
TXA:PHA
TYA:PHA
LDA #6
LDX #f4Block MOD256
LDY #f4Block DIV256
JSR &FFF1
PLA:TAY
PLA:TAX
PLA
RTS

.staFE30                \\ STA &FE30 in I/O
STA fe30Block+4
LDA #6
LDX #fe30Block MOD256
LDY #fe30Block DIV256
JMP &FFF1

.setRomNumber           \\ STA romNumber in I/O
LDA bank
STA romNumberBlock+4
LDA #6
LDX #romNumberBlock MOD256
LDY #romNumberBlock DIV256
JMP &FFF1

.SRLOAD
JSR ldaF4
PHA
LDA bank
JSR staF4
JSR staFE30
.SR1
LDY #0
LDA (fromAddr),Y
STA toBlock+4
LDA #6
LDX #toBlock MOD256
LDY #toBlock DIV256
JSR &FFF1
INC fromAddr
INC toBlock
BNE SR1
INC fromAddr+1
INC toBlock+1
LDA toBlock+1
CMP #&C0
BNE SR1
PLA
JSR staF4
JSR staFE30
RTS

.bank
EQUB 0

.romSelBlock
EQUD RomSel
EQUD 0

.tstaddrBlock
EQUD tstaddr
EQUD 0

.f4Block
EQUD &F4
EQUD 0

.fe30Block
EQUD &FE30
EQUD 0

.romNumberBlock
EQUD romNumber
EQUD 0

.toBlock
EQUD &8000
EQUD 0
]
NEXT
CALL CODE
N%=16-?&90
IF N%=0 THEN PRINT'"Can't run:";CHR$129;"no sideways RAM detected":END
PRINT'"Detected ";16-?&90;" sideways RAM bank";
IF N% > 1 THEN PRINT "s";
REM IF N% > 0 THEN FOR X% = ?&90 TO 15 : PRINT;" ";X%?&90; : NEXT
?bank=?(&90+?&90) : REM Store bank number
CALL setRomNumber : REM STORE RAM BANK USED SOMEWHERE IN ZERO PAGE
PRINT'"Loading music into RAM bank ";?bank;"...";
*LOAD MUSIC 4000
P%=&400F
[OPT 0
.platform       EQUB 64
.addrDNOIZ      EQUW &3E17
.addrplay1      EQUW &3DCA+1
.addrDELAY      EQUW &3E08
.addrSFX        EQUW &394F      \ Set to SFX in elite-z
.end
]
!&80=&4000 : CALL SRLOAD : REM Load ROM image into the correct bank in I/O
PRINT CHR$130;"OK"
PRINT'"Press any key to play Elite";
A$=GET$
*RUN ELITE
