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
OSWRCH = &FFEE
OSBYTE = &FFF4
OSWORD = &FFF1
OSFILE = &FFDD
SCLI = &FFF7

VIA = &FE00             \ Memory-mapped space for accessing internal hardware,
                        \ such as the video ULA, 6845 CRTC and 6522 VIAs (also
                        \ known as SHEILA)

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

YELLOW  = %00001111     \ Four mode 1 pixels of colour 1 (yellow)
RED     = %11110000     \ Four mode 1 pixels of colour 2 (red, magenta or white)
CYAN    = %11111111     \ Four mode 1 pixels of colour 3 (cyan or white)
GREEN   = %10101111     \ Four mode 1 pixels of colour 3, 1, 3, 1 (cyan/yellow)
WHITE   = %11111010     \ Four mode 1 pixels of colour 3, 2, 3, 2 (cyan/red)
MAGENTA = RED
DUST    = WHITE

RED2    = %00000011     \ Two mode 2 pixels of colour 1    (red)
GREEN2  = %00001100     \ Two mode 2 pixels of colour 2    (green)
YELLOW2 = %00001111     \ Two mode 2 pixels of colour 3    (yellow)
BLUE2   = %00110000     \ Two mode 2 pixels of colour 4    (blue)
MAG2    = %00110011     \ Two mode 2 pixels of colour 5    (magenta)
CYAN2   = %00111100     \ Two mode 2 pixels of colour 6    (cyan)
WHITE2  = %00111111     \ Two mode 2 pixels of colour 7    (white)
STRIPE  = %00100011     \ Two mode 2 pixels of colour 5, 1 (magenta/red)

\ ******************************************************************************
\
\       Name: ZP
\       Type: Workspace
\    Address: &0080 to &0089
\   Category: Workspaces
\    Summary: Important variables used by the I/O processor
\
\ ******************************************************************************

ORG &0080

.ZP

 SKIP 0                 \ The start of the zero page workspace

.P

 SKIP 1                 \ Temporary storage, used in a number of places

.Q

 SKIP 1                 \ Temporary storage, used in a number of places

.R

 SKIP 1                 \ Temporary storage, used in a number of places

.S

 SKIP 1                 \ Temporary storage, used in a number of places

.T

 SKIP 1                 \ Temporary storage, used in a number of places

.SWAP

 SKIP 1                 \ Temporary storage, used to store a flag that records
                        \ whether or not we had to swap a line's start and end
                        \ coordinates around when clipping the line in routine
                        \ LL145 (the flag is used in places like BLINE to swap
                        \ them back)

.T1

 SKIP 1                 \ Temporary storage, used in a number of places

.COL

 SKIP 1                 \ Temporary storage, used to store colour information
                        \ when drawing pixels in the dashboard

.OSSC

 SKIP 2                 \ When the parasite sends an OSWORD command to the I/O
                        \ processor (i.e. an OSWORD with A = 240 to 255), then
                        \ the relevant handler routine in the I/O processor is
                        \ called with OSSC(1 0) pointing to the OSWORD parameter
                        \ block (i.e. OSSC(1 0) = (Y X) from the original call
                        \ in the I/O processor)

\ ******************************************************************************
\
\       Name: TABLE
\       Type: Variable
\   Category: Drawing lines
\    Summary: The line buffer for line data transmited from the parasite
\
\ ------------------------------------------------------------------------------
\
\ Lines are drawn by sending the line coordinates one byte at a time from the
\ parasite, using the OSWRCH 129 and 130 commands. As they are sent, they are
\ stored in the TABLE buffer, until all the points have been received, at which
\ point the line is drawn.
\
\ LINTAB points to the offset of the first free byte within TABLE, so the table
\ can be reset by setting LINTAB to 0.
\
\ ******************************************************************************

ORG &2300

.TABLE

 SKIP &100

\ ******************************************************************************
\
\       Name: FONT%
\       Type: Variable
\   Category: Text
\    Summary: A copy of the character definition bitmap table from the MOS ROM
\
\ ------------------------------------------------------------------------------
\
\ This is used by the TT26 routine to save time looking up the character bitmaps
\ from the ROM. Note that FONT% contains just the high byte (i.e. the page
\ number) of the address of this table, rather than the full address.
\
\ The contents of the P.FONT.bin file included here are taken straight from the
\ following three pages in the BBC Micro OS 1.20 ROM:
\
\   ASCII 32-63  are defined in &C000-&C0FF (page 0)
\   ASCII 64-95  are defined in &C100-&C1FF (page 1)
\   ASCII 96-126 are defined in &C200-&C2F0 (page 2)
\
\ The code could look these values up each time (as the cassette version does),
\ but it's quicker to use a lookup table, at the expense of three pages of
\ memory.
\
\ ******************************************************************************

ORG CODE%

FONT% = P% DIV 256

INCBIN "binaries/P.FONT.bin"

\ ******************************************************************************
\
\       Name: log
\       Type: Variable
\   Category: Maths (Arithmetic)
\    Summary: 
\
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
\
\       Name: logL
\       Type: Variable
\   Category: Maths (Arithmetic)
\    Summary: 
\
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
\
\       Name: antilog
\       Type: Variable
\   Category: Maths (Arithmetic)
\    Summary: 
\
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
\
\       Name: antilogODD
\       Type: Variable
\   Category: Maths (Arithmetic)
\    Summary: 
\
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
\
\       Name: ylookup
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Lookup table for converting pixel y-coordinate to page number of
\             screen address
\
\ ------------------------------------------------------------------------------
\
\ Elite's screen mode is based on mode 1, so it allocates two pages of screen
\ memory to each character row (where a character row is 8 pixels high). This
\ table enables us to convert a pixel y-coordinate in the range 0-247 into the
\ page number for the start of the character row containing that coordinate.
\
\ Screen memory is from &4000 to &7DFF, so the lookup works like this:

\   Y =   0 to  7,  lookup value = &40 (so row 1 is from &4000 to &41FF)
\   Y =   8 to 15,  lookup value = &42 (so row 2 is from &4200 to &43FF)
\   Y =  16 to 23,  lookup value = &44 (so row 3 is from &4400 to &45FF)
\   Y =  24 to 31,  lookup value = &46 (so row 4 is from &4600 to &47FF)
\
\   ...
\
\   Y = 232 to 239, lookup value = &7A (so row 31 is from &7A00 to &7BFF)
\   Y = 240 to 247, lookup value = &7C (so row 31 is from &7C00 to &7DFF)
\
\ There is also a lookup value for y-coordinates from 248 to 255, but that's off
\ the end of the screen, as the special Elite screen mode only has 31 character
\ rows.
\
\ ******************************************************************************

.ylookup

FOR I%, 0, 255
  EQUB &40 + ((I% DIV 8) * 2)
NEXT

