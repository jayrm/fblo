# Options:
#   FBLODISTRO    Required to be set if we are building a distro
#   FBLOPACKAGE   Required if we are building a package
#
# Paths:
#   TOPDIR        the top level directory where ./build.sh was invoked
#   SRCDIR        path to the extracted package relative to TOPDIR
#   PATDIR        path to patch directory relative to TOPDIR
#
# Target and Target Paths:
#   FBCTARGET     target platform (win32, win64)
#   FBCVERSION    fbc version for distro: fbc-1.10.0, fbc-1.20.0, etc
#   TOOLCHAIN     winlibs-gcc-9.3.0, mingw-w64-gcc-11.2.0, etc
#   ROOTDIR       ./output
#   INCDIR        ROOTDIR/FBCVERSION/TOOLCHAIN/inc
#   LIBDIR        ROOTDIR/FBCVERSION/TOOLCHAIN/lib/FBCTARGET
#   BINDIR        ROOTDIR/FBCVERSION/TOOLCHAIN/bin/TARGET
#   DOCDIR        ROOTDIR/FBCVERSION/TOOLCHAIN/doc
#   BUILD_TRIPLET i686-w64-mingw32|x86_64-w64-mingw32
#
# Programs:
#   FBC           fbc to use for building fbc sources
#   EXEEXT        default executable extension expected on target platform
#   FBFROG        path to fbfrog to use for translating C headers
#   P7ZIP         path to 7-zip archive utility
#
# Information:
#   FBLO_VERSION  some version text to track builds of the distro
#

TOPDIR=$(shell pwd)

FBLO_VERSION := 0.4

FBC    := fbc
EXEEXT := $(shell $(FBC) -print x)

CMD_ECHO   := echo
CMD_CAT    := cat
CMD_RM     := rm
CMD_CP     := cp
CMD_MV     := mv
CMD_CD     := cd
CMD_MKDIR  := mkdir
CMD_HEAD   := head
CMD_U2D    := unix2dos
CMD_FIND   := find

CMD_MAKE   := make

FBFROG ?= fbfrog$(EXEEXT)
P7ZIP  ?= 7z$(EXEEXT)

AR     ?= ar
CC     ?= gcc
LD     ?= ld

ifeq ($(FBLOPACKAGE),)
ifeq ($(FBLODISTRO),)
$(error at least either FBLOPACKAGE or FBLODISTRO must be set)
endif
endif

ifneq ($(FBLOPACKAGE),)
PATDIR := patch/$(FBLOPACKAGE)
SRCDIR := build/$(FBLOPACKAGE)
endif

ROOTDIR := output
ifneq ($(FBCVERSION),)
ROOTDIR := $(ROOTDIR)/$(FBCVERSION)
endif
ifneq ($(TOOLCHAIN),)
ROOTDIR := $(ROOTDIR)/$(TOOLCHAIN)
endif

INCDIR := inc
LIBDIR := lib
BINDIR := bin
DOCDIR := doc

ifneq ($(FBCTARGET),)
LIBDIR := $(LIBDIR)/$(FBCTARGET)
BINDIR := $(BINDIR)/$(FBCTARGET)
endif

ifneq ($(TOOLCHAIN),)
INCDIR := $(TOOLCHAIN)/$(INCDIR)
LIBDIR := $(TOOLCHAIN)/$(LIBDIR)
BINDIR := $(TOOLCHAIN)/$(BINDIR)
DOCDIR := $(TOOLCHAIN)/$(DOCDIR)
endif

ifneq ($(FBCVERSION),)
INCDIR := $(FBCVERSION)/$(INCDIR)
LIBDIR := $(FBCVERSION)/$(LIBDIR)
BINDIR := $(FBCVERSION)/$(BINDIR)
DOCDIR := $(FBCVERSION)/$(DOCDIR)
endif

INCDIR := output/$(INCDIR)
LIBDIR := output/$(LIBDIR)
BINDIR := output/$(BINDIR)
DOCDIR := output/$(DOCDIR)

ifneq ($(FBLOPACKAGE),)
ifeq ($(FBCTARGET),win32)
BUILD_TRIPLET := i686-w64-mingw32
else ifeq ($(FBCTARGET),win64)
BUILD_TRIPLET := x86_64-w64-mingw32
else
BUILD_TRIPLET := unknown-unknown-unknown
$(error $(FBCTARGET) not supported)
endif
endif

.SUFFIXES:

-include config.mk
