# makefile for zlib version 1.3
# - build zlib.bi header
# - build libz.a static library
#
# Doing some tricky stuff to both auto translate the header and generate the lib
# fbc's supporting headers (like unistd.bi) are not fully completed so
# generating the header after ./configure will fail (currently).
# instead make a copy of the unconfigured header zconf.h and use that to
# translate the header, but also allow configuration to build the static lib
# by running the ./configure && make.

FBLOPACKAGE=zlib-1.3

include ./scripts/common.mk

FBFROG_SCRIPT := ./scripts/$(FBLOPACKAGE).fbfrog
TRANSLATOR    := ./scripts/translator.txt
FBFROGHEADER  := $(SRCDIR)/fbfrog-header.tmp

SRC_LICENSE   := $(SRCDIR)/LICENSE
DST_LICENSE   := $(DOCDIR)/zlib-license.txt

TARGETS := $(DST_LICENSE)
TARGETS += $(INCDIR)/zlib.bi
TARGETS += $(LIBDIR)/libz.a

BI_NEEDS := $(SRCDIR)/zlib.h
BI_NEEDS += $(SRCDIR)/zconf.h
BI_NEEDS += $(FBFROG_SCRIPT)
BI_NEEDS += $(SRC_LICENSE)
BI_NEEDS += $(FBFROGHEADER)
BI_NEEDS += $(SRCDIR)/zconf.h.original

LIB_NEEDS := $(SRCDIR)/zlib.h
LIB_NEEDS += $(SRCDIR)/zconf.h
LIB_NEEDS += $(SRCDIR)/Makefile

.phony : all
all: $(TARGETS)

$(FBFROGHEADER) : $(SRCDIR)/zlib.h
	$(CMD_HEAD) -n 30 $< > $@
	$(CMD_U2D) $@

$(INCDIR) :
	$(CMD_MKDIR) -p $(INCDIR)

$(INCDIR)/zlib.bi :  $(BI_NEEDS) | $(INCDIR)
	$(CMD_CP) $(SRCDIR)/zconf.h.original $(SRCDIR)/zconf.h
	$(FBFROG) \
		-o $@ \
		$(SRCDIR)/zlib.h \
		$(FBFROG_SCRIPT) \
		-title $(FBLOPACKAGE) $(FBFROGHEADER) $(TRANSLATOR)

$(SRCDIR)/zconf.h.original : $(SRCDIR)/zconf.h.in
	$(CMD_CP) $< $@

$(SRCDIR)/zconf.h.configured : $(SRCDIR)/configure.log
	$(CMD_CP) $(SRCDIR)/zconf.h $@

$(SRCDIR)/Makefile \
$(SRCDIR)/configure.log : $(SRCDIR)/configure $(SRCDIR)/zconf.h.original
	$(CMD_CP) $(SRCDIR)/zconf.h.original $(SRCDIR)/zconf.h
	$(CMD_CD) $(SRCDIR) && \
		CFLAGS="-O2 -fno-ident" \
		./configure

$(SRCDIR)/libz.a : $(LIB_NEEDS)
	$(CMD_CD) $(SRCDIR) && $(CMD_MAKE) libz.a

$(LIBDIR) :
	$(CMD_MKDIR) -p $(LIBDIR)

$(LIBDIR)/libz.a : $(SRCDIR)/libz.a | $(LIBDIR)
	$(CMD_CP) -p $< $@

$(DOCDIR) :
	$(CMD_MKDIR) -p $(DOCDIR)

$(DST_LICENSE) : $(SRC_LICENSE) | $(DOCDIR)
	$(CMD_CP) -p $< $@
	$(CMD_U2D) $@

.phony : clean
clean: clean-build
	$(CMD_RM) -f $(TARGETS)

.phony : clean-build
clean-build:
	$(CMD_RM) -rf $(SRCDIR)
