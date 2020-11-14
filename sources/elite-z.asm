\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE GAME SOURCE (I/O PROCESSOR)
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
\ The terminology and notations used in this commentary are explained at
\ https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html
\
\ ******************************************************************************

INCLUDE "sources/elite-header.h.asm"

CPU 1

CODE% = &2400
LOAD% = &2400
TABLE = &2300

C% = &2400
L% = C%
D% = &D000

Z = 0
XX15 = &90
X1 = XX15
Y1 = XX15+1
X2 = XX15+2
Y2 = XX15+3
SC = XX15+6
SCH = SC+1
OSTP = SC
FF = &FF
OSWRCH = &FFEE
OSBYTE = &FFF4
OSWORD = &FFF1
OSFILE = &FFDD
SCLI = &FFF7
SHEILA = &FE00
VIA = &FE40
USVIA = VIA
IRQ1V = &204
VSCAN = 57
XX21 = D%
WRCHV = &20E
WORDV = &20C
RDCHV = &210
NVOSWRCH = &FFCB
Tina = &B00
Y = 96
\protlen = 0
PARMAX = 15

\REMparameters expected by RDPARAMS
RED = &F0
WHITE = &FA
WHITE2 = &3F
RED2 = &3
YELLOW2 = &F
MAGNETA2 = &33
CYAN2 = &3C
BLUE2 = &30
GREEN2 = &C
STRIPE = &23

\ ******************************************************************************
\       Name: ZP
\ ******************************************************************************

ORG &80

.ZP

 SKIP 0

.P

 SKIP 1

.Q

 SKIP 1

.R

 SKIP 1

.S

 SKIP 1

.T

 SKIP 1

.SWAP

 SKIP 1

.T1

 SKIP 1

.COL

 SKIP 1

.OSSC

 SKIP 2

\ ******************************************************************************
\       Name: FONT%
\ ******************************************************************************

ORG CODE%

FONT% = P% DIV 256

INCBIN "binaries/P.FONT.bin"

\ ******************************************************************************
\       Name: log
\ ******************************************************************************

.log

IF _MATCH_EXTRACTED_BINARIES
 INCBIN "extracted/workspaces/ICODE-log.bin"
ELSE
 SKIP 1
 FOR I%, 1, 255
   B% = INT(&2000 * LOG(I%) / LOG(2) + 0.5)
   EQUB B% DIV 256
 NEXT
ENDIF

\ ******************************************************************************
\       Name: logL
\ ******************************************************************************

.logL

IF _MATCH_EXTRACTED_BINARIES
 INCBIN "extracted/workspaces/ICODE-logL.bin"
ELSE
 SKIP 1
 FOR I%, 1, 255
   B% = INT(&2000 * LOG(I%) / LOG(2) + 0.5)
   EQUB B% MOD 256
 NEXT
ENDIF

\ ******************************************************************************
\       Name: antilog
\ ******************************************************************************

.antilog

IF _MATCH_EXTRACTED_BINARIES
 INCBIN "extracted/workspaces/ICODE-antilog.bin"
ELSE
 FOR I%, 0, 255
   B% = INT(2^((I% / 2 + 128) / 16) + 0.5) DIV 256
   IF B% = 256
     EQUB B%+1
   ELSE
     EQUB B%
   ENDIF
 NEXT
ENDIF

\ ******************************************************************************
\       Name: antilogODD
\ ******************************************************************************

.antilogODD

IF _MATCH_EXTRACTED_BINARIES
 INCBIN "extracted/workspaces/ICODE-antilogODD.bin"
ELSE
 FOR I%, 0, 255
   B% = INT(2^((I% / 2 + 128.25) / 16) + 0.5) DIV 256
   IF B% = 256
     EQUB B%+1
   ELSE
     EQUB B%
   ENDIF
 NEXT
ENDIF

\ ******************************************************************************
\       Name: ylookup
\ ******************************************************************************

.ylookup

FOR I%, 0, 255
  EQUB &40 + ((I% DIV 8) * 2)
NEXT

\ ******************************************************************************
\       Name: TVT3
\ ******************************************************************************

.TVT3

 EQUD &17243400
 EQUD &47576474
 EQUD &8696A1B1
 EQUD &C6D6E1F1 \View  YRC
 EQUD &17243400
 EQUD &47576474
 EQUD &8696A0B0
 EQUD &C6D6E0F0 \Trade YRW
 EQUD &17243400
 EQUD &47576474
 EQUD &8090A1B1
 EQUD &C0D0E1F1 \Title YWC
 EQUD &17243400
 EQUD &47576474
 EQUD &8292A0B0
 EQUD &C2D2E0F0 \Trade YMW

\.............. Variables - do not alter after PARAMS .................

.XC

 EQUB 1

.YC

 EQUB 1

.K3

 BRK

.U

 BRK

.LINTAB

 BRK

.LINMAX

 BRK

.YSAV

 BRK

\ ******************************************************************************
\
\       Name: svn
\       Type: Variable
\   Category: Save and load
\    Summary: The "saving in progress" flag
\
\ ******************************************************************************

.svn

 EQUB 0                 \ "Saving in progress" flag
                        \
                        \ Set to 1 while we are saving a commander, 0 otherwise

.PARANO

 BRK

.DL

 BRK

\ ******************************************************************************
\
\       Name: VEC
\       Type: Variable
\   Category: Screen mode
\    Summary: The original value of the IRQ1 vector
\
\ ******************************************************************************

.VEC

 EQUW 0                 \ VEC = &7FFE
                        \
                        \ Set to the original IRQ1 vector by elite-loader.asm

.HFX

 BRK

.CATF

 BRK

.K

 EQUD 0

.PARAMS

.ENERGY

 BRK

.ALP1

 BRK

.ALP2

 BRK

.BETA

 BRK

.BET1

 BRK

.DELTA

 BRK

.ALTIT

 BRK

.MCNT

 BRK

.FSH

 BRK

.ASH

 BRK

.QQ14

 BRK

.GNTMP

 BRK

.CABTMP

 BRK

.FLH

 BRK

.ESCP

 BRK
\ ******************************************************************************
\       Name: JMPTAB
\ ******************************************************************************

\ Vectors for OSWRCH - routine should end with JMPPUTBACK once it has had its fill of data

.JMPTAB

\Vector lookup table
 EQUW USOSWRCH
 EQUW BEGINLIN
 EQUW ADDBYT
 EQUW DOFE21 \3
 EQUW DOHFX
 EQUW SETXC \5
 EQUW SETYC \6
 EQUW CLYNS \7
 EQUW RDPARAMS \8-GAME PARAMETERS
 EQUW ADPARAMS \9
 EQUW DODIALS\10
 EQUW DOVIAE\11
 EQUW DOBULB\12
 EQUW DOCATF\13
 EQUW DOCOL \14
 EQUW SETVDU19 \15
 EQUW DOSVN \16
 EQUW DOBRK \17
 EQUW printer
 EQUW prilf

\ ******************************************************************************
\       Name: STARTUP
\ ******************************************************************************

.STARTUP

 LDA RDCHV
 STA newosrdch+1
 LDA RDCHV+1
 STA newosrdch+2
 LDA #(newosrdch MOD256)
 SEI
 STA RDCHV
 LDA #(newosrdch DIV256)
 STA RDCHV+1 \~~
 LDA #&39
 STA VIA+&E
 LDA #&7F
 STA &FE6E
 LDA IRQ1V
 STA VEC
 LDA IRQ1V+1
 STA VEC+1
 LDA #IRQ1 MOD256
 STA IRQ1V
 LDA #IRQ1 DIV256
 STA IRQ1V+1
 LDA #VSCAN
 STA USVIA+5
 CLI

.NOINT

 LDA WORDV
 STA notours+1
 LDA WORDV+1
 STA notours+2
 LDA #NWOSWD MOD256
 SEI
 STA WORDV
 LDA #NWOSWD DIV256
 STA WORDV+1
 CLI
 LDA #FF
 STA COL
 LDA Tina
 CMP #'T'
 BNE PUTBACK
 LDA Tina+1
 CMP #'I'
 BNE PUTBACK
 LDA Tina+2
 CMP #'N'
 BNE PUTBACK
 LDA Tina+3
 CMP #'A'
 BNE PUTBACK
 JSR Tina+4

\ ******************************************************************************
\       Name: PUTBACK
\ ******************************************************************************

\ ............. OSWRCH revectored bumbling .....................

.PUTBACK

 LDA #128

\ ******************************************************************************
\       Name: USOSWRCH
\ ******************************************************************************

.USOSWRCH

 STX SC
 TAX
 BPL OHMYGOD
 ASL A
 TAX
 CPX #39
 BCS OHMYGOD
 LDA JMPTAB,X
 SEI
 STA WRCHV
 LDA JMPTAB+1,X
 STA WRCHV+1
 CLI
 RTS

.OHMYGOD

 LDX SC
 JMP TT26

\ ******************************************************************************
\
\       Name: DET1
\       Type: Subroutine
\   Category: Screen mode
\    Summary: Hide the dashboard (for when we die)
\
\ ------------------------------------------------------------------------------
\
\ Set the screen to show the number of text rows given in X. This is used when
\ we are killed, as reducing the number of rows from the usual 31 to 24 has the
\ effect of hiding the dashboard, leaving a monochrome image of ship debris and
\ explosion clouds. Increasing the rows back up to 31 makes the dashboard
\ reappear, as the dashboard's screen memory doesn't get touched by this
\ process.
\
\ Arguments:
\
\   X                   The number of text rows to display on the screen (24
\                       will hide the dashboard, 31 will make it reappear)
\
\ Returns
\
\   A                   A is set to 6
\
\ ******************************************************************************

.DODIALS

TAX

 LDA #6                 \ Set A to 6 so we can update 6845 register R6 below

 SEI                    \ Disable interrupts so we can update the 6845

 STA SHEILA+&00         \ Set 6845 register R6 to the value in X. Register R6
 STX SHEILA+&01         \ is the "vertical displayed" register, which sets the
                        \ number of rows shown on the screen

 CLI                    \ Re-enable interrupts

 JMP PUTBACK\hide dials on death

\ ******************************************************************************
\       Name: DOFE21
\ ******************************************************************************

.DOFE21

 STA &FE21
 JMP PUTBACK \Shimmer on energy bomb

\ ******************************************************************************
\       Name: DOHFX
\ ******************************************************************************

.DOHFX

 STA HFX
 JMP PUTBACK \Hyperspace colours

\ ******************************************************************************
\       Name: DOVIAE
\ ******************************************************************************

.DOVIAE

 STA VIA+&E
 JMP PUTBACK \Keyboard interrupt

\ ******************************************************************************
\       Name: DOCATF
\ ******************************************************************************

.DOCATF

 STA CATF
 JMP PUTBACK

\ ******************************************************************************
\       Name: DOCOL
\ ******************************************************************************

.DOCOL

 STA COL
 JMP PUTBACK

\ ******************************************************************************
\       Name: DOSVN
\ ******************************************************************************

.DOSVN

 STA svn
 JMP PUTBACK
\ ******************************************************************************
\       Name: DOBRK
\ ******************************************************************************

.DOBRK

 BRK
 EQUS "TTEST"
 EQUW 13

\ ******************************************************************************
\       Name: printer
\ ******************************************************************************

.printer

 PHA
 JSR TT26
 PLA
 CMP #11
 BEQ nottosend
 PHA
 LDA #2
 JSR NVOSWRCH
 PLA
 PHA
 CMP #32
 BCS tosend
 CMP #10
 BEQ tosend2
 LDA #13
 JSR POSWRCH
 JMP sent

.tosend2

\CMP#13\BEQsent
 LDA #10
 JSR POSWRCH

.sent

 LDA #3
 JSR NVOSWRCH
 PLA

.nottosend

 JMP PUTBACK

\ ******************************************************************************
\       Name: POSWRCH
\ ******************************************************************************

.POSWRCH

 PHA
 LDA #1
 JSR NVOSWRCH
 PLA
 JMP NVOSWRCH

\ ******************************************************************************
\       Name: tosend
\ ******************************************************************************

.tosend

 JSR POSWRCH
 JMP sent

\ ******************************************************************************
\       Name: prilf
\ ******************************************************************************

.prilf

 LDA #2
 JSR NVOSWRCH
 LDA #10
 JSR POSWRCH
 JSR POSWRCH
 LDA #3
 JSR NVOSWRCH
 JMP PUTBACK

