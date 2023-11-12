#!/usr/bin/env bash

set -e

FBLOPACKAGE=
FBCVERSION=
TOOLCHAIN=
FBCTARGET=
SHOWHELP=
DOALL=
DOCLEAN=
FBCEXE=
FBFROGEXE=
TOOLCHAINPREFIX=

usage() {
	echo "usage: ./mk-pkg.sh [options] [target] [fbc-version] [toolchain] [package>]"
	echo ""
	echo "options:"
	echo "   -h, --help        show help"
	echo "   --all             download all packages"
	echo "   --clean           clean all output files"
	echo "   --clean-build     clean only build directory"
	echo "   --keep-build      don't clean build directory before building"
	echo "   --fbc <name>      set name for fbc executable"
	echo "   --fbfrog <name>   set name for fbfrog executable"
	echo "   --prefix <path>   set path for toolchain"
	echo "targets:"
	echo "   win32             build output for win32 x86 target"
	echo "   win64             build output for win64 x86_64 target"
	echo "fbc-version:"
	echo "   fbc-1.10.0        building with fbc version 1.10.0"
	echo "   fbc-1.20.0        building with fbc version 1.20.0"
	echo "toolchain:"
	echo "   winlibs-gcc-9.3.0     building with winlibs gcc-9.3.0 toolchain"
	echo "   mingw-w64-gcc-5.2.0   building with mingw-w64 gcc-5.2.0 toolchain"
	echo "   mingw-w64-gcc-11.2.0  building with mingw-w64 gcc-11.2.0 toolchain"
	echo "package:"
	echo "   none              don't build, but allow --clean-build"
	echo "   fblo              freebasic load out specifics"
	echo "   fbfrog-jayrm      fbfrog (jayrm fork of freebasic/fbfrog)"
	echo "   FBImage-20171102  FBImage version 2017-11-02"
	echo "   libogg-1.3.2      ogg version 1.3.2"
	echo "   libvorbis-1.3.7   vorbis version 1.3.7"
	echo "   libmad-0.15.1b    libmad version 0.15.1b"
	echo "   libdumb-0.9.3     libdumb version 0.9.3"
	echo "   libcsid-jayrm     libcsid (jayrm fork)"
	echo "   fbsound-1.2       fbsound version 1.2"
	echo "   fbpng-3.2.z       fbpng version 3.2.z"
	echo "   libpng-1.6.40     libpng version 1.6.40"
	echo "   pcre-8.45         pcre version 8.45"
	echo "   zlib-1.2.8        zlib version 1.2.8"
	echo "   zlib-1.3          zlib version 1.3"
	echo ""
	exit 1
}

makepackage() {

	export FBFROG=${FBFROGEXE}
	export FBC=${FBCEXE}
	case $FBCTARGET in
	win32)
		SUBSYSTEM=mingw32
		;;
	win64)
		SUBSYSTEM=mingw64
		;;
	*)
		SUBSYTEM=error
		;;
	esac
	echo "Toolchain PATH=${PATH}"
	export AR=${TOOLCHAINPREFIX}/${SUBSYSTEM}/bin/ar.exe
	export CC=${TOOLCHAINPREFIX}/${SUBSYSTEM}/bin/gcc.exe

	./build.sh ${FBCVERSION} ${FBCTARGET} ${TOOLCHAIN} ${FBLOPACKAGE} ${DOCLEAN}
}

# show usage if no arguments
if [ -z "$1" ]; then
	SHOWHELP="yes"
	usage
fi

# parse command line arguments
# first pass, collect options
while [[ $# -gt 0 ]]
do
	arg="$1"
	case $arg in
	--help|-h)
		SHOWHELP="yes"
		;;
	--all|all)
		DOALL="yes"
		FBLOPACKAGE="all"
		;;
	--fbc)
		shift
		FBCEXE="$1"
		;;
	--fbfrog)
		shift
		FBFROGEXE="$1"
		;;
	--prefix)
		shift
		TOOLCHAINPREFIX="$1"
		;;
	win32|win64)
		FBCTARGET="$arg"
		;;
	winlibs-gcc-9.3.0)
		TOOLCHAIN="$arg"
		;;
	winlibs-*)
		echo "invalid winlibs version $arg"
		exit 1
		;;
	mingw-w64-gcc-5.2.0|mingw-w64-gcc-11.2.0)
		TOOLCHAIN="$arg"
		;;
	mingw-*)
		echo "invalid mingw version $arg"
		exit 1
		;;
	fbc-1.10.0|fbc-1.20.0)
		FBCVERSION="$arg"
		;;
	fbc-*)
		echo "invalid fbc version $arg"
		exit 1
		;;
	--clean|-clean|clean)
		DOCLEAN="clean"
		;;
	--clean-build|-clean-build|clean-build)
		DOCLEAN="clean-build"
		;;
	--keep-build|-keep-build|keep-build)
		DOCLEAN="keep-build"
		;;
	none)
		FBLOPACKAGE="$arg"
		;;
	fblo)
		FBLOPACKAGE="$arg"
		;;
	fbfrog-jayrm)
		FBLOPACKAGE="$arg"
		;;
	FBImage-20171102)
		FBLOPACKAGE="$arg"
		;;
	libogg-1.3.2)
		FBLOPACKAGE="$arg"
		;;
	libvorbis-1.3.7)
		FBLOPACKAGE="$arg"
		;;
	libmad-0.15.1b)
		FBLOPACKAGE="$arg"
		;;
	libdumb-0.9.3)
		FBLOPACKAGE="$arg"
		;;
	libcsid-jayrm)
		FBLOPACKAGE="$arg"
		;;
	fbsound-1.2)
		FBLOPACKAGE="$arg"
		;;
	fbpng-3.2.z)
		FBLOPACKAGE="$arg"
		;;
	libpng-1.6.40)
		FBLOPACKAGE="$arg"
		;;
	pcre-8.45)
		FBLOPACKAGE="$arg"
		;;
	zlib-1.2.8|zlib-1.3)
		FBLOPACKAGE="$arg"
		;;
	-*)
		echo "invalid argument $arg"
		exit 1
		;;
	*)
		echo "invalid package $arg"
		exit 1
		;;
	esac

	shift
done

if [ "${SHOWHELP}" = "yes" ]; then
	usage
	exit 0
fi

if [ -z "${TOOLCHAIN}" ]; then
	echo "must specify toolchain"
	exit 1
fi

if [ -z "${FBCVERSION}" ]; then
	echo "must specify fbc version"
	exit 1
fi

if [ -z "${FBCTARGET}" ]; then
	echo "must specify target"
	exit 1
fi

if [ -z "${FBLOPACKAGE}" ]; then
	FBLOPACKAGE="all"
fi

if [ -z "${TOOLCHAINPREFIX}" ]; then
	echo "must specify toolchain prefix"
	exit 1
fi

if [ -z "${FBCEXE}" ]; then
	echo "must specify fbc executable"
	exit 1
fi

if [ -z "${FBFROGEXE}" ]; then
	echo "must specify fbfrog executable"
	exit 1
fi

makepackage

