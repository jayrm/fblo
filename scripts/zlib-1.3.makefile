# makefile for zlib version 1.3
# - build zlib.bi header
# - build libz.a static library

FBLOPACKAGE=zlib-1.3

include ./scripts/common.mk

FBFROG_SCRIPT := ./scripts/$(FBLOPACKAGE).fbfrog
TRANSLATOR    := ./scripts/translator.txt
FBFROGHEADER  := $(SRCDIR)/fbfrog-header.tmp

TARGETS := $(LIBDIR)/libz.a
TARGETS += $(INCDIR)/zlib.bi
TARGETS += $(DOCDIR)/zlib-license.txt

.phony : all
all: $(TARGETS)

$(INCDIR)/zlib.bi : $(SRCDIR)/zlib.h $(FBFROG_SCRIPT) $(DOCDIR)/zlib-license.txt $(FBFROGHEADER)
	$(QUIET_MKDIR) -p $(INCDIR)
	# $(QUIET_FBFROG) $^ -title $(FBLOPACKAGE) $(FBFROGHEADER) $(TRANSLATOR) -o $@
	$(QUIET_FBFROG) $(FBFROG_SCRIPT) -o $@ $(SRCDIR)/zlib.h -title $(FBLOPACKAGE) $(FBFROGHEADER) $(TRANSLATOR)

$(FBFROGHEADER) : $(DOCDIR)/zlib-license.txt
	$(QUIET_ECHO) "  zlib.h" > $@
	$(QUIET_ECHO) "" >> $@
	$(QUIET_CAT)  $^ >> $@

$(DOCDIR)/zlib-license.txt : $(SRCDIR)/LICENSE
	$(QUIET_MKDIR) -p $(DOCDIR)
	$(QUIET_CP) $< $@

$(SRCDIR)/configure.log : $(SRCDIR)/configure
	cd $(SRCDIR) && \
		CFLAGS="-O2 -fno-ident" \
		./configure

$(SRCDIR)/libz.a : $(SRCDIR)/configure.log $(SRCDIR)/Makefile
	cd $(SRCDIR) && make libz.a

$(LIBDIR)/libz.a : $(SRCDIR)/libz.a
	$(QUIET_MKDIR) -p $(LIBDIR)
	$(QUIET_CP) $< $@

.phony : clean
clean: clean-build
	$(QUIET_RM) -rf $(TARGETS)

.phony : clean-build
clean-build:
	$(QUIET_RM) -rf $(SRCDIR)
