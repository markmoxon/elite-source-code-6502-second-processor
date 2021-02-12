# Fully documented source code for Elite on the BBC Micro with a 6502 Second Processor

[BBC Micro (cassette)](https://github.com/markmoxon/elite-beebasm) | [BBC Micro (disc)](https://github.com/markmoxon/disc-elite-beebasm) | **6502 Second Processor** | [BBC Master 128](https://github.com/markmoxon/master-elite-beebasm)

This repository contains the original source code for Elite on the BBC Micro with a 6502 Second Processor, with every single line documented and (for the most part) explained.

It is a companion to the [bbcelite.com website](https://www.bbcelite.com), which contains all the code from this repository, but laid out in a much more human-friendly fashion. The links above will take you to repositories for the other versions of Elite that are covered by this project.

* If you want to browse the source and read about how Elite works under the hood, you will probably find [the website](https://www.bbcelite.com) is a better place to start than this repository.

* If you would rather explore the source code in your favourite IDE, then the [annotated source](sources/elite-source.asm) is what you're looking for. It contains the exact same content as the website, so you won't be missing out (the website is generated from the source files, so they are guaranteed to be identical). You might also like to read the section on [Browsing the source in an IDE](#browsing-the-source-in-an-ide) for some tips.

* If you want to build Elite from the source on a modern computer, to produce a working game disc that can be loaded into a BBC Micro or an emulator, then you want the section on [Building 6502 Second Processor Elite from the source](#building-6502-second-processor-elite-from-the-source).

My hope is that this repository and the [accompanying website](https://www.bbcelite.com) will be useful for those who want to learn more about Elite and what makes it tick. It is provided on an educational and non-profit basis, with the aim of helping people appreciate one of the most iconic games of the 8-bit era.


## Contents

* [Acknowledgements](#acknowledgements)

  * [A note on licences, copyright etc.](#user-content-a-note-on-licences-copyright-etc)

* [Browsing the source in an IDE](#browsing-the-source-in-an-ide)

* [Building 6502 Second Processor Elite from the source](#building-6502-second-processor-elite-from-the-source)

  * [Requirements](#requirements)
  * [Build targets](#build-targets)
  * [Windows](#windows)
  * [Mac and Linux](#mac-and-linux)
  * [Verifying the output](#verifying-the-output)
  * [Log files](#log-files)

* [Building different release versions of Elite](#building-different-release-versions-of-elite)

* [Notes on the original source files](#notes-on-the-original-source-files)

  * [Fixing the original build process](#fixing-the-original-build-process)
  * [Producing byte-accurate binaries](#producing-byte-accurate-binaries)


## Acknowledgements

6502 Second Processor Elite was written by Ian Bell and David Braben and is copyright &copy; Acornsoft 1985.

The code on this site is identical to the version released on [Ian Bell's personal website](http://www.elitehomepage.org/) (it's just been reformatted to be more readable).

The commentary is copyright &copy; Mark Moxon. Any misunderstandings or mistakes in the documentation are entirely my fault.

Huge thanks are due to the original authors for not only creating such an important piece of my childhood, but also for releasing the source code for us to play with; to Paul Brink for his annotated disassembly; and to Kieran Connell for his [BeebAsm version](https://github.com/kieranhj/elite-beebasm), which I forked as the original basis for this project. You can find more information about this project in the [accompanying website's project page](https://www.bbcelite.com/about_site/about_this_project.html).

The following archive from Ian Bell's site forms the basis for this project:

* [6502 Second Processor sources as a disc image](http://www.elitehomepage.org/archive/a/a5022201.zip)

### A note on licences, copyright etc.

This repository is _not_ provided with a licence, and there is intentionally no `LICENSE` file provided.

According to [GitHub's licensing documentation](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/licensing-a-repository), this means that "the default copyright laws apply, meaning that you retain all rights to your source code and no one may reproduce, distribute, or create derivative works from your work".

The reason for this is that my commentary is intertwined with the original Elite source code, and the original source code is copyright. The whole site is therefore covered by default copyright law, to ensure that this copyright is respected.

Under GitHub's rules, you have the right to read and fork this repository... but that's it. No other use is permitted, I'm afraid.

My hope is that the educational and non-profit intentions of this repository will enable it to stay hosted and available, but the original copyright holders do have the right to ask for it to be taken down, in which case I will comply without hesitation. I do hope, though, that along with the various other disassemblies and commentaries of this source, it will remain viable.


## Browsing the source in an IDE

If you want to browse the source in an IDE, you might find the following useful.

* The most interesting files are in the [sources](sources) folder:

  * The main game's source code is in the [elite-source.asm](sources/elite-source.asm) file (for the parasite, i.e. the Second Processor) and [elite-z.asm](sources/elite-z.asm) (for the I/O processor, i.e. the BBC Micro) - this is the motherlode and probably contains all the stuff you're interested in.

  * The game's loader is in the [elite-loader1.asm](sources/elite-loader1.asm) and [elite-loader2.asm](sources/elite-loader2.asm) files - these are mainly concerned with setup and copy protection.

* It's probably worth skimming through the [notes on terminology and notations](https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html) on the accompanying website, as this explains a number of terms used in the commentary, without which it might be a bit tricky to follow at times (in particular, you should understand the terminology I use for multi-byte numbers).

* The accompamying website contains [a number of "deep dive" articles](https://www.bbcelite.com/deep_dives/), each of which goes into an aspect of the game in detail. Routines that are explained further in these articles are tagged with the label `Deep dive:` and the relevant article name.

* There are loads of routines and variables in Elite - literally hundreds. You can find them in the source files by searching for the following: `Type: Subroutine`, `Type: Variable`, `Type: Workspace` and `Type: Macro`.

* If you know the name of a routine, you can find it by searching for `Name: <name>`, as in `Name: SCAN` (for the 3D scanner routine) or `Name: LL9` (for the ship-drawing routine).

* The entry point for the [main game code](sources/elite-source.asm) is routine `TT170`, which you can find by searching for `Name: TT170` (though there are some decryption and setup routines at `S%` and `BEGIN` that you may also find useful). If you want to follow the program flow all the way from the title screen around the main game loop, then you can find a number of [deep dives on program flow](https://www.bbcelite.com/deep_dives/) on the accompanying website.

* The source code is designed to be read at an 80-column width and with a monospaced font, just like in the good old days.

I hope you enjoy exploring the inner-workings of BBC Elite as much as I have.


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
ffdb229a    788  ffdb229a    788   Yes   ELITE.bin
e78cb0cf   5769  e78cb0cf   5769   Yes   ELITEa.bin
a95bc864   2666  a95bc864   2666   Yes   ELTA.bin
99c700a0   3096  99c700a0   3096   Yes   ELTB.bin
681bae80   3290  681bae80   3290   Yes   ELTC.bin
c395ca71   3336  c395ca71   3336   Yes   ELTD.bin
a315bf38   2708  a315bf38   2708   Yes   ELTE.bin
5fc1be4a   3957  5fc1be4a   3957   Yes   ELTF.bin
6ced0040   3582  6ced0040   3582   Yes   ELTG.bin
c34e877a   1427  c34e877a   1427   Yes   ELTH.bin
6e59d3e2   1411  6e59d3e2   1411   Yes   ELTI.bin
a5dfbfdd   3586  a5dfbfdd   3586   Yes   ELTJ.bin
ee25ce2a   6454  ee25ce2a   6454   Yes   I.CODE.bin
9b6480bb  38799  9b6480bb  38799   Yes   P.CODE.bin
5cfd1851  38799  5cfd1851  38799   Yes   P.CODE.unprot.bin
2580d019   8460  2580d019   8460   Yes   SHIPS.bin
fc481d3e   1024  fc481d3e   1024   Yes   WORDS.bin
```

All the compiled binaries match the extracts, so we know we are producing the same final game as the release version.

### Log files

During compilation, details of every step are output in a file called `compile.txt` in the `output` folder. If you have problems, it might come in handy, and it's a great reference if you need to know the addresses of labels and variables for debugging (or just snooping around).


## Building different release versions of Elite

This repository contains the source code for two different versions of 6502 Second Processor Elite:

* The version from the SNG45 Acornsoft release (the first official release of 6502 Second Processor Elite)

* The version produced by the source disc from Ian Bell's site (which was never released)

By default the build process builds the SNG45 version, but you can build the source disc version by appending `release-6502sp=source-disc` to the `make` command, like this on Windows:

```
make.bat encrypt verify release-6502sp=source-disc
```

or this on a Mac or Linux:

```
make encrypt verify release-6502sp=source-disc
```

You can also add `release-6502sp=sng45`, though that's the default value so it isn't necessary.

You can see the differences between the versions by searching the source code for `_SNG45` (for features in the SNG45 version) or `_SOURCE_DISC` (for features in the source disc). There are only a few differences, if you ignore [workspace noise](#producing-byte-accurate-binaries):

* In the source disc version, the extended description of Lave is replaced by the rather cryptic "Bits'n Pieces - End Of Part 1". You can see this by pressing F6 just after starting the game (you have to be docked at Lave).

* In the SNG45 version, the top laser line aims slightly higher than in the source disc version (see the `LASLI` routine for details).

* The loader contains an extra copyright string inserted at the start of the file ("Copyright (c) Acornsoft Limited 1985"), and most of the Tube-detection code in the source disc version is commented out.


## Notes on the original source files

### Fixing the original build process

The source files on the source disc do not build as they are; some massaging is required, as described in [this thread on Stardot](https://stardot.org.uk/forums/viewtopic.php?t=14607). Note also that the `P.DIALS2P` file on the source disc has some erroneous dots in the right-hand side of the dashboard; a fixed version is available in the `images` folder in this repository, and this fixed version was used to build the reference binaries in the `extracted` folder.

### Producing byte-accurate binaries 

The `extracted/<release>/workspaces` folders (where `<release>` is the release version) contain binary files that match the workspaces in the original game binaries (a workspace being a block of memory, such as `LBUF` or `LSX2`). Instead of initialising workspaces with null values like BeebAsm, the original BBC Micro source code creates its workspaces by simply incrementing the `P%` and `O%` program counters, which means that the workspaces end up containing whatever contents the allocated memory had at the time. As the source files are broken into multiple BBC BASIC programs that run each other sequentially, this means the workspaces in the source code tend to contain either fragments of these BBC BASIC source programs, or assembled code from an earlier stage. This doesn't make any difference to the game code, which either intialises the workspaces at runtime or just ignores their initial contents, but if we want to be able to produce byte-accurate binaries from the modern BeebAsm assembly process, we need to include this "workspace noise" when building the project, and that's what the binaries in the `extracted/<release>/workspaces` folder are for. These binaries are only loaded by the `encrypt` target; for the `build` target, workspaces are initialised with zeroes.

Here's an example of how these binaries are included, in this case for the `LBUF` workspace in the `ELTB` section:

```
.LBUF

IF _MATCH_EXTRACTED_BINARIES

 IF _SNG45
  INCBIN "versions/6502sp/extracted/sng45/workspaces/ELTB-LBUF.bin"
 ELIF _SOURCE_DISC
  INCBIN "versions/6502sp/extracted/source-disc/workspaces/ELTB-LBUF.bin"
 ENDIF

ELSE

 SKIP &100

ENDIF
```

Note that the log tables in both the `ELTG` and `I.CODE` sections of the source are also included in the `workspaces` folder. This is because BBC BASIC calculates slightly different values for these tables compared to those calculated by BeebAsm. The `encrypt` target therefore loads the original BBC Micro versions of these log tables using the same approach as above, to ensure the output matches the originals, while the `build` target sticks with BeebAsm's built-in `LOG()` function and generates the tables as part of the build process.

---

Right on, Commanders!

_Mark Moxon_