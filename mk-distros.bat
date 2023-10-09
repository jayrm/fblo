@echo off
setlocal

@rem TODO:
@rem   - maybe move this to a bash script?
@rem   - or create a ./mk-distro.sh script for single distro?
@rem   - configuration file?  paths are user system dependant
@rem NOTE:
@rem   - should not matter if 32-bit / 64-bit tools are used,
@rem     but we need to choose something to generate the package
@rem     and satisfy the makefiles.

	set MSYS32PATHS=c:\msys32\mingw32\bin;c:\msys32\usr\bin
	set FBC32=d:/fb.1.10/fbc-win32.exe

	set P7ZIP=c:/msys32/usr/bin/7z

	set PATH=%MSYS32PATHS%

	call :BUILD120
	call :BUILD110

	goto DONE

@Rem ======================================================
:BUILD
	@rem %1 = FBCVERSION
	@rem %2 = TOOLCHAIN

	if /i "%1" == "" exit /b
	if /i "%2" == "" exit /b
	if not exist output\%1\%2\ exit /b

	sh -c "make -s P7ZIP=%P7ZIP% FBC=%FBC32% FBCVERSION=%1 TOOLCHAIN=%2"
	exit /b

@Rem ======================================================
:BUILD120
	if not exist output\fbc-1.20.0\ exit /b

	call :BUILD fbc-1.20.0 mingw-w64-gcc-11.2.0
	call :BUILD fbc-1.20.0 winlibs-gcc-9.3.0
	call :BUILD fbc-1.20.0 mingw-w64-gcc-5.2.0
	exit /b

@Rem ======================================================
:BUILD110
	if not exist output\fbc-1.10.0\ exit /b

	call :BUILD fbc-1.10.0 mingw-w64-gcc-11.2.0
	call :BUILD fbc-1.10.0 winlibs-gcc-9.3.0
	call :BUILD fbc-1.10.0 mingw-w64-gcc-5.2.0
	exit /b

@Rem ======================================================
:DONE
