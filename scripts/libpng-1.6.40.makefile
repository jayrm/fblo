# makefile for libpng version 1.6.40
# - translate libpng.h header to freebasic png16.bi header
# - build static library

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

.phony : all
all: $(TARGETS)

$(INCDIR) :
	$(QUIET_MKDIR) -p $(INCDIR)

$(INCDIR)/png16.bi : $(SRCDIR)/png.h $(FBFROG_SCRIPT) $(DOCDIR)/libpng-license.txt $(FBFROGHEADER) | $(INCDIR)
	$(QUIET_FBFROG) -incdir $(ZINCDIR) \
		$(FBFROG_SCRIPT) -o $@ $(SRCDIR)/png.h \
		-title $(FBLOPACKAGE) $(FBFROGHEADER) $(TRANSLATOR)

$(FBFROGHEADER) : $(DOCDIR)/libpng-license.txt
	$(QUIET_ECHO) "  png.h" > $@
	$(QUIET_ECHO) "" >> $@
	$(QUIET_CAT)  $^ >> $@

$(DOCDIR) :
	$(QUIET_MKDIR) -p $(DOCDIR)

$(DOCDIR)/libpng-license.txt : $(SRCDIR)/LICENSE | $(DOCDIR)
	$(QUIET_CP) $< $@

$(SRCDIR)/config.log : $(SRCDIR)/configure
	cd $(SRCDIR) && \
		CPPFLAGS="-I$(ZINCDIR)" \
		CFLAGS="-O2 -fno-ident" \
		LDFLAGS="-L$(ZLIBDIR)" \
		./configure

$(SRCDIR)/.libs/libpng16.a : $(SRCDIR)/config.log $(SRCDIR)/Makefile
	cd $(SRCDIR) \
		&& make libpng16.la \
		CPPFLAGS="-I$(ZINCDIR)" \
		LDFLAGS="-L$(ZLIBDIR)"

$(LIBDIR) :
	$(QUIET_MKDIR) -p $(LIBDIR)

$(LIBDIR)/libpng16.a : $(SRCDIR)/.libs/libpng16.a | $(LIBDIR)
	$(QUIET_CP) $< $@

.phony : clean
clean: clean-build
	$(QUIET_RM) -rf $(TARGETS)

.phony : clean-build
clean-build:
	$(QUIET_RM) -rf $(SRCDIR)
