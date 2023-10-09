@echo off
setlocal

set DOCLEAN=
set DOPACKAGE=
set DOFBCVERSION=
set DOTOOLCHAIN=

@rem TODO:
@rem   - maybe move this to a bash script?
@rem   - allow setting a package (to allow updating one package only)
@rem   - configuration file?  paths are user system dependant

	set FBFROG=d:/fbfrog.git/fbfrog.exe

	set MSYS32PATHS=c:\msys32\mingw32\bin;c:\msys32\usr\bin
	set MSYS64PATHS=c:\msys64\mingw64\bin;c:\msys64\usr\bin

@Rem ======================================================
:GETARGS
	if /I "%1" == "/?"      goto HELP
	if /I "%1" == "/help"   goto HELP
	if /I "%1" == "-h"      goto HELP
	if /I "%1" == "--help"  goto HELP

	if /i "%1" == "--clean"      goto SETCLEAN
	if /i "%1" == "clean"        goto SETCLEAN
	if /i "%1" == "--keep-build" goto SETKEEPBUILD
	if /i "%1" == "keep-build"   goto SETKEEPBUILD

	if /i "%1" == "fbc-1.10.0" goto SETFBCVERSION %1
	if /i "%1" == "fbc-1.20.0" goto SETFBCVERSION %1

	if /i "%1" == "mingw-w64-gcc-11.2.0"  goto SETTOOLCHAIN  %1
	if /i "%1" == "winlbs-gcc-9.3.0"      goto SETTOOLCHAIN  %1
	if /i "%1" == "mingw-w64-gcc-5.2.0"   goto SETTOOLCHAIN  %1

	if NOT "%1" == "" set DOPACKAGE=%1

:NEXTARG
	shift
	if "%1" == "" goto STARTBUILD
	goto GETARGS

:SETCLEAN
	set DOCLEAN=clean
	goto NEXTARG

:SETKEEPBUILD
	set DOCLEAN=keep-build
	goto NEXTARG

:SETFBCVERSION
	set DOFBCVERSION=%1
	goto NEXTARG

:SETTOOLCHAIN
	set DOTOOLCHAIN=%1
	goto NEXTARG

@Rem ======================================================
:STARTBUILD
	@rem default to clean-build (./build.sh should choose it anyway)
	if "%DOCLEAN%" == "" set DOCLEAN=clean-build

	if "%DOFBCVERSION%" == "" goto BUILDALL
	if "%DOFBCVERSION%" == "fbc-1.20.0" call :BUILD120
	if "%DOFBCVERSION%" == "fbc-1.10.0" call :BUILD110
	goto DONE

:BUILDALL
	call :BUILD120
	call :BUILD110
	goto DONE

@Rem ======================================================
:BUILD110
	set FBC32=d:/fb.1.10/fbc-win32.exe
	set FBC64=d:/fb.1.10/fbc-win64.exe

	call :BUILD32 fbc-1.10.0
	call :BUILD64 fbc-1.10.0
	exit /b

@Rem ======================================================
:BUILD120
	set FBC32=d:/fb.git/fbc-win32.exe
	set FBC64=d:/fb.git/fbc-win64.exe

	call :BUILD32 fbc-1.20.0
	call :BUILD64 fbc-1.20.0
	exit /b

@Rem ======================================================
:SETTOOLCHAINS
	set dowinlibs930=N
	set domingw520=N
	set domingw1120=N

	if /i "%DOTOOLCHAIN%" == "" set domingw1120=Y
	if /i "%DOTOOLCHAIN%" == "" set dowinlibs930=Y
	if /i "%DOTOOLCHAIN%" == "" set domingw520=Y

	if /i "%DOTOOLCHAIN%" == "mingw-w64-gcc-11.2.0" set domingw1120=Y
	if /i "%DOTOOLCHAIN%" == "winlibs-gcc-9.3.0" set dowinlibs930=Y
	if /i "%DOTOOLCHAIN%" == "mingw-w64-gcc-5.2.0" set domingw520=Y

	exit /b

@Rem ======================================================
:BUILD32
	set PATH=%MSYS32PATHS%
	set ARGS=win32 --fbfrog %FBFROG% --fbc %FBC32% %1 %DOCLEAN% %DOPACKAGE%

	call :SETTOOLCHAINS

	if /i "%domingw1120%"  == "Y" sh -c "./mk-pkg.sh %ARGS% mingw-w64-gcc-11.2.0 --prefix c:/mingw-w64-11.2"
	if /i "%dowinlibs930%" == "Y" sh -c "./mk-pkg.sh %ARGS% winlibs-gcc-9.3.0 --prefix c:/winlibs-9.3"
	if /i "%domingw520%"   == "Y" sh -c "./mk-pkg.sh %ARGS% mingw-w64-gcc-5.2.0 --prefix c:/mingw-w64-5.2"

	exit /b

:BUILD64
	set PATH=%MSYS64PATHS%
	set ARGS=win64 --fbfrog %FBFROG% --fbc %FBC64% %1 %DOCLEAN% %DOPACKAGE%

	call :SETTOOLCHAINS

	if /i "%domingw1120%"  == "Y" sh -c "./mk-pkg.sh %ARGS% mingw-w64-gcc-11.2.0 --prefix c:/mingw-w64-11.2"
	if /i "%dowinlibs930%" == "Y" sh -c "./mk-pkg.sh %ARGS% winlibs-gcc-9.3.0 --prefix c:/winlibs-9.3"
	if /i "%domingw520%"   == "Y" sh -c "./mk-pkg.sh %ARGS% mingw-w64-gcc-5.2.0 --prefix c:/mingw-w64-5.2"

	exit /b

@Rem ======================================================
:HELP
	echo mk-pkgs.bat [options] [packageid] [fbcversion]
	echo --clean
	echo --keep-build
	echo see ./build.sh for package ids
	goto DONE

@Rem ======================================================
:DONE