\ ******************************************************************************
\
\       Name: TVT3
\       Type: Variable
\   Category: Screen mode
\    Summary: Palette data for the mode 1 part of the screen (the top part)
\
\ ------------------------------------------------------------------------------
\
\ The following table contains four different mode 1 palettes, each of which
\ sets a four-colour palatte for the top part of the screen. Mode 1 supports
\ four colours on-screen and in Elite colour 0 is always set to black, so each
\ of the palettes in this table defines the three other colours (1 to 3).
\
\ There is some consistency between the palettes:
\
\   * Colour 0 is always black
\   * Colour 1 (#YELLOW) is always yellow
\   * Colour 2 (#RED) is normally red-like (i.e. red or magenta)
\              ... except in the title screen palette, when it is white
\   * Colour 3 (#CYAN) is always cyan-like (i.e. white or cyan)
\
\ The configuration variables of #YELLOW, #RED and #CYAN are a bit misleading,
\ but if you think of them in terms of hue rather than specific colours, they
\ work reasonably well (outside of the title screen palette, anyway).
\
\ The palettes are set in the IRQ1 handler that implements the split screen
\ mode, and can be changed by the parasite sending a #SETVDU19 <offset> command
\ to point to the offset of the new palette in this table.
\
\ This table must start on a page boundary (i.e. an address that ends in two
\ zeroes in hexadecimal). In the release version of the game TVT3 is at &2C00.
\ This is so the #SETVDU19 command can switch palettes properly, as it does this
\ by overwriting the low byte of the palette data address with a new offset, so
\ the low byte for first palette's address must be 0.
\
\ Palette data is given as a set of bytes, with each byte mapping a logical
\ colour to a physical one. In each byte, the logical colour is given in bits
\ 4-7 and the physical colour in bits 0-3. See p.379 of the Advanced User Guide
\ for details of how palette mapping works, as in modes 1 and 2 we have to do
\ multiple palette commands to change the colours correctly, and the physical
\ colour value is EOR'd with 7, just to make things even more confusing.
\
\ ******************************************************************************

.TVT3

 EQUB &00, &34          \ 1 = yellow, 2 = red, 3 = cyan (space view)
 EQUB &24, &17          \
 EQUB &74, &64          \ Set with a #SETVDU19 0 command, after which:
 EQUB &57, &47          \
 EQUB &B1, &A1          \   #YELLOW = yellow
 EQUB &96, &86          \   #RED    = red
 EQUB &F1, &E1          \   #CYAN   = cyan
 EQUB &D6, &C6          \   #GREEN  = cyan/yellow stripe
                        \   #WHITE  = cyan/red stripe

 EQUB &00, &34          \ 1 = yellow, 2 = red, 3 = white (chart view)
 EQUB &24, &17          \
 EQUB &74, &64          \ Set with a #SETVDU19 16 command, after which:
 EQUB &57, &47          \
 EQUB &B0, &A0          \   #YELLOW = yellow
 EQUB &96, &86          \   #RED    = red
 EQUB &F0, &E0          \   #CYAN   = white
 EQUB &D6, &C6          \   #GREEN  = white/yellow stripe
                        \   #WHITE  = white/red stripe

 EQUB &00, &34          \ 1 = yellow, 2 = white, 3 = cyan (title screen)
 EQUB &24, &17          \
 EQUB &74, &64          \ Set with a #SETVDU19 32 command, after which:
 EQUB &57, &47          \
 EQUB &B1, &A1          \   #YELLOW = yellow
 EQUB &90, &80          \   #RED    = white
 EQUB &F1, &E1          \   #CYAN   = cyan
 EQUB &D0, &C0          \   #GREEN  = cyan/yellow stripe
                        \   #WHITE  = cyan/white stripe

 EQUB &00, &34          \ 1 = yellow, 2 = magenta, 3 = white (trade view)
 EQUB &24, &17          \
 EQUB &74, &64          \ Set with a #SETVDU19 48 command, after which:
 EQUB &57, &47          \
 EQUB &B0, &A0          \   #YELLOW = yellow
 EQUB &92, &82          \   #RED    = magenta
 EQUB &F0, &E0          \   #CYAN   = white
 EQUB &D2, &C2          \   #GREEN  = white/yellow stripe
                        \   #WHITE  = white/magenta stripe

\ ******************************************************************************
\
\       Name: I/O Variables
\       Type: Workspace
\    Address: &2C40 to &2C60
\   Category: Workspaces
\    Summary: Various variables used by the I/O processor
\
\ ******************************************************************************

.XC

 EQUB 1                 \ The x-coordinate of the text cursor (i.e. the text
                        \ column), set to an initial value of 1

.YC

 EQUB 1                 \ The y-coordinate of the text cursor (i.e. the text
                        \ row), set to an initial value of 1

.K3

 SKIP 1                 \ Temporary storage, used in a number of places

.U

 SKIP 1                 \ Temporary storage, used in a number of places

.LINTAB

 SKIP 1                 \ The offset of the first free byte in the TABLE buffer,
                        \ which stores bytes in the current line as they are
                        \ transmitted from the parasite using the OSWRCH 129 and
                        \ 130 commands

.LINMAX

 SKIP 1                 \ The number of points in the line currently being
                        \ transmitted from the parasite using the OSWRCH 129
                        \ and 130 commands

.YSAV

 SKIP 1                 \ Temporary storage for saving the value of the Y
                        \ register, used in a number of places

.svn

 SKIP 1                 \ "Saving in progress" flag
                        \
                        \   * Non-zero while the disc is being accessed (so this
                        \     is also the case for cataloguing, loading etc.)
                        \
                        \   * 0 otherwise

.PARANO

 SKIP 1                 \ PARANO points to the last free byte in PARAMS, which
                        \ is used as a buffer for bytes sent from the parasite
                        \ by the #RDPARAMS and OSWRCH 137 <param> commands when
                        \ updating the dashboard

.DL

 SKIP 1                 \ Vertical sync flag
                        \
                        \ DL gets set to 30 every time we reach vertical sync on
                        \ the video system, which happens 50 times a second
                        \ (50Hz). The WSCAN routine uses this to pause until the
                        \ vertical sync, by setting DL to 0 and then monitoring
                        \ its value until it changes to 30

.VEC

 SKIP 2                 \ VEC = &7FFE
                        \
                        \ Set to the original IRQ1 vector by elite-loader.asm

.HFX

 SKIP 1                 \ A flag that toggles the hyperspace colour effect
                        \
                        \   * 0 = no colour effect
                        \
                        \   * Non-zero = hyperspace colour effect enabled
                        \
                        \ When HFS is set to 1, the mode 1 screen that makes
                        \ up the top part of the display is temporarily switched
                        \ to mode 2 (the same screen mode as the dashboard),
                        \ which has the effect of blurring and colouring the
                        \ hyperspace rings in the top part of the screen. The
                        \ code to do this is in the LINSCN routine, which is
                        \ called as part of the screen mode routine at IRQ1.
                        \ It's in LINSCN that HFX is checked, and if it is
                        \ non-zero, the top part of the screen is not switched
                        \ to mode 1, thus leaving the top part of the screen in
                        \ the more colourful mode 2

.CATF

 SKIP 1                 \ The disc catalogue flag
                        \
                        \ Determines whether a disc catalogue is currently in
                        \ progress, so the TT26 print routine can format the
                        \ output correctly:
                        \
                        \   * 0 = disc is not currently being catalogued
                        \
                        \   * 1 = disc is currently being catalogued
                        \
                        \ Specifically, when CATF is non-zero, TT26 will omit
                        \ column 17 from the catalogue so that it will fit
                        \ on-screen (column 17 is blank column in the middle
                        \ of the catalogue, between the two lists of filenames,
                        \ so it can be dropped without affecting the layout)

.K

 SKIP 4                 \ Temporary storage, used in a number of places

.PARAMS

 SKIP 0                 \ PARAMS points to the start of the dashboard parameter
                        \ block that is populated by the parasite when it sends
                        \ the #RDPARAMS and OSWRCH 137 <param> commands
                        \
                        \ These commands update the dashboard, but because the
                        \ parameter block uses the same locations as the flight
                        \ variables, these commands also have the effect of
                        \ updating the following variables, from ENERGY to ESCP

.ENERGY

 SKIP 1                 \ Energy bank status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.ALP1

 SKIP 1                 \ Magnitude of the roll angle alpha, i.e. |alpha|,
                        \ which is a positive value between 0 and 31

.ALP2

 SKIP 1                 \ Bit 7 of ALP2 = sign of the roll angle in ALPHA

.BETA

 SKIP 1                 \ The current pitch angle beta, which is reduced from
                        \ JSTY to a sign-magnitude value between -8 and +8
                        \
                        \ This describes how fast we are pitching our ship, and
                        \ determines how fast the universe pitches around us
                        \
                        \ The sign bit is also stored in BET2, while the
                        \ opposite sign is stored in BET2+1

.BET1

 SKIP 1                 \ The magnitude of the pitch angle beta, i.e. |beta|,
                        \ which is a positive value between 0 and 8

.DELTA

 SKIP 1                 \ Our current speed, in the range 1-40

.ALTIT

 SKIP 1                 \ Our altitude above the surface of the planet or sun
                        \
                        \   * 255 = we are a long way above the surface
                        \
                        \   * 1-254 = our altitude as the square root of:
                        \
                        \       x_hi^2 + y_hi^2 + z_hi^2 - 6^2
                        \
                        \     where our ship is at the origin, the centre of the
                        \     planet/sun is at (x_hi, y_hi, z_hi), and the
                        \     radius of the planet is 6
                        \
                        \   * 0 = we have crashed into the surface

.MCNT

 SKIP 1                 \ The main loop counter
                        \
                        \ This counter determines how often certain actions are
                        \ performed within the main loop. See the deep dive on
                        \ "Scheduling tasks with the main loop counter" for more
                        \ details

.FSH

 SKIP 1                 \ Forward shield status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.ASH

 SKIP 1                 \ Aft shield status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.QQ14

 SKIP 1                 \ Our current fuel level (0-70)
                        \
                        \ The fuel level is stored as the number of light years
                        \ multiplied by 10, so QQ14 = 1 represents 0.1 light
                        \ years, and the maximum possible value is 70, for 7.0
                        \ light years

.GNTMP

 SKIP 1                 \ Laser temperature (or "gun temperature")
                        \
                        \ If the laser temperature exceeds 242 then the laser
                        \ overheats and cannot be fired again until it has
                        \ cooled down

.CABTMP

 SKIP 1                 \ Cabin temperature
                        \
                        \ The ambient cabin temperature in deep space is 30,
                        \ which is displayed as one notch on the dashboard bar
                        \
                        \ We get higher temperatures closer to the sun
                        \
                        \ CABTMP shares a location with MANY, but that's OK as
                        \ MANY+0 would contain the number of ships of type 0,
                        \ but as there is no ship type 0 (they start at 1), MANY
                        \ is unused

.FLH

 SKIP 1                 \ Flashing console bars configuration setting
                        \
                        \   * 0 = static bars (default)
                        \
                        \   * &FF = flashing bars
                        \
                        \ Toggled by pressing "F" when paused, see the DKS3
                        \ routine for details

.ESCP

 SKIP 1                 \ Escape pod
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

\ ******************************************************************************
\
\       Name: JMPTAB
\       Type: Variable
\   Category: Text
\    Summary: The lookup table for OSWRCH jump commands (128-147)
\
\ ------------------------------------------------------------------------------
\
\ Once they have finished, routines in this table should reset WRCHV to point
\ back to USOSWRCH again by calling the PUTBACK routine with a JMP as their last
\ instruction.
\
\ ******************************************************************************

.JMPTAB

 EQUW USOSWRCH          \              128 (&80)     0 = Put back to USOSWRCH
 EQUW BEGINLIN          \              129 (&81)     1 = Begin drawing a line
 EQUW ADDBYT            \              130 (&82)     2 = Add line byte/draw line
 EQUW DOFE21            \ #DOFE21    = 131 (&83)     3 = Show energy bomb effect
 EQUW DOHFX             \ #DOhfx     = 132 (&84)     4 = Show hyperspace colours
 EQUW SETXC             \ #SETXC     = 133 (&85)     5 = Set text cursor column
 EQUW SETYC             \ #SETYC     = 134 (&86)     6 = Set text cursor row
 EQUW CLYNS             \ #clyns     = 135 (&87)     7 = Clear bottom of screen
 EQUW RDPARAMS          \ #RDPARAMS  = 136 (&88)     8 = Update dashboard
 EQUW ADPARAMS          \              137 (&89)     9 = Add dashboard parameter
 EQUW DODIALS           \ #DODIALS   = 138 (&8A)    10 = Show or hide dashboard
 EQUW DOVIAE            \ #VIAE      = 139 (&8B)    11 = Set 6522 System VIA IER
 EQUW DOBULB            \ #DOBULB    = 140 (&8C)    12 = Toggle dashboard bulb
 EQUW DOCATF            \ #DOCATF    = 141 (&8D)    13 = Set disc catalogue flag
 EQUW DOCOL             \ #SETCOL    = 142 (&8E)    14 = Set the current colour
 EQUW SETVDU19          \ #SETVDU19  = 143 (&8F)    15 = Change mode 1 palette
 EQUW DOSVN             \ #DOsvn     = 144 (&90)    16 = Set file saving flag
 EQUW DOBRK             \              145 (&91)    17 = Execute BRK instruction
 EQUW printer           \ #printcode = 146 (&92)    18 = Write to printer/screen
 EQUW prilf             \ #prilf     = 147 (&93)    19 = Blank line on printer

\ ******************************************************************************
\
\       Name: STARTUP
\       Type: Subroutine
\   Category: Loader
\    Summary: Set the various vectors, interrupts and timers, and terminate the
\             loading process so the vector handlers can take over
\
\ ******************************************************************************

.STARTUP

 LDA RDCHV              \ Store the current RDCHV vector in newosrdch(2 1),
 STA newosrdch+1        \ which modifies the address portion of the JSR &FFFF
 LDA RDCHV+1            \ instruction at the start of the newosrdch routine and
 STA newosrdch+2        \ changes it to a JSR to the existing RDCHV address

 LDA #LO(newosrdch)     \ Disable interrupts and set WRCHV to newosrdch, so
 SEI                    \ calls to OSRDCH are now handled by newosrdch, which
 STA RDCHV              \ lets us implement all our custom OSRDCH commands
 LDA #HI(newosrdch)
 STA RDCHV+1
 
 LDA #%00111001         \ Set 6522 System VIA interrupt enable register IER
 STA VIA+&4E            \ (SHEILA &4E) bits 0 and 3-5 (i.e. disable the Timer1,
                        \ CB1, CB2 and CA2 interrupts from the System VIA)

 LDA #%01111111         \ Set 6522 User VIA interrupt enable register IER
 STA &FE6E              \ (SHEILA &6E) bits 0-7 (i.e. disable all hardware
                        \ interrupts from the User VIA)

 LDA IRQ1V              \ Store the current IRQ1V vector in VEC, so VEC(1 0) now
 STA VEC                \ contains the original address of the IRQ1 handler
 LDA IRQ1V+1
 STA VEC+1

 LDA #LO(IRQ1)          \ Set the IRQ1V vector to IRQ1, so IRQ1 is now the
 STA IRQ1V              \ interrupt handler
 LDA #HI(IRQ1)
 STA IRQ1V+1

 LDA #VSCAN             \ Set 6522 System VIA T1C-L timer 1 high-order counter
 STA VIA+&45            \ (SHEILA &45) to VSCAN (57) to start the T1 counter
                        \ counting down from 14592 at a rate of 1 MHz (this is
                        \ a different value to the main game code and to the
                        \ loader's IRQ1 routine in the cassette version)

 CLI                    \ Enable interrupts again

.NOINT

 LDA WORDV              \ Store the current WORDV vector in notours(2 1)
 STA notours+1
 LDA WORDV+1
 STA notours+2

 LDA #LO(NWOSWD)        \ Disable interrupts and set WORDV to NWOSWD, so calls
 SEI                    \ calls to OSWORD are now handled by NWOSWD, which lets
 STA WORDV              \ us implement all our custom OSWORD commands
 LDA #HI(NWOSWD)
 STA WORDV+1

 CLI                    \ Enable interrupts again

 LDA #&FF               \ Set the text and graphics colour to cyan
 STA COL

 LDA Tina               \ If the contents of locations &0B00 to &0B03 are "TINA"
 CMP #'T'               \ then keep going, otherwise jump to PUTBACK to point
 BNE PUTBACK            \ WRCHV to USOSWRCH, and then end the program, as from
 LDA Tina+1             \ now on the handlers pointed to by the vectors will
 CMP #'I'               \ handle everything
 BNE PUTBACK
 LDA Tina+2
 CMP #'N'
 BNE PUTBACK
 LDA Tina+3
 CMP #'A'
 BNE PUTBACK

 JSR Tina+4             \ &0B00 to &0B03 contains "TINA", so call the subroutine
                        \ at &B04. This allows us to add a hook to the startup
                        \ process by populating page &B with TINA plus the code
                        \ for a subroutine, and it will be called just before
                        \ the setup code terminates on the I/O processor

                        \ Fall through into PUTBACK to point WRCHV to USOSWRCH,
                        \ and then end the program, as from now on the handlers
                        \ pointed to by the vectors will handle everything

\ ******************************************************************************
\
\       Name: PUTBACK
\       Type: Subroutine
\   Category: Tube
\    Summary: Reset the OSWRCH vector in WRCHV to point to USOSWRCH
\
\ ******************************************************************************

.PUTBACK

 LDA #128               \ Set A = 128 to denote the first entry in JMPTAB, i.e.
                        \ USOSWRCH

                        \ Fall through into USOSWRCH to set WRCHV to the first
                        \ entry in JMPTAB - in other words, put WRCHV back to
                        \ its original value of USOSWRCH

\ ******************************************************************************
\
\       Name: USOSWRCH
\       Type: Subroutine
\   Category: Tube
\    Summary: The custom OSWRCH routine for writing characters and implementing
\             jump table commands
\
\ ------------------------------------------------------------------------------
\
\ WRCHV is set to point to this routine in the STARTUP routine that runs when
\ the I/O processor code first loads (it's set via a call to PUTBACK).
\
\ This routine prints characters to the I/O processor's screen. For special jump
\ table commands with characters in the range 128-147, the routine calls the
\ corresponding routines in the JMPTAB table; all other characters are printed
\ normally using TT26.
\
\ To implement the special jump table commands, this routine sets the address
\ in WRCHV so that calls to OSWRCH get vectored via the appropriate address from
\ JMPTAB. The routine does the following, depending on the value in A:
\
\   * If A is in the range 128-147, it sets WRCHV to entry number A - 128 in
\     the JMPTAB table (so 128 is the first entry, 129 the second, and so on)
\
\   * Otherwise it prints the character in A by calling TT26
\
\ The vector can be reset to USOSWRCH by calling the PUTBACK routine, which is
\ done at the end of all of the routines that are pointed to by JMPTAB.
\
\ Arguments:
\
\   A                   The character to print:
\
\                         * 128-147: Run the jump command in A (see JMPTAB)
\
\                         * All others: Print the character in A
\
\ ******************************************************************************

.USOSWRCH

 STX SC                 \ Store X in SC so we can retrieve it later

 TAX                    \ Store A in X

 BPL OHMYGOD            \ If A < 128 jump to OHMYGOD to print the character in A

 ASL A                  \ Set X = A << 2
 TAX                    \       = (A - 128) * 2 (because A >= 128)
                        \
                        \ so X can be used as an index into a jump table, where
                        \ the table entries correspond to original values of A
                        \ of 128 for entry 0, 129 for entry 1, 130 for entry 2,
                        \ and so on

 CPX #39                \ If X >= 39 then it is past the end of the jump table
 BCS OHMYGOD            \ (JMPTAB contains addresses 0-19, so the last entry is
                        \ for X = 38), so jump to OHMYGOD to print the
                        \ character in A

 LDA JMPTAB,X           \ Fetch the low byte of the jump table address pointed
                        \ to by X from JMPTAB + X

 SEI                    \ Disable interrupts while we update the WRCHV vector

 STA WRCHV              \ Store the low byte of the jump table entry in the low
                        \ byte of WRCHV

 LDA JMPTAB+1,X         \ Fetch the high byte of the jump table address pointed
 STA WRCHV+1            \ to by X from JMPTAB+1 + X, and store it in the high
                        \ byte of WRCHV

 CLI                    \ Enable interrupts again

 RTS                    \ Return from the subroutine

.OHMYGOD

 LDX SC                 \ Retrieve X from SC

 JMP TT26               \ Jump to TT26 to print the character in A, returning
                        \ from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DODIALS
\       Type: Subroutine
\   Category: Screen mode
\    Summary: Implement the #DODIALS <rows> command (show or hide the dashboard)
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
\   A                   The number of text rows to display on the screen (24
\                       will hide the dashboard, 31 will make it reappear)
\
\ Returns
\
\   A                   A is set to 6
\
\ ******************************************************************************

.DODIALS

 TAX                    \ Copy the number of rows to display into X

 LDA #6                 \ Set A to 6 so we can update 6845 register R6 below

 SEI                    \ Disable interrupts so we can update the 6845

 STA VIA+&00            \ Set 6845 register R6 to the value in X. Register R6
 STX VIA+&01            \ is the "vertical displayed" register, which sets the
                        \ number of rows shown on the screen

 CLI                    \ Re-enable interrupts

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOFE21
\       Type: Subroutine
\   Category: Flight
\    Summary: Implement the #DOFE21 <flag> command (show the energy bomb effect)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DOFE21 <flag> command. It takes
\ the argument and stores it in SHEILA &21 to change the palette.
\
\ See p.379 of the Advanced User Guide for an explanation of palette bytes.
\
\ Arguments:
\
\   A                   The new value of SHEILA &21
\
\ ******************************************************************************

.DOFE21

 STA &FE21              \ Store the new value in SHEILA &21

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOHFX
\       Type: Subroutine
\   Category: Drawing circles
\    Summary: Implement the #DOHFX <flag> command (update the hyperspace effect
\             flag)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DOHFX <flag> command. It
\ updates the hyperspace effect flag in HFX.
\
\ Arguments:
\
\   A                   The new value of the hyperspace effect flag:
\
\                         * 0 = no colour effect
\
\                         * Non-zero = enable hyperspace colour effect
\
\ ******************************************************************************

.DOHFX

 STA HFX                \ Store the new hyperspace effect flag in HFX

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOVIAE
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Implement the #VIAE <flag> command (enable/disable interrupts)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #VIAE <flag> command. It updates
\ the 6522 System VIA interrupt enable register (IER) at SHEILA &4E, which
\ allows us to enable and disable interrupts. It is used for enabling and
\ disabling the keyboard interrupt.
\
\ Arguments:
\
\   A                   The new value of the interrupt enable register (IER)
\
\ ******************************************************************************

.DOVIAE

 STA VIA+&4E            \ Store A in SHEILA &4E

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOCATF
\       Type: Subroutine
\   Category: Save and load
\    Summary: Implement the #DOCATF <flag> command (update the disc catalogue
\             flag)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DOCATF <flag> command. It
\ updates the disc catalogue flag in CATF.
\
\ Arguments:
\
\   A                   The new value of the disc catalogue flag:
\
\                         * 0 = disc is not currently being catalogued
\
\                         * 1 = disc is currently being catalogued
\
\ ******************************************************************************

.DOCATF

 STA CATF               \ Store the new value in CATF

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOCOL
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Implement the #SETCOL <colour> command (set the current colour)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #SETCOL <colour> command. It
\ updates the current colour in COL.
\
\ Arguments:
\
\   A                   The new colour
\
\ ******************************************************************************

.DOCOL

 STA COL                \ Store the new colour in COL

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOSVN
\       Type: Subroutine
\   Category: Save and load
\    Summary: Implement the #DOSVN <flag> command (update the "save in progress"
\             flag)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DOSVN <flag> command. It
\ updates the "save in progress" flag in svn
\
\ Arguments:
\
\   A                   The new value of the "save in progress" flag
\
\ ******************************************************************************

.DOSVN

 STA svn                \ Store the new "save in progress" flag in svn

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOBRK
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Implement the OSWRCH 145 command (execute a BRK instruction)
\
\ ------------------------------------------------------------------------------
\
\ This command doesn't appear to be used, but it would execute a BRK on the I/O
\ processor, causing a call to BRKV. This typically  points to BRBR or MEBRK,
\ both of which print out the current system error, if there is one.
\
\ ******************************************************************************

.DOBRK

 BRK                    \ Execute a BRK instruction

 EQUS "TTEST"           \ A carriage-return-terminated test string, which
 EQUB 13                \ doesn't appear to be used anywhere

 BRK                    \ End of the test string

\ ******************************************************************************
\
\       Name: printer
\       Type: Subroutine
\   Category: Text
\    Summary: Implement the #printcode <char> command (print a character on the
\             printer and screen)
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The character to print on the printer and screen
\
\ ******************************************************************************

.printer

 PHA                    \ Store A on the stack so we can retrieve it after the
                        \ following call to TT26

 JSR TT26               \ Call TT26 to print the character in A on-screen

 PLA                    \ Retrieve A from the stack

 CMP #11                \ If A = 11, which normally means "move the cursor up
 BEQ nottosend          \ one line", jump to nottosend to skip sending this
                        \ character to the printer, as you can't roll back time
                        \ when you're printing hard copy

 PHA                    \ Store A on the stack so we can retrieve it after the
                        \ following call to NVOSWRCH

 LDA #2                 \ Send ASCII 2 to the printer using the non-vectored
 JSR NVOSWRCH           \ OSWRCH, which means "start sending characters to the
                        \ printer"

 PLA                    \ Retrieve A from the stack, though this is a bit
                        \ pointless given the next instruction, as they cancel
                        \ each other out

 PHA                    \ Store A on the stack so we can retrieve it after the
                        \ following calls to POSWRCH and/or NVOSWRCH

 CMP #' '               \ If A is greater than ASCII " ", then it's a printable
 BCS tosend             \ character, so jump to tosend to print the character
                        \ and jump back to sent to turn the printer off and
                        \ finish

 CMP #10                \ If we are printing a line feed, jump to tosend2 to
 BEQ tosend2            \ send it to POSWRCH

 LDA #13                \ Otherwise print a carriage return instead of whatever
 JSR POSWRCH            \ was in A, and jump to sent to turn the printer off and
 JMP sent               \ finish

.tosend2

\CMP #13                \ These instructions are commented out in the original
\BEQ sent               \ source; perhaps they were replaced by the above JMP
                        \ instruction at some point, which does a similar thing
                        \ but in fewer bytes (and without the risk of POSWRCH
                        \ corrupting the value of A)

 LDA #10                \ Call POSWRCH to send a line feed to the printer
 JSR POSWRCH

.sent

 LDA #3                 \ Send ASCII 3 to the printer using the non-vectored
 JSR NVOSWRCH           \ OSWRCH, which means "stop sending characters to the
                        \ printer"

 PLA                    \ Retrieve A from the stack

.nottosend

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: POSWRCH
\       Type: Subroutine
\   Category: Text
\    Summary: Print a character on the printer only
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The character to send to the printer
\
\ ******************************************************************************

.POSWRCH

 PHA                    \ Store A on the stack so we can retrieve it after the
                        \ following call to NVOSWRCH

 LDA #1                 \ Send ASCII 1 to the printer using the non-vectored
 JSR NVOSWRCH           \ OSWRCH, which means "send the next character to the
                        \ printer only"

 PLA                    \ Retrieve A from the stack

 JMP NVOSWRCH           \ Send the character in A to the printer using the
                        \ non-vectored OSWRCH, which prints the character on the
                        \ printer, and return from the subroutine using a tail
                        \ call

\ ******************************************************************************
\
\       Name: tosend
\       Type: Subroutine
\   Category: Text
\    Summary: Print a printable character and return to the printer routine
\
\ ******************************************************************************

.tosend

 JSR POSWRCH            \ Call POSWRCH to print the character in A on the
                        \ printer only

 JMP sent               \ Jump to sent to turn the printer off and restore the
                        \ USOSWRCH handler, returning from the subroutine using
                        \ a tail call

\ ******************************************************************************
\
\       Name: prilf
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Implement the #prilf command (print a blank line on the printer)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #prilf command. It prints a
\ blank line on the printer by printing two line feeds.
\
\ ******************************************************************************

.prilf

 LDA #2                 \ Send ASCII 2 to the printer using the non-vectored
 JSR NVOSWRCH           \ OSWRCH, which means "start sending characters to the
                        \ printer"

 LDA #10                \ Send ASCII 10 to the printer twice using the POSWRCH
 JSR POSWRCH            \ routine, which prints a blank line below the current
 JSR POSWRCH            \ line as ASCII 10 is the line feed character

 LDA #3                 \ Send ASCII 3 to the printer using the non-vectored
 JSR NVOSWRCH           \ OSWRCH, which means "stop sending characters to the
                        \ printer"

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOBULB
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the #DOBULB 0 command (draw the space station indicator
\             bulb)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DOBULB 0 command. It draws
\ (or erases) the space station indicator bulb ("S") on the dashboard.
\
\ ******************************************************************************

