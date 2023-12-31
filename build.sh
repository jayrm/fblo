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
	echo "   fblo              freebasic load out specifics"
	echo "   fbfrog-jayrm      fbfrog (jayrm fork of freebasic/fbfrog)"
	echo "   FBImage-20171102  FBImage version 2017-11-02"
	echo "   libogg-1.3.2      libogg version 1.3.2"
	echo "   libvorbis-1.3.7   libvorbis version 1.3.7"
	echo "   libmad-0.15.1b    libmad version 0.15.1b"
	echo "   libdumb-0.9.3     libdumb version 0.9.3"
	echo "   libcsid-jayrm     libcsid (jayrm fork)"
	echo "   fbsound-1.2       fbsound version 1.2 (jayrm fork)"
	echo "   fbpng-3.2.z       fbpng version 3.2.q"
	echo "   libpng-1.6.40     libpng version 1.6.40"
	echo "   pcre-8.45         pcre version 8.45"
	echo "   pcre2-10.42       pcre2 version 10.42"
	echo "   zlib-1.2.8        zlib version 1.2.8"
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
	if [ -z "$3" ]; then
		dstFile="$2"
	else
		dstFile="$3"
	fi

	mkdir -p ./cache
	download "$srcFile" $srcSite "$dstFile"
}

extract_package() {
	# $1 = archive file name
	# $2 = top level directory filename in archive
	# $3 = renamed directory (optional)
	# $4 = forced overwrite

	package="./cache/$1"
	blddir="./build"
	outdir1="$blddir/$2"
	forced="N"
	if [ -z "$3" ]; then
		outdir2="$blddir/$2"
	else
		outdir2="$blddir/$3"
		if [ ! -z "$4" ]; then
			forced="Y"
		fi
	fi

	if [ "$forced" = "N" ]; then
	if [ -d "$outdir2" ]; then
		# rm -rf $outdir2
		echo "cached      $outdir2"
		return
	fi
	fi

	mkdir -p "$blddir"
	echo "Extracting $package to $blddir"

	case $package in
	*.zip)
		unzip -o -q "$package" -d "$blddir"
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
	fblo)
		;;
	fbfrog-jayrm)
		fbfrog_sha1=b3fb44fa35ff772afee1be4fa5ecebeb56fdc262
		download_source https://github.com/jayrm/fbfrog/archive/ ${fbfrog_sha1}.zip fbfrog-${fbfrog_sha1}.zip
		extract_package fbfrog-${fbfrog_sha1}.zip fbfrog-${fbfrog_sha1} fbfrog-jayrm
		;;
	FBImage-20171102)
		download_source https://shiny3d.de/public/libs/ FBImage.zip FBImage-20171102.zip
		extract_package FBImage-20171102.zip FBImage FBImage-20171102
		;;
	libogg-1.3.2)
		download_source https://github.com/xiph/ogg/releases/download/v1.3.2/ libogg-1.3.2.tar.xz
		extract_package libogg-1.3.2.tar.xz libogg-1.3.2
		;;
	libvorbis-1.3.7)
		download_source https://github.com/xiph/vorbis/releases/download/v1.3.7/ libvorbis-1.3.7.tar.xz libvorbis-1.3.7.tar.xz
		extract_package libvorbis-1.3.7.tar.xz libvorbis-1.3.7 libvorbis-1.3.7
		;;
	libmad-0.15.1b)
		download_source https://sourceforge.net/projects/mad/files/libmad/0.15.1b/ libmad-0.15.1b.tar.gz/download libmad-0.15.1b.tar.gz
		extract_package libmad-0.15.1b.tar.gz libmad-0.15.1b
		;;
	libdumb-0.9.3)
		download_source https://sourceforge.net/projects/dumb/files/dumb/0.9.3/ dumb-0.9.3.zip/download libdumb-0.9.3.zip
		extract_package libdumb-0.9.3.zip dumb-0.9.3 libdumb-0.9.3
		;;
	libcsid-jayrm)
		csid_sha1=034e4680fb1d3c999f9c17c38b3e1836ea18abbb
		download_source https://github.com/jayrm/csid/archive/ ${csid_sha1}.zip csid-${csid_sha1}.zip
		extract_package csid-${csid_sha1}.zip csid-${csid_sha1} libcsid-jayrm
		;;
	fbsound-1.2)
		# download_source https://shiny3d.de/public/fbsound/ fbsound-1.2-src.zip fbsound-1.2-src.zip
		# download_source https://shiny3d.de/public/fbsound/ fbsound-1.2.zip fbsound-1.2.zip
		# extract_package fbsound-1.2-src.zip fbsound-1.2-src fbsound-1.2
		# extract_package fbsound-1.2.zip fbsound-1.2 fbsound-1.2 Y
		fbsound_sha1=3a41c93dd5959226f2839fc5be194b07d6ee6d89
		download_source https://github.com/jayrm/fbsound/archive/ ${fbsound_sha1}.zip fbsound-${fbsound_sha1}.zip
		extract_package fbsound-${fbsound_sha1}.zip fbsound-${fbsound_sha1} fbsound-1.2
		;;
	fbpng-3.2.z)
		download_source https://github.com/mudhairless/fbpng/archive/refs/tags/ v3.2.z.zip fbpng-3.2.z.zip
		extract_package fbpng-3.2.z.zip fbpng-3.2.z
		;;
	libpng-1.6.40)
		# download_source http://prdownloads.sourceforge.net/libpng/ lpng1640.zip?download libpng-1.6.40.zip
		download_source https://download.sourceforge.net/libpng/ libpng-1.6.40.tar.xz libpng-1.6.40.tar.xz
		# extract_package libpng-1.6.40.zip lpng1640 libpng-1.6.40
		extract_package libpng-1.6.40.tar.xz libpng-1.6.40
		;;
	pcre-8.45)
		download_source https://sourceforge.net/projects/pcre/files/pcre/8.45/ pcre-8.45.zip/download pcre-8.45.zip
		extract_package pcre-8.45.zip pcre-8.45 pcre-8.45
		;;
	pcre2-10.42)
		download_source https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/ pcre2-10.42.zip
		extract_package pcre2-10.42.zip pcre2-10.42
		;;
	zlib-1.2.8)
		download_source http://zlib.net/fossils/ zlib-1.2.8.tar.gz zlib-1.2.8.tar.gz
		# download_source https://github.com/madler/zlib/archive/refs/tags/ v1.2.8.zip zlib-1.2.8.zip
		extract_package zlib-1.2.8.zip zlib-1.2.8
		;;
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
	pcre2-10.42)
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
	dobuild fblo
	dobuild fbfrog-jayrm
	dobuild zlib-1.3
	dobuild pcre-8.45
	dobuild pcre2-10.42
	dobuild libpng-1.6.40
	dobuild fbpng-3.2.z
	dobuild FBImage-20171102
	dobuild libogg-1.3.2
	dobuild libvorbis-1.3.7
	dobuild libmad-0.15.1b
	dobuild libdumb-0.9.3
	dobuild libcsid-jayrm
	dobuild fbsound-1.2

	if [ "${DOCLEAN}" = "clean-build" ]; then
		echo "removing build directory"
		rm -rf build
	fi

else
	dobuild "${FBLOPACKAGE}"
fi
