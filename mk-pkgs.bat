@echo off
setlocal

set DOCLEAN=

@rem TODO:
@rem   - maybe move this to a bash script
@rem   - allow setting a package (to allow updating one package only)
@rem   - configuration file?  paths are user system dependant
@rem   - deduplicate commands? but maybe that makes it even more confusing...

	set FBFROG=d:/fbfrog.git/fbfrog.exe

	set MSYS32PATHS=c:\msys32\mingw32\bin;c:\msys32\usr\bin
	set MSYS64PATHS=c:\msys64\mingw64\bin;c:\msys64\usr\bin

	if /i "%1" == "--clean" set DOCLEAN=clean
	if /i "%1" == "clean" set DOCLEAN=clean
	if /i "%1" == "--keep-build" set DOCLEAN=keep-build
	if /i "%1" == "keep-build" set DOCLEAN=keep-build

	@rem default to clean-build (./build.sh should choose it anyway)
	if "%DOCLEAN%" == "" set DOCLEAN=clean-build

	call :BUILD120
	call :BUILD110

	goto DONE

@Rem ======================================================
:BUILD120

	set FBC32=d:/fb.git/fbc-win32.exe
	set FBC64=d:/fb.git/fbc-win64.exe

	set PATH=%MSYS32PATHS%
	set ARGS=win32 --fbfrog %FBFROG% --fbc %FBC32% fbc-1.20.0 %DOCLEAN%

	sh -c "./mk-pkg.sh %ARGS% winlibs-gcc-9.3.0 --prefix c:/winlibs-9.3"
	sh -c "./mk-pkg.sh %ARGS% mingw-w64-gcc-5.2.0 --prefix c:/mingw-w64-5.2"
	sh -c "./mk-pkg.sh %ARGS% mingw-w64-gcc-11.2.0 --prefix c:/mingw-w64-11.2"

	set PATH=%MSYS64PATHS%
	set ARGS=win64 --fbfrog %FBFROG% --fbc %FBC64% fbc-1.20.0 %DOCLEAN%

	sh -c "./mk-pkg.sh %ARGS% winlibs-gcc-9.3.0 --prefix c:/winlibs-9.3"
	sh -c "./mk-pkg.sh %ARGS% mingw-w64-gcc-5.2.0 --prefix c:/mingw-w64-5.2"
	sh -c "./mk-pkg.sh %ARGS% mingw-w64-gcc-11.2.0 --prefix c:/mingw-w64-11.2"

	exit /b

@Rem ======================================================
:BUILD110

	set FBC32=d:/fb.1.10/fbc-win32.exe
	set FBC64=d:/fb.1.10/fbc-win64.exe

	set PATH=%MSYS32PATHS%
	set ARGS=win32 --fbfrog %FBFROG% --fbc %FBC32% fbc-1.10.0 %DOCLEAN%

	sh -c "./mk-pkg.sh %ARGS% winlibs-gcc-9.3.0 --prefix c:/winlibs-9.3"
	sh -c "./mk-pkg.sh %ARGS% mingw-w64-gcc-5.2.0 --prefix c:/mingw-w64-5.2"
	sh -c "./mk-pkg.sh %ARGS% mingw-w64-gcc-11.2.0 --prefix c:/mingw-w64-11.2"

	set PATH=%MSYS64PATHS%
	set ARGS=win64 --fbfrog %FBFROG% --fbc %FBC64% fbc-1.10.0 %DOCLEAN%

	sh -c "./mk-pkg.sh %ARGS% winlibs-gcc-9.3.0 --prefix c:/winlibs-9.3"
	sh -c "./mk-pkg.sh %ARGS% mingw-w64-gcc-5.2.0 --prefix c:/mingw-w64-5.2"
	sh -c "./mk-pkg.sh %ARGS% mingw-w64-gcc-11.2.0 --prefix c:/mingw-w64-11.2"

	exit /b

@Rem ======================================================
:DONE
