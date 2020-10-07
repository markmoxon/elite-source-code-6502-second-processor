\ ******************************************************************************
\
\ TUBE ELITE I/O LOADER (PART 1) SOURCE
\
\ The original 1984 source code is copyright Ian Bell and David Braben, and the
\ code on this site is identical to the version released by the authors on Ian
\ Bell's personal website at http://www.iancgbell.clara.net/elite/
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ ******************************************************************************

C% = &2000
L% = C%
D% = &D000
LC% = &8000-C%
svn = &7FFD
N% = 77

OSWRCH = &FFEE
OSBYTE = &FFF4
OSWORD = &FFF1
SCLI = &FFF7
IRQ1V = &204
ZP = &90
P = &92
Q = &93
YY = &94
T = &95
Z1 = ZP
Z2 = P
FF = &FF
VIA = &FE40

CODE% = &2000
LOAD% = &2000

ORG CODE%

.B%

 EQUB 22,1,28,2,17,15,16
 EQUB 23,0, 6,31,0,0,0,0,0,0
 EQUB 23,0,12, 8,0,0,0,0,0,0
 EQUB 23,0,13, 0,0,0,0,0,0,0
 EQUB 23,0, 1,64,0,0,0,0,0,0
 EQUB 23,0, 2,90,0,0,0,0,0,0
 EQUB 23,0,10,32,0,0,0,0,0,0
 EQUB 23,0,&87,34,0,0,0,0,0,0

.E%

 EQUB 1,1,0,111,-8,4,1,8, 8,-2,0,-1,126,44
 EQUB 2,1,14,-18,-1,44,32,50, 6,1,0,-2,120,126
 EQUB 3,1,1,-1,-3,17,32,128,1,0,0,-1,1,1
 EQUB 4,1,4,-8,44,4,6,8,22,0,0,-127,126,0

.ENTRY

 CLD 
 LDA #&81
 LDX #0
 LDY #&FF
 JSR OSBYTE
 TXA 
 BNE not0
 TYA 
 BNE not0
 JMP happy

.not0

 INX 
 BNE blap1
 INY 
 BEQ blap2

.blap1

 JMP happy

\JSRZZZAP\BRK\BRK\EQUS" This program only runs on a BBC Micro with 6502 Second Processor\EQUW&0C0A\BRK

.blap2

 LDA #&EA
 DEY 
 JSR OSBYTE
 TXA 
 BNE happy
 JSR ZZZAP
 BRK 
 BRK 
 EQUS "This program needs a 6502 Second Processor"
 EQUW &D0A
 BRK 

.ZZZAP

 LDA #(happy MOD256)
 STA ZP
 LDX #(happy DIV256)
 LDY #0

.ZZZAPL

 STX ZP+1
 STA (ZP),Y
 INY 
 BNE ZZZAPL
 INX 
 CPX #((MESS2 DIV256)+1)
 BNE ZZZAPL
 RTS 

.happy

\  Only run if OSBYTE&81,0,&FF returns X and Y zero OR if (OSBYTE&81,0,&FF         returns XY = &FFFF AND OSBYTE&EA,0,&FF returns X nonzero)
\.....
 LDA #16
 LDX #3
 JSR OSBYTE \ADC
 LDA #190
 LDX #8
 JSR OSB \8bitADC
 LDA #200
 LDX #3
 JSR OSB \break,escape
\LDA#144\LDX#255\JSROSB \TV
 LDA #225
 LDX #128
 JSR OSB \fn keys
 LDA #13
 LDX #2
 JSR OSB \kybrd buffer
 LDA #(B% MOD256)
 STA ZP
 LDA #(B% DIV256)
 STA ZP+1
 LDY #0

.LOOP

 LDA (ZP),Y
 JSR OSWRCH
 INY 
 CPY #N%
 BNE LOOP \set up mode
 LDA #20
 LDX #0
 JSR OSB \Implode character definitions
 LDA #4
 LDX #1
 JSR OSB \cursor
 LDA #9
 LDX #0
 JSR OSB \flashing
\....
 JSR PLL1 \Draw Saturn
\....

MACRO FNE I%
  LDX #LO(E%+I%*14)     \ Call OSWORD with A = 8 and (Y X) pointing to the
  LDY #HI(E%+I%*14)     \ I%-th set of envelope data in E%, to set up sound
  LDA #8                \ envelope I%
  JSR OSWORD
ENDMACRO

 FNE 0                  \ Set up sound envelopes 0-3 using the FNE macro
 FNE 1
 FNE 2
 FNE 3
 