\ ******************************************************************************
\       Name: DOBULB
\ ******************************************************************************

.DOBULB

 TAX
 BNE ECBLB
 LDA #16*8
 STA SC
 LDA #&7B
 STA SC+1
 LDY #15

.BULL

 LDA SPBT,Y
 EOR (SC),Y
 STA (SC),Y
 DEY
 BPL BULL
 JMP PUTBACK

\ ******************************************************************************
\       Name: ECBLB
\ ******************************************************************************

.ECBLB

 LDA #8*14
 STA SC
 LDA #&7A
 STA SC+1
 LDY #15

.BULL2

 LDA ECBT,Y
 EOR (SC),Y
 STA (SC),Y
 DEY
 BPL BULL2
 JMP PUTBACK

\ ******************************************************************************
\
\       Name: SPBT
\       Type: Variable
\   Category: Dashboard
\    Summary: The character definition for the space station indicator
\
\ ------------------------------------------------------------------------------
\
\ The character definition for the space station indicator's "S" bulb that gets
\ displayed on the dashboard. Each pixel is in mode 5 colour 2 (%10), which is
\ yellow/white.
\
\ ******************************************************************************

.SPBT

 EQUD &FFAAFFFF
 EQUD &FFFF00FF
 EQUD &FF00FFFF
 EQUD &FFFF55FF

\ ******************************************************************************
\
\       Name: ECBT
\       Type: Variable
\   Category: Dashboard
\    Summary: The character definition for the E.C.M. indicator
\
\ ------------------------------------------------------------------------------
\
\ The character definition for the E.C.M. indicator's "E" bulb that gets
\ displayed on the dashboard. The E.C.M. indicator uses the first 5 rows of the
\ space station's "S" bulb below, as the bottom 5 rows of the "E" match the top
\ 5 rows of the "S". Each pixel is in mode 5 colour 2 (%10), which is
\ yellow/white.
\
\ ******************************************************************************

.ECBT

 EQUD &FFAAFFFF
 EQUD &FFFFAAFF
 EQUD &FF00FFFF
 EQUD &FFFF00FF

\ ******************************************************************************
\       Name: DOT
\ ******************************************************************************

.DOT

 LDY #2
 LDA (OSSC),Y
 STA X1
 INY
 LDA (OSSC),Y
 STA Y1
 INY
 LDA (OSSC),Y
 STA COL
 CMP #WHITE2
 BNE CPIX2

\ ******************************************************************************
\
\       Name: CPIX4
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a double-height dot on the dashboard
\
\ ------------------------------------------------------------------------------
\
\ Draw a double-height mode 5 dot (2 pixels high, 2 pixels wide).
\
\ Arguments:
\
\   X1                  The screen pixel x-coordinate of the bottom-left corner
\                       of the dot
\
\   Y1                  The screen pixel y-coordinate of the bottom-left corner
\                       of the dot
\
\   COL                 The colour of the dot as a mode 5 character row byte
\
\ ******************************************************************************

.CPIX4

 JSR CPIX2              \ Call CPIX2 to draw a single-height dash at (X1, Y1)

 DEC Y1                 \ Decrement Y1

                        \ Fall through into CPIX2 to draw a second single-height
                        \ dash on the pixel row above the first one, to create a
                        \ double-height dot

\ ******************************************************************************
\
\       Name: CPIX2
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a single-height dot on the dashboard
\  Deep dive: Drawing colour pixels in mode 5
\
\ ------------------------------------------------------------------------------
\
\ Draw a single-height mode 5 dash (1 pixel high, 2 pixels wide).
\
\ Arguments:
\
\   X1                  The screen pixel x-coordinate of the dash
\
\   Y1                  The screen pixel y-coordinate of the dash
\
\   COL                 The colour of the dash as a mode 5 character row byte
\
\ ******************************************************************************

.CPIX2

 LDA Y1                 \ Fetch the y-coordinate into A

\.CPIX                  \ This label is commented out in the original source. It
                        \ would provide a new entry point with A specifying the
                        \ y-coordinate instead of Y1, but it isn't used anywhere

 TAY                    \ Store the y-coordinate in Y

 LDA ylookup,Y
 STA SC+1

 LDA X1
 AND #&FC
 ASL A
 STA SC
 BCC P%+5
 INC SC+1
 CLC

 TYA                    \ Set Y to just bits 0-2 of the y-coordinate, which will
 AND #%00000111         \ be the number of the pixel row we need to draw into
 TAY                    \ within the character block

 LDA X1
 AND #2
 TAX

 LDA CTWOS,X            \ Fetch a mode 5 1-pixel byte with the pixel position
 AND COL                \ at X, and AND with the colour byte so that pixel takes
                        \ on the colour we want to draw (i.e. A is acting as a
                        \ mask on the colour byte)

 EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
 STA (SC),Y             \ remove it later without ruining the background that's
                        \ already on-screen

 LDA CTWOS+2,X

 BPL CP1                \ The CTWOS table has an extra row at the end of it that
                        \ repeats the first value, %10001000, so if we have not
                        \ fetched that value, then the right pixel of the dash
                        \ is in the same character block as the left pixel, so
                        \ jump to CP1 to draw it

 LDA SC                 \ Otherwise the left pixel we drew was at the last
 ADC #8                 \ position of four in this character block, so we add
 STA SC                 \ 8 to the screen address to move onto the next block
                        \ along (as there are 8 bytes in a character block).
                        \ The C flag was cleared above, so this ADC is correct

 BCC P%+4
 INC SC+1
 LDA CTWOS+2,X

.CP1

 AND COL                \ Draw the dash's right pixel according to the mask in
 EOR (SC),Y             \ A, with the colour in COL, using EOR logic, just as
 STA (SC),Y             \ above

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\       Name: SC48 - is like the last half of common/subroutine_scan.asm
\ ******************************************************************************

\  ...................... Scanners  ..............................

.SC48

 LDY #4
 LDA (OSSC),Y
 STA COL
 INY
 LDA (OSSC),Y
 STA X1
 INY
 LDA (OSSC),Y
 STA Y1
 JSR CPIX4
 LDA CTWOS+2,X
 AND COL
 STA X1
 STY Q
 LDY #2
 LDA (OSSC),Y
 ASL A
 INY
 LDA (OSSC),Y
 BEQ RTS
 LDY Q
 TAX
 BCC RTS+1

.VLL1

 DEY
 BPL VL1
 LDY #7
 DEC SC+1
 DEC SC+1

.VL1

 LDA X1
 EOR (SC),Y
 STA (SC),Y
 DEX
 BNE VLL1

.RTS

 RTS
 INY
 CPY #8
 BNE VLL2
 LDY #0
 INC SC+1
 INC SC+1

.VLL2

 INY
 CPY #8
 BNE VL2
 LDY #0
 INC SC+1
 INC SC+1

.VL2

 LDA X1
 EOR (SC),Y
 STA (SC),Y
 INX
 BNE VLL2
 RTS

\ ******************************************************************************
\       Name: BEGINLIN   see LL155 in tape
\ ******************************************************************************

\.............Empty Linestore after copying over Tube .........

.BEGINLIN

\was LL155 -CLEAR LINEstr
 STA LINMAX
 LDA #0
 STA LINTAB
 LDA #&82
 JMP USOSWRCH

.RTS1

 RTS

\ ******************************************************************************
\       Name: ADDBYT
\ ******************************************************************************

.ADDBYT

 INC LINTAB
 LDX LINTAB
 STA TABLE-1,X
 INX
 CPX LINMAX
 BCC RTS1
 LDY #0
 DEC LINMAX
 LDA TABLE+3
 CMP #FF
 BEQ doalaser

.LL27

 LDA TABLE,Y
 STA X1
 LDA TABLE+1,Y
 STA Y1
 LDA TABLE+2,Y
 STA X2
 LDA TABLE+3,Y
 STA Y2
 STY T1
 JSR LOIN
 LDA T1
 CLC
 ADC #4

.Ivedonealaser

 TAY
 CMP LINMAX
 BCC LL27

.DRLR1

 JMP PUTBACK

.doalaser

 LDA COL
 PHA
 LDA #RED
 STA COL
 LDA TABLE+4
 STA X1
 LDA TABLE+5
 STA Y1
 LDA TABLE+6
 STA X2
 LDA TABLE+7
 STA Y2
 JSR LOIN
 PLA
 STA COL
 LDA #8
 BNE Ivedonealaser

\ ******************************************************************************
\       Name: TWOS
\ ******************************************************************************

.TWOS

 EQUD &11224488

\ ******************************************************************************
\       Name: TWOS2
\ ******************************************************************************

.TWOS2

 EQUD &333366CC

\ ******************************************************************************
\       Name: CTWOS
\ ******************************************************************************

.CTWOS

 EQUD &5555AAAA
 EQUW &AAAA

\ ******************************************************************************
\       Name: HLOIN2
\ ******************************************************************************

.HLOIN2

 LDX X1
 STY Y2
 INY
 STY Q
 LDA COL
 JMP HLOIN3 \any colour

\ ******************************************************************************
\       Name: LOIN (Part 1 of 7)
\ ******************************************************************************

.LOIN

 LDA #128
 STA S
 ASL A
 STA SWAP
 LDA X2
 SBC X1
 BCS LI1
 EOR #FF
 ADC #1
 SEC

.LI1

 STA P
 LDA Y2
 SBC Y1
 BEQ HLOIN2
 BCS LI2
 EOR #FF
 ADC #1

.LI2

 STA Q
 CMP P
 BCC STPX
 JMP STPY

\ ******************************************************************************
\       Name: LOIN (Part 2 of 7)
\ ******************************************************************************

.STPX

 LDX X1
 CPX X2
 BCC LI3
 DEC SWAP
 LDA X2
 STA X1
 STX X2
 TAX
 LDA Y2
 LDY Y1
 STA Y1
 STY Y2

.LI3

 LDY Y1
 LDA ylookup,Y
 STA SC+1
 LDA Y1
 AND #7
 TAY
 TXA
 AND #&FC
 ASL A
 STA SC
 BCC P%+4
 INC SC+1
 TXA
 AND #3
 STA R
 LDX Q
 BEQ LIlog7
 LDA logL,X
 LDX P
 SEC
 SBC logL,X
 BMI LIlog4
 LDX Q
 LDA log,X
 LDX P
 SBC log,X
 BCS LIlog5
 TAX
 LDA antilog,X
 JMP LIlog6

.LIlog5

 LDA #FF
 BNE LIlog6

.LIlog7

 LDA #0
 BEQ LIlog6

.LIlog4

 LDX Q
 LDA log,X
 LDX P
 SBC log,X
 BCS LIlog5
 TAX
 LDA antilogODD,X

.LIlog6

 STA Q
 LDX P
 BEQ LIEXS
 INX
 LDA Y2
 CMP Y1
 BCC P%+5
 JMP DOWN

\ ******************************************************************************
\       Name: LOIN (Part 3 of 7)
\ ******************************************************************************

 LDA #&88
 AND COL
 STA LI100+1
 LDA #&44
 AND COL
 STA LI110+1
 LDA #&22
 AND COL
 STA LI120+1
 LDA #&11
 AND COL
 STA LI130+1
 LDA SWAP
 BEQ LI190
 LDA R
 BEQ LI100+6
 CMP #2
 BCC LI110+6
 CLC
 BEQ LI120+6
 BNE LI130+6

.LI190

 DEX
 LDA R
 BEQ LI100
 CMP #2
 BCC LI110
 CLC
 BEQ LI120
 JMP LI130

.LI100

 LDA #&88
 EOR (SC),Y
 STA (SC),Y
 DEX

.LIEXS

 BEQ LIEX
 LDA S
 ADC Q
 STA S
 BCC LI110
 CLC
 DEY
 BMI LI101

.LI110

 LDA #&44
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX
 LDA S
 ADC Q
 STA S
 BCC LI120
 CLC
 DEY
 BMI LI111

.LI120

 LDA #&22
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX
 LDA S
 ADC Q
 STA S
 BCC LI130
 CLC
 DEY
 BMI LI121

.LI130

 LDA #&11
 EOR (SC),Y
 STA (SC),Y
 LDA S
 ADC Q
 STA S
 BCC LI140
 CLC
 DEY
 BMI LI131

