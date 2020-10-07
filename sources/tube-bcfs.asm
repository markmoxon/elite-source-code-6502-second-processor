\ ******************************************************************************
\
\ TUBE ELITE BIG CODE FILE SOURCE
\
\ The original 1984 source code is copyright Ian Bell and David Braben, and the
\ code on this site is identical to the version released by the authors on Ian
\ Bell's personal website at http://www.iancgbell.clara.net/elite/
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
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
INCBIN "extracted/SHIPS.bin"
INCBIN "extracted/workspaces/BCFS-SHIPS.bin"

.end

\ ******************************************************************************
\
\ Save output/CODE.unprot.bin
\
\ ******************************************************************************

PRINT "P% = ", ~P%
PRINT "S.P.CODE ", ~LOAD%, ~(F% + &400 + &2200), " ", ~LOAD%, ~LOAD%
SAVE "output/CODE.unprot.bin", CODE%, (F% + &400 + &2200), LOAD%
