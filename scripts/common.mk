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

SRCDIR := build/$(PACKAGE)

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

ifneq ($(TARGET),)
LIBDIR := $(LIBDIR)/$(TARGET)
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