.LI140

 DEX
 BEQ LIEX
 LDA SC
 ADC #8
 STA SC
 BCC LI100
 INC SC+1
 CLC
 BCC LI100

.LI101

 DEC SC+1
 DEC SC+1
 LDY #7
 BPL LI110

.LI111

 DEC SC+1
 DEC SC+1
 LDY #7
 BPL LI120

.LI121

 DEC SC+1
 DEC SC+1
 LDY #7
 BPL LI130

.LI131

 DEC SC+1
 DEC SC+1
 LDY #7
 BPL LI140

.LIEX

 RTS

\ ******************************************************************************
\       Name: LOIN (Part 4 of 7)
\ ******************************************************************************

.DOWN

 LDA #&88
 AND COL
 STA LI200+1
 LDA #&44
 AND COL
 STA LI210+1
 LDA #&22
 AND COL
 STA LI220+1
 LDA #&11
 AND COL
 STA LI230+1
 LDA SC
 SBC #&F8
 STA SC
 LDA SC+1
 SBC #0
 STA SC+1
 TYA
 EOR #&F8
 TAY
 LDA SWAP
 BEQ LI191
 LDA R
 BEQ LI200+6
 CMP #2
 BCC LI210+6
 CLC
 BEQ LI220+6
 BNE LI230+6

.LI191

 DEX
 LDA R
 BEQ LI200
 CMP #2
 BCC LI210
 CLC
 BEQ LI220
 BNE LI230

.LI200

 LDA #&88
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX
 LDA S
 ADC Q
 STA S
 BCC LI210
 CLC
 INY
 BEQ LI201

.LI210

 LDA #&44
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX
 LDA S
 ADC Q
 STA S
 BCC LI220
 CLC
 INY
 BEQ LI211

.LI220

 LDA #&22
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX2
 LDA S
 ADC Q
 STA S
 BCC LI230
 CLC
 INY
 BEQ LI221

.LI230

 LDA #&11
 EOR (SC),Y
 STA (SC),Y
 LDA S
 ADC Q
 STA S
 BCC LI240
 CLC
 INY
 BEQ LI231

.LI240

 DEX
 BEQ LIEX2
 LDA SC
 ADC #8
 STA SC
 BCC LI200
 INC SC+1
 CLC
 BCC LI200

.LI201

 INC SC+1
 INC SC+1
 LDY #&F8
 BNE LI210

.LI211

 INC SC+1
 INC SC+1
 LDY #&F8
 BNE LI220

.LI221

 INC SC+1
 INC SC+1
 LDY #&F8
 BNE LI230

.LI231

 INC SC+1
 INC SC+1
 LDY #&F8
 BNE LI240

.LIEX2

 RTS

\ ******************************************************************************
\       Name: LOIN (Part 5 of 7)
\ ******************************************************************************

.STPY

 LDY Y1
 TYA
 LDX X1
 CPY Y2
 BCS LI15
 DEC SWAP
 LDA X2
 STA X1
 STX X2
 TAX
 LDA Y2
 STA Y1
 STY Y2
 TAY

.LI15

 LDA ylookup,Y
 STA SC+1
 TXA
 AND #&FC
 ASL A
 STA SC
 BCC P%+4
 INC SC+1
 TXA
 AND #3
 TAX
 LDA TWOS,X
 STA R
 LDX P
 BEQ LIfudge
 LDA logL,X
 LDX Q
 SEC
 SBC logL,X
 BMI LIloG
 LDX P
 LDA log,X
 LDX Q
 SBC log,X
 BCS LIlog3
 TAX
 LDA antilog,X
 JMP LIlog2

.LIlog3

 LDA #FF
 BNE LIlog2

.LIloG

 LDX P
 LDA log,X
 LDX Q
 SBC log,X
 BCS LIlog3
 TAX
 LDA antilogODD,X

.LIlog2

 STA P

.LIfudge

 LDX Q
 BEQ LIEX7
 INX
 LDA X2
 SEC
 SBC X1
 BCS P%+6
 JMP LFT

\ ******************************************************************************
\       Name: LOIN (Part 6 of 7)
\ ******************************************************************************

.LIEX7

 RTS
 LDA SWAP
 BEQ LI290
 TYA
 AND #7
 TAY
 BNE P%+5
 JMP LI307+8
 CPY #2
 BCS P%+5
 JMP LI306+8
 CLC
 BNE P%+5
 JMP LI305+8
 CPY #4
 BCS P%+5
 JMP LI304+8
 CLC
 BNE P%+5
 JMP LI303+8
 CPY #6
 BCS P%+5
 JMP LI302+8
 CLC
 BEQ P%+5
 JMP LI300+8
 JMP LI301+8

.LI290

 DEX
 TYA
 AND #7
 TAY
 BNE P%+5
 JMP LI307
 CPY #2
 BCS P%+5
 JMP LI306
 CLC
 BNE P%+5
 JMP LI305
 CPY #4
 BCC LI304S
 CLC
 BEQ LI303S
 CPY #6
 BCC LI302S
 CLC
 BEQ LI301S
 JMP LI300

.LI310

 LSR R
 BCC LI301
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI301
 INC SC+1
 CLC

.LI301S

 BCC LI301

.LI311

 LSR R
 BCC LI302
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI302
 INC SC+1
 CLC

.LI302S

 BCC LI302

.LI312

 LSR R
 BCC LI303
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI303
 INC SC+1
 CLC

.LI303S

 BCC LI303

.LI313

 LSR R
 BCC LI304
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI304
 INC SC+1
 CLC

.LI304S

 BCC LI304

.LIEX3

 RTS

.LI300

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX3
 DEY
 LDA S
 ADC P
 STA S
 BCS LI310

.LI301

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX3
 DEY
 LDA S
 ADC P
 STA S
 BCS LI311

.LI302

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX3
 DEY
 LDA S
 ADC P
 STA S
 BCS LI312

.LI303

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX3
 DEY
 LDA S
 ADC P
 STA S
 BCS LI313

.LI304

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX4
 DEY
 LDA S
 ADC P
 STA S
 BCS LI314

.LI305

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX4
 DEY
 LDA S
 ADC P
 STA S
 BCS LI315

.LI306

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX4
 DEY
 LDA S
 ADC P
 STA S
 BCS LI316

.LI307

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX4
 DEC SC+1
 DEC SC+1
 LDY #7
 LDA S
 ADC P
 STA S
 BCS P%+5
 JMP LI300
 LSR R
 BCS P%+5
 JMP LI300
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCS P%+5
 JMP LI300
 INC SC+1
 CLC
 JMP LI300

.LIEX4

 RTS

.LI314

 LSR R
 BCC LI305
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI305
 INC SC+1
 CLC
 BCC LI305

.LI315

 LSR R
 BCC LI306
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI306
 INC SC+1
 CLC
 BCC LI306

.LI316

 LSR R
 BCC LI307
 LDA #&88
 STA R
 LDA SC
 ADC #7
 STA SC
 BCC LI307
 INC SC+1
 CLC
 BCC LI307

\ ******************************************************************************
\       Name: LOIN (Part 7 of 7)
\ ******************************************************************************

.LFT

 LDA SWAP
 BEQ LI291
 TYA
 AND #7
 TAY
 BNE P%+5
 JMP LI407+8
 CPY #2
 BCS P%+5
 JMP LI406+8
 CLC
 BNE P%+5
 JMP LI405+8
 CPY #4
 BCS P%+5
 JMP LI404+8
 CLC
 BNE P%+5
 JMP LI403+8
 CPY #6
 BCS P%+5
 JMP LI402+8
 CLC
 BEQ P%+5
 JMP LI400+8
 JMP LI401+8

.LI291

 DEX
 TYA
 AND #7
 TAY
 BNE P%+5
 JMP LI407
 CPY #2
 BCS P%+5
 JMP LI406
 CLC
 BNE P%+5
 JMP LI405
 CPY #4
 BCC LI404S
 CLC
 BEQ LI403S
 CPY #6
 BCC LI402S
 CLC
 BEQ LI401S
 JMP LI400

.LI410

 ASL R
 BCC LI401
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC

.LI401S

 BCC LI401

.LI411

 ASL R
 BCC LI402
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC

.LI402S

 BCC LI402

.LI412

 ASL R
 BCC LI403
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC

.LI403S

 BCC LI403

.LI413

 ASL R
 BCC LI404
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC

.LI404S

 BCC LI404

.LIEX5

 RTS

.LI400

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX5
 DEY
 LDA S
 ADC P
 STA S
 BCS LI410

.LI401

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX5
 DEY
 LDA S
 ADC P
 STA S
 BCS LI411

.LI402

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX5
 DEY
 LDA S
 ADC P
 STA S
 BCS LI412

.LI403

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX5
 DEY
 LDA S
 ADC P
 STA S
 BCS LI413

.LI404

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX6
 DEY
 LDA S
 ADC P
 STA S
 BCS LI414

.LI405

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX6
 DEY
 LDA S
 ADC P
 STA S
 BCS LI415

.LI406

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX6
 DEY
 LDA S
 ADC P
 STA S
 BCS LI416

.LI407

 LDA R
 AND COL
 EOR (SC),Y
 STA (SC),Y
 DEX
 BEQ LIEX6
 DEC SC+1
 DEC SC+1
 LDY #7
 LDA S
 ADC P
 STA S
 BCS P%+5
 JMP LI400
 ASL R
 BCS P%+5
 JMP LI400
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC
 JMP LI400

.LIEX6

 RTS

.LI414

 ASL R
 BCC LI405
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC
 BCC LI405

.LI415

 ASL R
 BCC LI406
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC
 BCC LI406

.LI416

 ASL R
 BCC LI407
 LDA #&11
 STA R
 LDA SC
 SBC #8
 STA SC
 BCS P%+4
 DEC SC+1
 CLC
 JMP LI407

\ ******************************************************************************
\       Name: HLOIN
\ ******************************************************************************

.HLOIN

 LDY #0
 LDA (OSSC),Y
 STA Q
 INY
 INY

.HLLO

 LDA (OSSC),Y
 STA X1
 TAX
 INY
 LDA (OSSC),Y
 STA X2
 INY
 LDA (OSSC),Y
 STA Y1
 STY Y2
 AND #3
 TAY
 LDA orange,Y

.HLOIN3

 STA S
 CPX X2
 BEQ HL6
 BCC HL5
 LDA X2
 STA X1
 STX X2
 TAX

.HL5

 DEC X2
 LDY Y1
 LDA ylookup,Y
 STA SC+1
 TYA
 AND #7
 STA SC
 TXA
 AND #&FC
 ASL A
 TAY
 BCC P%+4
 INC SC+1

.HL1

 TXA
 AND #&FC
 STA T
 LDA X2
 AND #&FC
 SEC
 SBC T
 BEQ HL2
 LSR A
 LSR A
 STA R
 LDA X1
 AND #3
 TAX
 LDA TWFR,X
 AND S
 EOR (SC),Y
 STA (SC),Y
 TYA
 ADC #8
 TAY
 BCS HL7

.HL8

 LDX R
 DEX
 BEQ HL3
 CLC

.HLL1

 LDA S
 EOR (SC),Y
 STA (SC),Y
 TYA
 ADC #8
 TAY
 BCS HL9

.HL10

 DEX
 BNE HLL1

.HL3

 LDA X2
 AND #3
 TAX
 LDA TWFL,X
 AND S
 EOR (SC),Y
 STA (SC),Y

.HL6

 LDY Y2
 INY
 CPY Q
 BEQ P%+5
 JMP HLLO
 RTS

.HL2

 LDA X1
 AND #3
 TAX
 LDA TWFR,X
 STA T
 LDA X2
 AND #3
 TAX
 LDA TWFL,X
 AND T
 AND S
 EOR (SC),Y
 STA (SC),Y
 LDY Y2
 INY
 CPY Q
 BEQ P%+5
 JMP HLLO
 RTS

.HL7

 INC SC+1
 CLC
 JMP HL8

.HL9

 INC SC+1
 CLC
 JMP HL10

\ ******************************************************************************
\       Name: TWFL
\ ******************************************************************************

.TWFL

 EQUD &FFEECC88

\ ******************************************************************************
\       Name: TWFR
\ ******************************************************************************

.TWFR

 EQUD &113377FF

\ ******************************************************************************
\       Name: orange
\ ******************************************************************************