.DOBULB

 TAX                    \ If the parameter to the #DOBULB command is non-zero,
 BNE ECBLB              \ i.e. this is a #DOBULB 255 command, jump to EXBLB to
                        \ draw the E.C.M. bulb instead

 LDA #16*8              \ The space station bulb is in character block number 48
 STA SC                 \ (counting from the left edge of the screen), with the
                        \ first half of the row in one page, and the second half
                        \ in another. We want to set the screen address to point
                        \ to the second part of the row, as the bulb is in that
                        \ half, so that's character block number 16 within that
                        \ second half (as the first half takes up 32 character
                        \ blocks, so given that each character block takes up 8
                        \ bytes, this sets the low byte of the screen address
                        \ of the character block we want to draw to

 LDA #&7B               \ Set the high byte of SC(1 0) to &7B, as the bulbs are
 STA SC+1               \ both in the character row from &7A00 to &7BFF, and the
                        \ space station bulb is in the right half, which is from
                        \ &7B00 to &7BFF

 LDY #15                \ Now to poke the bulb bitmap into screen memory, and
                        \ there are two character blocks' worth, each with eight
                        \ lines of one byte, so set a counter in Y for 16 bytes

.BULL

 LDA SPBT,Y             \ Fetch the Y-th byte of the bulb bitmap

 EOR (SC),Y             \ EOR the byte with the current contents of screen
                        \ memory, so drawing the bulb when it is already
                        \ on-screen will erase it

 STA (SC),Y             \ Store the Y-th byte of the bulb bitmap in screen
                        \ memory

 DEY                    \ Decrement the loop counter

 BPL BULL               \ Loop back to poke the next byte until we have done
                        \ all 16 bytes across two character blocks

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: ECBLB
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the #DOBULB 255 command (draw the E.C.M. indicator bulb)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DOBULB 255 command. It draws
\ (or erases) the E.C.M. indicator bulb ("E") on the dashboard.
\
\ ******************************************************************************

.ECBLB

 LDA #8*14              \ The E.C.M. bulb is in character block number 14 with
 STA SC                 \ each character taking 8 bytes, so this sets the low
                        \ byte of the screen address of the character block we
                        \ want to draw to

 LDA #&7A               \ Set the high byte of SC(1 0) to &7A, as the bulbs are
 STA SC+1               \ both in the character row from &7A00 to &7BFF, and the
                        \ E.C.M. bulb is in the left half, which is from &7A00
                        \ to &7AFF

 LDY #15                \ Now to poke the bulb bitmap into screen memory, and
                        \ there are two character blocks' worth, each with eight
                        \ lines of one byte, so set a counter in Y for 16 bytes

.BULL2

 LDA ECBT,Y             \ Fetch the Y-th byte of the bulb bitmap

 EOR (SC),Y             \ EOR the byte with the current contents of screen
                        \ memory, so drawing the bulb when it is already
                        \ on-screen will erase it

 STA (SC),Y             \ Store the Y-th byte of the bulb bitmap in screen
                        \ memory

 DEY                    \ Decrement the loop counter

 BPL BULL2              \ Loop back to poke the next byte until we have done
                        \ all 16 bytes across two character blocks

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: SPBT
\       Type: Variable
\   Category: Dashboard
\    Summary: The bitmap definition for the space station indicator bulb
\
\ ------------------------------------------------------------------------------
\
\ The bitmap definition for the space station indicator's "S" bulb that gets
\ displayed on the dashboard.
\
\ The bulb is four pixels wide, so it covers two mode 2 character blocks, one
\ containing the left half of the "S", and the other the right half, which are
\ displayed next to each other. Each pixel is in mode 2 colour 7 (%1111), which
\ is white.
\
\ ******************************************************************************

.SPBT

                        \ Left half of the "S" bulb
                        \
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %10101010         \ x .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %00000000         \ . .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x

                        \ Right half of the "S" bulb
                        \
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %00000000         \ . .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %01010101         \ . x
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x

                        \ Combined "S" bulb
                        \
                        \ x x x x
                        \ x x x x
                        \ x . . .
                        \ x x x x
                        \ x x x x
                        \ . . . x
                        \ x x x x
                        \ x x x x

\ ******************************************************************************
\
\       Name: ECBT
\       Type: Variable
\   Category: Dashboard
\    Summary: The character bitmap for the E.C.M. indicator bulb
\
\ ------------------------------------------------------------------------------
\
\ The character bitmap for the E.C.M. indicator's "E" bulb that gets displayed
\ on the dashboard.
\
\ The bulb is four pixels wide, so it covers two mode 2 character blocks, one
\ containing the left half of the "E", and the other the right half, which are
\ displayed next to each other. Each pixel is in mode 2 colour 7 (%1111), which
\ is white.
\
\ ******************************************************************************

.ECBT

                        \ Left half of the "E" bulb
                        \
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %10101010         \ x .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %10101010         \ x .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x

                        \ Right half of the "E" bulb
                        \
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %00000000         \ . .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %00000000         \ . .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x

                        \ Combined "E" bulb
                        \
                        \ x x x x
                        \ x x x x
                        \ x . . .
                        \ x x x x
                        \ x x x x
                        \ x . . .
                        \ x x x x
                        \ x x x x

\ ******************************************************************************
\
\       Name: DOT
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Implement the #DOdot command (draw a dot)
\
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
\ Draw a double-height mode 2 dot (2 pixels high, 2 pixels wide).
\
\ Arguments:
\
\   X1                  The screen pixel x-coordinate of the bottom-left corner
\                       of the dot
\
\   Y1                  The screen pixel y-coordinate of the bottom-left corner
\                       of the dot
\
\   COL                 The colour of the dot as a mode 2 character row byte
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
\ Draw a single-height mode 2 dash (1 pixel high, 2 pixels wide).
\
\ Arguments:
\
\   X1                  The screen pixel x-coordinate of the dash
\
\   Y1                  The screen pixel y-coordinate of the dash
\
\   COL                 The colour of the dash as a mode 2 character row byte
\
\ ******************************************************************************

.CPIX2

 LDA Y1                 \ Fetch the y-coordinate into A

\.CPIX                  \ This label is commented out in the original source. It
                        \ would provide a new entry point with A specifying the
                        \ y-coordinate instead of Y1, but it isn't used anywhere

 TAY                    \ Store the y-coordinate in Y

 LDA ylookup,Y          \ Look up the page number of the character row that
 STA SC+1               \ contains the pixel with the y-coordinate in Y, and
                        \ store it in the high byte of SC(1 0) at SC+1

 LDA X1                 \ Each character block contains 8 pixel rows, so to get
 AND #%11111100         \ the address of the first byte in the character block
 ASL A                  \ that we need to draw into, as an offset from the start
                        \ of the row, we clear bits 0-1 and shift left to double
                        \ it (as each character row contains two pages of bytes,
                        \ or 512 bytes, which cover 256 pixels). This also
                        \ shifts bit 7 of X1 into the C flag

 STA SC                 \ Store the address of the character block in the low
                        \ byte of SC(1 0), so now SC(1 0) points to the
                        \ character block we need to draw into

 BCC P%+5               \ If the C flag is clear then skip the next two
                        \ instructions

 INC SC+1               \ The C flag is set, which means bit 7 of X1 was set
                        \ before the ASL above, so the x-coordinate is in the
                        \ right half of the screen (i.e. in the range 128-255).
                        \ Each row takes up two pages in memory, so the right
                        \ half is in the second page but SC+1 contains the value
                        \ we looked up from ylookup, which is the page number of
                        \ the first memory page for the row... so we need to
                        \ increment SC+1 to point to the correct page

 CLC                    \ Clear the C flag

 TYA                    \ Set Y to just bits 0-2 of the y-coordinate, which will
 AND #%00000111         \ be the number of the pixel row we need to draw into
 TAY                    \ within the character block

 LDA X1                 \ Copy bit 1 of X1 to bit 1 of X. X will now be either
 AND #%00000010         \ 0 or 2, and will be double the pixel number in the
 TAX                    \ character row for the left pixel in the dash (so 0
                        \ means the left pixel in the 2-pixel character row,
                        \ while 2 means the right pixel)

 LDA CTWOS,X            \ Fetch a mode 2 1-pixel byte with the pixel position
 AND COL                \ at X/2, and AND with the colour byte so that pixel
                        \ takes on the colour we want to draw (i.e. A is acting
                        \ as a mask on the colour byte)

 EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
 STA (SC),Y             \ remove it later without ruining the background that's
                        \ already on-screen

 LDA CTWOS+2,X          \ Fetch a mode 2 1-pixel byte with the pixel position
                        \ at (X+1)/2, so we can draw the right pixel of the dash

 BPL CP1                \ The CTWOS table has 2 extra rows at the end of it that
                        \ repeat the first values, %10101010, so if we have not
                        \ fetched that value, then the right pixel of the dash
                        \ is in the same character block as the left pixel, so
                        \ jump to CP1 to draw it

 LDA SC                 \ Otherwise the left pixel we drew was at the last
 ADC #8                 \ position of four in this character block, so we add
 STA SC                 \ 8 to the screen address to move onto the next block
                        \ along (as there are 8 bytes in a character block).
                        \ The C flag was cleared above, so this ADC is correct

 BCC P%+4               \ If the addition we just did overflowed, then increment
 INC SC+1               \ the high byte of SC(1 0), as this means we just moved
                        \ into the right half of the screen row

 LDA CTWOS+2,X          \ Refetch the mode 2 1-pixel byte, as we just overwrote
                        \ A (the byte will still be the fifth or sixth byte from
                        \ the table, which is correct as we want to draw the
                        \ leftmost pixel in the next character along as the
                        \ dash's right pixel)

.CP1

 AND COL                \ Draw the dash's right pixel according to the mask in
 EOR (SC),Y             \ A, with the colour in COL, using EOR logic, just as
 STA (SC),Y             \ above

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: SC48
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the #onescan command (draw a ship on the 3D scanner)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #onescan command with parameters
\ in the block at OSSC(1 0). It draws a ship on the 3D scanner. The parameters
\ match those put into the SCANpars block in the parasite.
\
\ Arguments:
\
\   OSSC(1 0)           A parameter block as follows:
\
\                         * Byte #2 = The sign of the stick height (in bit 7)
\
\                         * Byte #3 = The stick height for this ship on the
\                                     scanner
\
\                         * Byte #4 = The colour of the ship on the scanner
\
\                         * Byte #5 = The screen x-coordinate of the dot on the
\                                     scanner
\
\                         * Byte #6 = The screen y-coordinate of the dot on the
\                                     scanner
\
\ ******************************************************************************

.SC48

 LDY #4                 \ Fetch byte #4 from the parameter block (the colour)
 LDA (OSSC),Y           \ and store it in COL
 STA COL

 INY                    \ Fetch byte #5 from the parameter block (the screen
 LDA (OSSC),Y           \ x-coordinate) and store it in X1
 STA X1

 INY                    \ Fetch byte #6 from the parameter block (the screen
 LDA (OSSC),Y           \ y-coordinate) and store it in Y1
 STA Y1

 JSR CPIX4              \ Draw a double-height mode 2 dot at (X1, Y1). This also
                        \ leaves the following variables set up for the dot's
                        \ top-right pixel, the last pixel to be drawn (as the
                        \ dot gets drawn from the bottom up):
                        \
                        \   SC(1 0) = screen address of the pixel's character
                        \             block
                        \
                        \   Y = number of the character row containing the pixel
                        \
                        \   X = the pixel's number (0-3) in that row
                        \
                        \ We can use there as the starting point for drawing the
                        \ stick, if there is one

 LDA CTWOS+2,X          \ Load the same mode 2 1-pixel byte that we just used
 AND COL                \ for the top-right pixel, and mask it with the same
 STA X1                 \ colour, storing the result in X1, so we can use it as
                        \ the character row byte for the stick

 STY Q                  \ Store Y in Q so we can retrieve it after fetching the
                        \ stick details

 LDY #2                 \ Fetch byte #2 from the parameter block (the sign of
 LDA (OSSC),Y           \ the stick height) and shift bit 7 into the C flag, so
 ASL A                  \ C now contains the sign of the stick height

 INY                    \ Set A to byte #3 from the parameter block (the stick
 LDA (OSSC),Y           \ height)

 BEQ RTS                \ If the stick height is zero, then there is no stick to
                        \ draw, so return from the subroutine (as RTS contains
                        \ an RTS)

 LDY Q                  \ Restore the value of Y from Q, so Y now contains the
                        \ character row containing the dot we drew above

 TAX                    \ Copy the stick height into X

 BCC RTS+1              \ If the C flag is clear then the stick height in A is
                        \ negative, so jump down to RTS+1

