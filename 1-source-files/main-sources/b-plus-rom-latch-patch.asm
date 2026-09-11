\ ******************************************************************************
\
\ BBC MICRO B+ ROM LATCH PATCH
\
\ Written by Mark Moxon
\
\ ------------------------------------------------------------------------------
\
\ Install the patch with *RUN FIXSRAM
\
\ This will fix OSWORD 6 on the BBC Micro B+ with 6502 Second Processor so that
\ using OSWORD 6 to write to the ROM latches at &00F4 and &FE30 will work
\
\ Uninstall the patch by using OSWORD 6 to write an arbitrary value to address
\ &FFFF (if you overwrite the handler code at NWOSWD without first uninstalling
\ the patch, then OSWORD will break)
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

 CODE% = &3000          \ The assembly address of the patch code

 LOAD% = &3000          \ The load address of the patch code

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

 ORG &0080              \ Set the assembly address to &0080

.addrIO

 SKIP 2                 \ The address being written in the OSWORD 6 call

 ORG &00EF              \ Set the assembly address to &00EF

.OSA

 SKIP 1                 \ The MOS location for storing the number of the OSWORD
                        \ call in A

.OSSC

 SKIP 2                 \ The MOS location for storing the address of the OSWORD
                        \ block in (Y X)

\ ******************************************************************************
\
\       Name: ENTRY
\       Type: Subroutine
\   Category: Tube
\    Summary: Set up a custom OSWORD handler to patch OSWORD 6
\
\ ******************************************************************************

 ORG CODE%              \ Set the assembly address to CODE%

.ENTRY

 LDA WORDV              \ Store the current WORDV vector in the operand of the
 STA osJMP+1            \ JMP instruction at osJMP
 LDA WORDV+1
 STA osJMP+2

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

 PHP                    \ Store the processor flags on the stack so we can
                        \ preserve them across the call

 SEI                    \ Disable interrupts

 CMP #6                 \ If this is not an OSWORD 6 command, jump to notOurs to
 BNE notOurs            \ pass the call to the standard handler

 STA OSA                \ Set OSA to the OSWORD number and OSCC to the address
 STX OSSC               \ of the OSWORD block, so it is set up in the same way
 STY OSSC+1             \ as when the MOS processes OSWORD calls

 LDY #0                 \ Set X = low byte of address to write
 LDA (OSSC),Y
 TAX

 INY                    \ Set A = high byte of address to write
 LDA (OSSC),Y
 
 CMP #&00               \ If address is &00F4, jump to nwos4 to perform a write
 BNE nwos1              \ without using the standard OSWORD handlers
 CPX #&F4
 BEQ nwos4

.nwos1

 CMP #&FE               \ If address is &FE30, jump to nwos4 to perform a write
 BNE nwos2              \ without using the standard OSWORD handlers
 CPX #&30
 BEQ nwos4

.nwos2

 CMP #&FF               \ If address is not &FFFF, jump to nwos3 to disable our
 BNE nwos3              \ custom OSWORD handler
 CPX #&FF
 BNE nwos3

                        \ If we get here then we have called OSWORD 6 with an
                        \ an address of &FFFF, which means we have finished with
                        \ the ROM loading code and need to reverse the patch

 LDA osJMP+1            \ Set WORDV to the address in the JMP instruction at
 STA WORDV              \ osJMP, so calls to OSWORD are now handled by the
 LDA osJMP+2            \ original handler once again
 STA WORDV+1

 LDA OSA                \ Set A to the original call value so it is preserved

 PLP                    \ Restore the processor flags from the stack so they are
                        \ unchanged

 RTS                    \ Return from the subroutine

.nwos3

                        \ If we get here then we have not called OSWORD 6 with
                        \ a ROM latch address or &FFFF, so we pass it on to the
                        \ standard OSWORD handler

 LDA OSA                \ Set A, X and Y to their values from the original
 LDX OSSC               \ OSWORD call
 LDY OSSC+1

 JMP notOurs            \ Jump to notOurs to pass the call to the standard
                        \ OSWORD handler

.nwos4

                        \ If we get here then we have called OSWORD 6 with a ROM
                        \ latch address of &00F4 or &FE40, so we write to the
                        \ address without calling the standard OSWORD handler
                        \ (as the latter would undo our write)

 STX addrIO             \ Set addrIO(1 0) to the address to write (i.e. the ROM
 STA addrIO+1           \ latch)

 LDY #4                 \ Set A to the value to write, from byte #4 of the
 LDA (OSSC),Y           \ OSWORD block

 LDY #0                 \ Write the value into the ROM latch
 STA (addrIO),Y

 LDA OSA                \ Set A to the original call value so it is preserved

 PLP                    \ Restore the processor flags from the stack so they are
                        \ unchanged

 RTS                    \ Return from the subroutine

.notOurs

 PLP                    \ Restore the processor flags from the stack so they are
                        \ unchanged

.osJMP

 JMP &FFFC              \ This address is overwritten by the ENTRY routine to
                        \ contain the original value of WORDV, so this call acts
                        \ just like a standard JMP OSWORD call and is used to
                        \ process OSWORD calls that aren't our custom call

\ ******************************************************************************
\
\ Save FIXSRAM.bin
\
\ ******************************************************************************

 PRINT "S.FIXSRAM ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/FIXSRAM.bin", CODE%, P%, LOAD%