.orange

 EQUB &A5
 EQUB &A5
 EQUB &5A
 EQUB &5A

\ ******************************************************************************
\       Name: PIXEL
\ ******************************************************************************

.PIXEL

 LDY #0
 LDA (OSSC),Y
 STA Q
 INY
 INY

.PXLO

 LDA (OSSC),Y
 STA P
 AND #7
 BEQ PX5
 TAX
 LDA PXCL,X
 STA S
 INY
 LDA (OSSC),Y
 TAX
 INY
 LDA (OSSC),Y
 STY T1
 TAY
 LDA ylookup,Y
 STA SC+1
 TXA
 AND #&FC
 ASL A
 STA SC
 BCC P%+4
 INC SC+1
 TYA
 AND #7
 TAY
 TXA
 AND #3
 TAX
 LDA P
 BMI PX3
 CMP #&50
 BCC PX2
 LDA TWOS2,X
 AND S
 EOR (SC),Y
 STA (SC),Y
 LDY T1
 INY
 CPY Q
 BNE PXLO
 RTS

.PX2

 LDA TWOS2,X
 AND S
 EOR (SC),Y
 STA (SC),Y
 DEY
 BPL P%+4
 LDY #1
 LDA TWOS2,X
 AND S
 EOR (SC),Y
 STA (SC),Y
 LDY T1
 INY
 CPY Q
 BNE PXLO
 RTS

.PX3

 LDA TWOS,X
 AND S
 EOR (SC),Y
 STA (SC),Y
 LDY T1
 INY
 CPY Q
 BNE PXLO
 RTS

.PX5

 INY
 LDA (OSSC),Y
 TAX
 INY
 LDA (OSSC),Y
 STY T1
 TAY
 LDA ylookup,Y
 STA SC+1
 TXA
 AND #&FC
 ASL A
 STA SC
 BCC P%+4
 INC SC+1
 TYA
 AND #7
 TAY
 TXA
 AND #3
 TAX
 LDA P
 CMP #&50
 BCS PX6
 LDA TWOS2,X
 AND #WHITE
 EOR (SC),Y
 STA (SC),Y
 DEY
 BPL P%+4
 LDY #1

.PX6

 LDA TWOS2,X
 AND #WHITE
 EOR (SC),Y
 STA (SC),Y
 LDY T1
 INY
 CPY Q
 BEQ P%+5
 JMP PXLO
 RTS

\ ******************************************************************************
\       Name: PXCL
\ ******************************************************************************

.PXCL

 EQUB WHITE
 EQUB &F
 EQUB &F
 EQUB &F0
 EQUB &F0
 EQUB &A5
 EQUB &A5
 EQUB &F

\ ******************************************************************************
\       Name: newosrdch
\ ******************************************************************************

.newosrdch

 JSR &FFFF
 CMP #128
 BCC P%+6

.badkey

 LDA #7
 CLC
 RTS
 CMP #32
 BCS coolkey
 CMP #13
 BEQ coolkey
 CMP #21
 BNE badkey

.coolkey

 CLC
 RTS

\ ******************************************************************************
\
\       Name: ADD
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (A X) = (A P) + (S R)
\  Deep dive: Adding sign-magnitude numbers
\
\ ------------------------------------------------------------------------------
\
\ Add two signed 16-bit numbers together, making sure the result has the
\ correct sign. Specifically:
\
\   (A X) = (A P) + (S R)
\
\ ******************************************************************************

.ADD

 STA T1                 \ Store argument A in T1

 AND #%10000000         \ Extract the sign (bit 7) of A and store it in T
 STA T

 EOR S                  \ EOR bit 7 of A with S. If they have different bit 7s
 BMI MU8                \ (i.e. they have different signs) then bit 7 in the
                        \ EOR result will be 1, which means the EOR result is
                        \ negative. So the AND, EOR and BMI together mean "jump
                        \ to MU8 if A and S have different signs"

                        \ If we reach here, then A and S have the same sign, so
                        \ we can add them and set the sign to get the result

 LDA R                  \ Add the least significant bytes together into X, so
 CLC                    \
 ADC P                  \   X = P + R
 TAX

 LDA S                  \ Add the most significant bytes together into A. We
 ADC T1                 \ stored the original argument A in T1 earlier, so we
                        \ can do this with:
                        \
                        \   A = A  + S + C
                        \     = T1 + S + C

 ORA T                  \ If argument A was negative (and therefore S was also
                        \ negative) then make sure result A is negative by
                        \ OR-ing the result with the sign bit from argument A
                        \ (which we stored in T)

 RTS                    \ Return from the subroutine

.MU8

                        \ If we reach here, then A and S have different signs,
                        \ so we can subtract their absolute values and set the
                        \ sign to get the result

 LDA S                  \ Clear the sign (bit 7) in S and store the result in
 AND #%01111111         \ U, so U now contains |S|
 STA U

 LDA P                  \ Subtract the least significant bytes into X, so
 SEC                    \   X = P - R
 SBC R
 TAX

 LDA T1                 \ Restore the A of the argument (A P) from T1 and
 AND #%01111111         \ clear the sign (bit 7), so A now contains |A|

 SBC U                  \ Set A = |A| - |S|

                        \ At this point we have |A P| - |S R| in (A X), so we
                        \ need to check whether the subtraction above was the
                        \ the right way round (i.e. that we subtracted the
                        \ smaller absolute value from the larger absolute
                        \ value)

 BCS MU9                \ If |A| >= |S|, our subtraction was the right way
                        \ round, so jump to MU9 to set the sign

                        \ If we get here, then |A| < |S|, so our subtraction
                        \ above was the wrong way round (we actually subtracted
                        \ the larger absolute value from the smaller absolute
                        \ value. So let's subtract the result we have in (A X)
                        \ from zero, so that the subtraction is the right way
                        \ round

 STA U                  \ Store A in U

 TXA                    \ Set X = 0 - X using two's complement (to negate a
 EOR #&FF               \ number in two's complement, you can invert the bits
 ADC #1                 \ and add one - and we know the C flag is clear as we
 TAX                    \ didn't take the BCS branch above, so ADC will do the 
                        \ correct addition)

 LDA #0                 \ Set A = 0 - A, which we can do this time using a
 SBC U                  \ a subtraction with the C flag clear

 ORA #%10000000         \ We now set the sign bit of A, so that the EOR on the
                        \ next line will give the result the opposite sign to
                        \ argument A (as T contains the sign bit of argument
                        \ A). This is the same as giving the result the same
                        \ sign as argument S (as A and S have different signs),
                        \ which is what we want, as S has the larger absolute
                        \ value

.MU9

 EOR T                  \ If we get here from the BCS above, then |A| >= |S|,
                        \ so we want to give the result the same sign as
                        \ argument A, so if argument A was negative, we flip
                        \ the sign of the result with an EOR (to make it
                        \ negative)

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\       Name: HANGER
\ ******************************************************************************

.HANGER

 LDX #2

.HAL1

 STX T
 LDA #130
 STX Q
 JSR DVID4
 LDA P
 CLC
 ADC #Y
 TAY
 LDA ylookup,Y
 STA SC+1
 STA R
 LDA P
 AND #7
 STA SC
 LDY #0
 JSR HAS2
 LDY R
 INY
 STY SC+1
 LDA #&40
 LDY #&F8
 JSR HAS3
 LDY #2
 LDA (OSSC),Y
 TAY
 BEQ HA2
 LDY #0
 LDA #&88
 JSR HAL3
 DEC SC+1
 LDY #&F8
 LDA #&10
 JSR HAS3

.HA2

 LDX T
 INX
 CPX #13
 BCC HAL1
 LDA #60
 STA S
 LDA #&10
 LDX #&40
 STX R

.HAL6

 LDX R
 STX SC+1
 STA T
 AND #&FC
 STA SC
 LDX #&88
 LDY #1

.HAL7

 TXA
 AND (SC),Y
 BNE HA6
 TXA
 AND #RED
 ORA (SC),Y
 STA (SC),Y
 INY
 CPY #8
 BNE HAL7
 INC SC+1
 INC SC+1
 LDY #0
 BEQ HAL7

.HA6

 LDA T
 CLC
 ADC #16
 BCC P%+4
 INC R
 DEC S
 BNE HAL6

.HA3

 RTS

.HAS2

 LDA #&22

.HAL2

 TAX
 AND (SC),Y
 BNE HA3
 TXA
 AND #RED
 ORA (SC),Y
 STA (SC),Y
 TXA
 LSR A
 BCC HAL2
 TYA
 ADC #7
 TAY
 LDA #&88
 BCC HAL2
 INC SC+1

.HAL3

 TAX
 AND (SC),Y
 BNE HA3
 TXA
 AND #RED
 ORA (SC),Y
 STA (SC),Y
 TXA
 LSR A
 BCC HAL3
 TYA
 ADC #7
 TAY
 LDA #&88
 BCC HAL3
 RTS

.HAS3

 TAX
 AND (SC),Y
 BNE HA3
 TXA
 ORA (SC),Y
 STA (SC),Y
 TXA
 ASL A
 BCC HAS3
 TYA
 SBC #8
 TAY
 LDA #&10
 BCS HAS3
 RTS

\ ******************************************************************************
\
\       Name: DVID4
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (P R) = 256 * A / Q
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following division and remainder:
\
\   P = A / Q
\
\   R = remainder as a fraction of Q, where 1.0 = 255
\
\ Another way of saying the above is this:
\
\   (P R) = 256 * A / Q
\
\ This uses the same shift-and-subtract algorithm as TIS2, but this time we
\ keep the remainder.
\
\ Returns:
\
\   C flag              The C flag is cleared
\
\ ******************************************************************************

.DVID4

 LDX #8                 \ Set a counter in X to count the 8 bits in A

 ASL A                  \ Shift A left and store in P (we will build the result
 STA P                  \ in P)

 LDA #0                 \ Set A = 0 for us to build a remainder

.DVL4

 ROL A                  \ Shift A to the left

 BCS DV8                \ If the C flag is set (i.e. bit 7 of A was set) then
                        \ skip straight to the subtraction

 CMP Q                  \ If A < Q skip the following subtraction
 BCC DV5

.DV8

 SBC Q                  \ A >= Q, so set A = A - Q

.DV5

 ROL P                  \ Shift P to the left, pulling the C flag into bit 0

 DEX                    \ Decrement the loop counter

 BNE DVL4               \ Loop back for the next bit until we have done all 8
                        \ bits of P

 RTS

\ ******************************************************************************
\       Name: ADPARAMS
\ ******************************************************************************

.ADPARAMS

 INC PARANO
 LDX PARANO
 STA PARAMS-1,X
 CPX #PARMAX
 BCS P%+3
 RTS
 JSR DIALS
 JMP PUTBACK

\ ******************************************************************************
\       Name: RDPARAMS
\ ******************************************************************************

.RDPARAMS

 LDA #0
 STA PARANO
 LDA #&89
 JMP USOSWRCH

\ ******************************************************************************
\
\       Name: DKS4
\       Type: Macro
\   Category: Keyboard
\    Summary: Scan the keyboard to see if a specific key is being pressed
\
\ ------------------------------------------------------------------------------
\
\ Scan the keyboard to see if the key specified in A is currently being
\ pressed.
\
\ Arguments:
\
\   A                   The internal number of the key to check (see p.142 of
\                       the Advanced User Guide for a list of internal key
\                       numbers)
\
\ Returns:
\
\   A                   If the key in A is being pressed, A contains the
\                       original argument A, but with bit 7 set (i.e. A + 128).
\                       If the key in A is not being pressed, the value in A is
\                       unchanged
\
\ ******************************************************************************

