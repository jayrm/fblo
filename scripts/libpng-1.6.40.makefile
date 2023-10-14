# makefile for libpng version 1.6.40
# - translate libpng.h header to freebasic png16.bi header
# - build static library

FBLOPACKAGE=libpng-1.6.40

include ./scripts/common.mk

FBFROG_SCRIPT := ./scripts/$(FBLOPACKAGE).fbfrog
TRANSLATOR    := ./scripts/translator.txt
FBFROGHEADER  := $(SRCDIR)/fbfrog-header.tmp

ZLIBDIR := $(TOPDIR)/build/zlib-1.3

TARGETS := $(LIBDIR)/libpng16.a
TARGETS += $(INCDIR)/png16.bi
TARGETS += $(DOCDIR)/libpng-license.txt

.phony : all
all: $(TARGETS)

$(INCDIR)/png16.bi : $(SRCDIR)/png.h $(FBFROG_SCRIPT) $(DOCDIR)/libpng-license.txt $(FBFROGHEADER)
	$(QUIET_MKDIR) -p $(INCDIR)
	$(QUIET_FBFROG) -incdir $(ZLIBDIR) \
		$(FBFROG_SCRIPT) -o $@ $(SRCDIR)/png.h \
		-title $(FBLOPACKAGE) $(FBFROGHEADER) $(TRANSLATOR)

$(FBFROGHEADER) : $(DOCDIR)/libpng-license.txt
	$(QUIET_ECHO) "  png.h" > $@
	$(QUIET_ECHO) "" >> $@
	$(QUIET_CAT)  $^ >> $@

$(DOCDIR)/libpng-license.txt : $(SRCDIR)/LICENSE
	$(QUIET_MKDIR) -p $(DOCDIR)
	$(QUIET_CP) $< $@

$(SRCDIR)/config.log : $(SRCDIR)/configure
	cd $(SRCDIR) && \
		CPPFLAGS="-I$(ZLIBDIR)" \
		CFLAGS="-O2 -fno-ident" \
		LDFLAGS="-L$(ZLIBDIR)" \
		./configure

$(SRCDIR)/.libs/libpng16.a : $(SRCDIR)/config.log $(SRCDIR)/Makefile
	cd $(SRCDIR) \
		&& make libpng16.la \
		CPPFLAGS="-I$(ZLIBDIR)" \
		LDFLAGS="-L$(ZLIBDIR)"

$(LIBDIR)/libpng16.a : $(SRCDIR)/.libs/libpng16.a
	$(QUIET_MKDIR) -p $(LIBDIR)
	$(QUIET_CP) $< $@

.phony : clean
clean: clean-build
	$(QUIET_RM) -rf $(TARGETS)

.phony : clean-build
clean-build:
	$(QUIET_RM) -rf $(SRCDIR)