.VLL1

                        \ If we get here then the stick length is positive (so
                        \ the dot is below the ellipse and the stick is above
                        \ the dot, and we need to draw the stick upwards from
                        \ the dot)

 DEY                    \ We want to draw the stick upwards, so decrement the
                        \ pixel row in Y

 BPL VL1                \ If Y is still positive then it correctly points at the
                        \ line above, so jump to VL1 to skip the following

 LDY #7                 \ We just decremented Y up through the top of the
                        \ character block, so we need to move it to the last row
                        \ in the character above, so set Y to 7, the number of
                        \ the last row

 DEC SC+1               \ Decrement the high byte of the screen address twice to
 DEC SC+1               \ move to the character block above (we do this twice as
                        \ there are two pages in memory per character row)

.VL1

 LDA X1                 \ Set A to the character row byte for the stick, which
                        \ we stored in X1 above, and which has the same pixel
                        \ pattern as the bottom-right pixel of the dot (so the
                        \ stick comes out of the right side of the dot)

 EOR (SC),Y             \ Draw the stick on row Y of the character block using
 STA (SC),Y

 DEX                    \ Decrement (positive) the stick height in X

 BNE VLL1               \ If we still have more stick to draw, jump up to VLL1
                        \ to draw the next pixel

.RTS

 RTS                    \ Return from the subroutine

                        \ If we get here then the stick length is negative (so
                        \ the dot is above the ellipse and the stick is below
                        \ the dot, and we need to draw the stick downwards from
                        \ the dot)

 INY                    \ We want to draw the stick downwards, so we first
                        \ increment the row counter so that it's pointing to the
                        \ bottom-right pixel in the dot (as opposed to the top-
                        \ right pixel that the call to CPIX4 finished on)

 CPY #8                 \ If the row number in Y is less than 8, then it
 BNE VLL2               \ correctly points at the next line down, so jump to
                        \ VLL2 to skip the following

 LDY #0                 \ We just incremented Y down through the bottom of the
                        \ character block, so we need to move it to the first
                        \ row in the character below, so set Y to 0, the number
                        \ of the first row

 INC SC+1               \ Increment the high byte of the screen address twice to
 INC SC+1               \ move to the character block above (we do this twice as
                        \ there are two pages in memory per character row)

.VLL2

 INY                    \ We want to draw the stick itself, heading downwards,
                        \ so increment the pixel row in Y

 CPY #8                 \ If the row number in Y is less than 8, then it
 BNE VL2                \ correctly points at the next line down, so jump to
                        \ VL2 to skip the following

 LDY #0                 \ We just incremented Y down through the bottom of the
                        \ character block, so we need to move it to the first
                        \ row in the character below, so set Y to 0, the number
                        \ of the first row

 INC SC+1               \ Increment the high byte of the screen address twice to
 INC SC+1               \ move to the character block above (we do this twice as
                        \ there are two pages in memory per character row)

.VL2

 LDA X1                 \ Set A to the character row byte for the stick, which
                        \ we stored in X1 above, and which has the same pixel
                        \ pattern as the bottom-right pixel of the dot (so the
                        \ stick comes out of the right side of the dot)

 EOR (SC),Y             \ Draw the stick on row Y of the character block using
 STA (SC),Y

 INX                    \ Decrement the (negative) stick height in X

 BNE VLL2               \ If we still have more stick to draw, jump up to VLL2
                        \ to draw the next pixel

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: BEGINLIN
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Implement the OSWRCH 129 <size> command (start receiving a new
\             line to draw)
\
\ ------------------------------------------------------------------------------
\
\ We draw line by first sending an OSWRCH 129 command to the I/O processor to
\ tell it to start receiving a new line to draw. The parameter to this call
\ (sent with the next OSWRCH) contains the number of bytes we are going to send
\ containing the line's coordinates.
\
\ This routine then executes an OSWRCH 130 command, which calls the ADDBYT
\ routine to start the I/O processor listening for more bytes from the parasite.
\ These get added to the TABLE buffer, and when the parasite has sent all the
\ coordinates, we draw the line.
\
\ Arguments:
\
\   A                   The number of points in the new line + 1
\
\ ******************************************************************************

.BEGINLIN

 STA LINMAX             \ Set LINMAX to the number of points in the new line + 1

 LDA #0                 \ Set LINTAB = 0 to point to the position of the next
 STA LINTAB             \ free byte in the TABLE buffer (i.e. the first byte, as
                        \ we have just reset the buffer)

 LDA #130               \ Execute a USOSWRCH 130 command so subsequent OSWRCH
 JMP USOSWRCH           \ calls from the parasite can send coordinates that get
                        \ added to TABLE, and return from the subroutine using a
                        \ tail call

\ ******************************************************************************
\
\       Name: ADDBYT
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Implement the OSWRCH 130 <byte> command (add a byte to a line and
\             draw it when all bytes are received)
\
\ ------------------------------------------------------------------------------
\
\ This routine received bytes from the parasite, each of which is a coordinate
\ in the line that is currently being drawn (following a call from the parasite
\ to OSWRCH 129, which starts the I/O processor listening for line bytes). They
\ are stored in the buffer at TABLE, where LINTAB points to the first free byte
\ in the table, and LINMAX contains double the number of points we are expecting
\ plus 1.
\
\ If the byte received is the last one in the line, then the line segments are
\ drawn by sending them to the LOIN routine.
\
\ If a laser line is sent by the parasite, it will be the first line segment
\ sent, and will be preceded by a dummy pair of coordinates where the Y2 value
\ is 255, which is not in the space view (as the maximum y-coordinate in the
\ space view is 191). Laser lines are drawn in red.
\
\ Arguments:
\
\   A                   The byte to be added to the line that's currently being
\                       transmitted to the I/O processor
\
\ ******************************************************************************

.RTS1

 RTS                    \ Return from the subroutine (this is called below)

.ADDBYT

 INC LINTAB             \ LINTAB points to the last free byte in TABLE, which is
                        \ where we're about to store the new byte in A, so
                        \ increment LINTAB to point to the byte after this one

 LDX LINTAB             \ Store the new byte in A at position LINTAB-1 in TABLE
 STA TABLE-1,X          \ (which was the last free byte before we incremented
                        \ LINTAB above)

 INX                    \ Increment X, so it now points to the byte after the
                        \ last free byte in TABLE (i.e. LINTAB + 1)

 CPX LINMAX             \ If X < LINMAX, jump up to RTS1 to return from the
 BCC RTS1               \ subroutine, as the line isn't complete yet (because
                        \ LINMAX contains the 2 * number of points + 1)

                        \ If we get here then X = LINMAX and we have received
                        \ all the line's points from the parasite, so now we
                        \ draw it

 LDY #0                 \ We are going to loop through all the points in the
                        \ line, so set a counter in Y, starting from 0

 DEC LINMAX             \ Decrement LINMAX so it now contains 2 * number of
                        \ points

 LDA TABLE+3            \ If TABLE+3 = 255, jump to doalaser to draw this line,
 CMP #255               \ as this denotes that the following segment is a laser
 BEQ doalaser           \ line, which should be drawn in red

.LL27

 LDA TABLE,Y            \ Set X1 to the Y-th byte from TABLE
 STA X1

 LDA TABLE+1,Y          \ Set Y1 to the Y+1-th byte from TABLE
 STA Y1

 LDA TABLE+2,Y          \ Set X2 to the Y+2-th byte from TABLE
 STA X2

 LDA TABLE+3,Y          \ Set Y2 to the Y+3-th byte from TABLE
 STA Y2

 STY T1                 \ Store the loop counter in T1 so we can retrieve it
                        \ after the call to LOIN

 JSR LOIN               \ Draw a line from (X1, Y1) to (X2, Y2)

 LDA T1                 \ Retrieve the loop counter from T1

 CLC                    \ Set A = A + 4
 ADC #4

.Ivedonealaser

 TAY                    \ Transfer the updated loop counter from A into Y

 CMP LINMAX             \ Loop back to LL27 to draw the next line segment, until
 BCC LL27               \ we the loop counter has reached LINMAX (which contains
                        \ 2 * number of points, so this is when we have run out
                        \ of points)

.DRLR1

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

.doalaser

 LDA COL                \ Store the current line colour on the stack, so we can
 PHA                    \ restore it below

 LDA #RED               \ Set the laser colour to red
 STA COL

                        \ The coordinates at bytes Y to Y+3 were used up with
                        \ the indicator bytes to say this is a laser line, so
                        \ we need to fetch the following bytes to get the line's
                        \ coordinates to draw

 LDA TABLE+4            \ Set X1 to the Y+4-th byte from TABLE
 STA X1

 LDA TABLE+5            \ Set Y1 to the Y+5-th byte from TABLE
 STA Y1

 LDA TABLE+6            \ Set X2 to the Y+6-th byte from TABLE
 STA X2

 LDA TABLE+7            \ Set Y2 to the Y+7-th byte from TABLE
 STA Y2

 JSR LOIN               \ Draw a line from (X1, Y1) to (X2, Y2)

 PLA                    \ Restore the original line colour from the stack
 STA COL

 LDA #8                 \ Jump up to Ivedonealaser with A set to 8, which will
 BNE Ivedonealaser      \ point to the rest of the lines as the laser line is
                        \ always the first to be transmitted from the parasite
                        \ (this BNE is effectively a JMP as A is never zero)

\ ******************************************************************************
\
\       Name: TWOS
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made single-pixel character row bytes for mode 1
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting one-pixel points in mode 1 (the top part of the
\ split screen).
\
\ ******************************************************************************

.TWOS

 EQUB %10001000
 EQUB %01000100
 EQUB %00100010
 EQUB %00010001

\ ******************************************************************************
\
\       Name: TWOS2
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made double-pixel character row bytes for mode 1
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting two-pixel dashes in mode 1 (the top part of the
\ split screen).
\
\ ******************************************************************************

.TWOS2

 EQUB %11001100
 EQUB %01100110
 EQUB %00110011
 EQUB %00110011

\ ******************************************************************************
\
\       Name: CTWOS
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made single-pixel character row bytes for mode 2
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting one-pixel points in mode 2 (the bottom part of
\ the split screen).
\
\ In mode 2, each character row is one byte, which is two pixels. Rows 0 and 1
\ of the table contain a character row byte with just the left pixel plotted,
\ while rows 2 and 3 contain a character row byte with just the right pixel
\ plotted.
\
\ In other words, looking up row X will return a character row byte with pixel
\ X/2 plotted (if the pixels are numbered 0 and 1).
\
\ There are two extra rows to support the use of CTWOS+2,X indexing in the CPIX2
\ routine. The extra rows are repeats of the first two rows, and save us from
\ having to work out whether CTWOS+2+X needs to be wrapped around when drawing a
\ two-pixel dash that crosses from one character block into another. See CPIX2
\ for more details.
\
\ ******************************************************************************

.CTWOS

 EQUB %10101010
 EQUB %10101010
 EQUB %01010101
 EQUB %01010101
 EQUB %10101010
 EQUB %10101010

\ ******************************************************************************
\
\       Name: HLOIN2
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: 
\
\ ******************************************************************************

.HLOIN2

 LDX X1
 STY Y2
 INY
 STY Q
 LDA COL
 JMP HLOIN3 \any colour