MACRO DKS4
 LDX #3                 \ Set X to 3, so it's ready to send to SHEILA once
                        \ interrupts have been disabled

 SEI                    \ Disable interrupts so we can scan the keyboard
                        \ without being hijacked

 STX SHEILA+&40         \ Set 6522 System VIA output register ORB (SHEILA &40)
                        \ to %0011 to stop auto scan of keyboard

 LDX #%01111111         \ Set 6522 System VIA data direction register DDRA
 STX SHEILA+&43         \ (SHEILA &43) to %01111111. This sets the A registers
                        \ (IRA and ORA) so that
                        \
                        \ Bits 0-6 of ORA will be sent to the keyboard
                        \
                        \ Bit 7 of IRA will be read from the keyboard

 STA SHEILA+&4F         \ Set 6522 System VIA output register ORA (SHEILA &4F)
                        \ to X, the key we want to scan for; bits 0-6 will be
                        \ sent to the keyboard, of which bits 0-3 determine the
                        \ keyboard column, and bits 4-6 the keyboard row

 LDA SHEILA+&4F         \ Read 6522 System VIA output register IRA (SHEILA &4F)
                        \ into A; bit 7 is the only bit that will have changed.
                        \ If the key is pressed, then bit 7 will be set (so A
                        \ will contain 128 + A), otherwise it will be clear (so
                        \ A will be unchanged)

 LDX #%00001011         \ Set 6522 System VIA output register ORB (SHEILA &40)
 STX SHEILA+&40         \ to %1011 to restart auto scan of keyboard

 CLI                    \ Allow interrupts again
ENDMACRO
\ ******************************************************************************
\       Name: KYTB
\ ******************************************************************************

.KYTB

 EQUB 0
 EQUB &E8
 EQUB &E2
 EQUB &E6
 EQUB &E7
 EQUB &C2
 EQUB &D1
 EQUB &C1
 EQUD &35237060
 EQUW &2265
 EQUB &45
 EQUB &52 \? <>XSA.FBRLtabescTUMEJC
 NOP

\ ******************************************************************************
\       Name: KEYBOARD
\ ******************************************************************************

.KEYBOARD

 LDY #9

.DKL2

 LDA KYTB-2,Y
 DKS4
 ASL A
 LDA #0
 ADC #FF
 EOR #FF
 STA (OSSC),Y
 DEY
 CPY #2
 BNE DKL2 \-ve INKEY
 LDA #16
 SED

.DKL3

 DKS4
 TAX
 BMI DK1
 CLC
 ADC #1
 BPL DKL3

.DK1

 CLD
 EOR #128
 STA (OSSC),Y
 LDX #1
 LDA #&80
 JSR OSBYTE
 TYA
 LDY #10
 STA (OSSC),Y
 LDX #2
 LDA #&80
 JSR OSBYTE
 TYA
 LDY #11
 STA (OSSC),Y
 LDX #3
 LDA #&80
 JSR OSBYTE
 TYA
 LDY #12
 STA (OSSC),Y
 LDY #14
 LDA &FE40
 STA (OSSC),Y

.DK2

 RTS

\ ******************************************************************************
\       Name: OSWVECS
\ ******************************************************************************

\ ......... Revectoring of OSWORD ...............................

.OSWVECS

 EQUW KEYBOARD
 EQUW PIXEL
 EQUW MSBAR
 EQUW WSCAN
 EQUW SC48
 EQUW DOT
 EQUW DODKS4
 EQUW HLOIN
 EQUW HANGER
 EQUW SOMEPROT
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE
 EQUW SAFE

\ Above vector lookup table is JSRed below, after registers are preserved.
\ OSSC points to the parameter block, and should not be corrupted.
\ Copy into SC if it may be corrupted.  End with an RTS

\ ******************************************************************************
\       Name: NWOSWD
\ ******************************************************************************

.NWOSWD

 BIT svn
 BMI notours
 CMP #240
 BCC notours
 STX OSSC
 STY OSSC+1
 PHA
 SBC #240
 ASL A
 TAX
 LDA OSWVECS,X
 STA JSRV+1
 LDA OSWVECS+1,X
 STA JSRV+2
 LDX OSSC

.JSRV

 JSR &FFFC \Poked over
 PLA
 LDX OSSC
 LDY OSSC+1

.SAFE

 RTS

\ ******************************************************************************
\       Name: notours
\ ******************************************************************************

.notours

 JMP &FFFC \~~

\ ******************************************************************************
\
\       Name: MSBAR
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Draw a specific indicator in the dashboard's missile bar
\
\ ------------------------------------------------------------------------------
\
\ Each indicator is a rectangle that's 3 pixels wide and 5 pixels high. If the
\ indicator is set to black, this effectively removes a missile.
\
\ Arguments:
\
\   X                   The number of the missile indicator to update (counting
\                       from right to left, so indicator NOMSL is the leftmost
\                       indicator)
\
\   Y                   The colour of the missile indicator:
\
\                         * &00 = black (no missile)
\
\                         * &0E = red (armed and locked)
\
\                         * &E0 = yellow/white (armed)
\
\                         * &EE = green/cyan (disarmed)
\
\ Returns:
\
\   Y                   Y is set to 0
\
\ ******************************************************************************

.MSBAR

 LDY #2
 LDA (OSSC),Y
 ASL A
 ASL A
 ASL A
 ASL A
 STA T

 LDA #97
 SBC T
 STA SC

                        \ So the low byte of SC(1 0) contains the row address
                        \ for the rightmost missile indicator, made up as
                        \ follows:
                        \
                        \   * 48 (character block 7, or byte #7 * 8 = 48, which
                        \     is the character block of the rightmost missile
                        \
                        \   * 1 (so we start drawing on the second row of the
                        \     character block)
                        \
                        \   * Move right one character (8 bytes) for each count
                        \     of X, so when X = 0 we are drawing the rightmost
                        \     missile, for X = 1 we hop to the left by one
                        \     character, and so on

 LDA #&7C
 STA SCH
 LDY #3
 LDA (OSSC),Y
 LDY #5

.MBL1

 STA (SC),Y
 DEY
 BNE MBL1
 PHA
 LDA SC
 CLC
 ADC #8
 STA SC
 PLA
 AND #&AA

 LDY #5                 \ We now want to draw this line five times, so set a
                        \ counter in Y

.MBL2

 STA (SC),Y             \ Draw the 3-pixel row, and as we do not use EOR logic,
                        \ this will overwrite anything that is already there
                        \ (so drawing a black missile will delete what's there)

 DEY                    \ Decrement the counter for the next row

 BNE MBL2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: WSCAN
\       Type: Subroutine
\   Category: Screen mode
\    Summary: Wait for the vertical sync
\
\ ------------------------------------------------------------------------------
\
\ Wait for vertical sync to occur on the video system - in other words, wait
\ for the screen to start its refresh cycle, which it does 50 times a second
\ (50Hz).
\
\ ******************************************************************************

.WSCAN

 LDA #0                 \ Set DL to 0
 STA DL

.WSCAN1

 LDA DL                 \ Loop round these two instructions until DL is no
 BEQ WSCAN1             \ longer 0 (DL gets set to 30 in the LINSCN routine,
                        \ which is run when vertical sync has occurred on the
                        \ video system, so DL will change to a non-zero value
                        \ at the start of each screen refresh)

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\       Name: DODKS4
\ ******************************************************************************

.DODKS4

 LDY #2
 LDA (OSSC),Y
 DKS4
 STA (OSSC),Y
 RTS

\ ******************************************************************************
\       Name: cls
\ ******************************************************************************

\ ............. Character Print .....................

.cls

 JSR TTX66
 JMP RR4

\ ******************************************************************************
\       Name: TT67
\ ******************************************************************************

.TT67

 LDA #12

\ ******************************************************************************
\
\       Name: TT26
\       Type: Subroutine
\   Category: Text
\    Summary: Print a character at the text cursor (WRCHV points here)
\
\ ------------------------------------------------------------------------------
\
\ Print a character at the text cursor (XC, YC), do a beep, print a newline,
\ or delete left (backspace).
\
\ WRCHV is set to point here by elite-loader.asm.
\
\ Arguments:
\
\   A                   The character to be printed. Can be one of the
\                       following:
\
\                         * 7 (beep)
\
\                         * 10-13 (line feeds and carriage returns)
\
\                         * 32-95 (ASCII capital letters, numbers and
\                           punctuation)
\
\                         * 127 (delete the character to the left of the text
\                           cursor and move the cursor to the left)
\
\   XC                  Contains the text column to print at (the x-coordinate)
\
\   YC                  Contains the line number to print on (the y-coordinate)
\
\ Returns:
\
\   A                   A is preserved
\
\   X                   X is preserved
\
\   Y                   Y is preserved
\
\   C flag              C flag is cleared
\
\ Other entry points:
\
\   RR3+1               Contains an RTS
\
\   RREN                Prints the character definition pointed to by P(2 1) at
\                       the screen address pointed to by (A SC). Used by the
\                       BULB routine
\
\   rT9                 Contains an RTS
\
\ ******************************************************************************

.TT26

 STA K3
 TYA
 PHA
 TXA
 PHA
 LDA K3
 TAY
 BEQ RR4S
 CMP #11
 BEQ cls
 CMP #7
 BNE P%+5
 JMP R5

 CMP #32                \ If this is an ASCII character (A >= 32), jump to RR1
 BCS RR1                \ below, which will print the character, restore the
                        \ registers and return from the subroutine

 CMP #10                \ If this is control code 10 (line feed) then jump to
 BEQ RRX1               \ RRX1, which will move down a line, restore the
                        \ registers and return from the subroutine

 LDX #1                 \ If we get here, then this is control code 11-13, of
 STX XC                 \ which only 13 is used. This code prints a newline,
                        \ which we can achieve by moving the text cursor
                        \ to the start of the line (carriage return) and down
                        \ one line (line feed). These two lines do the first
                        \ bit by setting XC = 1, and we then fall through into
                        \ the line feed routine that's used by control code 10

.RRX1

 CMP #13
 BEQ RR4S
 INC YC

.RR4S

 JMP RR4

.RR1

                        \ If we get here, then the character to print is an
                        \ ASCII character in the range 32-95. The quickest way
                        \ to display text on-screen is to poke the character
                        \ pixel by pixel, directly into screen memory, so
                        \ that's what the rest of this routine does
                        \
                        \ The first step, then, is to get hold of the bitmap
                        \ definition for the character we want to draw on the
                        \ screen (i.e. we need the pixel shape of this
                        \ character). The OS ROM contains bitmap definitions
                        \ of the BBC's ASCII characters, starting from &C000
                        \ for space (ASCII 32) and ending with the £ symbol
                        \ (ASCII 126)
                        \
                        \ There are 32 characters' definitions in each page of
                        \ memory, as each definition takes up 8 bytes (8 rows
                        \ of 8 pixels) and 32 * 8 = 256 bytes = 1 page. So:
                        \
                        \   ASCII 32-63  are defined in &C000-&C0FF (page &C0)
                        \   ASCII 64-95  are defined in &C100-&C1FF (page &C1)
                        \   ASCII 96-126 are defined in &C200-&C2F0 (page &C2)
                        \
                        \ The following code reads the relevant character
                        \ bitmap from the above locations in ROM and pokes
                        \ those values into the correct position in screen
                        \ memory, thus printing the character on-screen
                        \
                        \ It's a long way from 10 PRINT "Hello world!":GOTO 10

\LDX #LO(K3)            \ These instructions are commented out in the original
\INX                    \ source, but they call OSWORD &A, which reads the
\STX P+1                \ character bitmap for the character number in K3 and
\DEX                    \ stores it in the block at K3+1, while also setting
\LDY #HI(K3)            \ P+1 to point to the character definition. This is
\STY P+2                \ exactly what the following uncommented code does,
\LDA #10                \ just without calling OSWORD. Presumably the code
\JSR OSWORD             \ below is faster than using the system call, as this
                        \ version takes up 15 bytes, while the version below
                        \ (which ends with STA P+1 and SYX P+2) is 17 bytes.
                        \ Every efficiency saving helps, especially as this
                        \ routine is run each time the game prints a character
                        \
                        \ If you want to switch this code back on, uncomment
                        \ the above block, and comment out the code below from
                        \ TAY to STX P+2. You will also need to uncomment the
                        \ LDA YC instruction a few lines down (in RR2), just to
                        \ make sure the rest of the code doesn't shift in
                        \ memory. To be honest I can't see a massive difference
                        \ in speed, but there you go

 TAY                    \ Copy the character number from A to Y, as we are
                        \ about to pull A apart to work out where this
                        \ character definition lives in the ROM

                        \ Now we want to set X to point to the relevant page
                        \ number for this character - i.e. &C0, &C1 or &C2.
                        \ The following logic is easier to follow if we look
                        \ at the three character number ranges in binary:
                        \
                        \   Bit #  76543210
                        \
                        \   32  = %00100000     Page &C0
                        \   63  = %00111111
                        \
                        \   64  = %01000000     Page &C1
                        \   95  = %01011111
                        \
                        \   96  = %01100000     Page &C2
                        \   125 = %01111101
                        \
                        \ We'll refer to this below

 BPL P%+5
 JMP RR4
 LDX #(FONT%-1)

 ASL A                  \ If bit 6 of the character is clear (A is 32-63)
 ASL A                  \ then skip the following instruction
 BCC P%+4

 LDX #(FONT%+1)

 ASL A                  \ If bit 5 of the character is clear (A is 64-95)
 BCC P%+3               \ then skip the following instruction

 INX                    \ Increment X
                        \
                        \ By this point, we started with X = &BF, and then
                        \ we did the following:
                        \
                        \   If A = 32-63:   skip    then INX  so X = &C0
                        \   If A = 64-95:   X = &C1 then skip so X = &C1
                        \   If A = 96-126:  X = &C1 then INX  so X = &C2
                        \
                        \ In other words, X points to the relevant page. But
                        \ what about the value of A? That gets shifted to the
                        \ left three times during the above code, which
                        \ multiplies the number by 8 but also drops bits 7, 6
                        \ and 5 in the process. Look at the above binary
                        \ figures and you can see that if we cleared bits 5-7,
                        \ then that would change 32-53 to 0-31... but it would
                        \ do exactly the same to 64-95 and 96-125. And because
                        \ we also multiply this figure by 8, A now points to
                        \ the start of the character's definition within its
                        \ page (because there are 8 bytes per character
                        \ definition)
                        \
                        \ Or, to put it another way, X contains the high byte
                        \ (the page) of the address of the definition that we
                        \ want, while A contains the low byte (the offset into
                        \ the page) of the address

 STA Q
 STX R
 LDA XC
 LDX CATF
 BEQ RR5
 CPY #32
 BNE RR5
 CMP #17
 BEQ RR4

.RR5

 ASL A                  \ Multiply A by 8, and store in SC. As each
 ASL A                  \ character is 8 bits wide, and the special screen mode
 ASL A                  \ Elite uses for the top part of the screen is 256
 STA SC                 \ bits across with one bit per pixel, this value is
                        \ not only the screen address offset of the text cursor
                        \ from the left side of the screen, it's also the least
                        \ significant byte of the screen address where we want
                        \ to print this character, as each row of on-screen
                        \ pixels corresponds to one page. To put this more
                        \ explicitly, the screen starts at &6000, so the
                        \ text rows are stored in screen memory like this:
                        \
                        \   Row 1: &6000 - &60FF    YC = 1, XC = 0 to 31
                        \   Row 2: &6100 - &61FF    YC = 2, XC = 0 to 31
                        \   Row 3: &6200 - &62FF    YC = 3, XC = 0 to 31
                        \
                        \ and so on

 LDA YC                 \ Fetch YC, the y-coordinate (row) of the text cursor

 CPY #127               \ If the character number (which is in Y) <> 127, then
 BNE RR2                \ skip to RR2 to print that character, otherwise this is
                        \ the delete character, so continue on

 DEC XC                 \ We want to delete the character to the left of the
                        \ text cursor and move the cursor back one, so let's
                        \ do that by decrementing YC. Note that this doesn't
                        \ have anything to do with the actual deletion below,
                        \ we're just updating the cursor so it's in the right
                        \ position following the deletion

 ASL A
 ASL SC
 ADC #&3F
 TAX

                        \ Because YC starts at 0 for the first text row, this
                        \ means that X will be &5F for row 0, &60 for row 1 and
                        \ so on. In other words, X is now set to the page number
                        \ for the row before the one containing the text cursor,
                        \ and given that we set SC above to point to the offset
                        \ in memory of the text cursor within the row's page,
                        \ this means that (X SC) now points to the character
                        \ above the text cursor

 LDY #&F0

 JSR ZES2               \ Call ZES2, which zero-fills from address (X SC) + Y to
                        \ (X SC) + &FF. (X SC) points to the character above the
                        \ text cursor, and adding &FF to this would point to the
                        \ cursor, so adding &F8 points to the character before
                        \ the cursor, which is the one we want to delete. So
                        \ this call zero-fills the character to the left of the
                        \ cursor, which erases it from the screen

 BEQ RR4                \ We are done deleting, so restore the registers and
                        \ return from the subroutine (this BNE is effectively
                        \ a JMP as ZES2 always returns with the Z flag set)

.RR2

                        \ Now to actually print the character

 INC XC                 \ Once we print the character, we want to move the text
                        \ cursor to the right, so we do this by incrementing
                        \ XC. Note that this doesn't have anything to do
                        \ with the actual printing below, we're just updating
                        \ the cursor so it's in the right position following
                        \ the print

\LDA YC                 \ This instruction is commented out in the original
                        \ source. It isn't required because we only just did a
                        \ LDA YC before jumping to RR2, so this is presumably
                        \ an example of the authors squeezing the code to save
                        \ 2 bytes and 3 cycles
                        \
                        \ If you want to re-enable the commented block near the
                        \ start of this routine, you should uncomment this
                        \ instruction as well

 CMP #24                \ If the text cursor is on the screen (i.e. YC < 24, so
 BCC RR3                \ we are on rows 1-23), then jump to RR3 to print the
                        \ character

 PHA

 JSR TTX66              \ Otherwise we are off the bottom of the screen, so
                        \ clear the screen and draw a white border

 LDA #1
 STA XC
 STA YC
 PLA
 LDA K3

 JMP RR4                \ And restore the registers and return from the
                        \ subroutine

.RR3

 ASL A
 ASL SC
 ADC #&40

.RREN

 STA SC+1               \ Store the page number of the destination screen
                        \ location in SC+1, so SC now points to the full screen
                        \ location where this character should go

 LDA SC
 CLC
 ADC #8
 STA S
 LDA SC+1
 STA T

 LDY #7                 \ We want to print the 8 bytes of character data to the
                        \ screen (one byte per row), so set up a counter in Y
                        \ to count these bytes

.RRL1

 LDA (Q),Y
 AND #&F0
 STA U
 LSR A
 LSR A
 LSR A
 LSR A
 ORA U
 AND COL

 EOR (SC),Y             \ If we EOR this value with the existing screen
                        \ contents, then it's reversible (so reprinting the
                        \ same character in the same place will revert the
                        \ screen to what it looked like before we printed
                        \ anything); this means that printing a white pixel on
                        \ onto a white background results in a black pixel, but
                        \ that's a small price to pay for easily erasable text

 STA (SC),Y             \ Store the Y-th byte at the screen address for this
                        \ character location

 LDA (Q),Y
 AND #&F
 STA U
 ASL A
 ASL A
 ASL A
 ASL A
 ORA U
 AND COL
 EOR (S),Y
 STA (S),Y

 DEY                    \ Decrement the loop counter

 BPL RRL1               \ Loop back for the next byte to print to the screen

