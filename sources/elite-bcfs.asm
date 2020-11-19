\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE BIG CODE FILE SOURCE
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

CODE% = &1000
LOAD% = &1000

ORG CODE%

INCBIN "extracted/workspaces/BCFS-MOS.bin"

.elitea

PRINT "elitea = ", ~P%
INCBIN "output/ELTA.bin"

.eliteb

PRINT "eliteb = ", ~P%
INCBIN "output/ELTB.bin"

.elitec

PRINT "elitec = ", ~P%
INCBIN "output/ELTC.bin"

.elited

PRINT "elited = ", ~P%
INCBIN "output/ELTD.bin"

.elitee

PRINT "elitee = ", ~P%
INCBIN "output/ELTE.bin"

.elitef

PRINT "elitef = ", ~P%
INCBIN "output/ELTF.bin"

.eliteg

PRINT "eliteg = ", ~P%
INCBIN "output/ELTG.bin"

.eliteh

PRINT "eliteh = ", ~P%
INCBIN "output/ELTH.bin"

.elitei

PRINT "elitei = ", ~P%
INCBIN "output/ELTI.bin"

.elitej

PRINT "elitej = ", ~P%
INCBIN "output/ELTJ.bin"

F% = P%
PRINT "F% = ", ~F%
PRINT "P% = ", ~P%

ORG F%

.words

PRINT "words = ", ~P%
INCBIN "extracted/WORDS.bin"

ORG F% + &400

.ships

PRINT "ships = ", ~P%
INCBIN "output/SHIPS.bin"
INCBIN "extracted/workspaces/BCFS-SHIPS.bin"

.end

\ ******************************************************************************
\
\ Save 6502sp/output/CODE.unprot.bin
\
\ ******************************************************************************

PRINT "P% = ", ~P%
PRINT "S.P.CODE ", ~LOAD%, ~(F% + &400 + &2200), " ", ~LOAD%, ~LOAD%
SAVE "output/CODE.unprot.bin", CODE%, (F% + &400 + &2200), LOAD%