\ ******************************************************************************
\
\       Name: LOIN (Part 1 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: 
\
\ ******************************************************************************

.LOIN

 LDA #128
 STA S
 ASL A
 STA SWAP
 LDA X2
 SBC X1
 BCS LI1
 EOR #&FF
 ADC #1
 SEC

.LI1

 STA P
 LDA Y2
 SBC Y1
 BEQ HLOIN2
 BCS LI2
 EOR #&FF
 ADC #1

.LI2

 STA Q
 CMP P
 BCC STPX
 JMP STPY

\ ******************************************************************************
\
\       Name: LOIN (Part 2 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: 
\
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

 LDA ylookup,Y          \ Look up the page number of the character row that
 STA SC+1               \ contains the pixel with the y-coordinate in Y, and
                        \ store it in the high byte of SC(1 0) at SC+1

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

 LDA #&FF
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
\
\       Name: LOIN (Part 3 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: 
\
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
\
\       Name: LOIN (Part 4 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: 
\
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
\
\       Name: LOIN (Part 5 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: 
\
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

 LDA ylookup,Y          \ Look up the page number of the character row that
 STA SC+1               \ contains the pixel with the y-coordinate in Y, and
                        \ store it in the high byte of SC(1 0) at SC+1

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

 LDA #&FF
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
\
\       Name: LOIN (Part 6 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: 
\
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
\
\       Name: LOIN (Part 7 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: 
\
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
\
\       Name: HLOIN
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Implement the OSWORD 247 command (draw a horizontal line)
\
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

 LDA ylookup,Y          \ Look up the page number of the character row that
 STA SC+1               \ contains the pixel with the y-coordinate in Y, and
                        \ store it in the high byte of SC(1 0) at SC+1

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
\
\       Name: TWFL
\       Type: Variable
\   Category: Drawing pixels
\    Summary: 
\
\ ******************************************************************************

.TWFL

 EQUD &FFEECC88

\ ******************************************************************************
\
\       Name: TWFR
\       Type: Variable
\   Category: Drawing pixels
\    Summary: 
\
\ ******************************************************************************

.TWFR

 EQUD &113377FF

\ ******************************************************************************
\
\       Name: orange
\       Type: Variable
\   Category: Drawing pixels
\    Summary: 
\
\ ******************************************************************************

.orange

 EQUB &A5
 EQUB &A5
 EQUB &5A
 EQUB &5A

\ ******************************************************************************
\
\       Name: PIXEL
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Implement the OSWORD 240 command (draw a pixel)
\
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

 LDA ylookup,Y          \ Look up the page number of the character row that
 STA SC+1               \ contains the pixel with the y-coordinate in Y, and
                        \ store it in the high byte of SC(1 0) at SC+1

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

 LDA ylookup,Y          \ Look up the page number of the character row that
 STA SC+1               \ contains the pixel with the y-coordinate in Y, and
                        \ store it in the high byte of SC(1 0) at SC+1

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
\
\       Name: PXCL
\       Type: Variable
\   Category: Drawing pixels
\    Summary: 
\
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
\
\       Name: newosrdch
\       Type: Subroutine
\   Category: Tube
\    Summary: The custom OSRDCH routine for reading characters
\
\ ------------------------------------------------------------------------------
\
\ RDCHV is set to point to this routine in the STARTUP routine that runs when
\ the I/O processor code first loads. It uses the standard OSRDCH routine to
\ read characters from the input stream, and bolts on logic to check for valid
\ and invalid characters.
\
\ Returns:
\
\   A                   The character that is read:
\
\                         * Valid input: The character's ASCII value
\
\                         * Invalid input: 7
\
\   C flag              The C flag is cleared
\
\ ******************************************************************************

.newosrdch

 JSR &FFFF              \ This address is overwritten by the STARTUP routine to
                        \ contain the original value of RDCHV, so this call acts
                        \ just like a standard JSR OSRDCH call, and reads a
                        \ character from the current input stream and stores it
                        \ in A

 CMP #128               \ If A < 128 then skip the following three instructions,
 BCC P%+6               \ otherwise the character is invalid, so fall through
                        \ into badkey to deal with it

.badkey

                        \ If we get here then the character we read is invalid,
                        \ so we return a beep character

 LDA #7                 \ Set A to the beep character

 CLC                    \ Clear the C flag

 RTS                    \ Return from the subroutine

                        \ If we get here then A < 128

 CMP #' '               \ If A >= ASCII " " then this is a valid alphanumerical
 BCS coolkey            \ key press (as A is in the range 32 to 127), so jump
                        \ down to coolkey to return this key press

 CMP #13                \ If A = 13 then this is the return character, so jump
 BEQ coolkey            \ down to coolkey to return this key press

 CMP #21                \ If A <> 21 jump up to badkey
 BNE badkey

.coolkey

                        \ If we get here then the character we read is valid, so
                        \ return it

 CLC                    \ Clear the C flag

 RTS                    \ Return from the subroutine

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
\ Add two 16-bit sign-magnitude numbers together, calculating:
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

 LDA R                  \ Add the least significant bytes together into X:
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

 LDA P                  \ Subtract the least significant bytes into X:
 SEC                    \
 SBC R                  \   X = P - R
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
                        \ value). So let's subtract the result we have in (A X)
                        \ from zero, so that the subtraction is the right way
                        \ round

 STA U                  \ Store A in U

 TXA                    \ Set X = 0 - X using two's complement (to negate a
 EOR #&FF               \ number in two's complement, you can invert the bits
 ADC #1                 \ and add one - and we know the C flag is clear as we
 TAX                    \ didn't take the BCS branch above, so the ADC will do
                        \ the correct addition)

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
\
\       Name: HANGER
\       Type: Subroutine
\   Category: Ship hanger
\    Summary: Implement the OSWORD 248 command (display the ship hanger)
\
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

 LDA ylookup,Y          \ Look up the page number of the character row that
 STA SC+1               \ contains the pixel with the y-coordinate in Y, and
                        \ store it in the high byte of SC(1 0) at SC+1

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

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ADPARAMS
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the OSWRCH 137 <param> command (add a dashboard
\             parameter and update the dashboard when all are received)
\
\ ******************************************************************************

.ADPARAMS

 INC PARANO             \ PARANO points to the last free byte in PARAMS, which
                        \ is where we're about to store the new byte in A, so
                        \ increment PARANO to point to the byte after this one

 LDX PARANO             \ Store the new byte in A at position PARANO-1 in TABLE
 STA PARAMS-1,X         \ (which was the last free byte before we incremented
                        \ PARANO above)

 CPX #PARMAX            \ If X >= #PARMAX, skip the following instruction, as we
 BCS P%+3               \ have now received all the parameters we need to update
                        \ the dashboard

 RTS                    \ Otherwise we still have more parameters to receive, so
                        \ return from the subroutine

 JSR DIALS              \ Call DIALS to update the dashboard with the parameters
                        \ in PARAMS

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: RDPARAMS
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the #RDPARAMS command (start receiving a new set of
\             parameters for updating the dashboard)
\
\ ******************************************************************************

.RDPARAMS

 LDA #0                 \ Set PARANO = 0 to point to the position of the next
 STA PARANO             \ free byte in the PARAMS buffer (i.e. reset the buffer)

 LDA #137               \ Execute a USOSWRCH 137 command so subsequent OSWRCH
 JMP USOSWRCH           \ calls from the parasite can send parameters that get
                        \ added to PARAMS, and return from the subroutine using
                        \ a tail call

\ ******************************************************************************
\
\       Name: DKS4
\       Type: Macro
\   Category: Keyboard
\    Summary: Scan the keyboard to see if a specific key is being pressed
\
\ ------------------------------------------------------------------------------
\
\ Scan the keyboard to see if the key specified in A is currently being pressed.
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

 STX VIA+&40            \ Set 6522 System VIA output register ORB (SHEILA &40)
                        \ to %00000011 to stop auto scan of keyboard

 LDX #%01111111         \ Set 6522 System VIA data direction register DDRA
 STX VIA+&43            \ (SHEILA &43) to %01111111. This sets the A registers
                        \ (IRA and ORA) so that:
                        \
                        \   * Bits 0-6 of ORA will be sent to the keyboard
                        \
                        \   * Bit 7 of IRA will be read from the keyboard

 STA VIA+&4F            \ Set 6522 System VIA output register ORA (SHEILA &4F)
                        \ to X, the key we want to scan for; bits 0-6 will be
                        \ sent to the keyboard, of which bits 0-3 determine the
                        \ keyboard column, and bits 4-6 the keyboard row

 LDA VIA+&4F            \ Read 6522 System VIA output register IRA (SHEILA &4F)
                        \ into A; bit 7 is the only bit that will have changed.
                        \ If the key is pressed, then bit 7 will be set,
                        \ otherwise it will be clear

 LDX #%00001011         \ Set 6522 System VIA output register ORB (SHEILA &40)
 STX VIA+&40            \ to %00001011 to restart auto scan of keyboard

 CLI                    \ Allow interrupts again

ENDMACRO

\ ******************************************************************************
\
\       Name: KYTB
\       Type: Variable
\   Category: Keyboard
\    Summary: Lookup table for in-flight keyboard controls
\  Deep dive: The key logger
\
\ ------------------------------------------------------------------------------
\
\ Keyboard table for in-flight controls. This table contains the internal key
\ codes for the flight keys (see p.142 of the Advanced User Guide for a list of
\ internal key numbers).
\
\ The pitch, roll, speed and laser keys (i.e. the seven primary flight
\ control keys) have bit 7 set, so they have 128 added to their internal
\ values. This doesn't appear to be used anywhere.
\
\ Note that KYTB actually points to the byte before the start of the table, so
\ the offset of the first key value is 1 (i.e. KYTB+1), not 0.
\
\ ******************************************************************************

.KYTB

 EQUB 0                 \ Pad the table out so that the first key is at KYTB+1

                        \ These are the primary flight controls (pitch, roll,
                        \ speed and lasers):

 EQUB &68 + 128         \ ?         KYTB+1      Slow down
 EQUB &62 + 128         \ Space     KYTB+2      Speed up
 EQUB &66 + 128         \ <         KYTB+3      Roll left
 EQUB &67 + 128         \ >         KYTB+4      Roll right
 EQUB &42 + 128         \ X         KYTB+5      Pitch up
 EQUB &51 + 128         \ S         KYTB+6      Pitch down
 EQUB &41 + 128         \ A         KYTB+7      Fire lasers

                        \ These are the secondary flight controls:

 EQUB &60               \ TAB       KYTB+8      Energy bomb
 EQUB &70               \ ESCAPE    KYTB+9      Launch escape pod
 EQUB &23               \ T         KYTB+10     Arm missile
 EQUB &35               \ U         KYTB+11     Unarm missile
 EQUB &65               \ M         KYTB+12     Fire missile
 EQUB &22               \ E         KYTB+13     E.C.M.
 EQUB &45               \ J         KYTB+14     In-system jump
 EQUB &52               \ C         KYTB+15     Docking computer

 NOP                    \ In the parasite's version of this table, this byte
                        \ maps to "P", the key to cancel the docking computer,
                        \ but because the I/O processor only uses this table for
                        \ the primary flight keys, this byte isn't used

\ ******************************************************************************
\
\       Name: KEYBOARD
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Implement the OSWORD 240 command (scan the keyboard and joystick
\             and log the results)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends an OSWORD 240 command. It scans
\ the keyboard and joystick and stores the results in the key logger buffer
\ pointed to by OSSC, which is then sent across the Tube to the parasite's own
\ key logger buffer at KTRAN.
\
\ First, it scans the keyboard for the primary flight keys. If any of the
\ primary flight keys are pressed, the corresponding byte in the key logger is
\ set to &FF, otherwise it is set to 0. If multiple flight keys are being
\ pressed, they are all logged.
\
\ Next, it scans the keyboard for any other key presses, starting with internal
\ key number 16 ("Q") and working through the set of internal key numbers (see
\ p.142 of the Advanced User Guide for a list of internal key numbers). If a key
\ press is detected, the internal key number is stored in byte #2 of the key
\ logger table and scanning stops.
\
\ Finally, the joystick is read for X, Y and fire button values. The rotation
\ value is also read from the Bitstik.
\
\ Arguments:
\
\   OSSC                The address of the table in which to log the key presses
\
\ Returns:
\
\   OSSC                The table is updated as follows:
\
\                         * Byte #2: If a non-primary flight control key is
\                           being pressed, its internal key number is put here
\
\                         * Byte #3: "?" is being pressed (0 = no, &FF = yes)
\
\                         * Byte #4: Space is being pressed (0 = no, &FF = yes)
\
\                         * Byte #5: "<" is being pressed (0 = no, &FF = yes)
\
\                         * Byte #6: ">" is being pressed (0 = no, &FF = yes)
\
\                         * Byte #7: "X" is being pressed (0 = no, &FF = yes)
\
\                         * Byte #8: "S" is being pressed (0 = no, &FF = yes)
\
\                         * Byte #9: "A" is being pressed (0 = no, &FF = yes)
\
\                         * Byte #10: Joystick X value (high byte)
\
\                         * Byte #11: Joystick Y value (high byte)
\
\                         * Byte #12: Bitstik rotation value (high byte)
\
\                         * Byte #14: Joystick 1 fire button is being pressed
\                           (Bit 4 set = no, Bit 4 clear = yes)
\
\ ******************************************************************************

.KEYBOARD

 LDY #9                 \ We're going to loop through the seven primary flight
                        \ controls in KYTB and update the block pointed to by
                        \ OSSC with their details. We want to store the seven
                        \ results in bytes #2 to #9 in the block, so we set a
                        \ loop counter in Y to count down from 9 to 3, so we can
                        \ use this as an index into both the OSSC block and the
                        \ KYTB table

.DKL2

 LDA KYTB-2,Y           \ Set A to the relevant internal key number from the
                        \ KYTB table (we add Y to KYTB-2 rather than KYTB as Y
                        \ is looping from 9 down to 3, so this grabs the key
                        \ numbers from 7 to 1, i.e. from "A" to "?"

 DKS4                   \ Include macro DKS4 to check whether the key in A is
                        \ being pressed, and if it is, set bit 7 of A

 ASL A                  \ Shift bit 7 of A into the C flag

 LDA #0                 \ Set A = 0 + &FF + C
 ADC #&FF               \
                        \ If the C flag is set (i.e. the key is being pressed)
                        \ then this sets A = 0, otherwise it sets A = &FF

 EOR #%11111111         \ Flip all the bits in A, so now A = &FF if the key is
                        \ being pressed, or A = 0 if it isn't

 STA (OSSC),Y           \ Store A in the Y-th byte of the block pointed to by
                        \ OSSC

 DEY                    \ Decrement the loop counter

 CPY #2                 \ Loop back until we have processed all seven primary
 BNE DKL2               \ flight keys, leaving the loop with Y = 2

                        \ We're now going to scan the keyboard to see if any
                        \ other keys are being pressed

 LDA #16                \ We start scanning from internal key number 16 ("Q"),
                        \ so we set A as a loop counter

 SED                    \ Set the D flag to enter decimal mode. Because
                        \ internal key numbers are all valid BCD (Binary Coded
                        \ Decimal) numbers, setting this flag ensures we only
                        \ loop through valid key numbers. To put this another
                        \ way, when written in hexadecimal, internal key numbers
                        \ only use the digits 0-9 and none of the letters A-F,
                        \ and setting the D flag makes the following loop
                        \ iterate through the following values of A:
                        \
                        \ &10, &11, &12, &13, &14, &15, &16, &17, &18, &19,
                        \ &20, &21, &22, &23, &24, &25, &26, &27, &28, &29,
                        \ &30, &31...
                        \
                        \ and so on up to &79, and then &80, at which point the
                        \ loop terminates. This lets us efficiently work our
                        \ way through all the internal key numbers without
                        \ wasting time on numbers that aren't valid in BCD

.DKL3

 DKS4                   \ Include macro DKS4 to check whether the key in A is
                        \ being pressed, and if it is, set bit 7 of A

 TAX                    \ Copy the key press result into X

 BMI DK1                \ If bit 7 is set, i.e. the key is being pressed, skip
                        \ to DK1

 CLC                    \ Otherwise this key is not being pressed, so increment
 ADC #1                 \ the loop counter in A. We couldn't use an INX or INY
                        \ instruction here because the only instructions that
                        \ support decimal mode are ADC and SBC. INX and INY
                        \ always increment in binary mode, whatever the setting
                        \ of the D flag, so instead we have to use an ADC

 BPL DKL3               \ Loop back to test the next key, ending the loop when
                        \ A is negative (i.e. A = &80 = 128 = %10000000)

.DK1

 CLD                    \ Clear the D flag to return to binary mode

 EOR #%10000000         \ EOR A with #%10000000 to flip bit 7, so A now contains
                        \ 0 if no key has been pressed, or the internal key
                        \ number if a key has been pressed

 STA (OSSC),Y           \ We exited the first loop above with Y = 2, so this
                        \ stores the "other key" result in byte #2 of the block
                        \ pointed to by OSSC

                        \ We now check the joystick or Bitstik

 LDX #1                 \ Call OSBYTE 128 to fetch the 16-bit value from ADC
 LDA #128               \ channel 1 (the joystick X value), returning the value
 JSR OSBYTE             \ in (Y X)

 TYA                    \ Copy Y to A, so the result is now in (A X)

 LDY #10                \ Store the high byte of the joystick X value in byte
 STA (OSSC),Y           \ #10 of the block pointed to by OSSC

 LDX #2                 \ Call OSBYTE 128 to fetch the 16-bit value from ADC
 LDA #128               \ channel 2 (the joystick Y value), returning the value
 JSR OSBYTE             \ in (Y X)

 TYA                    \ Copy Y to A, so the result is now in (A X)

 LDY #11                \ Store the high byte of the joystick Y value in byte
 STA (OSSC),Y           \ #11 of the block pointed to by OSSC

 LDX #3                 \ Call OSBYTE 128 to fetch the 16-bit value from ADC
 LDA #128               \ channel 3 (the Bitstik rotation value), returning the
 JSR OSBYTE             \ value in (Y X)

 TYA                    \ Copy Y to A, so the result is now in (A X)

 LDY #12                \ Store the high byte of the Bitstik rotation value in
 STA (OSSC),Y           \ byte #12 of the block pointed to by OSSC

 LDY #14                \ Read 6522 System VIA input register IRB (SHEILA &40),
 LDA &FE40              \ which has bit 4 clear if joystick 1's fire button is
 STA (OSSC),Y           \ pressed (otherwise it's set), and store the value in
                        \ byte #14 of the block pointed to by OSSC

.DK2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: OSWVECS
\       Type: Variable
\   Category: Text
\    Summary: The lookup table for OSWORD jump commands (240-255)
\
\ ------------------------------------------------------------------------------
\
\ On entry into these routines, OSSC(1 0) points to the parameter block passed
\ to the OSWORD call in (Y X). OSSC must not be changed by the routines, as it
\ is used by NWOSWD to preserve the values of X and Y through the revectored
\ OSWORD call. OSSC(1 0) can be copied into SC(1 0) to avoid changing it.
\
\ ******************************************************************************

.OSWVECS

 EQUW KEYBOARD          \            240 (&F0)     0 = Scan the keyboard
 EQUW PIXEL             \            241 (&F1)     1 = Draw a pixel
 EQUW MSBAR             \ #DOmsbar = 242 (&F2)     2 = Update missile indicators
 EQUW WSCAN             \ #wscn    = 243 (&F3)     3 = Wait for vertical sync
 EQUW SC48              \ #onescan = 244 (&F4)     4 = Draw ship on 3D scanner
 EQUW DOT               \ #DOdot   = 245 (&F5)     5 = Draw a dot
 EQUW DODKS4            \ #DODKS4  = 246 (&F6)     6 = Scan for a specific key
 EQUW HLOIN             \            247 (&F7)     7 = Draw a horizontal line
 EQUW HANGER            \            248 (&F8)     8 = Display the hanger
 EQUW SOMEPROT          \            249 (&F9)     9 = Copy protection
 EQUW SAFE              \            250 (&FA)    10 = Do nothing
 EQUW SAFE              \            251 (&FB)    11 = Do nothing
 EQUW SAFE              \            252 (&FC)    12 = Do nothing
 EQUW SAFE              \            253 (&FD)    13 = Do nothing
 EQUW SAFE              \            254 (&FE)    14 = Do nothing
 EQUW SAFE              \            255 (&FF)    15 = Do nothing

 EQUW SAFE              \ These addresses are never used and have no effect, as
 EQUW SAFE              \ they are out of range for one-byte OSWORD numbers
 EQUW SAFE

\ ******************************************************************************
\
\       Name: NWOSWD
\       Type: Subroutine
\   Category: Tube
\    Summary: The custom OSWORD routine
\
\ ------------------------------------------------------------------------------
\
\ WORDV is set to point to this routine in the STARTUP routine that runs when
\ the I/O processor code first loads.
\
\ Arguments:
\
\   A                   The OSWORD call to perform:
\
\                         * 240-255: Run the jump command in A (see OSWVECS)
\
\                         * All others: Call the standard OSWORD routine
\
\  (Y X)                The address of the associated OSWORD parameter block
\
\ ******************************************************************************

.NWOSWD

 BIT svn                \ If bit 7 of svn is set, jump to notours to process
 BMI notours            \ this call with the standard OSWORD handler

 CMP #240               \ If A < 240, this is not a special jump command call,
 BCC notours            \ so jump to notours to pass it to the standard OSWORD
                        \ handler

 STX OSSC               \ Store X in OSCC so we can retrieve it later

 STY OSSC+1             \ Store Y in OSCC+1 so we can retrieve it later

 PHA                    \ Store A on the stack so we can retrieve it later

 SBC #240               \ Set X = (A - 240) * 2
 ASL A                  \
 TAX                    \ so X can be used as an index into a jump table, where
                        \ the table entries correspond to original values of A
                        \ of 240 for entry 0, 241 for entry 1, 242 for entry 2,
                        \ and so on

 LDA OSWVECS,X          \ Fetch the OSWVECS jump table address pointed to by X,
 STA JSRV+1             \ and store it in JSRV(2 1). This modifies the address
 LDA OSWVECS+1,X        \ of the JSR instruction at JSRV below, so it will call
 STA JSRV+2             \ the subroutine from the jump table

 LDX OSSC               \ Restore the value of X we stored in OSSC, so now both
                        \ X and Y have the values from the original OSWORD call

.JSRV

 JSR &FFFC              \ This address is overwritten by the code above to point
                        \ to the relevant jump command from the OSWVECS jump
                        \ table, so this instruction runs the jump command

 PLA                    \ Retrieve A from the stack

 LDX OSSC               \ Retrieve X from OSSC

 LDY OSSC+1             \ Retrieve Y from OSSC+1

.SAFE

 RTS                    \ Return from the subroutine

.notours

 JMP &FFFC              \ This address is overwritten by the STARTUP routine to
                        \ contain the original value of WORDV, so this call acts
                        \ just like a standard JMP OSWORD call and is used to
                        \ process OSWORD calls that aren't our custom calls

\ ******************************************************************************
\
\       Name: MSBAR
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the #DOmsbar command (draw a specific indicator in the
\             dashboard's missile bar)
\
\ ------------------------------------------------------------------------------
\
\ Each indicator is a rectangle that's 3 pixels wide and 5 pixels high. If the
\ indicator is set to black, this effectively removes a missile.
\
\ This routine is run when the parasite sends a #DOmsbar command with parameters
\ in the block at OSSC(1 0). It draws a specific indicator in the dashboard's
\ missile bar. The parameters match those put into the msbpars block in the
\ parasite.
\
\ Arguments:
\
\   OSSC(1 0)           A parameter block as follows:
\
\                         * Byte #2 = The number of the missile indicator to
\                           update (counting from right to left, so indicator
\                           NOMSL is the leftmost indicator)
\
\                         * Byte #3 = The colour of the missile indicator:
\
\                           * &00 = black (no missile)
\
\                           * #RED2 = red (armed and locked)
\
\                           * #YELLOW2 = yellow/white (armed)
\
\                           * #GREEN2 = green (disarmed)
\
\ Returns:
\
\   X                   X is preserved
\
\   Y                   Y is set to 0
\
\ ******************************************************************************

.MSBAR

 LDY #2                 \ Fetch byte #2 from the parameter block (the number of
 LDA (OSSC),Y           \ the missile indicator) into A

 ASL A                  \ Set T = A * 8
 ASL A
 ASL A
 ASL A
 STA T

 LDA #97                \ Set SC = 97 - T
 SBC T                  \        = 96 + 1 - (X * 8)
 STA SC

                        \ So the low byte of SC(1 0) contains the row address
                        \ for the rightmost missile indicator, made up as
                        \ follows:
                        \
                        \   * 96 (character block 14, as byte #14 * 8 = 96), the
                        \     character block of the rightmost missile
                        \
                        \   * 1 (so we start drawing on the second row of the
                        \     character block)
                        \
                        \   * Move right one character (8 bytes) for each count
                        \     of X, so when X = 0 we are drawing the rightmost
                        \     missile, for X = 1 we hop to the left by one
                        \     character, and so on

 LDA #&7C               \ Set the high byte of SC(1 0) to &7C, the character row
 STA SCH                \ that contains the missile indicators (i.e. the bottom
                        \ row of the screen)

 LDY #3                 \ Fetch byte #2 from the parameter block (the indicator
 LDA (OSSC),Y           \ colour) into A. This is one of #GREEN2, #YELLOW2 or
                        \ #RED2, or 0 for black, so this is a 2-pixel wide mode
                        \ 2 character row byte in the specified colour

 LDY #5                 \ We now want to draw this line five times to do the
                        \ left two pixels of the indicator, so set a counter in
                        \ Y

.MBL1

 STA (SC),Y             \ Draw the 3-pixel row, and as we do not use EOR logic,
                        \ this will overwrite anything that is already there
                        \ (so drawing a black missile will delete what's there)

 DEY                    \ Decrement the counter for the next row

 BNE MBL1               \ Loop back to MBL1 if have more rows to draw

 PHA                    \ Store the value of A on the stack so we can retrieve
                        \ it after the following addition

 LDA SC                 \ Set SC = SC + 8
 CLC                    \
 ADC #8                 \ so SC(1 0) now points to the next character block on
 STA SC                 \ the row (for the right half of the indicator)

 PLA                    \ Retrieve A from the stack

 AND #%10101010         \ Mask the character row to plot just the first pixel
                        \ in the next character block, as we already did a
                        \ two-pixel wide band in the previous character block,
                        \ so we need to plot just one more pixel, width-wise

 LDY #5                 \ We now want to draw this line five times, so set a
                        \ counter in Y

.MBL2

 STA (SC),Y             \ Draw the 1-pixel row, and as we do not use EOR logic,
                        \ this will overwrite anything that is already there
                        \ (so drawing a black missile will delete what's there)

 DEY                    \ Decrement the counter for the next row

 BNE MBL2               \ Loop back to MBL2 if have more rows to draw

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: WSCAN
\       Type: Subroutine
\   Category: Screen mode
\    Summary: Implement the #wscn command (wait for the vertical sync)
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
\
\       Name: DODKS4
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Implement the #DODKS4 command (scan the keyboard to see if a
\             specific key is being pressed)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DODKS4 command with parameters
\ in the block at OSSC(1 0). It scans the keyboard to see if the specified key
\ is being pressed.
\
\ Arguments:
\
\   OSSC(1 0)           A parameter block as follows:
\
\                         * Byte #2 = The internal number of the key to check
\
\                       See p.142 of the Advanced User Guide for a list of
\                       internal key numbers
\
\ Returns:
\
\   OSSC(1 0)           A parameter block as follows:
\
\                         * Byte #2 = If the key is being pressed, it contains
\                           the original key number from byte #2, but with bit 7
\                           set (i.e. key number + 128). If the key is not being
\                           pressed, it contains the unchanged key number
\
\ ******************************************************************************

.DODKS4

 LDY #2                 \ Fetch byte #2 from the block pointed to by OSSC, which
 LDA (OSSC),Y           \ contains the key to check, and store it in A

 DKS4                   \ Include macro DKS4 to check whether the key in A is
                        \ being pressed, and if it is, set bit 7 of A

 STA (OSSC),Y           \ Store the updated A in byte #2 of the block pointed to
                        \ by OSSC

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: cls
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Clear the top part of the screen and draw a white border
\
\ ******************************************************************************

.cls

 JSR TTX66              \ Call TTX66 to clear the top part of the screen and
                        \ draw a white border

 JMP RR4                \ Jump to RR4 to restore X and Y from the stack and A
                        \ from K3, and return from the subroutine using a tail
                        \ call

\ ******************************************************************************
\
\       Name: TT67
\       Type: Subroutine
\   Category: Text
\    Summary: Print a newline
\
\ ******************************************************************************

.TT67

 LDA #12                \ Set A to a carriage return character

                        \ Fall through into TT26 to print the newline

\ ******************************************************************************
\
\       Name: TT26
\       Type: Subroutine
\   Category: Text
\    Summary: Print a character at the text cursor by poking into screen memory
\
\ ------------------------------------------------------------------------------
\
\ Print a character at the text cursor (XC, YC), do a beep, print a newline,
\ or delete left (backspace).
\
\ Calls to OSWRCH will end up here when A is not in the range 128-147, as those
\ are reserved for the special jump table OSWRCH commands.
\
\ Arguments:
\
\   A                   The character to be printed. Can be one of the
\                       following:
\
\                         * 7 (beep)
\
\                         * 10 (line feed)
\
\                         * 11 (clear the top part of the screen and draw a
\                           border)
\
\                         * 12-13 (carriage return)
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
\ ******************************************************************************

.TT26

 STA K3                 \ Store the A, X and Y registers, so we can restore
 TYA                    \ them at the end (so they don't get changed by this
 PHA                    \ routine)
 TXA
 PHA
 LDA K3

 TAY                    \ Set Y = the character to be printed

 BEQ RR4S               \ If the character is zero, which is typically a string
                        \ terminator character jump down to RR4 (via the JMP in
                        \ RR4S) to restore the registers and return from the
                        \ subroutine using a tail call

 CMP #11                \ If this is control code 11 (clear screen), jump to cls
 BEQ cls                \ ro clear the top part of the screen, draw a white
                        \ border and return from the subroutine via RR4

 CMP #7                 \ If this is not control code 7 (beep), skip the next
 BNE P%+5               \ instruction

 JMP R5                 \ This is control code 7 (beep), so jump to R5 to make
                        \ a beep and return from the subroutine via RR4

 CMP #32                \ If this is an ASCII character (A >= 32), jump to RR1
 BCS RR1                \ below, which will print the character, restore the
                        \ registers and return from the subroutine

 CMP #10                \ If this is control code 10 (line feed) then jump to
 BEQ RRX1               \ RRX1, which will move down a line, restore the
                        \ registers and return from the subroutine

 LDX #1                 \ If we get here, then this is control code 12 or 13,
 STX XC                 \ both of which are used. This code prints a newline,
                        \ which we can achieve by moving the text cursor
                        \ to the start of the line (carriage return) and down
                        \ one line (line feed). These two lines do the first
                        \ bit by setting XC = 1, and we then fall through into
                        \ the line feed routine that's used by control code 10

.RRX1

 CMP #13                \ If this is control code 13 (carriage return) then jump
 BEQ RR4S               \ to RR4 (via the JMP in RR4S) to restore the registers
                        \ and return from the subroutine using a tail call

 INC YC                 \ Increment the text cursor y-coordinate to move it
                        \ down one row

.RR4S

 JMP RR4                \ Jump to RR4 to restore the registers and return from
                        \ the subroutine using a tail call

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
                        \ character). The MOS ROM contains bitmap definitions
                        \ of the BBC's ASCII characters, starting from &C000
                        \ for space (ASCII 32) and ending with the £ symbol
                        \ (ASCII 126)
                        \
                        \ To save time looking this information up from the MOS
                        \ ROM a copy of these bitmap definitions is embedded
                        \ into this source code at page FONT%, so page 0 of the
                        \ font is at FONT%, page 1 is at FONT%+1, and page 2 at
                        \ FONT%+3
                        \
                        \ There are definitions for 32 characters in each of the
                        \ three pages of MOS memory, as each definition takes up
                        \ 8 bytes (8 rows of 8 pixels) and 32 * 8 = 256 bytes =
                        \ 1 page. So:
                        \
                        \   ASCII 32-63  are defined in &C000-&C0FF (page 0)
                        \   ASCII 64-95  are defined in &C100-&C1FF (page 1)
                        \   ASCII 96-126 are defined in &C200-&C2F0 (page 2)
                        \
                        \ The following code reads the relevant character
                        \ bitmap from the copied MOS bitmaps at FONT% and pokes
                        \ those values into the correct position in screen
                        \ memory, thus printing the character on-screen
                        \
                        \ It's a long way from 10 PRINT "Hello world!":GOTO 10

 TAY                    \ Copy the character number from A to Y, as we are
                        \ about to pull A apart to work out where this
                        \ character definition lives in memory

                        \ Now we want to set X to point to the relevant page
                        \ number for this character - i.e. FONT% to FONT%+2

                        \ The following logic is easier to follow if we look
                        \ at the three character number ranges in binary:
                        \
                        \   Bit #  76543210
                        \
                        \   32  = %00100000     Page 0 of bitmap definitions
                        \   63  = %00111111
                        \
                        \   64  = %01000000     Page 1 of bitmap definitions
                        \   95  = %01011111
                        \
                        \   96  = %01100000     Page 2 of bitmap definitions
                        \   125 = %01111101
                        \
                        \ We'll refer to this below

\BEQ RR4                \ This instruction is commented out in the original
                        \ source, but it would return from the subroutine if A
                        \ is zero

 BPL P%+5               \ If the character number is positive (i.e. A < 128)
                        \ then skip the following instruction

 JMP RR4                \ A >= 128, so jump to RR4 to restore the registers and
                        \ return from the subroutine using a tail call

 LDX #(FONT%-1)         \ Set X to point to the page before the first font page,
                        \ which is FONT% - 1

 ASL A                  \ If bit 6 of the character is clear (A is 32-63)
 ASL A                  \ then skip the following instruction
 BCC P%+4

 LDX #(FONT%+1)         \ A is 64-126, so set X to point to page FONT% + 1

 ASL A                  \ If bit 5 of the character is clear (A is 64-95)
 BCC P%+3               \ then skip the following instruction

 INX                    \ Increment X
                        \
                        \ By this point, we started with X = FONT%-1, and then
                        \ we did the following:
                        \
                        \   If A = 32-63:   skip        then INX  so X = FONT%
                        \   If A = 64-95:   X = FONT%+1 then skip so X = FONT%+1
                        \   If A = 96-126:  X = FONT%+1 then INX  so X = FONT%+2
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

 STA Q                  \ R is the same location as Q+1, so this stores the
 STX R                  \ address of this character's definition in Q(1 0)

 LDA XC                 \ Fetch XC, the x-coordinate (column) of the text cursor
                        \ into A

 LDX CATF               \ If CATF = 0, jump to RR5, otherwise we are printing a
 BEQ RR5                \ disc catalogue

 CPY #' '               \ If the character we want to print in Y is a space,
 BNE RR5                \ jump to RR5

                        \ If we get here, then CATF is non-zero, so we are
                        \ printing a disc catalogue and we are not printing a
                        \ space, so we drop column 17 from the output so the
                        \ catalogue will fit on-screen (column 17 is a blank
                        \ column in the middle of the catalogue, between the
                        \ two lists of filenames, so it can be dropped without
                        \ affecting the layout). Without this, the catalogue
                        \ would be one character too wide for the square screen
                        \ mode (it's 34 characters wide, while the screen mode
                        \ is only 33 characters across)

 CMP #17                \ If A = 17, i.e. the text cursor is in column 17, jump
 BEQ RR4                \ to RR4 to restore the registers and return from the
                        \ subroutine, thus omitting this column

.RR5

 ASL A                  \ Multiply A by 8, and store in SC, so we now have:
 ASL A                  \
 ASL A                  \   SC = XC * 8
 STA SC

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

 ASL A                  \ A contains YC (from above), so this sets A = YC * 2

 ASL SC                 \ Double the low byte of SC(1 0), catching bit 7 in the
                        \ C flag. As each character is 8 pixels wide, and the
                        \ special screen mode Elite uses for the top part of the
                        \ screen is 256 pixels across with two bits per pixel,
                        \ this value is not only double the screen address
                        \ offset of the text cursor from the left side of the
                        \ screen, it's also the least significant byte of the
                        \ screen address where we want to print this character,
                        \ as each row of on-screen pixels corresponds to two
                        \ pages. To put this more explicitly, the screen starts
                        \ at &4000, so the text rows are stored in screen
                        \ memory like this:
                        \
                        \   Row 1: &4000 - &41FF    YC = 1, XC = 0 to 31
                        \   Row 2: &4200 - &43FF    YC = 2, XC = 0 to 31
                        \   Row 3: &4400 - &45FF    YC = 3, XC = 0 to 31
                        \
                        \ and so on

 ADC #&3F               \ Set X = A
 TAX                    \       = A + &3F + C
                        \       = YC * 2 + &3F + C

                        \ Because YC starts at 0 for the first text row, this
                        \ means that X will be &3F for row 0, &41 for row 1 and
                        \ so on. In other words, X is now set to the page number
                        \ for the row before the one containing the text cursor,
                        \ and given that we set SC above to point to the offset
                        \ in memory of the text cursor within the row's page,
                        \ this means that (X SC) now points to the character
                        \ above the text cursor

 LDY #&F0               \ Set Y = &F0, so the following call to ZES2 will count
                        \ Y upwards from &F0 to &FF

 JSR ZES2               \ Call ZES2, which zero-fills from address (X SC) + Y to
                        \ (X SC) + &FF. (X SC) points to the character above the
                        \ text cursor, and adding &FF to this would point to the
                        \ cursor, so adding &F0 points to the character before
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

 CMP #24                \ If the text cursor is on the screen (i.e. YC < 24, so
 BCC RR3                \ we are on rows 1-23), then jump to RR3 to print the
                        \ character

 PHA                    \ Store A on the stack so we can retrieve it below

 JSR TTX66              \ Otherwise we are off the bottom of the screen, so
                        \ clear the screen and draw a white border

 LDA #1                 \ Otherwise we are off the bottom of the screen, so move
 STA XC                 \ the text cursor to column 1, row 1
 STA YC

 PLA                    \ Retrieve A from the stack... only to overwrite it with
                        \ the next instruction, so presumably we didn't need to
                        \ preserve it and this and the PHA above have no effect

 LDA K3                 \ Set A to the character to be printed, though again
                        \ this has no effect, as the following call to RR4 does
                        \ the exact same thing

 JMP RR4                \ And restore the registers and return from the
                        \ subroutine

.RR3

                        \ A contains the value of YC - the screen row where we
                        \ want to print this character - so now we need to
                        \ convert this into a screen address, so we can poke
                        \ the character data to the right place in screen
                        \ memory

 ASL A                  \ Set A = 2 * A
                        \       = 2 * YC

 ASL SC                 \ Back in RR5 we set SC = XC * 8, so this does the
                        \ following:
                        \
                        \   SC = SC * 2
                        \      = XC * 16
                        \
                        \ so SC contains the low byte of the screen address we
                        \ want to poke the character into, as each text
                        \ character is 8 pixels wide, and there are four pixels
                        \ per byte, so the offset within the row's 512 bytes
                        \ is XC * 8 pixels * 2 bytes for each 8 pixels = XC * 16

 ADC #&40               \ Set A = &40 + A
                        \       = &40 + (2 * YC)
                        \
                        \ so A contains the high byte of the screen address we
                        \ want to poke the character into, as screen memory
                        \ starts at &4000 (page &40) and each screen row takes
                        \ up 2 pages (512 bytes)

.RREN

 STA SC+1               \ Store the page number of the destination screen
                        \ location in SC+1, so SC now points to the full screen
                        \ location where this character should go

 LDA SC                 \ Set (T S) = SC(1 0) + 8
 CLC                    \
 ADC #8                 \ starting with the low bytes
 STA S

 LDA SC+1               \ And then adding the high bytes, so (T S) points to the
 STA T                  \ character block after the one pointed to by SC(1 0),
                        \ and because T = S+1, we have:
                        \
                        \   S(1 0) = SC(1 0) + 8

 LDY #7                 \ We want to print the 8 bytes of character data to the
                        \ screen (one byte per row), so set up a counter in Y
                        \ to count these bytes

.RRL1

                        \ We print the character's 8-pixel row in two parts,
                        \ starting with the first four pixels (one byte of
                        \ screen memory), and then the second four (a second
                        \ byte of screen memory)

 LDA (Q),Y              \ The character definition is at Q(1 0) - we set this up
                        \ above - so load the Y-th byte from Q(1 0), which will
                        \ contain the bitmap for the Y-th row of the character

 AND #%11110000         \ Extract the top nibble of the character definition
                        \ byte, so the first four pixels on this row of the
                        \ character are in the first nibble, i.e. xxxx 0000
                        \ where xxxx is the pattern of those four pixels in the
                        \ character

 STA U                  \ Set A = (A >> 4) OR A
 LSR A                  \
 LSR A                  \ which duplicates the top nibble into the bottom nibble
 LSR A                  \ to give xxxx xxxx
 LSR A
 ORA U

 AND COL                \ AND with the colour byte so that the pixels take on
                        \ the colour we want to draw (i.e. A is acting as a mask
                        \ on the colour byte)

 EOR (SC),Y             \ If we EOR this value with the existing screen
                        \ contents, then it's reversible (so reprinting the
                        \ same character in the same place will revert the
                        \ screen to what it looked like before we printed
                        \ anything); this means that printing a white pixel on
                        \ onto a white background results in a black pixel, but
                        \ that's a small price to pay for easily erasable text

 STA (SC),Y             \ Store the Y-th byte at the screen address for this
                        \ character location

                        \ We now repeat the process for the second batch of four
                        \ pixels in this character row

 LDA (Q),Y              \ Fetch the the bitmap for the Y-th row of the character
                        \ again

 AND #%00001111         \ This time we extract the bottom nibble of the
                        \ character definition, to get 0000 xxxx

 STA U                  \ Set A = (A << 4) OR A
 ASL A                  \
 ASL A                  \ which duplicates the bottom nibble into the top nibble
 ASL A                  \ to give xxxx xxxx
 ASL A
 ORA U

 AND COL                \ AND with the colour byte so that the pixels take on
                        \ the colour we want to draw (i.e. A is acting as a mask
                        \ on the colour byte)

 EOR (S),Y              \ EOR this value with the existing screen contents of
                        \ S(1 0), which is equal to SC(1 0) + 8, the next four
                        \ pixels along from the first four pixels we just
                        \ plotted in SC(1 0)

 STA (S),Y              \ Store the Y-th byte at the screen address for this
                        \ character location

 DEY                    \ Decrement the loop counter

 BPL RRL1               \ Loop back for the next byte to print to the screen

.RR4

 PLA                    \ We're done printing, so restore the values of the
 TAX                    \ A, X and Y registers that we saved above, so
 PLA                    \ everything is back to how it was
 TAY
 LDA K3

.rT9

 RTS                    \ Return from the subroutine

.R5

 LDX #LO(BELI)          \ Set (Y X) to point to the parameter block below
 LDY #HI(BELI)

 JSR OSWORD             \ We call this from above with A = 7, so this calls
                        \ OSWORD 7 to make a short, high beep

 JMP RR4                \ Jump to RR4 to restore the registers and return from
                        \ the subroutine using a tail call

.BELI

 EQUW &0012             \ The SOUND block for a short, high beep:
 EQUW &FFF1             \
 EQUW &00C8             \   SOUND &12, -15, &C8, &02
 EQUW &0002             \
                        \ This makes a sound with flush control 1 on channel 2,
                        \ and with amplitude &F1 (-15), pitch &C8 (200) and
                        \ duration &02 (2). This is a louder, higher and longer
                        \ beep than that generated by the NOISE routine with
                        \ A = 32 (a short, high beep)

\ ******************************************************************************
\
\       Name: TTX66
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Clear the top part of the screen and draw a white border
\
\ ------------------------------------------------------------------------------
\
\ Clear the top part of the screen (the space view) and draw a white border
\ along the top and sides.
\
\ ******************************************************************************

.TTX66

 LDX #&40               \ Set X to point to page &40, which is the start of the
                        \ screen memory at &4000

.BOL1

 JSR ZES1               \ Call ZES1 below to zero-fill the page in X, which will
                        \ clear half a character row

 INX                    \ Increment X to point to the next page in screen
                        \ memory

 CPX #&70               \ Loop back to keep clearing character rows until we
 BNE BOL1               \ have cleared up to &7000, which is where the dashoard
                        \ starts

.BOX

 LDA #%00001111         \ Set COL = %00001111 to act as a four-pixel yellow
 STA COL                \ character byte (i.e. set the line colour to yellow)

 LDY #1                 \ Move the text cursor to row 1
 STY YC

 LDY #11                \ Move the text cursor to column 11
 STY XC

 LDX #0                 \ Set X1 = Y1 = Y2 = 0
 STX X1
 STX Y1
 STX Y2

\STX QQ17               \ This instruction is commented out in the original
                        \ source

 DEX                    \ Set X2 = 255
 STX X2

 JSR LOIN               \ Draw a line from (X1, Y1) to (X2, Y2), so that's from
                        \ (0, 0) to (255, 0), along the very top of the screen

 LDA #2                 \ Set X1 = X2 = 2
 STA X1
 STA X2

 JSR BOS2               \ Call BOS2 below, which will call BOS1 twice, and then
                        \ fall through into BOS2 again, so we effectively do
                        \ BOS1 four times, decrementing X1 and X2 each time
                        \ before calling LOIN, so this whole loop-within-a-loop
                        \ mind-bender ends up drawing these four lines:
                        \
                        \   (1, 0)   to (1, 191)
                        \   (0, 0)   to (0, 191)
                        \   (255, 0) to (255, 191)
                        \   (254, 0) to (254, 191)
                        \
                        \ So that's a 2-pixel wide vertical border along the
                        \ left edge of the upper part of the screen, and a
                        \ 2-pixel wide vertical border along the right edge

.BOS2

 JSR BOS1               \ Call BOS1 below and then fall through into it, which
                        \ ends up running BOS1 twice. This is all part of the
                        \ loop-the-loop border-drawing mind-bender explained
                        \ above

.BOS1

 LDA #0                 \ Set Y1 = 0
 STA Y1

 LDA #2*Y-1             \ Set Y2 = 2 * #Y - 1. The constant #Y is 96, the
 STA Y2                 \ y-coordinate of the mid-point of the space view, so
                        \ this sets Y2 to 191, the y-coordinate of the bottom
                        \ pixel row of the space view

 DEC X1                 \ Decrement X1 and X2
 DEC X2

 JSR LOIN               \ Draw a line from (X1, Y1) to (X2, Y2)

 LDA #%00001111         \ Set locations &4000 &41F8 to %00001111, as otherwise
 STA &4000              \ the top-left and top-right corners will be black (as
 STA &41F8              \ the lines overlap at the corners, and the EOR logic
                        \ used by LOIN will otherwise make them black)

 RTS                    \ Return from the subroutine

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
\
\       Name: SETXC
\       Type: Subroutine
\   Category: Text
\    Summary: Implement the #SETXC <column> command (move the text cursor to a
\             specific column)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #SETXC <column> command. It
\ updates the text cursor x-coordinate (i.e. the text column) in XC.
\
\ Arguments:
\
\   A                   The text column
\
\ ******************************************************************************

.SETXC

 STA XC                 \ Store the new text column in XC

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: SETYC
\       Type: Subroutine
\   Category: Text
\    Summary: Implement the #SETYC <row> command (move the text cursor to a
\             specific row)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #SETYC <row> command. It updates
\ the text cursor y-coordinate (i.e. the text row) in YC.
\
\ Arguments:
\
\   A                   The text row
\
\ ******************************************************************************

.SETYC

 STA YC                 \ Store the new text row in YC

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: SOMEPROT
\       Type: Subroutine
\   Category: Copy protection
\    Summary: Implement the OSWORD 249 command (some copy protection)
\
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
\
\       Name: CLYNS
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Implement the #clyns command (clear the bottom of the screen)
\
\ ******************************************************************************

.CLYNS

 LDA #20                \ Move the text cursor in YC to row 20
 STA YC

 LDA #&6A               \ Set SC+1 = &6A, for the high byte of SC(1 0)
 STA SC+1

 JSR TT67               \ Print a newline

 LDA #0                 \ Set SC = 0, so now SC(1 0) = &6A00
 STA SC

 LDX #3                 \ We want to clear three text rows, so set a counter in
                        \ X for 3 rows

.CLYL

 LDY #8                 \ We want to clear each text row, starting from the
                        \ left, but we don't want to overwrite the border, so we
                        \ start from the second character block, which is byte
                        \ #8 from the edge, so set Y to 8 to act as the byte
                        \ counter within the row

.EE2

 STA (SC),Y             \ Zero the Y-th byte from SC(1 0), which clears it by
                        \ setting it to colour 0, black

 INY                    \ Increment the byte counter in Y

 BNE EE2                \ Loop back to EE2 to blank the next byte along, until
                        \ we have done one page's worth (from byte #8 to #255)

 INC SC+1               \ We have just finished the first page - which covers
                        \ the left half of the text row - so we increment SC+1
                        \ so SC(1 0) points to the start of the next page, or
                        \ the start of the right half of the row

 STA (SC),Y             \ Clear the byte at SC(1 0), as that won't be caught by
                        \ the next loop

 LDY #247               \ The second page covers the right half of the text row,
                        \ and as before we don't want to overwrite the border,
                        \ which we can do by starting from the last-but-one
                        \ character block and working our way left towards the
                        \ centre of the row. The last-but-one character block
                        \ ends at byte 247 (that's 255 - 8, as each character
                        \ is 8 bytes), so we put this in Y to act as a byte
                        \ counter, as before

.EE3

 STA (SC),Y             \ Zero the Y-th byte from SC(1 0), which clears it by
                        \ setting it to colour 0, black

 DEY                    \ Decrement the byte counter in Y

 BNE EE3                \ Loop back to EE2 to blank the next byte to the left,
                        \ until we have done one page's worth (from byte #247 to
                        \ #1)

 INC SC+1               \ We have now blanked a whole text row, so increment
                        \ SC+1 so that SC(1 0) points to the next row

 DEX                    \ Decrement the row counter in X

 BNE CLYL               \ Loop back to blank another row, until we have done the
                        \ number of rows in X

\INX                    \ These instructions are commented out in the original
\STX SC                 \ source

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

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

 LDA #%00000001         \ Set 6522 System VIA interrupt enable register IER
 STA VIA+&4E            \ (SHEILA &4E) bit 1 (i.e. disable the CA2 interrupt,
                        \ which comes from the keyboard)

 LDA #&A0               \ Set SC(1 0) = &71A0, which is the screen address for
 STA SC                 \ the character block containing the left end of the
 LDA #&71               \ top indicator in the right part of the dashboard, the
 STA SC+1               \ one showing our speed

 JSR PZW2               \ Call PZW2 to set A to the colour for dangerous values
                        \ and X to the colour for safe values, suitable for
                        \ non-striped indicators

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

 LDA #YELLOW2           \ Set K (the colour we should show for high values) to
 STA K                  \ yellow

 STA K+1                \ Set K+1 (the colour we should show for low values) to
                        \ yellow, so the fuel indicator always shows in this
                        \ colour

 LDA QQ14               \ Draw the fuel level indicator using a range of 0-63,
 JSR DILX+2             \ and increment SC to point to the next indicator (the
                        \ cabin temperature)

 JSR PZW2               \ Call PZW2 to set A to the colour for dangerous values
                        \ and X to the colour for safe values, suitable for
                        \ non-striped indicators

 STX K+1                \ Set K+1 (the colour we should show for low values) to
                        \ X (the colour to use for safe values)

 STA K                  \ Set K (the colour we should show for high values) to
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

 LDA #YELLOW2           \ Set K (the colour we should show for high values) to
 STA K                  \ yellow

 STA K+1                \ Set K+1 (the colour we should show for low values) to
                        \ yellow, so the altitude indicator always shows in this
                        \ colour

 LDA ALTIT              \ Draw the altitude indicator using a range of 0-255,
 JMP DILX               \ returning from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: PZW2
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Fetch the current dashboard colours for non-striped indicators, to
\             support flashing
\
\ ******************************************************************************

.PZW2

 LDX #WHITE2            \ Set X to white, so we can return that as the safe
                        \ colour in PZW below

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &A9 &23, or BIT &23A9, which does nothing apart
                        \ from affect the flags

                        \ Fall through into PZW to fetch the current dashboard
                        \ colours, returning white for safe colours rather than
                        \ stripes

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

 LDX #STRIPE            \ Set X to the dashboard stripe colour, which is stripe
                        \ 5-1 (magenta/red)

 LDA MCNT               \ A will be non-zero for 8 out of every 16 main loop
 AND #%00001000         \ counts, when bit 4 is set, so this is what we use to
                        \ flash the "danger" colour

 AND FLH                \ A will be zeroed if flashing colours are disabled

 BEQ P%+5               \ If A is zero, skip the next two instructions

 LDA #GREEN2            \ Otherwise flashing colours are enabled and it's the
 RTS                    \ main loop iteration where we flash them, so set A to
                        \ dashboard colour 2 (green) and return from the
                        \ subroutine

 LDA #RED2              \ Set A to dashboard colour 1 (red)

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

 LDX #7                 \ Set up a counter in X for the width of the indicator,
                        \ which is 8 characters (each of which is 2 pixels wide,
                        \ to give a total width of 16 pixels)

.DL1

 LDA Q                  \ Fetch the indicator value (0-15) from Q into A

 CMP #2                 \ If Q < 2, then we need to draw the end cap of the
 BCC DL2                \ indicator, which is less than a full character's
                        \ width, so jump down to DL2 to do this

 SBC #2                 \ Otherwise we can draw a 2-pixel wide block, so
 STA Q                  \ subtract 2 from Q so it contains the amount of the
                        \ indicator that's left to draw after this character

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

 EOR #1                 \ If we get here then we are drawing the indicator's
 STA Q                  \ end cap, so Q is < 2, and this EOR flips the bits, so
                        \ instead of containing the number of indicator columns
                        \ we need to fill in on the left side of the cap's
                        \ character block, Q now contains the number of blank
                        \ columns there should be on the right side of the cap's
                        \ character block

 LDA R                  \ Fetch the current mask from R, which will be &FF at
                        \ this point, so we need to turn Q of the columns on the
                        \ right side of the mask to black to get the correct end
                        \ cap shape for the indicator

.DL3

 ASL A                  \ Shift the mask left and clear bits 0, 2, 4 and 8,
 AND #%10101010         \ which has the effect of shifting zeroes from the left
                        \ into each two-bit segment (i.e. xx xx xx xx becomes
                        \ x0 x0 x0 x0, which blanks out the last column in the
                        \ 2-pixel mode 2 character block)

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
 INC SC+1               \ character row on-screen (as each row takes up exactly
                        \ two pages of 256 bytes) - so this sets up SC to point
                        \ to the next indicator, i.e. the one below the one we
                        \ just drew

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
\   C flag              The C flag is set
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
                        \ block (as each character block contains 8 rows)

.DLL10

 SEC                    \ Set A = Q - 2, so that A contains the offset of the
 LDA Q                  \ vertical bar from the start of this character block
 SBC #2

 BCS DLL11              \ If Q >= 2 then the character block we are drawing does
                        \ not contain the vertical indicator bar, so jump to
                        \ DLL11 to draw a blank character block

 LDA #&FF               \ Set A to a high number (and &FF is as high as they go)

 LDX Q                  \ Set X to the offset of the vertical bar, which we know
                        \ is within this character block

 STA Q                  \ Set Q to a high number (&FF, why not) so we will keep
                        \ drawing blank characters after this one until we reach
                        \ the end of the indicator row

 LDA CTWOS,X            \ CTWOS is a table of ready-made 1-pixel mode 5 bytes,
                        \ just like the TWOS and TWOS2 tables for mode 4 (see
                        \ the PIXEL routine for details of how they work). This
                        \ fetches a mode 5 1-pixel byte with the pixel position
                        \ at X, so the pixel is at the offset that we want for
                        \ our vertical bar

 AND #WHITE2            \ The 2-pixel mode 2 byte in #WHITE2 represents two
                        \ pixels of colour %0111 (7), which is white in both
                        \ dashboard palettes. We AND this with A so that we only
                        \ keep the pixel that matches the position of the
                        \ vertical bar (i.e. A is acting as a mask on the
                        \ 2-pixel colour byte)

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
 INC SC+1               \ character row on-screen (as each row takes up exactly
                        \ two pages of 256 bytes) - so this sets up SC to point
                        \ to the next indicator, i.e. the one below the one we
                        \ just drew

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TVT1
\       Type: Variable
\   Category: Screen mode
\    Summary: Palette data for the mode 2 part of the screen (the dashboard)
\
\ ------------------------------------------------------------------------------
\
\ This palette is applied in the IRQ1 routine. If we have an eacape pod fitted,
\ then the first byte is changed to &30, which maps logical colour 3 to actual
\ colour 0 (black) instead of colour 4 (blue).
\
\ ******************************************************************************

.TVT1

 EQUB &34, &43
 EQUB &25, &16
 EQUB &86, &70
 EQUB &61, &52
 EQUB &C3, &B4
 EQUB &A5, &96
 EQUB &07, &F0
 EQUB &E1, &D2

\ ******************************************************************************
\
\       Name: do65C02
\       Type: Subroutine
\   Category: Copy protection
\    Summary: 
\
\ ******************************************************************************

.do65C02

.whiz

 LDA (0)
 PHA
 LDA (2)
 STA (0)
 PLA
 STA (2)
\NOP
\NOP
\NOP
\NOP
 INC 0
 BNE P%+4
 INC 1
 LDA 2
 BNE P%+4
 DEC 3
 DEC 2                  \ SC = 2
 DEA
 CMP 0
 LDA 3
 SBC 1
 BCS whiz
 JMP (0,X)
.end65C02

protlen = end65C02 - do65C02

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

 LDY #15                \ Set Y as a counter for 16 bytes, to use when setting
                        \ the dashboard palette below

 LDA #%00000010         \ Read the 6522 System VIA status byte bit 1 (SHEILA
 BIT VIA+&4D            \ &4D), which is set if vertical sync has occurred on
                        \ the video system

 BNE LINSCN             \ If we are on the vertical sync pulse, jump to LINSCN
                        \ to set up the timers to enable us to switch the
                        \ screen mode between the space view and dashboard

 BVC jvec               \ Read the 6522 System VIA status byte bit 6, which is
                        \ set if timer 1 has timed out. We set the timer in
                        \ LINSCN above, so this means we only run the next bit
                        \ if the screen redraw has reached the boundary between
                        \ the space view and the dashboard. Otherwise bit 6 is
                        \ clear and we aren't at the boundary, so we jump to
                        \ jvec to pass control to the next interrupt handler

 LDA #%00010100         \ Set the Video ULA control register (SHEILA &20) to
 STA VIA+&20            \ %00010100, which is the same as switching to mode 2,
                        \ (i.e. the bottom part of the screen) but with no
                        \ cursor

 LDA ESCP               \ Set A = ESCP, which is &FF if we have an escape pod
                        \ fitted, or 0 if we don't

 AND #4                 \ Set A = 4 if we have an escape pod fitted, or 0 if we
                        \ don't

 EOR #&34               \ Set A = &30 if we have an escape pod fitted, or &34 if
                        \ we don't

 STA &FE21              \ Store A in SHEILA &21 to map colour 3 (#YELLOW2) to
                        \ white if we have an escape pod fitted, or yellow if we
                        \ don't, so the outline colour of the dashboard changes
                        \ from yellow to white if we have an escape pod fitted

                        \ The following loop copies bytes #15 to #1 from TVT1 to
                        \ SHEILA &21, but not byte #0, as we just did that
                        \ colour mapping

.VNT2

 LDA TVT1,Y             \ Copy the Y-th palette byte from TVT1 to SHEILA &21
 STA &FE21              \ to map logical to actual colours for the bottom part
                        \ of the screen (i.e. the dashboard)

 DEY                    \ Decrement the palette byte counter

 BNE VNT2               \ Loop back to VNT2 until we have copied all the palette
                        \ bytes bar the first one

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

 STA VIA+&44            \ Set 6522 System VIA T1C-L timer 1 low-order counter
                        \ (SHEILA &44) to 30

 LDA #VSCAN             \ Set 6522 System VIA T1C-L timer 1 high-order counter
 STA VIA+&45            \ (SHEILA &45) to VSCAN (57) to start the T1 counter
                        \ counting down from 14622 at a rate of 1 MHz

 LDA HFX                \ If the hyperspace effect flag in HFX is non-zero, then
 BNE jvec               \ jump up to jvec to pass control to the next interrupt
                        \ handler, instead of switching the palette to mode 1.
                        \ This will have the effect of blurring and colouring
                        \ the top screen in a mode 2 palette, making the
                        \ hyperspace rings turn multicoloured when we do a
                        \ hyperspace jump. This effect is triggered by the
                        \ parasite issuing a #DOHFX 1 command in routine LL164
                        \ and is disabled again by a #DOHFX 0 command

 LDA #%00011000         \ Set the Video ULA control register (SHEILA &20) to
 STA VIA+&20            \ %00011000, which is the same as switching to mode 1
                        \ (i.e. the top part of the screen) but with no cursor

.VNT3

                        \ The following instruction gets modified in-place by
                        \ the #SETVDU19 <offset> command, which changes the
                        \ value of TVT3+1 (i.e. the low byte of the address in
                        \ the LDA instruction). This changes the palette block
                        \ that gets copied to SHEILA &21, so a #SETVDU19 32
                        \ command applies the third palette from TVT3 in this
                        \ loop, for example

 LDA TVT3,Y             \ Copy the Y-th palette byte from TVT3 to SHEILA &21
 STA VIA+&21            \ to map logical to actual colours for the bottom part
                        \ of the screen (i.e. the dashboard)

 DEY                    \ Decrement the palette byte counter

 BNE VNT3               \ Loop back to VNT3 until we have copied all the
                        \ palette bytes

 PLA                    \ Otherwise restore Y from the stack
 TAY

 LDA VIA+&41            \ Read 6522 System VIA input register IRA (SHEILA &41)

 LDA &FC                \ Set A to the interrupt accumulator save register,
                        \ which restores A to the value it had on entering the
                        \ interrupt

 RTI                    \ Return from interrupts, so this interrupt is not
                        \ passed on to the next interrupt handler, but instead
                        \ the interrupt terminates here

\ ******************************************************************************
\
\       Name: SETVDU19
\       Type: Subroutine
\   Category: Screen mode
\    Summary: Implement the #SETVDU19 <offset> command (change mode 1 palette)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #SETVDU19 <offset> command. It
\ updates the VNT+3 location in the IRQ1 handler to change the palette that's
\ applied to the top part of the screen (the four-colour mode 1 part). The
\ parameter is the offset within the TVT3 palette block of the desired palette.
\
\ Arguments:
\
\   A                   The offset within the TVT3 table of palettes:
\
\                         * 0 = Yellow, red, cyan palette (space view)
\
\                         * 16 = Yellow, red, white palette (charts)
\
\                         * 32 = Yellow, white, cyan palette (title screen)
\
\                         * 48 = Yellow, magenta, white palette (trading)
\
\ ******************************************************************************

.SETVDU19

 STA VNT3+1             \ Store the new colour in VNT3+1, in the IRQ1 routine,
                        \ which modifies which TVT3 palette block gets applied
                        \ to the mode 1 part of the screen

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

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
