# Source code for Elite on the BBC Micro with a 6502 Second Processor

This repository contains the original source code for Elite on the BBC Micro with a 6502 Second Processor (also known as "6502SP Elite" or "Tube Elite").

It is a companion to the repository containing the [tape version of Elite](https://github.com/markmoxon/elite-beebasm) and its [accompanying website](https://www.bbcelite.com).

## Contents

* [Acknowledgements](#acknowledgements)

* [Building 6502 Second Processor Elite from the source](#building-6502-second-processor-elite-from-the-source)

* [Notes on the original source files](#notes-on-the-original-source-files)

* [Next steps](#next-steps)

## Acknowledgements

6502 Second Processor Elite was written by Ian Bell and David Braben and is copyright &copy; Acornsoft 1985.

The code on this site is identical to the version released on [Ian Bell's personal website](http://www.elitehomepage.org/) (it's just been reformatted to be more readable).

The commentary is copyright &copy; Mark Moxon. Any misunderstandings or mistakes in the documentation are entirely my fault.

The following archive from Ian Bell's site forms the basis for this project:

* [6502 Second Processor sources as a disc image](http://www.elitehomepage.org/archive/a/a5022201.zip)

### A note on licences, copyright etc.

This repository is _not_ provided with a licence, and there is intentionally no `LICENSE` file provided.

According to [GitHub's licensing documentation](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/licensing-a-repository), this means that "the default copyright laws apply, meaning that you retain all rights to your source code and no one may reproduce, distribute, or create derivative works from your work".

The reason for this is that my commentary is intertwined with the original Elite source code, and the original source code is copyright. The whole site is therefore covered by default copyright law, to ensure that this copyright is respected.

Under GitHub's rules, you have the right to read and fork this repository... but that's it. No other use is permitted, I'm afraid.

My hope is that the educational and non-profit intentions of this repository will enable it to stay hosted and available, but the original copyright holders do have the right to ask for it to be taken down, in which case I will comply without hesitation. I do hope, though, that along with the various other disassemblies and commentaries of this source, it will remain viable.

## Building 6502 Second Processor Elite from the source

### Requirements

You will need the following to build 6502 Second Processor Elite from the source:

* BeebAsm, which can be downloaded from the [BeebAsm repository](https://github.com/stardot/beebasm). Mac and Linux users will have to build their own executable with `make code`, while Windows users can just download the `beebasm.exe` file.
* Python. Both versions 2.7 and 3.x should work.
* Mac and Linux users may need to install `make` if it isn't already present (for Windows users, `make.exe` is included in this repository).

Let's look at how to build 6502 Second Processor Elite from the source.

### Build targets

There are two main build targets available. They are:

* `build` - An unencrypted version
* `encrypt` - An encrypted version that exactly matches the released version of the game

The unencrypted version should be more useful for anyone who wants to make modifications to the game code. It includes a default commander with lots of cash and equipment, which makes it easier to test the game. As this target produces unencrypted files, the binaries produced will be quite different to the binaries on the original source disc, which are encrypted.

The encrypted version produces the released version of Elite, along with the standard default commander.

Builds are supported for both Windows and Mac/Linux systems. In all cases the build process is defined in the `Makefile` provided.

Note that the build ends with a warning that there is no `SAVE` command in the source file. You can ignore this, as the source file contains a `PUTFILE` command instead, but BeebAsm still reports this as a warning.

### Windows

For Windows users, there is a batch file called `make.bat` to which you can pass one of the build targets above. Before this will work, you should edit the batch file and change the values of the `BEEBASM` and `PYTHON` variables to point to the locations of your `beebasm.exe` and `python.exe` executables. You also need to change directory to the repository folder (i.e. the same folder as `make.exe`).

All being well, doing one of the following:

```
make.bat build
```

```
make.bat encrypt
```

will produce a file called `elite-6502sp.ssd`, which you can then load into an emulator, or into a real BBC Micro using a device like a Gotek.

### Mac and Linux

The build process uses a standard GNU `Makefile`, so you just need to install `make` if your system doesn't already have it. If BeebAsm or Python are not on your path, then you can either fix this, or you can edit the `Makefile` and change the `BEEBASM` and `PYTHON` variables in the first two lines to point to their locations. You also need to change directory to the repository folder (i.e. the same folder as `Makefile`).

All being well, doing one of the following:

```
make build
```

```
make encrypt
```

will produce a file called `elite-6502sp.ssd`, which you can then load into an emulator, or into a real BBC Micro using a device like a Gotek.

### Verifying the output

The build process also supports a verification target that prints out checksums of all the generated files, along with the checksums of the files extracted from the original sources.

You can run this verification step on its own, or you can run it once a build has finished. To run it on its own, use the following command on Windows:

```
make.bat verify
```

or on Mac/Linux:

```
make verify
```

To run a build and then verify the results, you can add two targets, like this on Windows:

```
make.bat encrypt verify
```

or this on Mac/Linux:

```
make encrypt verify
```

The Python script `crc32.py` does the actual verification, and shows the checksums and file sizes of both sets of files, alongside each other, and with a Match column that flags any discrepancies. If you are building an unencrypted set of files then there will be lots of differences, while the encrypted files should match.

The binaries in the `extracted` folder were taken straight from the [6502 Second Processor sources disc image](http://www.elitehomepage.org/archive/a/a5022201.zip), while those in the `output` folder are produced by the build process. For example, if you don't make any changes to the code and build the project with `make encrypt verify`, then this is the output of the verification process:

```
[--extracted--]  [---output----]
Checksum   Size  Checksum   Size  Match  Filename
-----------------------------------------------------------
11ccbb59  38832  11ccbb59  38832   Yes   CODE.unprot.bin
56520930    752  56520930    752   Yes   ELITE.bin
e78cb0cf   5769  e78cb0cf   5769   Yes   ELITEa.bin
455ba962   2666  455ba962   2666   Yes   ELTA.bin
ff84a532   3096  ff84a532   3096   Yes   ELTB.bin
54e6f0e3   3284  54e6f0e3   3284   Yes   ELTC.bin
cb34d904   3336  cb34d904   3336   Yes   ELTD.bin
9c847981   2708  9c847981   2708   Yes   ELTE.bin
dbb22442   3954  dbb22442   3954   Yes   ELTF.bin
22b0e99e   3591  22b0e99e   3591   Yes   ELTG.bin
a949f485   1427  a949f485   1427   Yes   ELTH.bin
6379fa24   1411  6379fa24   1411   Yes   ELTI.bin
62e09fa4   3619  62e09fa4   3619   Yes   ELTJ.bin
a1342e53   6454  a1342e53   6454   Yes   I.CODE.bin
5908b6d5  38832  5908b6d5  38832   Yes   P.CODE.bin
2580d019   8460  -             -    -    SHIPS.bin
57406380   1024  -             -    -    WORDS.bin
```

All the compiled binaries match the extracts, so we know we are producing the same final game as the release version.

### Log files

During compilation, details of every step are output in a file called `compile.txt` in the `output` folder. If you have problems, it might come in handy, and it's a great reference if you need to know the addresses of labels and variables for debugging (or just snooping around).

## Notes on the original source files

The source files on the source disc do not build as they are; some massaging is required, as described in [this thread on Stardot](https://stardot.org.uk/forums/viewtopic.php?t=14607). Note also that the `P.DIALS2P` file on the source disc has some erroneous dots in the right-hand side of the dashboard; a fixed version is available in the `images` folder in this repository, and this fixed version was used to build the reference binaries in the `extracted` folder.

The `extracted/workspaces` folder contains binary files that match the workspaces in the original game binaries (a workspace being a block of memory, such as `LBUF` or `LSX2`). Instead of initialising workspaces with null values like BeebAsm, the original BBC Micro source code creates its workspaces by simply incrementing the `P%` and `O%` program counters, which means that the workspaces end up containing whatever contents the allocated memory had at the time. As the source files are broken into multiple BBC BASIC programs that run each other sequentially, this means the workspaces in the source code tend to contain either fragments of these BBC BASIC source programs, or assembled code from an earlier stage. This doesn't make any difference to the game code, which either intialises the workspaces at runtime or just ignores their initial contents, but if we want to be able to produce byte-accurate binaries from the modern BeebAsm assembly process, we need to include this "workspace noise" when building the project, and that's what the binaries in the `extracted/workspaces` folder are for. These binaries are only loaded by the `encrypt` target; for the `build` target, workspaces are initialised with zeroes.

Here's an example of how these binaries are included, in this case for the `LBUF` workspace in the `ELTB` section:

```
.LBUF

IF _MATCH_EXTRACTED_BINARIES
 INCBIN "extracted/workspaces/ELTB-LBUF.bin"
ELSE
 SKIP &100
ENDIF
```

Note that the log tables in both the `ELTG` and `I.CODE` sections of the source are also included in the `workspaces` folder. This is because BBC BASIC calculates slightly different values for these tables compared to those calculated by BeebAsm. The `encrypt` target therefore loads the original BBC Micro versions of these log tables using the same approach as above, to ensure the output matches the originals, while the `build` target sticks with BeebAsm's built-in `LOG()` function and generates the tables as part of the build process.

## Next steps

I'm planning to document the 6502 Second Processor version of Elite in the same way that I [documented the tape version](https://www.bbcelite.com), though this is a long-term plan.

---

Right on, Commanders!

_Mark Moxon_