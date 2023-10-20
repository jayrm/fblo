# makefile for libpng version 1.6.40
# - translate png.h header to freebasic png16.bi header
# - build libpn16.a static library
#
# Doing some tricky stuff to both auto translate the header and generate the lib
# fbc's supporting headers (like unistd.bi) are not fully completed so
# generating the header after ./configure will fail (currently).
# instead make a copy of the unconfigured header pnglibconf.h and use that to
# translate the header, but also allow configuration to build the static lib
# by running the ./configure && make.

FBLOPACKAGE=libpng-1.6.40

include ./scripts/common.mk

FBFROG_SCRIPT := ./scripts/$(FBLOPACKAGE).fbfrog
TRANSLATOR    := ./scripts/translator.txt
FBFROGHEADER  := $(SRCDIR)/fbfrog-header.tmp

ZINCDIR := $(TOPDIR)/build/zlib-1.3
ZLIBDIR := $(TOPDIR)/$(LIBDIR)

TARGETS := $(DOCDIR)/libpng-license.txt
TARGETS += $(INCDIR)/png16.bi
TARGETS += $(LIBDIR)/libpng16.a

BI_NEEDS := $(SRCDIR)/png.h
BI_NEEDS += $(FBFROG_SCRIPT)
BI_NEEDS += $(DOCDIR)/libpng-license.txt
BI_NEEDS += $(FBFROGHEADER)
BI_NEEDS += $(SRCDIR)/pnglibconf.h.original
BI_NEEDS += $(SRCDIR)/scripts/pnglibconf.h.prebuilt

LIB_NEEDS := $(SRCDIR)/png.h
LIB_NEEDS += $(SRCDIR)/pnglibconf.h.configured
LIB_NEEDS += $(SRCDIR)/Makefile

.phony : all
all: $(TARGETS)

$(INCDIR) :
	$(CMD_MKDIR) -p $(INCDIR)

$(INCDIR)/png16.bi :  $(BI_NEEDS) | $(INCDIR)
	$(CMD_CP) $(SRCDIR)/pnglibconf.h.original $(SRCDIR)/pnglibconf.h
	$(FBFROG) \
		-o $@ $(SRCDIR)/png.h \
		-incdir $(ZINCDIR) \
		$(FBFROG_SCRIPT) \
		-title $(FBLOPACKAGE) $(FBFROGHEADER) $(TRANSLATOR)

$(FBFROGHEADER) : $(SRCDIR)/png.h
	$(CMD_HEAD) -n 170 $< > $@
	$(CMD_U2D) $@

$(DOCDIR) :
	$(CMD_MKDIR) -p $(DOCDIR)

$(DOCDIR)/libpng-license.txt : $(SRCDIR)/LICENSE | $(DOCDIR)
	$(CMD_CP) $< $@
	$(CMD_U2D) $@

$(SRCDIR)/pnglibconf.h.original : $(SRCDIR)/scripts/pnglibconf.h.prebuilt
	$(CMD_CP) -n $< $@

$(SRCDIR)/pnglibconf.h.configured : $(SRCDIR)/config.log
	$(CMD_CP) $(SRCDIR)/pnglibconf.h $@

$(SRCDIR)/Makefile \
$(SRCDIR)/config.log : $(SRCDIR)/configure $(SRCDIR)/pnglibconf.h.original | $(INCDIR)/png16.bi
	$(CMD_CP) $(SRCDIR)/pnglibconf.h.original $(SRCDIR)/pnglibconf.h
	$(CMD_CD) $(SRCDIR) && \
		CPPFLAGS="-I$(ZINCDIR)" \
		CFLAGS="-O2 -fno-ident" \
		LDFLAGS="-L$(ZLIBDIR)" \
		./configure

$(SRCDIR)/.libs/libpng16.a : $(LIB_NEEDS)
	$(CMD_CD) $(SRCDIR) \
		&& $(CMD_MAKE) libpng16.la \
		CPPFLAGS="-I$(ZINCDIR)" \
		LDFLAGS="-L$(ZLIBDIR)"

$(LIBDIR) :
	$(CMD_MKDIR) -p $(LIBDIR)

$(LIBDIR)/libpng16.a : $(SRCDIR)/.libs/libpng16.a | $(LIBDIR)
	$(CMD_CP) $< $@

.phony : clean
clean: clean-build
	$(CMD_RM) -f $(TARGETS)

.phony : clean-build
clean-build:
	$(CMD_RM) -rf $(SRCDIR)
