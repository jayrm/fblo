#!/usr/bin/env bash

set -e

PACKAGEID=
FBCVERSION=
TOOLCHAIN=
TARGET=
SHOWHELP=
DOALL=
DOCLEAN=

usage() {
	echo "usage: ./build.sh [options] <target> <fbc-version> <toolchain> <package>"
	echo ""
	echo "options:"
	echo "   -h, --help        show help"
	echo "   --all             download all packages"
	echo "   --clean           clean all output files"
	echo "   --clean-build     clean only build directory"
	echo "   --keep-build      don't clean build directory before building"
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
	echo ""
	exit 1
}

download() {
	srcfile="$1"
	url="$2/$srcFile"
	dstfile="$3"

	if [ -f "./cache/$dstfile" ]; then
		echo "cached      $dstfile"
	else
		echo "downloading $srcfile to $dstfile"
		#if ! curl -L -o "./cache/$dstfile" "$url"; then
		if ! wget -O "./cache/$dstfile" "$url"; then
			echo "download failed"
			rm -f "./cache/$dstfile"
			exit 1
		fi
	fi
}

download_source() {
	srcSite="$1"
	srcFile="$2"
	dstFile="$3"

	mkdir -p ./cache
	download "$srcFile" $srcSite "$dstFile"
}

extract_package() {
	package="./cache/$1"
	blddir="./build"
	outdir="$blddir/$2"

	if [ -d "$outdir" ]; then
		# rm -rf $outdir
		echo "cached      $outdir"
		return
	fi

	if [ ! -d "$outdir" ]; then
		mkdir -p "$blddir"
		echo "Extracting $package to $blddir"

		case $srcfile in
		*.zip)
			unzip -q "$package" -d "$blddir"
			;;
		*.tar.xz)
			tar -xf "$package" -C "$blddir"
			;;
		*.7z)
			7z x "$package" -y -bd -o$blddir > nul
			;;
		*)
			echo "unsupported format $package"
			exit 1
			;;
		esac
	fi
}

domake() {
	mkfile="$1"
	mkgoal="$2"

	case ${mkgoal} in
	clean)
		echo "cleaning ${arg} for ${FBCVERSION}, ${TARGET}-${TOOLCHAIN}"
		;;
	clean-build)
		echo "cleaning ${arg} build directory"
		;;
	keep-build)
		echo "warning: not cleaning ${arg} before building ${FBCVERSION}, ${TARGET}-${TOOLCHAIN}"
		mkgoal="all"
		;;
	esac

	make -f "./scripts/${mkfile}" $mkgoal \
		TARGET=${TARGET} \
		FBCVERSION=${FBCVERSION} TOOLCHAIN=${TOOLCHAIN} \
		FBC=${FBC} FBFROG=${FBFROG}
}

dobuild () {
	arg="$1"
	mkfile=${arg}.makefile

	case ${DOCLEAN} in
	clean)
		domake ${mkfile} ${DOCLEAN}
		return
		;;
	clean-build|keep-build)
		domake ${mkfile} ${DOCLEAN}
		;;
	esac

	echo "building ${arg} for ${FBCVERSION}, ${TARGET}-${TOOLCHAIN}"

	case $arg in
	*)
		echo "unrecognized package $1"
		exit 1
		;;
	esac

	domake ${mkfile} all
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

if [ -z "${TARGET}" ]; then
	echo "must specify target"
	exit 1
fi

if [ -z "${TOOLCHAIN}" ]; then
	echo "must specify toolchain"
	exit 1
fi

if [ -z "${FBCVERSION}" ]; then
	echo "must specify fbc version"
	exit 1
fi

if [ -z "${PACKAGEID}" ]; then
	echo "must specify package name (or all)"
	exit 1
fi

if [ "${DOALL}" = "yes" ]; then

	# list all packages here

	if [ "${DOCLEAN}" = "build" ]; then
		echo "removing build directory"
		rm -rf build
		rm -rf output/${FBCVERSION}/${TOOLCHAIN}
	fi
else
	dobuild "${PACKAGEID}"
fi
