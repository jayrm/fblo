JayRM's FreeBASIC Load Out - v0.3
---------------------------------
Prebuilt libraries for win32/win64 and source files that can be can be dropped
in to an existing standalone FreeBASIC install.

The repository contains the scripts needed to build the win32/win64
libraries from sources.

The release packages contain the prebuilt binaries and supporting
files.


License
-------
For binary releases, see ./doc/{package}-license.txt for licenses
of each of the packages included with the release.

Some header files are automatically translated from original C sources and
the license and/or copyright statement is located at the top of each header.

For the source repository itself, see ./LICENSE.txt in the top level directory.


Installing a Prebuilt Load Out
-----------------------------------
  1) Download the release package that matches your version version of freebasic.

     For example: for FreeBASIC 1.10.0 using winlibs gcc-9.3 toolchain:
        fblo-0.3-fbc-1.10.0-winlibs-gcc-9.3.0.7z

  2) Extract in to your FreeBASIC installation.
     **careful!** - some files may be replaced
     The top level directory was omitted on purpose, since users may have
     renamed fbc installation directory.


Packages Included in the Load Out
---------------------------------

  + fblo: JayRM's FreeBASIC Load Out
    * Copyright (C) 2023 Jeff Marshall <coder[at]execulink.com>

    * Files for Load Out:
      - ./fblo-readme.txt
      - ./doc/fblo-license.txt


  + fbfrog: A binding generator for FreeBASIC
    * Copyright (C) 2011 - 2016  Daniel C. Klauer <daniel.c.klauer[at]web.de>

    * https://github.com/freebasic/fbfrog
    * Forked version at https://github.com/jayrm/fbfrog

    * Files for Load Out:
      - ./doc/fbfrog-license.txt
      - ./fbfrog.exe
      - ./fbfrog/*


  + fbimage: Load BMP, PNG, JPG, TGA, DDS from file or memory as FBImage

    * subset of SOIL library assembled by D.J.Peters (Joshy)
      https://shiny3d.de/public/libs/FBImage.zip

    * stb_image_write - v1.02
      - writes out PNG/BMP/TGA images to C stdio
      - public domain
      - http://nothings.org/stb/stb_image_write.h
      - Sean Barrett 2010-2015
      - no warranty implied; use at your own risk

    * Simple OpenGL Image Library
      - Jonathan Dummer 2007-07-26-10.36
      - public domain
      - using Sean Barret's stb_image as a base

    * simple DXT compression / decompression code
      - Jonathan Dummer - 2007-07-31-10.32
      - public domain

    * image helper functions
      - Jonathan Dummer
      - MIT license

    * Files for Load Out:
      - ./doc/FBImage-license.txt
      - ./inc/FBImage.bi
      - ./lib/win32/libFBImage-32-static.a
      - ./lib/win64/libFBImage-64-static.a


  + fbpng 3.2.z: FreeBASIC PNG Library
    * Copyright (C) 2007-2010 Simon Nash/Eric Cowles
    * Copyright (C) 2022 Ebben Feagan

    * https://github.com/mudhairless/fbpng/

    * Files for Load Out:
      - ./doc/fbpng-license.txt
      - ./inc/fbpng/*.bi
      - ./lib/win32/libfbpng.a
      - ./lib/win64/libfbpng.a


  + libogg 1.3.2 - Reference implementation of the Ogg media container
    * Copyright (c) 2002, Xiph.org Foundation

    * https://github.com/xiph/ogg/
    * https://xiph.org/ogg/

    * Files for Load Out:
      - ./doc/libogg-license.txt
      - ./inc/ogg/ogg.bi
      - ./lib/win32/libogg.a
      - ./lib/win64/libogg.a


  + libvorbis 1.3.7 - Reference implementation of the Ogg Vorbis audio format
    * Copyright (c) 2002-2020 Xiph.org Foundation

    * https://github.com/xiph/vorbis/
    * https://xiph.org/vorbis/

    * Files for Load Out:
      - ./doc/libvorbis-license.txt
      - ./inc/vorbis/vorbis.bi
      - ./inc/vorbis/vorbisenc.bi
      - ./inc/vorbis/vorbisfile.bi
      - ./lib/win32/libvorbis.a
      - ./lib/win32/libvorbisenc.a
      - ./lib/win32/libvorbisfile.a
      - ./lib/win64/libvorbis.a
      - ./lib/win64/libvorbisenc.a
      - ./lib/win64/libvorbisfile.a


  + libmad-0.15.1b - MPEG audio decoder library
     * Copyright (C) 2000-2004 Underbit Technologies, Inc.

     * https://www.underbit.com/products/mad/
     * https://sourceforge.net/projects/mad/

    * Files for Load Out:
      - ./doc/libmad-license.txt
      - ./inc/mad/mad.bi
      - ./lib/win32/libmad.a
      - ./lib/win64/libmad.a


  + libdumb-0.9.3 - Dynamic Universal Music Bibliotheque
    * Copyright (C) 2001-2005 Ben Davis, Robert J Ohannessian
    *                         and Julien Cugniere

    * https://sourceforge.net/projects/dumb/
    * https://dumb.sourceforge.net/

    * Files for Load Out:
      - ./doc/libdumb-license.txt
      - ./inc/dumb/dumb.bi
      - ./lib/win32/libdumb.a
      - ./lib/win64/libdumb.a


  + libpng 1.6.40 - PNG Reference Library
    * Copyright (c) 1995-2023 The PNG Reference Library Authors

    * http://www.libpng.org/

    * Files for Load Out:
      - ./doc/libgpng-license.txt
      - ./inc/png16.bi
      - ./lib/win32/libpng16.a
      - ./lib/win64/libpng16.a


  + zlib 1.3 - Data Compression Library
    * Copyright (C) 1995-2023 Jean-loup Gailly and Mark Adler

    * https://www.zlib.net/

    * Files for Load Out:
      - ./doc/zlib-license.txt
      - ./inc/zlib.bi
      - ./lib/win32/libz.a
      - ./lib/win64/libz.a


Building the Load Out from Scratch
-----------------------------------
The intent is that the scripts will download source files, compile them with
a specified toolchain (or all of the toolchains), and package in to a
distribution that can be extracted directly in to a pre-existing FreeBASIC
installation directory.

Basic steps:
  1) mk-pkgs.bat     (calls ./mk-pkg.sh, build.sh)
  2) mk-distros.bat  (uses  ./makefile)

The batch files and scripts require toolchains to be pre-installed at some
known locations and (sorry) some paths are currently hard coded. (perhaps
in a future version this will be more easily configured).

  * Build environment (32-bit and 64-bit versions)
    - c:/msys32/mingw32, c:/msys32/usr/bin
    - c:/msys64/mingw64, c:/msys64/usr/bin
    - Base install plus 'make tar zip p7zip git wget curl dos2unix'

  * FreeBASIC (32-bit and 64-bit versions)
    - d:/fb.git/fbc-win32.exe
    - d:/fb.git/fbc-win64.exe
    - d:/fb.1.10/fbc-win32.exe
    - d:/fb.1.10/fbc-win64.exe
    - d:/fb.1.20/fbc-win32.exe
    - d:/fb.1.20/fbc-win64.exe

  * gnu gcc toolchains (32-bit and 64-bit versions)
    - c:/winlibs-9.3/mingw32    , c:/winlibs-9.3/mingw64
    - c:/mingw-w64-5.2/mingw32  , c:/mingw-w64-5.2/mingw64
    - c:/mingw-w64-11.2/mingw32 , c:/mingw-w64-11.2/mingw64

  * fbfrog (forked):
    - d:/fbfrog.git/fbfrog.exe


Tools Used
----------
    - FreeBASIC     https://www.freebasic.net/
                    https://github.com/freebasic/fbc/
    - fbfrog        https://github.com/freebasic/fbfrog/
    - GCC           https://gcc.gnu.org/
    - GNU binutils  https://gnu.org/software/binutils/
    - MinGW         https://osdn.net/projects/mingw/
    - MinGW-w64     https://mingw-w64.org/
                    https://github.com/niXman/mingw-builds-binaries/
    - WinLibs       https://www.winlibs.com/
    - fblo          https://github.com/jayrm/fblo/


TODO
----
  + move hard coded paths to a configuration
  + allow configuration to select fbc versions
  + allow configuration to select toolchains
  + review makefile process - maybe shell scripts would have been simpler
    since the extract/confgure/make/package is typically only completed
    once for each package, the makefile is overkill (though the makefile
    is nice to have for dealing with lots of variables, paths, and files)
  + reduce to single target build configuration
  + make a shell script for dealing with license file and fbfrog header
  + use the newly build fbfrog.exe instead relying on the host install