\.....
 LDX #(MESS1 MOD256)
 LDY #(MESS1 DIV256)
 JSR SCLI \*DIR E

 LDX #(MESS2 MOD256)
 LDY #(MESS2 DIV256)
 JMP SCLI \*RUN ELITEa
\
\......Saturn.......
\

.PLL1

 LDA VIA+4
 STA RAND+1
 JSR DORND
 JSR SQUA2
 STA ZP+1
 LDA P
 STA ZP
 JSR DORND
 STA YY
 JSR SQUA2
 TAX 
 LDA P
 ADC ZP
 STA ZP
 TXA 
 ADC ZP+1
 BCS PLC1
 STA ZP+1
 LDA #1
 SBC ZP
 STA ZP
 LDA #&40
 SBC ZP+1
 STA ZP+1
 BCC PLC1
 JSR ROOT
 LDA ZP
 LSR A
 TAX 
 LDA YY
 CMP #128
 ROR A
 JSR PIX

.PLC1

 DEC CNT
 BNE PLL1
 DEC CNT+1
 BNE PLL1

.PLL2

 JSR DORND
 TAX 
 JSR SQUA2
 STA ZP+1
 JSR DORND
 STA YY
 JSR SQUA2
 ADC ZP+1
 CMP #&11
 BCC PLC2
 LDA YY
 JSR PIX

.PLC2

 DEC CNT2
 BNE PLL2
 DEC CNT2+1
 BNE PLL2

.PLL3

 JSR DORND
 STA ZP
 JSR SQUA2
 STA ZP+1
 JSR DORND
 STA YY
 JSR SQUA2
 STA T
 ADC ZP+1
 STA ZP+1
 LDA ZP
 CMP #128
 ROR A
 CMP #128
 ROR A
 ADC YY
 TAX 
 JSR SQUA2
 TAY 
 ADC ZP+1
 BCS PLC3
 CMP #&50
 BCS PLC3
 CMP #&20
 BCC PLC3
 TYA 
 ADC T
 CMP #&10
 BCS PL1
 LDA ZP
 BPL PLC3

.PL1

 LDA YY
 JSR PIX

.PLC3

 DEC CNT3
 BNE PLL3
 DEC CNT3+1
 BNE PLL3

.DORND

 LDA RAND+1
 TAX 
 ADC RAND+3
 STA RAND+1
 STX RAND+3
 LDA RAND
 TAX 
 ADC RAND+2
 STA RAND
 STX RAND+2
 RTS 

.RAND

 EQUD &34785349

.SQUA2

 BPL SQUA
 EOR #FF
 CLC 
 ADC #1

.SQUA

 STA Q
 STA P
 LDA #0
 LDY #8
 LSR P

.SQL1

 BCC SQ1
 CLC 
 ADC Q

.SQ1

 ROR A
 ROR P
 DEY 
 BNE SQL1
 RTS 

.PIX

 TAY 
 EOR #128
 LSR A
 LSR A
 LSR A
 ASL A
 ORA #&40
 STA ZP+1
 TXA 
 EOR #128
 AND #&FC
 ASL A
 STA ZP
 BCC P%+4
 INC ZP+1
 TYA 
 AND #7
 TAY 
 TXA 
 AND #7
 TAX 
 LDA TWOS,X
 STA (ZP),Y
 RTS 

.TWOS

 EQUD &10204080
 EQUD &01020408

.CNT

 EQUW &300

.CNT2

 EQUW &1DD

.CNT3

 EQUW &333

.ROOT

 LDY ZP+1
 LDA ZP
 STA Q
 LDX #0
 STX ZP
 LDA #8
 STA P

.LL6

 CPX ZP
 BCC LL7
 BNE LL8
 CPY #&40
 BCC LL7

.LL8

 TYA 
 SBC #&40
 TAY 
 TXA 
 SBC ZP
 TAX 

.LL7

 ROL ZP
 ASL Q
 TYA 
 ROL A
 TAY 
 TXA 
 ROL A
 TAX 
 ASL Q
 TYA 
 ROL A
 TAY 
 TXA 
 ROL A
 TAX 
 DEC P
 BNE LL6
 RTS 

.OSB

 LDY #0
 JMP OSBYTE

.MESS1

 EQUS "DIR E"
 EQUB 13

.MESS2

 EQUS "R.I.ELITEa"
 EQUB 13

\ ******************************************************************************
\
\ Save output/ELITE.bin
\
\ ******************************************************************************

PRINT "S.ELITE ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/ELITE.bin", CODE%, P%, LOAD%