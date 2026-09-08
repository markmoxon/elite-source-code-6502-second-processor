\ ******************************************************************************
\
\ BBC MICRO B+ ROM LATCH PATCH
\
\ Written by Mark Moxon
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * FIXSRAM.bin
\
\ ******************************************************************************

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 CODE% = &3000          \ The assembly address of the main I/O processor code

 LOAD% = &3000          \ The load address of the main I/O processor code

 WORDV = &020C          \ The WORDV vector that we intercept to implement our
                        \ own custom OSWORD handler

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

.OSSC

 SKIP 2                 \ The address of the OSWORD block

.addrIO

 SKIP 2                 \ The address being written in the OSWORD 6 call

\ ******************************************************************************
\
\       Name: ENTRY
\       Type: Subroutine
\   Category: Tube
\    Summary: Set up a custom OSWORD handler to patch OSWORD 6
\
\ ******************************************************************************

ORG CODE%

.ENTRY

 LDA WORDV              \ Store the current WORDV vector in notours(2 1)
 STA notours+1
 LDA WORDV+1
 STA notours+2

 LDA #LO(NWOSWD)        \ Disable interrupts and set WORDV to NWOSWD, so calls
 SEI                    \ to OSWORD are now handled by NWOSWD, which lets us
 STA WORDV              \ implement all our custom OSWORD commands
 LDA #HI(NWOSWD)
 STA WORDV+1

 CLI                    \ Enable interrupts again

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: NWOSWD
\       Type: Subroutine
\   Category: Tube
\    Summary: The custom OSWORD routine that patches writes to the ROM latch
\
\ ******************************************************************************

.NWOSWD

 CMP #6                 \ If this is not an OSWORD 6 command, jump to notours to
 BNE notours            \ pass the call to the standard handler

 STX OSSC               \ Set OSCC to the address of the OSWORD block
 STY OSSC+1

 LDY #0                 \ Set X = low byte of address to write
 LDA (OSSC),Y
 TAX

 INY                    \ Set A = high byte of address to write
 LDA (OSSC),Y
 
 CMP #&00               \ If address is &00F4, jump to romLatch
 BNE nwos1
 CPX #&F4
 BEQ romLatch

.nwos1

 CMP #&FE               \ If address is &FE30, jump to romLatch
 BNE nwos2
 CPX #&30
 BEQ romLatch

.nwos2

 CMP #&FF               \ If address is not &FFFF, jump to nwos3
 BNE nwos3
 CPX #&FF
 BNE nwos3

                        \ If we get here then we have called OSWORD 6 with an
                        \ an address of &FFFF, which means we have finished with
                        \ the ROM loading code and need to reverse the patch

 LDA notours+1          \ Disable interrupts and set WORDV to notours, so calls
 SEI                    \ to OSWORD are now handled by the original handler once
 STA WORDV              \ again
 LDA notours+2
 STA WORDV+1

 CLI                    \ Enable interrupts again

 RTS                    \ Return from the subroutine

.nwos3

                        \ If we get here then we have not called OSWORD 6 with
                        \ a ROM latch address or &FFFF, so we pass it on to the
                        \ standard OSWORD handler

 LDA #6                 \ Set A, X and Y to their values from the original
 LDX OSSC               \ OSWORD call
 LDY OSSC+1

 JMP notours            \ Pass the call to the standard handler

.romLatch

 STX addrIO             \ Set addrIO(1 0) to the address to write (i.e. the ROM
 STA addrIO+1           \ latch)

 LDY #4                 \ Set A to the value to write
 LDA (OSSC),Y

 LDY #0                 \ Write the value into the ROM latch
 STA (addrIO),Y

 RTS                    \ Return from the subroutine

.notours

 JMP &FFFC              \ This address is overwritten by the STARTUP routine to
                        \ contain the original value of WORDV, so this call acts
                        \ just like a standard JMP OSWORD call and is used to
                        \ process OSWORD calls that aren't our custom calls

\ ******************************************************************************
\
\ Save FIXSRAM.bin
\
\ ******************************************************************************

 PRINT "S.FIXSRAM ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/FIXSRAM.bin", CODE%, P%, LOAD%