.RR4

 PLA
 TAX
 PLA
 TAY
 LDA K3

.rT9

 RTS                    \ Return from the subroutine

.R5

 LDX #(BELI MOD256)
 LDY #(BELI DIV256)
 JSR OSWORD
 JMP RR4

.BELI

 EQUW &12
 EQUW &FFF1
 EQUW 200
 EQUW 2

\ ******************************************************************************
\       Name: TTX66
\ ******************************************************************************

.TTX66

 LDX #&40

.BOL1

 JSR ZES1
 INX
 CPX #&70
 BNE BOL1

.BOX

 LDA #&F
 STA COL
 LDY #1
 STY YC
 LDY #11
 STY XC
 LDX #0
 STX X1
 STX Y1
 STX Y2
\STXQQ17
 DEX
 STX X2
 JSR LOIN
 LDA #2
 STA X1
 STA X2
 JSR BOS2

.BOS2

 JSR BOS1

.BOS1

 LDA #0
 STA Y1
 LDA #2*Y-1
 STA Y2
 DEC X1
 DEC X2
 JSR LOIN
 LDA #&F
 STA &4000
 STA &41F8
 RTS

\ ******************************************************************************
\
\       Name: ZES1
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Zero-fill the page whose number is in X
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   The page we want to zero-fill
\
\ ******************************************************************************

.ZES1

 LDY #0                 \ If we set Y = SC = 0 and fall through into ZES2
 STY SC                 \ below, then we will zero-fill 255 bytes starting from
                        \ SC - in other words, we will zero-fill the whole of
                        \ page X

\ ******************************************************************************
\
\       Name: ZES2
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Zero-fill a specific page
\
\ ------------------------------------------------------------------------------
\
\ Zero-fill from address (X SC) + Y to (X SC) + &FF.
\
\ Arguments:
\
\   X                   The high byte (i.e. the page) of the starting point of
\                       the zero-fill
\
\   Y                   The offset from (X SC) where we start zeroing, counting
\                       up to to &FF
\
\   SC                  The low byte (i.e. the offset into the page) of the
\                       starting point of the zero-fill
\
\ Returns:
\
\   Z flag              Z flag is set
\
\ ******************************************************************************

.ZES2

 LDA #0                 \ Load A with the byte we want to fill the memory block
                        \ with - i.e. zero

 STX SC+1               \ We want to zero-fill page X, so store this in the
                        \ high byte of SC, so the 16-bit address in SC and
                        \ SC+1 is now pointing to the SC-th byte of page X

.ZEL1

 STA (SC),Y             \ Zero the Y-th byte of the block pointed to by SC,
                        \ so that's effectively the Y-th byte before SC

 INY                    \ Increment the loop counter

 BNE ZEL1               \ Loop back to zero the next byte

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\       Name: SETXC
\ ******************************************************************************

.SETXC

 STA XC
 JMP PUTBACK
\ ******************************************************************************
\       Name: SETYC
\ ******************************************************************************

.SETYC

 STA YC
 JMP PUTBACK

\ ******************************************************************************
\       Name: SOMEPROT
\ ******************************************************************************

.SOMEPROT

 LDY #2

.SMEPRTL

 LDA do65C02-2,Y
 STA (OSSC),Y
 INY
 CPY #protlen+2
 BCC SMEPRTL
 RTS

\ ******************************************************************************
\       Name: CLYNS
\ ******************************************************************************

.CLYNS

 LDA #20
 STA YC
 LDA #&6A
 STA SC+1
 JSR TT67
 LDA #0
 STA SC
 LDX #3

.CLYL

 LDY #8

.EE2

 STA (SC),Y
 INY
 BNE EE2
 INC SC+1
 STA (SC),Y
 LDY #&F7

.EE3

 STA (SC),Y
 DEY
 BNE EE3
 INC SC+1
 DEX
 BNE CLYL
\INX\STXSC
 JMP PUTBACK

