JayRM's FreeBASIC Load Out
--------------------------
Prebuilt libraries for win32/win64 and source files that can be can be dropped
in to an existing FreeBASIC install.

Version 0.1 (script template only)

The repository itself contains the scripts needed to build the win32/win64
libraries from sources.


LICENSE
-------
See ./LICENSE.txt in the top level directory

In releases, see ./doc/<package>-license.txt for builds of projects included
in each distribution package.


How to Install a Prebuilt Load Out
-----------------------------------
  1) Download the release package that matches your version version of freebasic.

     For example: for FreeBASIC 1.10.0 using winlibs gcc-9.3 toolchain:
        fblo-0.1-fbc-1.10.0-winlibs-gcc-9.3.0.7z

  2) Extract in to your FreeBASIC installation.
     **careful!** - some files may be replaced
     The top level directory was omitted on purpose, since users may have
     renamed fbc installation directory.


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

  Build environment (32-bit and 64-bit versions)
    c:/msys32/mingw32, c:/msys32/usr/bin
    c:/msys64/mingw64, c:/msys64/usr/bin
    Base install plus 'make tar zip p7zip git wget curl'

  FreeBASIC (32-bit and 64-bit versions)
    d:/fb.git/fbc-win32.exe
    d:/fb.git/fbc-win64.exe
    d:/fb.1.10/fbc-win32.exe
    d:/fb.1.10/fbc-win64.exe
    d:/fb.1.20/fbc-win32.exe
    d:/fb.1.20/fbc-win64.exe

  gnu gcc toolchains (32-bit and 64-bit versions)
    c:/winlibs-9.3/mingw32    , c:/winlibs-9.3/mingw64
    c:/mingw-w64-5.2/mingw32  , c:/mingw-w64-5.2/mingw64
    c:/mingw-w64-11.2/mingw32 , c:/mingw-w64-11.2/mingw64

  fbfrog:
    d:/fbfrog.git/fbfrog.exe


Tools Used
----------
    - FreeBASIC     https://www.freebasic.net
                    https://github.com/freebasic/fbc
    - fbfrog        https://github.com/freebasic/fbfrog
    - GCC           https://gcc.gnu.org/
    - GNU binutils  https://gnu.org/software/binutils/
    - MinGW         https://osdn.net/projects/mingw/
    - MinGW-w64     https://mingw-w64.org/
                    https://github.com/niXman/mingw-builds-binaries/
    - WinLibs       https://www.winlibs.com/
