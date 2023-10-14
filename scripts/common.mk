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
#   DOCDIR        ROOTDIR/FBCVERSION/TOOLCHAIN/doc
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

FBLO_VERSION := 0.3

FBC    := fbc
EXEEXT := $(shell $(FBC) -print x)

ECHO   := echo
CAT    := cat
RM     := rm
CP     := cp
MKDIR  := mkdir
MAKE   := make
FBFROG := fbfrog
P7ZIP  := 7z

FBFROG ?= fbfrog$(EXEEXT)
P7ZIP  ?= 7z$(EXEEXT)

AR     ?= ar
CC     ?= gcc
LD     ?= ld

ifndef V
QUIET_ECHO   := @$(ECHO)
QUIET_CAT    := @$(CAT)
QUIET_RM     := @$(RM)
QUIET_CP     := @$(CP)
QUIET_MKDIR  := @$(MKDIR)
QUIET_MAKE   := @$(MAKE)
QUIET_FBFROG := @$(FBFROG)
QUIET_P7ZIP  := @$(P7ZIP)
endif

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
DOCDIR := doc

ifneq ($(FBCTARGET),)
LIBDIR := $(LIBDIR)/$(FBCTARGET)
endif

ifneq ($(TOOLCHAIN),)
INCDIR := $(TOOLCHAIN)/$(INCDIR)
LIBDIR := $(TOOLCHAIN)/$(LIBDIR)
DOCDIR := $(TOOLCHAIN)/$(DOCDIR)
endif

ifneq ($(FBCVERSION),)
INCDIR := $(FBCVERSION)/$(INCDIR)
LIBDIR := $(FBCVERSION)/$(LIBDIR)
DOCDIR := $(FBCVERSION)/$(DOCDIR)
endif

INCDIR := output/$(INCDIR)
LIBDIR := output/$(LIBDIR)
DOCDIR := output/$(DOCDIR)

.SUFFIXES:

-include config.mk
