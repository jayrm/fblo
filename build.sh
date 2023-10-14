#!/usr/bin/env bash

set -e

FBLOPACKAGE=
FBCVERSION=
TOOLCHAIN=
FBCTARGET=
SHOWHELP=
DOALL=
DOCLEAN=
DODRYRUN=

usage() {
	echo "usage: ./build.sh [options] <target> <fbc-version> <toolchain> <package>"
	echo ""
	echo "options:"
	echo "   -h, --help        show help"
	echo "   --all             download all packages"
	echo "   --clean           clean all output files"
	echo "   --clean-build     clean only build directory"
	echo "   --keep-build      don't clean build directory before building"
	echo "   --dry-run         do everything except the actual build"
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

download() {
	srcfile="$1"
	url="$2$srcFile"
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
	# $1 = archive file name
	# $2 = top level directory filename in archive
	# $3 = renamed directory (optional)

	package="./cache/$1"
	blddir="./build"
	outdir1="$blddir/$2"
	if [ -z "$3" ]; then
		outdir2="$blddir/$2"
	else
		outdir2="$blddir/$3"
	fi

	if [ -d "$outdir2" ]; then
		# rm -rf $outdir2
		echo "cached      $outdir2"
		return
	fi

	mkdir -p "$blddir"
	echo "Extracting $package to $blddir"

	case $package in
	*.zip)
		unzip -q "$package" -d "$blddir"
		;;
	*.tar.xz|*.tar.gz)
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

	if [ "${outdir1}" != "${outdir2}" ]; then
		echo "moving ${outdir1} to ${outdir2}"
		mv "${outdir1}" "${outdir2}"
	fi
}

domake() {
	mkfile="$1"
	mkgoal="$2"

	case ${mkgoal} in
	clean)
		echo "cleaning ${arg} for ${FBCVERSION}, ${FBCTARGET}-${TOOLCHAIN}"
		;;
	clean-build)
		echo "cleaning ${arg} build directory"
		;;
	keep-build)
		echo "warning: not cleaning ${arg} before building ${FBCVERSION}, ${FBCTARGET}-${TOOLCHAIN}"
		mkgoal="all"
		;;
	esac

	make -f "./scripts/${mkfile}" $mkgoal \
		FBCTARGET=${FBCTARGET} \
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

	echo "building ${arg} for ${FBCVERSION}, ${FBCTARGET}-${TOOLCHAIN}"

	case $arg in
	jayrm-fbfrog)
		fbfrog_sha1=03bc64bfae9a85852687548c37180865303e452e
		download_source https://github.com/jayrm/fbfrog/archive/ ${fbfrog_sha1}.zip fbfrog-${fbfrog_sha1}.zip
		extract_package fbfrog-${fbfrog_sha1}.zip fbfrog-${fbfrog_sha1} jayrm-fbfrog
		;;
	libpng-1.6.40)
		# download_source http://prdownloads.sourceforge.net/libpng/ lpng1640.zip?download libpng-1.6.40.zip
		download_source https://download.sourceforge.net/libpng/ libpng-1.6.40.tar.xz libpng-1.6.40.tar.xz
		# extract_package libpng-1.6.40.zip lpng1640 libpng-1.6.40
		extract_package libpng-1.6.40.tar.xz libpng-1.6.40
		;;
#   zlib-1.2.8)
#       download_source https://github.com/madler/zlib/archive/refs/tags/ v1.2.8.zip zlib-1.2.8.zip
#       extract_package zlib-1.2.8.zip zlib-1.2.8
#       ;;
	zlib-1.3)
		# https://github.com/madler/zlib/releases/download/v1.3/zlib13.zip
		download_source https://www.zlib.net/ zlib13.zip zlib-1.3.zip
		extract_package zlib-1.3.zip zlib-1.3
		;;
	*)
		echo "unrecognized package $1"
		exit 1
		;;
	esac

	if [ ! "${DRYRUN}" = "Y" ]; then
		domake ${mkfile} all
	fi
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
	--dry-run|-dry-run|-dry-run)
		DODRYRUN="Y"
		;;
	jayrm-fbfrog)
		FBLOPACKAGE="$arg"
		;;
	libpng-1.6.40)
		FBLOPACKAGE="$arg"
		;;
	zlib-1.3)
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

if [ -z "${FBCTARGET}" ]; then
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

if [ -z "${FBLOPACKAGE}" ]; then
	echo "must specify package name (or all)"
	exit 1
fi

if [ "${DOALL}" = "yes" ]; then

	# list all packages here
	dobuild jayrm-fbfrog
	dobuild zlib-1.3
	dobuild libpng-1.6.40

	if [ "${DOCLEAN}" = "build" ]; then
		echo "removing build directory"
		rm -rf build
		rm -rf output/${FBCVERSION}/${TOOLCHAIN}
	fi
else
	dobuild "${FBLOPACKAGE}"
fi
