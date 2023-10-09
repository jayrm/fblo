#!/usr/bin/env bash

set -e

PACKAGEID=
FBCVERSION=
TOOLCHAIN=
TARGET=
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
	echo "   jayrm-fbfrog      jayrm fork of fbfrog version"
	echo "   libpng-1.6.40     libpng version 1.6.40"
	echo "   zlib-1.3          zlib version 1.3"
	echo ""
	exit 1
}

makepackage() {

	export FBFROG=${FBFROGEXE}
	export FBC=${FBCEXE}
	case $TARGET in
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
	export AR=${TOOLCHAINPREFIX}/${SUBSYSTEM}/bin/ar.exe
	export CC=${TOOLCHAINPREFIX}/${SUBSYSTEM}/bin/gcc.exe

	./build.sh ${FBCVERSION} ${TARGET} ${TOOLCHAIN} ${PACKAGEID} ${DOCLEAN}
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
		PACKAGEID="all"
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
		TARGET="$arg"
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
		PACKAGEID="$arg"
		;;
	jayrm-fbfrog)
		PACKAGEID="$arg"
		;;
	libpng-1.6.40)
		PACKAGEID="$arg"
		;;
	zlib-1.3)
		PACKAGEID="$arg"
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

if [ -z "${TARGET}" ]; then
	echo "must specify target"
	exit 1
fi

if [ -z "${PACKAGEID}" ]; then
	PACKAGEID="all"
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

