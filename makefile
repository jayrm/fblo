# makefile to build distro packages
#
# before running this makefile, need to build all the sources / libraries
# see mk-pkgs.bat, mk-pkg.sh, ./build.sh
#
# FBCVERSION
#    fbc-1.10.0        building with fbc version 1.10.0
#    fbc-1.20.0        building with fbc version 1.20.0
#
# TOOLCHAIN
#    winlibs-gcc-9.3.0     building with winlibs gcc-9.3.0 toolchain
#    mingw-w64-gcc-5.2.0   building with mingw-w64 gcc-5.2.0 toolchain
#    mingw-w64-gcc-11.2.0  building with mingw-w64 gcc-11.2.0 toolchain
#

FBLODISTRO := 1

include ./scripts/common.mk

ifndef FBCVERSION
$(error need FBCVERSION to be set)
endif

ifndef TOOLCHAIN
$(error need TOOLCHAIN to be set)
endif

DSTPREFIX := fblo-${FBLO_VERSION}
DSTDIR    := distros
OUTDIR    := output/$(FBCVERSION)/$(TOOLCHAIN)

SRCFILES  := $(shell $(CMD_FIND) $(OUTDIR) -type f -printf "%p ")

TSTFILES  := $(wildcard tests/*.bas)
TESTEXES  := $(patsubst tests/%.bas,tests/%.exe,$(TSTFILES))

ZIPNAME   := $(DSTPREFIX)-$(FBCVERSION)-$(TOOLCHAIN)

-include config.mk

.phony : all
all: $(DSTDIR)/$(ZIPNAME).7z

$(DSTDIR)/$(ZIPNAME).7z : $(SRCFILES)
	$(CMD_ECHO) "making $(ZIPNAME).7z"
	$(CMD_MKDIR) -p $(DSTDIR)
	$(CMD_RM) -f "$(DSTDIR)/$(ZIPNAME).7z"
	$(CMD_CD) "output/$(FBCVERSION)/$(TOOLCHAIN)" && \
		"$(P7ZIP)" a -r -mx9 -xr!.git "$(ZIPNAME).7z" > /dev/nul
	$(CMD_MV) "output/$(FBCVERSION)/$(TOOLCHAIN)/$(ZIPNAME).7z" "$(DSTDIR)/$(ZIPNAME).7z"

.phony : tests
tests : $(TESTEXES)

tests/%.exe : tests/%.bas
	$(FBC) $< -i $(INCDIR) -p $(LIBDIR) -x $@

.phony : clean-tests
clean-tests:
	$(CMD_RM) -f  $(TESTEXES)

.phony : clean
clean: clean-tests
	$(CMD_RM) -f  "$(DSTDIR)/*.7z"