\ ******************************************************************************
\
\       Name: DIALS (Part 1 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: speed indicator
\
\ ------------------------------------------------------------------------------
\
\ This routine updates the dashboard. First we draw all the indicators in the
\ right part of the dashboard, from top (speed) to bottom (energy banks), and
\ then we move on to the left part, again drawing from top (forward shield) to
\ bottom (altitude).
\
\ This first section starts us off with the speedometer in the top right.
\
\ ******************************************************************************

.DIALS

 LDA #1
 STA VIA+&E
 LDA #&A0
 STA SC
 LDA #&71
 STA SC+1
 JSR PZW2

 STX K+1                \ Set K+1 (the colour we should show for low values) to
                        \ X (the colour to use for safe values)

 STA K                  \ Set K (the colour we should show for high values) to
                        \ A (the colour to use for dangerous values)

                        \ The above sets the following indicators to show red
                        \ for high values and yellow/white for low values

 LDA #14                \ Set T1 to 14, the threshold at which we change the
 STA T1                 \ indicator's colour

 LDA DELTA              \ Fetch our ship's speed into A, in the range 0-40

\LSR A                  \ Draw the speed indicator using a range of 0-31, and
 JSR DIL-1              \ increment SC to point to the next indicator (the roll
                        \ indicator). The LSR is commented out as it isn't
                        \ required with a call to DIL-1, so perhaps this was
                        \ originally a call to DIL that got optimised

\ ******************************************************************************
\
\       Name: DIALS (Part 2 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: pitch and roll indicators
\
\ ******************************************************************************

 LDA #0                 \ Set R = P = 0 for the low bytes in the call to the ADD
 STA R                  \ routine below
 STA P

 LDA #8                 \ Set S = 8, which is the value of the centre of the
 STA S                  \ roll indicator

 LDA ALP1               \ Fetch the roll angle alpha as a value between 0 and
 LSR A                  \ 31, and divide by 4 to get a value of 0 to 7
 LSR A

 ORA ALP2               \ Apply the roll sign to the value, and flip the sign,
 EOR #%10000000         \ so it's now in the range -7 to +7, with a positive
                        \ roll angle alpha giving a negative value in A

 JSR ADD                \ We now add A to S to give us a value in the range 1 to
                        \ 15, which we can pass to DIL2 to draw the vertical
                        \ bar on the indicator at this position. We use the ADD
                        \ routine like this:
                        \
                        \ (A X) = (A 0) + (S 0)
                        \
                        \ and just take the high byte of the result. We use ADD
                        \ rather than a normal ADC because ADD separates out the
                        \ sign bit and does the arithmetic using absolute values
                        \ and separate sign bits, which we want here rather than
                        \ the two's complement that ADC uses

 JSR DIL2               \ Draw a vertical bar on the roll indicator at offset A
                        \ and increment SC to point to the next indicator (the
                        \ pitch indicator)

 LDA BETA               \ Fetch the pitch angle beta as a value between -8 and
                        \ +8

 LDX BET1               \ Fetch the magnitude of the pitch angle beta, and if it
 BEQ P%+4               \ is 0 (i.e. we are not pitching), skip the next
                        \ instruction

 SBC #1                 \ The pitch angle beta is non-zero, so set A = A - 1
                        \ (the C flag is set by the call to DIL2 above, so we
                        \ don't need to do a SEC). This gives us a value of A
                        \ from -7 to +7 because these are magnitude-based
                        \ numbers with sign bits, rather than two's complement
                        \ numbers

 JSR ADD                \ We now add A to S to give us a value in the range 1 to
                        \ 15, which we can pass to DIL2 to draw the vertical
                        \ bar on the indicator at this position (see the JSR ADD
                        \ above for more on this)

 JSR DIL2               \ Draw a vertical bar on the pitch indicator at offset A
                        \ and increment SC to point to the next indicator (the
                        \ four energy banks)

\ ******************************************************************************
\
\       Name: DIALS (Part 3 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: four energy banks
\
\ ------------------------------------------------------------------------------
\
\ This and the next section only run once every four iterations of the main
\ loop, so while the speed, pitch and roll indicators update every iteration,
\ the other indicators update less often.
\
\ ******************************************************************************

 LDY #0                 \ Set Y = 0, for use in various places below

 JSR PZW                \ Call PZW to set A to the colour for dangerous values
                        \ and X to the colour for safe values

 STX K                  \ Set K (the colour we should show for high values) to X
                        \ (the colour to use for safe values)

 STA K+1                \ Set K+1 (the colour we should show for low values) to
                        \ A (the colour to use for dangerous values)

                        \ The above sets the following indicators to show red
                        \ for low values and yellow/white for high values, which
                        \ we use not only for the energy banks, but also for the
                        \ shield levels and current fuel

 LDX #3                 \ Set up a counter in X so we can zero the four bytes at
                        \ XX15, so we can then calculate each of the four energy
                        \ banks' values before drawing them later

 STX T1                 \ Set T1 to 3, the threshold at which we change the
                        \ indicator's colour

.DLL23

 STY XX15,X             \ Set the X-th byte of XX15 to 0

 DEX                    \ Decrement the counter

 BPL DLL23              \ Loop back for the next byte until the four bytes at
                        \ XX12 are all zeroed

 LDX #3                 \ Set up a counter in X to loop through the 4 energy
                        \ bank indicators, so we can calculate each of the four
                        \ energy banks' values and store them in XX12

 LDA ENERGY             \ Set A = Q = ENERGY / 4, so they are both now in the
 LSR A                  \ range 0-63 (so that's a maximum of 16 in each of the
 LSR A                  \ banks, and a maximum of 15 in the top bank)

 STA Q                  \ Set Q to A, so we can use Q to hold the remaining
                        \ energy as we work our way through each bank, from the
                        \ full ones at the bottom to the empty ones at the top

.DLL24

 SEC                    \ Set A = A - 16 to reduce the energy count by a full
 SBC #16                \ bank

 BCC DLL26              \ If the C flag is clear then A < 16, so this bank is
                        \ not full to the brim, and is therefore the last one
                        \ with any energy in it, so jump to DLL26

 STA Q                  \ This bank is full, so update Q with the energy of the
                        \ remaining banks

 LDA #16                \ Store this bank's level in XX15 as 16, as it is full,
 STA XX15,X             \ with XX15+3 for the bottom bank and XX15+0 for the top

 LDA Q                  \ Set A to the remaining energy level again

 DEX                    \ Decrement X to point to the next bank, i.e. the one
                        \ above the bank we just processed

 BPL DLL24              \ Loop back to DLL24 until we have either processed all
                        \ four banks, or jumped out early to DLL26 if the top
                        \ banks have no charge

 BMI DLL9               \ Jump to DLL9 as we have processed all four banks (this
                        \ BMI is effectively a JMP as A will never be positive)

.DLL26

 LDA Q                  \ If we get here then the bank we just checked is not
 STA XX15,X             \ fully charged, so store its value in XX15 (using Q,
                        \ which contains the energy of the remaining banks -
                        \ i.e. this one)

                        \ Now that we have the four energy bank values in XX12,
                        \ we can draw them, starting with the top bank in XX12
                        \ and looping down to the bottom bank in XX12+3, using Y
                        \ as a loop counter, which was set to 0 above

.DLL9

 LDA XX15,Y             \ Fetch the value of the Y-th indicator, starting from
                        \ the top

 STY P                  \ Store the indicator number in P for retrieval later

 JSR DIL                \ Draw the energy bank using a range of 0-15, and
                        \ increment SC to point to the next indicator (the
                        \ next energy bank down)

 LDY P                  \ Restore the indicator number into Y

 INY                    \ Increment the indicator number

 CPY #4                 \ Check to see if we have drawn the last energy bank

 BNE DLL9               \ Loop back to DLL9 if we have more banks to draw,
                        \ otherwise we are done

\ ******************************************************************************
\
\       Name: DIALS (Part 4 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: shields, fuel, laser & cabin temp, altitude
\
\ ******************************************************************************

 LDA #&70               \ Set SC(1 0) = &7020, which is the screen address for
 STA SC+1               \ the character block containing the left end of the
 LDA #&20               \ top indicator in the left part of the dashboard, the
 STA SC                 \ one showing the forward shield

 LDA FSH                \ Draw the forward shield indicator using a range of
 JSR DILX               \ 0-255, and increment SC to point to the next indicator
                        \ (the aft shield)

 LDA ASH                \ Draw the aft shield indicator using a range of 0-255,
 JSR DILX               \ and increment SC to point to the next indicator (the
                        \ fuel level)

 LDA #YELLOW2
 STA K
 STA K+1

 LDA QQ14               \ Draw the fuel level indicator using a range of 0-63,
 JSR DILX+2             \ and increment SC to point to the next indicator (the
                        \ cabin temperature)

 JSR PZW2

 STX K+1                \ Set K+1 (the colour we should show for low values) to
                        \ X (the colour to use for safe values)

 STA K                  \ Set K+1 (the colour we should show for high values) to
                        \ A (the colour to use for dangerous values)

                        \ The above sets the following indicators to show red
                        \ for high values and yellow/white for low values, which
                        \ we use for the cabin and laser temperature bars

 LDX #11                \ Set T1 to 11, the threshold at which we change the
 STX T1                 \ cabin and laser temperature indicators' colours

 LDA CABTMP             \ Draw the cabin temperature indicator using a range of
 JSR DILX               \ 0-255, and increment SC to point to the next indicator
                        \ (the laser temperature)

 LDA GNTMP              \ Draw the laser temperature indicator using a range of
 JSR DILX               \ 0-255, and increment SC to point to the next indicator
                        \ (the altitude)

 LDA #240               \ Set T1 to 240, the threshold at which we change the
 STA T1                 \ altitude indicator's colour. As the altitude has a
                        \ range of 0-255, pixel 16 will not be filled in, and
                        \ 240 would change the colour when moving between pixels
                        \ 15 and 16, so this effectively switches off the colour
                        \ change for the altitude indicator

 LDA #YELLOW2
 STA K

 STA K+1                \ Set K+1 (the colour we should show for low values) to
                        \ 240, or &F0 (dashboard colour 2, yellow/white), so the
                        \ altitude indicator always shows in this colour

 LDA ALTIT              \ Draw the altitude indicator using a range of 0-255,
 JMP DILX               \ returning from the subroutine using a tail call

\ ******************************************************************************
\       Name: PZW2
\ ******************************************************************************

.PZW2

 LDX #WHITE2
 EQUB &2C

\ ******************************************************************************
\
\       Name: PZW
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Fetch the current dashboard colours, to support flashing
\
\ ------------------------------------------------------------------------------
\
\ Set A and X to the colours we should use for indicators showing dangerous and
\ safe values respectively. This enables us to implement flashing indicators,
\ which is one of the game's configurable options. If flashing is enabled, the
\ colour returned in A (dangerous values) will be red for 8 iterations of the
\ main loop, and yellow/white for the next 8, before going back to red. If we
\ always use PZW to decide which colours we should use when updating indicators,
\ flashing colours will be automatically taken care of for us.
\
\ The values returned are &F0 for yellow/white and &0F for red. These are mode 5
\ bytes that contain 4 pixels, with the colour of each pixel given in two bits,
\ the high bit from the first nibble (bits 4-7) and the low bit from the second
\ nibble (bits 0-3). So in &F0 each pixel is %10, or colour 2 (yellow or white,
\ depending on the dashboard palette), while in &0F each pixel is %01, or colour
\ 1 (red).
\
\ Returns:
\
\   A                   The colour to use for indicators with dangerous values
\
\   X                   The colour to use for indicators with safe values
\
\ ******************************************************************************

.PZW

 LDX #STRIPE

 LDA MCNT               \ A will be non-zero for 8 out of every 16 main loop
 AND #%00001000         \ counts, when bit 4 is set, so this is what we use to
                        \ flash the "danger" colour

 AND FLH                \ A will be zeroed if flashing colours are disabled

 BEQ P%+5
 LDA #GREEN2
 RTS
 LDA #RED2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DILX
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update a bar-based indicator on the dashboard
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ The range of values shown on the indicator depends on which entry point is
\ called. For the default entry point of DILX, the range is 0-255 (as the value
\ passed in A is one byte). The other entry points are shown below.
\
\ Arguments:
\
\   A                   The value to be shown on the indicator (so the larger
\                       the value, the longer the bar)
\
\   T1                  The threshold at which we change the indicator's colour
\                       from the low value colour to the high value colour. The
\                       threshold is in pixels, so it should have a value from
\                       0-16, as each bar indicator is 16 pixels wide
\
\   K                   The colour to use when A is a high value, as a 4-pixel
\                       mode 5 character row byte
\
\   K+1                 The colour to use when A is a low value, as a 4-pixel
\                       mode 5 character row byte
\
\   SC(1 0)             The screen address of the first character block in the
\                       indicator
\
\ Other entry points:
\
\   DILX+2              The range of the indicator is 0-64 (for the fuel
\                       indicator)
\
\   DIL-1               The range of the indicator is 0-32 (for the speed
\                       indicator)
\
\   DIL                 The range of the indicator is 0-16 (for the energy
\                       banks)
\
\ ******************************************************************************

.DILX

 LSR A                  \ If we call DILX, we set A = A / 16, so A is 0-15
 LSR A

 LSR A                  \ If we call DILX+2, we set A = A / 4, so A is 0-15

 LSR A                  \ If we call DIL-1, we set A = A / 2, so A is 0-15

.DIL

                        \ If we call DIL, we leave A alone, so A is 0-15

 STA Q                  \ Store the indicator value in Q, now reduced to 0-15,
                        \ which is the length of the indicator to draw in pixels

 LDX #&FF               \ Set R = &FF, to use as a mask for drawing each row of
 STX R                  \ each character block of the bar, starting with a full
                        \ character's width of 4 pixels

 CMP T1                 \ If A >= T1 then we have passed the threshold where we
 BCS DL30               \ change bar colour, so jump to DL30 to set A to the
                        \ "high value" colour

 LDA K+1                \ Set A to K+1, the "low value" colour to use

 BNE DL31               \ Jump down to DL31 (this BNE is effectively a JMP as A
                        \ will never be zero)

.DL30

 LDA K                  \ Set A to K, the "high value" colour to use

.DL31

 STA COL                \ Store the colour of the indicator in COL

 LDY #2                 \ We want to start drawing the indicator on the third
                        \ line in this character row, so set Y to point to that
                        \ row's offset

 LDX #7

.DL1

 LDA Q                  \ Fetch the indicator value (0-15) from Q into A

 CMP #2
 BCC DL2
 SBC #2
 STA Q

 LDA R                  \ Fetch the shape of the indicator row that we need to
                        \ display from R, so we can use it as a mask when
                        \ painting the indicator. It will be &FF at this point
                        \ (i.e. a full 4-pixel row)

.DL5

 AND COL                \ Fetch the 4-pixel mode 5 colour byte from COL, and
                        \ only keep pixels that have their equivalent bits set
                        \ in the mask byte in A

 STA (SC),Y             \ Draw the shape of the mask on pixel row Y of the
                        \ character block we are processing

 INY                    \ Draw the next pixel row, incrementing Y
 STA (SC),Y

 INY                    \ And draw the third pixel row, incrementing Y
 STA (SC),Y

 TYA                    \ Add 6 to Y, so Y is now 8 more than when we started
 CLC                    \ this loop iteration, so Y now points to the address
 ADC #6                 \ of the first line of the indicator bar in the next
 TAY                    \ character block (as each character is 8 bytes of
                        \ screen memory)

 DEX                    \ Decrement the loop counter for the next character
                        \ block along in the indicator

 BMI DL6                \ If we just drew the last character block then we are
                        \ done drawing, so jump down to DL6 to finish off

 BPL DL1                \ Loop back to DL1 to draw the next character block of
                        \ the indicator (this BPL is effectively a JMP as A will
                        \ never be negative following the previous BMI)

.DL2

 EOR #1
 STA Q

 LDA R                  \ Fetch the current mask from R, which will be &FF at
                        \ this point, so we need to turn Q of the columns on the
                        \ right side of the mask to black to get the correct end
                        \ cap shape for the indicator

.DL3

 ASL A
 AND #&AA

 DEC Q                  \ Decrement the counter for the number of columns to
                        \ blank out

 BPL DL3                \ If we still have columns to blank out in the mask,
                        \ loop back to DL3 until the mask is correct for the
                        \ end cap

 PHA                    \ Store the mask byte on the stack while we use the
                        \ accumulator for a bit

 LDA #0                 \ Change the mask so no bits are set, so the characters
 STA R                  \ after the one we're about to draw will be all blank

 LDA #99                \ Set Q to a high number (99, why not) so we will keep
 STA Q                  \ drawing blank characters until we reach the end of
                        \ the indicator row

 PLA                    \ Restore the mask byte from the stack so we can use it
                        \ to draw the end cap of the indicator

 JMP DL5                \ Jump back up to DL5 to draw the mask byte on-screen

.DL6

 INC SC+1               \ Increment the high byte of SC to point to the next
                        \ character row on-screen (as each row takes up exactly
                        \ one page of 256 bytes) - so this sets up SC to point
                        \ to the next indicator, i.e. the one below the one we
                        \ just drew

 INC SC+1

.DL9                    \ This label is not used but is in the original source

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DIL2
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the roll or pitch indicator on the dashboard
\
\ ------------------------------------------------------------------------------
\
\ The indicator can show a vertical bar in 16 positions, with a value of 8
\ showing the bar in the middle of the indicator.
\
\ In practice this routine is only ever called with A in the range 1 to 15, so
\ the vertical bar never appears in the leftmost position (though it does appear
\ in the rightmost).
\
\ Arguments:
\
\   A                   The offset of the vertical bar to show in the indicator,
\                       from 0 at the far left, to 8 in the middle, and 15 at
\                       the far right
\
\ Returns:
\
\   C flag              C flag is set
\
\ ******************************************************************************

.DIL2

 LDY #1                 \ We want to start drawing the vertical indicator bar on
                        \ the second line in the indicator's character block, so
                        \ set Y to point to that row's offset

 STA Q                  \ Store the offset of the vertical bar to draw in Q

                        \ We are now going to work our way along the indicator
                        \ on the dashboard, from left to right, working our way
                        \ along one character block at a time. Y will be used as
                        \ a pixel row counter to work our way through the
                        \ character blocks, so each time we draw a character
                        \ block, we will increment Y by 8 to move on to the next
                        \ block

.DLL10

 SEC
 LDA Q
 SBC #2

 BCS DLL11              \ If Q >= 4 then the character block we are drawing does
                        \ not contain the vertical indicator bar, so jump to
                        \ DLL11 to draw a blank character block

 LDA #&FF               \ Set A to a high number (and &FF is as high as they go)

 LDX Q                  \ Set X to the offset of the vertical bar, which is
                        \ within this character block as Q < 4

 STA Q                  \ Set Q to a high number (&FF, why not) so we will keep
                        \ drawing blank characters after this one until we reach
                        \ the end of the indicator row

 LDA CTWOS,X            \ CTWOS is a table of ready-made 1-pixel mode 5 bytes,
                        \ just like the TWOS and TWOS2 tables for mode 4 (see
                        \ the PIXEL routine for details of how they work). This
                        \ fetches a mode 5 1-pixel byte with the pixel position
                        \ at X, so the pixel is at the offset that we want for
                        \ our vertical bar

 AND #WHITE2

 BNE DLL12              \ If A is non-zero then we have something to draw, so
                        \ jump to DLL12 to skip the following and move on to the
                        \ drawing

.DLL11

                        \ If we get here then we want to draw a blank for this
                        \ character block

 STA Q                  \ Update Q with the new offset of the vertical bar, so
                        \ it becomes the offset after the character block we
                        \ are about to draw

 LDA #0                 \ Change the mask so no bits are set, so all of the
                        \ character blocks we display from now on will be blank
.DLL12

 STA (SC),Y             \ Draw the shape of the mask on pixel row Y of the
                        \ character block we are processing

 INY                    \ Draw the next pixel row, incrementing Y
 STA (SC),Y

 INY                    \ And draw the third pixel row, incrementing Y
 STA (SC),Y

 INY                    \ And draw the fourth pixel row, incrementing Y
 STA (SC),Y

 TYA                    \ Add 5 to Y, so Y is now 8 more than when we started
 CLC                    \ this loop iteration, so Y now points to the address
 ADC #5                 \ of the first line of the indicator bar in the next
 TAY                    \ character block (as each character is 8 bytes of
                        \ screen memory)

 CPY #60                \ If Y < 60 then we still have some more character
 BCC DLL10              \ blocks to draw, so loop back to DLL10 to display the
                        \ next one along

 INC SC+1               \ Increment the high byte of SC to point to the next
                        \ character row on-screen (as each row takes up exactly
                        \ one page of 256 bytes) - so this sets up SC to point
                        \ to the next indicator, i.e. the one below the one we
                        \ just drew

 INC SC+1

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\       Name: TVT1
\ ******************************************************************************

.TVT1

 EQUD &16254334
 EQUD &52617086
 EQUD &96A5B4C3
 EQUD &D2E1F007 \Dials

\ ******************************************************************************
\       Name: do65C02, whiz
\ ******************************************************************************

.do65C02

.whiz

 LDA (0)
 PHA
 LDA (2)
 STA (0)
 PLA
 STA (2)
\NOP\NOP\NOP\NOP
 INC 0
 BNE P%+4
 INC 1
 LDA 2
 BNE P%+4
 DEC 3
 DEC 2 \SC = 2
 DEA
 CMP 0
 LDA 3
 SBC 1
 BCS whiz
 JMP (0,X)
.end65C02

\**
protlen = end65C02-do65C02

\ ******************************************************************************
\
\       Name: IRQ1
\       Type: Subroutine
\   Category: Screen mode
\    Summary: The main screen-mode interrupt handler (IRQ1V points here)
\  Deep dive: The split-screen mode
\
\ ------------------------------------------------------------------------------
\
\ The main interrupt handler, which implements Elite's split-screen mode (see
\ the deep dive on "The split-screen mode" for details).
\
\ IRQ1V is set to point to IRQ1 by elite-loader.asm.
\
\ ******************************************************************************

.IRQ1

 TYA                    \ Store Y on the stack
 PHA

 LDY #15

 LDA #%00000010         \ Read the 6522 System VIA status byte bit 1, which is
 BIT SHEILA+&4D         \ set if vertical sync has occurred on the video system

 BNE LINSCN             \ If we are on the vertical sync pulse, jump to LINSCN
                        \ to set up the timers to enable us to switch the
                        \ screen mode between the space view and dashboard

 BVC jvec               \ Read the 6522 System VIA status byte bit 6, which is
                        \ set if timer 1 has timed out. We set the timer in
                        \ LINSCN above, so this means we only run the next bit
                        \ if the screen redraw has reached the boundary between
                        \ the mode 4 and mode 5 screens (i.e. the top of the
                        \ dashboard). Otherwise bit 6 is clear and we aren't at
                        \ the boundary, so we jump to jvec to pass control to
                        \ the next interrupt handler

 LDA #&14

 STA SHEILA+&20         \ Set Video ULA control register (SHEILA+&20) to
                        \ %00000100, which is the same as switching to mode 5,
                        \ (i.e. the bottom part of the screen) but with no
                        \ cursor

 LDA ESCP
 AND #4
 EOR #&34
 STA &FE21\ESCP

.VNT2

 LDA TVT1,Y
 STA &FE21
 DEY
 BNE VNT2

.jvec

 PLA                    \ Restore Y from the stack
 TAY

 JMP (VEC)              \ Jump to the address in VEC, which was set to the
                        \ original IRQ1V vector by elite-loader.asm, so this
                        \ instruction passes control to the next interrupt
                        \ handler

.LINSCN

                        \ This is called from the interrupt handler below, at
                        \ the start of each vertical sync (i.e. when the screen
                        \ refresh starts)

 LDA #30                \ Set the line scan counter to a non-zero value, so
 STA DL                 \ routines like WSCAN can set DL to 0 and then wait for
                        \ it to change to non-zero to catch the vertical sync

 STA SHEILA+&44         \ Set 6522 System VIA T1C-L timer 1 low-order counter
                        \ (SHEILA &44) to 30

 LDA #VSCAN             \ Set 6522 System VIA T1C-L timer 1 high-order counter
 STA SHEILA+&45         \ (SHEILA &45) to VSCAN (57) to start the T1 counter
                        \ counting down from 14622 at a rate of 1 MHz

 LDA HFX
 BNE jvec
 LDA #&18
 STA &FE20

.VNT3

 LDA TVT3,Y
 STA &FE21
 DEY
 BNE VNT3

 PLA                    \ Otherwise restore Y from the stack
 TAY

 LDA SHEILA+&41         \ Read 6522 System VIA input register IRA (SHEILA &41)

 LDA &FC                \ Set A to the interrupt accumulator save register,
                        \ which restores A to the value it had on entering the
                        \ interrupt

 RTI                    \ Return from interrupts, so this interrupt is not
                        \ passed on to the next interrupt handler, but instead
                        \ the interrupt terminates here

\ ******************************************************************************
\       Name: SETVDU19
\ ******************************************************************************

.SETVDU19

 STA VNT3+1
 JMP PUTBACK

\ ******************************************************************************
\
\ Save output/I.CODE.bin
\
\ ******************************************************************************

PRINT "I.CODE"
PRINT "Assembled at ", ~CODE%
PRINT "Ends at ", ~P%
PRINT "Code size is ", ~(P% - CODE%)
PRINT "Execute at ", ~LOAD%
PRINT "Reload at ", ~LOAD%
PRINT "protlen = ", ~protlen

PRINT "S.I.CODE ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/I.CODE.bin", CODE%, P%, LOAD%

\INPUT"Insert destination disk and hit RETURN"A$
\OSCLI("S.I.CODE "+STR$~W%+" "+STR$~O%+" FFFF"+STR$~STARTUP+" FFFF"+STR$~H%)
\PRINT"CODE:";~C%",";~P%" (";&4000-P%" Free)  ZP:";~ZP;"Prot: ";~protlen
