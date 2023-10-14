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

SRCFILES  := $(shell find $(OUTDIR) -type f -printf "%p ")

ZIPNAME   := $(DSTPREFIX)-$(FBCVERSION)-$(TOOLCHAIN)

-include config.mk

.phony : all
all: $(DSTDIR)/$(ZIPNAME).7z

$(DSTDIR)/$(ZIPNAME).7z : $(SRCFILES)
	$(QUIET_ECHO) "making $(ZIPNAME).7z"
	$(QUIET_MKDIR) -p $(DSTDIR)
	$(QUIET_RM) -f "$(DSTDIR)/$(ZIPNAME).7z"
	@cd "output/$(FBCVERSION)/$(TOOLCHAIN)" && \
		"$(P7ZIP)" a -r "$(ZIPNAME).7z" > /dev/nul
	@mv "output/$(FBCVERSION)/$(TOOLCHAIN)/$(ZIPNAME).7z" "$(DSTDIR)/$(ZIPNAME).7z"

.phony : clean
clean:
	$(QUIET_RM) -f  "$(DSTDIR)/*.7z"
