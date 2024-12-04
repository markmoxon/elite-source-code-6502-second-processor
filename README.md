# Fully documented source code for Elite on the BBC Micro with a 6502 Second Processor

[BBC Micro cassette Elite](https://github.com/markmoxon/elite-source-code-bbc-micro-cassette) | [BBC Micro disc Elite](https://github.com/markmoxon/elite-source-code-bbc-micro-disc) | **6502 Second Processor Elite** | [BBC Master Elite](https://github.com/markmoxon/elite-source-code-bbc-master) | [Acorn Electron Elite](https://github.com/markmoxon/elite-source-code-acorn-electron) | [Commodore 64 Elite](https://github.com/markmoxon/elite-source-code-commodore-64) | [Apple II Elite](https://github.com/markmoxon/elite-source-code-apple-ii) | [NES Elite](https://github.com/markmoxon/elite-source-code-nes) | [Elite-A](https://github.com/markmoxon/elite-a-source-code-bbc-micro) | [Teletext Elite](https://github.com/markmoxon/teletext-elite) | [Elite Universe Editor](https://github.com/markmoxon/elite-universe-editor) | [Elite Compendium (BBC Master)](https://github.com/markmoxon/elite-compendium-bbc-master) | [Elite Compendium (BBC Micro)](https://github.com/markmoxon/elite-compendium-bbc-micro) | [Elite over Econet](https://github.com/markmoxon/elite-over-econet) | [Flicker-free Commodore 64 Elite](https://github.com/markmoxon/c64-elite-flicker-free) | [BBC Micro Aviator](https://github.com/markmoxon/aviator-source-code-bbc-micro) | [BBC Micro Revs](https://github.com/markmoxon/revs-source-code-bbc-micro) | [Archimedes Lander](https://github.com/markmoxon/lander-source-code-acorn-archimedes)

![Screenshot of 6502 Second Processor Elite on the BBC Micro](https://elite.bbcelite.com/images/github/Elite-Tube.png)

This repository contains the original source code for Elite on the BBC Micro with a 6502 Second Processor, with every single line documented and (for the most part) explained. It is literally the original source code, just heavily documented.

It is a companion to the [elite.bbcelite.com website](https://elite.bbcelite.com).

See the [introduction](#introduction) for more information, or jump straight into the [documented source code](1-source-files/main-sources).

## Contents

* [Introduction](#introduction)

* [Acknowledgements](#acknowledgements)

  * [A note on licences, copyright etc.](#user-content-a-note-on-licences-copyright-etc)

* [Browsing the source in an IDE](#browsing-the-source-in-an-ide)

* [Folder structure](#folder-structure)

* [Flicker-free Elite](#flicker-free-elite)

* [6502 Second Processor Elite with music](#6502-second-processor-elite-with-music)

* [Elite Compendium](#elite-compendium)

* [Elite over Econet](#elite-over-econet)

* [Elite 3D](#elite-3d)

* [Building 6502 Second Processor Elite from the source](#building-6502-second-processor-elite-from-the-source)

  * [Requirements](#requirements)
  * [Windows](#windows)
  * [Mac and Linux](#mac-and-linux)
  * [Build options](#build-options)
  * [Updating the checksum scripts if you change the code](#updating-the-checksum-scripts-if-you-change-the-code)
  * [Verifying the output](#verifying-the-output)
  * [Log files](#log-files)
  * [Auto-deploying to the b2 emulator](#auto-deploying-to-the-b2-emulator)

* [Building different variants of 6502 Second Processor Elite](#building-different-variants-of-6502-second-processor-elite)

  * [Building the SNG45 variant](#building-the-sng45-variant)
  * [Building the source disc variant](#building-the-source-disc-variant)
  * [Building the Executive version](#building-the-executive-version)
  * [Differences between the variants](#differences-between-the-variants)

* [Notes on the original source files](#notes-on-the-original-source-files)

  * [Fixing the original build process](#fixing-the-original-build-process)
  * [Producing byte-accurate binaries](#producing-byte-accurate-binaries)

## Introduction

This repository contains the original source code for Elite on the BBC Micro with a 6502 Second Processor, with every single line documented and (for the most part) explained.

You can build the fully functioning game from this source. [Three variants](#building-different-variants-of-6502-second-processor-elite) are currently supported: the Acornsoft SNG45 variant, the Executive version, and the version produced by the original source discs.

This repository is a companion to the [elite.bbcelite.com website](https://elite.bbcelite.com), which contains all the code from this repository, but laid out in a much more human-friendly fashion. The links at the top of this page will take you to repositories for the other versions of Elite that are covered by this project.

* If you want to browse the source and read about how Elite works under the hood, you will probably find [the website](https://elite.bbcelite.com) a better place to start than this repository.

* If you would rather explore the source code in your favourite IDE, then the [annotated source](1-source-files/main-sources) is what you're looking for. It contains the exact same content as the website, so you won't be missing out (the website is generated from the source files, so they are guaranteed to be identical). You might also like to read the section on [browsing the source in an IDE](#browsing-the-source-in-an-ide) for some tips.

* If you want to build 6502 Second Processor Elite from the source on a modern computer, to produce a working game disc that can be loaded into a BBC Micro or an emulator, then you want the section on [building 6502 Second Processor Elite from the source](#building-6502-second-processor-elite-from-the-source).

My hope is that this repository and the [accompanying website](https://elite.bbcelite.com) will be useful for those who want to learn more about Elite and what makes it tick. It is provided on an educational and non-profit basis, with the aim of helping people appreciate one of the most iconic games of the 8-bit era.

## Acknowledgements

6502 Second Processor Elite was written by Ian Bell and David Braben and is copyright &copy; Acornsoft 1985.

The code on this site is identical to the source discs released on [Ian Bell's personal website](http://www.elitehomepage.org/) (it's just been reformatted to be more readable).

The commentary is copyright &copy; Mark Moxon. Any misunderstandings or mistakes in the documentation are entirely my fault.

Huge thanks are due to the original authors for not only creating such an important piece of my childhood, but also for releasing the source code for us to play with; to Paul Brink for his annotated disassembly; and to Kieran Connell for his [BeebAsm version](https://github.com/kieranhj/elite-beebasm), which I forked as the original basis for this project. You can find more information about this project in the [accompanying website's project page](https://elite.bbcelite.com/about_site/about_this_project.html).

The following archive from Ian Bell's personal website forms the basis for this project:

* [6502 Second Processor Elite sources as a disc image](http://www.elitehomepage.org/archive/a/a5022201.zip)

### A note on licences, copyright etc.

This repository is _not_ provided with a licence, and there is intentionally no `LICENSE` file provided.

According to [GitHub's licensing documentation](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/licensing-a-repository), this means that "the default copyright laws apply, meaning that you retain all rights to your source code and no one may reproduce, distribute, or create derivative works from your work".

The reason for this is that my commentary is intertwined with the original Elite source code, and the original source code is copyright. The whole site is therefore covered by default copyright law, to ensure that this copyright is respected.

Under GitHub's rules, you have the right to read and fork this repository... but that's it. No other use is permitted, I'm afraid.

My hope is that the educational and non-profit intentions of this repository will enable it to stay hosted and available, but the original copyright holders do have the right to ask for it to be taken down, in which case I will comply without hesitation. I do hope, though, that along with the various other disassemblies and commentaries of this source, it will remain viable.

## Browsing the source in an IDE

If you want to browse the source in an IDE, you might find the following useful.

* The most interesting files are in the [main-sources](1-source-files/main-sources) folder:

  * The main game's source code is in the [elite-source.asm](1-source-files/main-sources/elite-source.asm) file (for the parasite, i.e. the Second Processor) and [elite-z.asm](1-source-files/main-sources/elite-z.asm) (for the I/O processor, i.e. the BBC Micro) - this is the motherlode and probably contains all the stuff you're interested in.

  * The game's loader is in the [elite-loader1.asm](1-source-files/main-sources/elite-loader1.asm) and [elite-loader2.asm](1-source-files/main-sources/elite-loader2.asm) files - these are mainly concerned with setup and copy protection.

* It's probably worth skimming through the [notes on terminology and notations](https://elite.bbcelite.com/terminology/) on the accompanying website, as this explains a number of terms used in the commentary, without which it might be a bit tricky to follow at times (in particular, you should understand the terminology I use for multi-byte numbers).

* The accompanying website contains [a number of "deep dive" articles](https://elite.bbcelite.com/deep_dives/), each of which goes into an aspect of the game in detail. Routines that are explained further in these articles are tagged with the label `Deep dive:` and the relevant article name.

* There are loads of routines and variables in Elite - literally hundreds. You can find them in the source files by searching for the following: `Type: Subroutine`, `Type: Variable`, `Type: Workspace` and `Type: Macro`.

* If you know the name of a routine, you can find it by searching for `Name: <name>`, as in `Name: SCAN` (for the 3D scanner routine) or `Name: LL9` (for the ship-drawing routine).

* The entry point for the [main game code](1-source-files/main-sources/elite-source.asm) is routine `TT170`, which you can find by searching for `Name: TT170` (though there are some decryption and setup routines at `S%` and `BEGIN` that you may also find useful). If you want to follow the program flow all the way from the title screen around the main game loop, then you can find a number of [deep dives on program flow](https://elite.bbcelite.com/deep_dives/) on the accompanying website.

* The source code is designed to be read at an 80-column width and with a monospaced font, just like in the good old days.

I hope you enjoy exploring the inner workings of BBC Elite as much as I have.

## Folder structure

There are five main folders in this repository, which reflect the order of the build process.

* [1-source-files](1-source-files) contains all the different source files, such as the main assembler source files, image binaries, fonts, boot files and so on.

* [2-build-files](2-build-files) contains build-related scripts, such as the checksum, encryption and crc32 verification scripts.

* [3-assembled-output](3-assembled-output) contains the output from the assembly process, when the source files are assembled and the results processed by the build files.

* [4-reference-binaries](4-reference-binaries) contains the correct binaries for each variant, so we can verify that our assembled output matches the reference.

* [5-compiled-game-discs](5-compiled-game-discs) contains the final output of the build process: an SSD disc image that contains the compiled game and which can be run on real hardware or in an emulator.

## Flicker-free Elite

This repository also includes a flicker-free version, which incorporates the backported flicker-free ship-drawing routines from the BBC Master, as well as a fix for planets so they no longer flicker. The flicker-free code is in a separate branch called `flicker-free`, and apart from the code differences for reducing flicker, this branch is identical to the main branch and the same build process applies.

The annotated source files in the `flicker-free` branch contain both the original Acornsoft code and all of the modifications for flicker-free Elite, so you can look through the source to see exactly what's changed. Any code that I've removed from the original version is commented out in the source files, so when they are assembled they produce the flicker-free binaries, while still containing details of all the modifications. You can find all the diffs by searching the sources for `Mod:`.

For more information on flicker-free Elite, see the [hacks section of the accompanying website](https://elite.bbcelite.com/hacks/flicker-free_elite.html).

## 6502 Second Processor Elite with music

This repository also includes a version of 6502 Second Processor Elite that includes the music from the Commodore 64 version. The music-specific code is in a separate branch called `music`, and apart from the code differences for adding the music, this branch is identical to the main branch and the same build process applies.

The annotated source files in the `music` branch contain both the original Acornsoft code and all of the modifications for the musical version of Elite, so you can look through the source to see exactly what's changed. Any code that I've removed from the original version is commented out in the source files, so when they are assembled they produce the music-enabled binaries, while still containing details of all the modifications. You can find all the diffs by searching the sources for `Mod:`.

The music itself is built as a sideways ROM using the code in the [elite-music repository](https://github.com/markmoxon/elite-music/).

For more information on the music, see the [hacks section of the accompanying website](https://elite.bbcelite.com/hacks/bbc_elite_with_music.html).

## Elite Compendium

This repository also includes a version of 6502 Second Processor Elite for the Elite Compendium, which incorporates all the available hacks in one game. The Compendium version is in a separate branch called `elite-compendium`, which is included in the [Elite Compendium (BBC Master)](https://github.com/markmoxon/elite-compendium-bbc-master) and [Elite Compendium (BBC Micro)](https://github.com/markmoxon/elite-compendium-bbc-micro) repositories as a submodule.

The annotated source files in the `elite-compendium` branch contain both the original Acornsoft code and all of the modifications for the Elite Compendium, so you can look through the source to see exactly what's changed. Any code that I've removed from the original version is commented out in the source files, so when they are assembled they produce the Compendium binaries, while still containing details of all the modifications. You can find all the diffs by searching the sources for `Mod:`.

For more information on the Elite Compendium, see the [hacks section of the accompanying website](https://elite.bbcelite.com/hacks/elite_compendium.html).

## Elite over Econet

This repository also includes a version of 6502 Second Processor Elite that loads over Econet and supports multiplayer scoreboards. The Elite over Econet version is in a separate branch called `econet`, which is included in the [Elite over Econet](https://github.com/markmoxon/elite-over-econet) repository as a submodule.

The annotated source files in the `econet` branch contain both the original Acornsoft code and all of the modifications for Elite over Econet, so you can look through the source to see exactly what's changed. Any code that I've removed from the original version is commented out in the source files, so when they are assembled they produce the Elite over Econet binaries, while still containing details of all the modifications. You can find all the diffs by searching the sources for `Mod:`.

For more information on Elite over Econet, see the [hacks section of the accompanying website](https://elite.bbcelite.com/hacks/elite_over_econet.html).

## Elite 3D

This repository also includes an anaglyph 3D version of 6502 Second Processor Elite. Elite 3D is in a separate branch called `anaglyph-3d`, and apart from the code differences for adding the anaglyph 3D, this branch is identical to the main branch and the same build process applies.

The annotated source files in the `anaglyph-3d` branch contain both the original Acornsoft code and all of the modifications for Elite 3D, so you can look through the source to see exactly what's changed. Any code that I've removed from the original version is commented out in the source files, so when they are assembled they produce the Elite 3D binaries, while still containing details of all the modifications. You can find all the diffs by searching the sources for `Mod:`.

For more information on Elite 3D, see the [hacks section of the accompanying website](https://elite.bbcelite.com/hacks/elite_3d.html).

## Building 6502 Second Processor Elite from the source

Builds are supported for both Windows and Mac/Linux systems. In all cases the build process is defined in the `Makefile` provided.

### Requirements

You will need the following to build 6502 Second Processor Elite from the source:

* BeebAsm, which can be downloaded from the [BeebAsm repository](https://github.com/stardot/beebasm). Mac and Linux users will have to build their own executable with `make code`, while Windows users can just download the `beebasm.exe` file.

* Python. The build process has only been tested on 3.x, but 2.7 might work.

* Mac and Linux users may need to install `make` if it isn't already present (for Windows users, `make.exe` is included in this repository).

Let's look at how to build 6502 Second Processor Elite from the source.

### Windows

For Windows users, there is a batch file called `make.bat` which you can use to build the game. Before this will work, you should edit the batch file and change the values of the `BEEBASM` and `PYTHON` variables to point to the locations of your `beebasm.exe` and `python.exe` executables. You also need to change directory to the repository folder (i.e. the same folder as `make.bat`).

All being well, entering the following into a command window:

```
make.bat
```

will produce a file called `elite-6502sp-sng45.ssd` in the `5-compiled-game-discs` folder that contains the SNG45 variant, which you can then load into an emulator, or into a real BBC Micro using a device like a Gotek.

### Mac and Linux

The build process uses a standard GNU `Makefile`, so you just need to install `make` if your system doesn't already have it. If BeebAsm or Python are not on your path, then you can either fix this, or you can edit the `Makefile` and change the `BEEBASM` and `PYTHON` variables in the first two lines to point to their locations. You also need to change directory to the repository folder (i.e. the same folder as `Makefile`).

All being well, entering the following into a terminal window:

```
make
```

will produce a file called `elite-6502sp-sng45.ssd` in the `5-compiled-game-discs` folder that contains the SNG45 variant, which you can then load into an emulator, or into a real BBC Micro using a device like a Gotek.

### Build options

By default the build process will create a typical Elite game disc with a standard commander and verified binaries. There are various arguments you can pass to the build to change how it works. They are:

* `variant=<name>` - Build the specified variant:

  * `variant=sng45` (default)
  * `variant=source-disc`
  * `variant=executive`

* `commander=max` - Start with a maxed-out commander (specifically, this is the test commander file from the original source, which is almost but not quite maxed-out)

* `encrypt=no` - Disable encryption and checksum routines

* `match=no` - Do not attempt to match the original game binaries (i.e. omit workspace noise)

* `verify=no` - Disable crc32 verification of the game binaries

So, for example:

`make variant=source-disc commander=max encrypt=no match=no verify=no`

will build an unencrypted source disc variant with a maxed-out commander, no workspace noise and no crc32 verification.

The unencrypted version should be more useful for anyone who wants to make modifications to the game code. As this argument produces unencrypted files, the binaries produced will be quite different to the binaries on the original source disc, which are encrypted.

See below for more on the verification process.

### Updating the checksum scripts if you change the code

If you change the source code in any way, you may break the game; if so, it will typically hang at the loading screen, though in some versions it may hang when launching from the space station.

To fix this, you may need to update some of the hard-coded addresses in the checksum script so that they match the new addresses in your changed version of the code. See the comments in the [elite-checksum.py](2-build-files/elite-checksum.py) script for details.

### Verifying the output

The default build process prints out checksums of all the generated files, along with the checksums of the files from the original sources. You can disable verification by passing `verify=no` to the build.

The Python script `crc32.py` in the `2-build-files` folder does the actual verification, and shows the checksums and file sizes of both sets of files, alongside each other, and with a Match column that flags any discrepancies. If you are building an unencrypted set of files then there will be lots of differences, while the encrypted files should match.

The binaries in the `4-reference-binaries` folder were taken straight from the [6502 Second Processor sources disc image](http://www.elitehomepage.org/archive/a/a5022201.zip), while those in the `3-assembled-output` folder are produced by the build process. For example, if you don't make any changes to the code and build the project with `make`, then this is the output of the verification process:

```
Results for variant: sng45
[--originals--]  [---output----]
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

All the compiled binaries match the originals, so we know we are producing the same final game as the SNG45 variant.

### Log files

During compilation, details of every step are output in a file called `compile.txt` in the `3-assembled-output` folder. If you have problems, it might come in handy, and it's a great reference if you need to know the addresses of labels and variables for debugging (or just snooping around).

### Auto-deploying to the b2 emulator

For users of the excellent [b2 emulator](https://github.com/tom-seddon/b2), you can include the build parameter `b2` to automatically load and boot the assembled disc image in b2. The b2 emulator must be running for this to work.

For example, to build, verify and load the game into b2, you can do this on Windows:

```
make.bat all b2
```

or this on Mac/Linux:

```
make all b2
```

If you omit the `all` target then b2 will start up with the results of the last successful build.

Note that you should manually choose the correct platform in b2 (I intentionally haven't automated this part to make it easier to test across multiple platforms).

## Building different variants of 6502 Second Processor Elite

This repository contains the source code for three different variants of 6502 Second Processor Elite:

* The Acornsoft SNG45 variant, which was the first appearence of 6502 Second Processor Elite, and the one included on all subsequent discs

* The variant produced by the source disc from Ian Bell's personal website, which was never released

* The Executive version from Ian Bell's personal website, which was also never released

By default the build process builds the SNG45 variant, but you can build a specified variant using the `variant=` build parameter.

### Building the SNG45 variant

You can add `variant=sng45` to produce the `elite-6502sp-sng45.ssd` file that contains the SNG45 variant, though that's the default value so it isn't necessary. In other words, you can build it like this:

```
make.bat variant=sng45
```

or this on a Mac or Linux:

```
make variant=sng45
```

This will produce a file called `elite-6502sp-sng45.ssd` in the `5-compiled-game-discs` folder that contains the SNG45 variant.

The verification checksums for this version are as follows:

```
Results for variant: sng45
[--originals--]  [---output----]
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

### Building the source disc variant

You can build the source disc variant by appending `variant=source-disc` to the `make` command, like this on Windows:

```
make.bat variant=source-disc
```

or this on a Mac or Linux:

```
make variant=source-disc
```

This will produce a file called `elite-6502sp-from-source-disc.ssd` in the `5-compiled-game-discs` folder that contains the source disc variant.

The verification checksums for this version are as follows:

```
Results for variant: source-disc
[--originals--]  [---output----]
Checksum   Size  Checksum   Size  Match  Filename
-----------------------------------------------------------
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
11ccbb59  38832  11ccbb59  38832   Yes   P.CODE.unprot.bin
2580d019   8460  2580d019   8460   Yes   SHIPS.bin
57406380   1024  57406380   1024   Yes   WORDS.bin
```

### Building the Executive version

You can build the Executive version by appending `variant=executive` to the `make` command, like this on Windows:

```
make.bat variant=executive
```

or this on a Mac or Linux:

```
make variant=executive
```

This will produce a file called `elite-6502sp-executive.ssd` in the `5-compiled-game-discs` folder that contains the Executive version.

The verification checksums for this version are as follows:

```
Results for variant: executive
[--originals--]  [---output----]
Checksum   Size  Checksum   Size  Match  Filename
-----------------------------------------------------------
ffdb229a    788  ffdb229a    788   Yes   ELITE.bin
e78cb0cf   5769  e78cb0cf   5769   Yes   ELITEa.bin
975735eb   2680  975735eb   2680   Yes   ELTA.bin
ed6ac460   3108  ed6ac460   3108   Yes   ELTB.bin
cd8079af   3284  cd8079af   3284   Yes   ELTC.bin
483aaeb3   3351  483aaeb3   3351   Yes   ELTD.bin
ba87b08c   2708  ba87b08c   2708   Yes   ELTE.bin
3056d88d   3973  3056d88d   3973   Yes   ELTF.bin
e7249d72   3529  e7249d72   3529   Yes   ELTG.bin
c325ced4   1427  c325ced4   1427   Yes   ELTH.bin
69e4c627   1667  69e4c627   1667   Yes   ELTI.bin
e2cf0d8a   3674  e2cf0d8a   3674   Yes   ELTJ.bin
52d06559   6451  52d06559   6451   Yes   I.CODE.bin
13bbc0b5  39143  13bbc0b5  39143   Yes   P.CODE.bin
d597e3d0  39143  d597e3d0  39143   Yes   P.CODE.unprot.bin
2580d019   8460  2580d019   8460   Yes   SHIPS.bin
272668f2   1024  272668f2   1024   Yes   WORDS.bin
```

### Differences between the variants

You can see the differences between the variants by searching the source code for `_SNG45` (for features in the SNG45 variant) or `_SOURCE_DISC` (for features in the source disc variant) or `_EXECUTIVE` (for features in the Executive version). There are only a few differences in the source disc variant (if you ignore [workspace noise](#producing-byte-accurate-binaries)), but quite a few in the Executive version.

The main differences in the source disc variant compared to the SNG45 variant are:

* In the source disc variant, the extended description of Lave is replaced by the rather cryptic "Bits'n Pieces - End Of Part 1". You can see this by pressing F6 just after starting the game (you have to be docked at Lave).

* The top laser line in the source disc variant aims slightly lower than in the SNG45 variant (see the `LASLI` routine for details).

* The loader in the source disc variant is missing the copyright string from the start of the file ("Copyright (c) Acornsoft Limited 1985").

* The loader in the source disc variant contains a load of Tube-detection code that is disabled in the SNG45 variant.

There are lots of differences in the Executive version compared to the SNG45 variant. You can read more about them in the deep dive on [secrets of the Executive version](https://elite.bbcelite.com/deep_dives/secrets_of_the_executive_version.html).

See the [accompanying website](https://elite.bbcelite.com/6502sp/releases.html) for a comprehensive list of differences between the variants.

## Notes on the original source files

### Fixing the original build process

The source files on the source disc do not build as they are; some massaging is required, as described in [this thread on Stardot](https://stardot.org.uk/forums/viewtopic.php?t=14607). Note also that the `P.DIALS2P` file on the source disc has some erroneous dots in the right-hand side of the dashboard; a fixed version is available in the `images` folder in this repository, and this fixed version was used to build the reference binaries in the `4-reference-binaries` folder.

### Producing byte-accurate binaries

Instead of initialising workspaces with null values like BeebAsm, the original BBC Micro source code creates its workspaces by simply incrementing the `P%` and `O%` program counters, which means that the workspaces end up containing whatever contents the allocated memory had at the time. As the source files are broken into multiple BBC BASIC programs that run each other sequentially, this means the workspaces in the source code tend to contain either fragments of these BBC BASIC source programs, or assembled code from an earlier stage. This doesn't make any difference to the game code, which either initialises the workspaces at runtime or just ignores their initial contents, but if we want to be able to produce byte-accurate binaries from the modern BeebAsm assembly process, we need to include this "workspace noise" when building the project. Workspace noise is only loaded by the `encrypt` target; for the `build` target, workspaces are initialised with zeroes.

You can disable the production of byte-accurate binaries by passing `match=no` to the build. This will omit most workspace noise, leaving workspaces initialised with zeroes instead.

Here's an example of how workspace noise is included, from the start of the ELITE G file in elite-source.asm:

```
IF _MATCH_ORIGINAL_BINARIES

 IF _SNG45

  EQUB &A5, &19, &8D, &FC, &08, &A5, &1A, &8D   \ These bytes appear to be
  EQUB &FD, &08, &60, &A6, &83, &20, &68, &4B   \ unused and just contain random
  EQUB &A6, &83, &4C, &D6, &12, &20, &C6, &4C   \ workspace noise left over from
  EQUB &20, &76, &43, &8D, &53, &08, &8D, &69   \ the BBC Micro assembly process
  EQUB &08, &20, &82, &45, &A9, &06, &85, &4A
  EQUB &A9, &81, &4C, &C1, &44, &A2, &FF, &E8
  EQUB &BD, &52, &08, &F0, &CB, &C9, &01, &D0
  EQUB &F6, &8A, &0A, &A8, &B9, &76, &1A, &85
  EQUB &05, &B9, &77, &1A, &85, &06, &A0, &20
  EQUB &B1, &05, &10, &E3, &29, &7F, &4A, &C5
  EQUB &97, &90, &DC, &F0, &09, &E9, &01, &0A
  EQUB &09, &80, &91, &05, &D0, &D1, &A9, &00
  EQUB &91, &05, &F0, &CB, &86, &97, &A5, &44
  EQUB &C5, &97, &D0, &0A, &A0, &0C, &20, &62
  EQUB &45, &A9, &C8, &20, &C7, &57, &A4, &97
  EQUB &BE, &52, &08, &E0, &02, &F0, &96, &E0
  EQUB &1F, &D0, &08, &AD, &A4, &08, &09

 ELIF _EXECUTIVE

  EQUB &A5, &19, &8D, &FC, &08, &A5, &1A, &8D   \ These bytes appear to be
  EQUB &FD, &08, &60, &A6, &83, &20, &8D, &4B   \ unused and just contain random
  EQUB &A6, &83, &4C, &D8, &12, &20, &EB, &4C   \ workspace noise left over from
  EQUB &20, &9B, &43, &8D, &53, &08, &8D, &69   \ the BBC Micro assembly process
  EQUB &08, &20, &A7, &45, &A9, &06, &85, &4A
  EQUB &A9, &81, &4C, &E6, &44, &A2, &FF, &E8
  EQUB &BD, &52, &08, &F0, &CB, &C9, &01, &D0
  EQUB &F6, &8A, &0A, &A8, &B9, &86, &1A, &85
  EQUB &05, &B9, &87, &1A, &85, &06, &A0, &20
  EQUB &B1, &05, &10, &E3, &29, &7F, &4A, &C5
  EQUB &97, &90

 ELIF _SOURCE_DISC

  EQUB &A5, &19, &8D, &FC, &08, &A5, &1A, &8D   \ These bytes appear to be
  EQUB &FD, &08, &60, &A6, &83, &20, &62, &4B   \ unused and just contain random
  EQUB &A6, &83, &4C, &D6, &12, &20, &C0, &4C   \ workspace noise left over from
  EQUB &20, &70, &43, &8D, &53, &08, &8D, &69   \ the BBC Micro assembly process
  EQUB &08, &20, &7C, &45, &A9, &06, &85, &4A
  EQUB &A9, &81, &4C, &BB, &44, &A2, &FF, &E8
  EQUB &BD, &52, &08, &F0, &CB, &C9, &01, &D0
  EQUB &F6, &8A, &0A, &A8, &B9, &76, &1A, &85
  EQUB &05, &B9, &77, &1A, &85, &06, &A0, &20
  EQUB &B1, &05, &10, &E3, &29, &7F, &4A, &C5
  EQUB &97, &90, &DC, &F0, &09, &E9, &01, &0A
  EQUB &09, &80, &91, &05, &D0, &D1, &A9, &00
  EQUB &91, &05, &F0, &CB, &86, &97, &A5, &44
  EQUB &C5, &97, &D0, &0A, &A0, &0C, &20, &5C
  EQUB &45, &A9, &C8, &20, &BE, &57, &A4, &97
  EQUB &BE, &52, &08, &E0, &02, &F0, &96, &E0
  EQUB &1F, &D0, &08, &AD, &A4, &08, &09, &02
  EQUB &8D, &A4, &08, &E0, &0F, &F0, &08, &E0

 ENDIF

ELSE

 ALIGN 256              \ Align the log tables so they start on page boundaries

ENDIF
```

---

Right on, Commanders!

_Mark Moxon_