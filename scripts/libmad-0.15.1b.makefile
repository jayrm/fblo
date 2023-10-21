# makefile for libmad 0.15.1b
#
#

FBLOPACKAGE=libmad-0.15.1b

include ./scripts/common.mk

FBFROG_SCRIPT := ./scripts/$(FBLOPACKAGE).fbfrog
TRANSLATOR    := ./scripts/translator.txt
FBFROGHEADER  := $(SRCDIR)/fbfrog-header.tmp

SRC_LICENSE := $(SRCDIR)/COPYING
DST_LICENSE := $(DOCDIR)/libmad-license.txt

TARGETS := $(DST_LICENSE)
TARGETS += $(INCDIR)/mad/mad.bi
TARGETS += $(LIBDIR)/libmad.a

BI_NEEDS := $(SRCDIR)/mad.h
BI_NEEDS += $(FBFROG_SCRIPT)
BI_NEEDS += $(FBFROGHEADER)
BI_NEEDS += $(SRC_LICENSE)
BI_NEEDS += $(LIBDIR)/libmad.a

LIB_NEEDS := $(SRCDIR)/mad.h
LIB_NEEDS := $(SRCDIR)/config.log
LIB_NEEDS += $(SRCDIR)/Makefile

.phony : all
all: $(TARGETS)

$(FBFROGHEADER) : $(SRCDIR)/mad.h
	$(CMD_HEAD) -n 22 $< > $@
	$(CMD_U2D) $@

$(INCDIR)/mad :
	$(CMD_MKDIR) -p $(INCDIR)/mad

$(INCDIR)/mad/mad.bi : $(BI_NEEDS) | $(INCDIR)/mad
	$(FBFROG) \
		-o $@ \
		-incdir $(SRCDIR) \
		$(FBFROG_SCRIPT) \
		-title $(FBLOPACKAGE) $(FBFROGHEADER) $(TRANSLATOR)

$(SRCDIR)/Makefile \
$(SRCDIR)/config.log &: $(SRCDIR)/configure
	$(CMD_CD) $(SRCDIR) && \
		CC=$(CC) CXX=$(CC) LDFLAGS="-Wl,-no-undefined" \
		./configure --build $(BUILD_TRIPLET)

$(SRCDIR)/.libs/libmad.a : $(LIB_NEEDS)
	$(CMD_CD) $(SRCDIR) && \
		$(CMD_MAKE) CFLAGS="-Wall -O2 -fno-ident" LDFLAGS="-no-undefined"

$(LIBDIR) :
	$(CMD_MKDIR) -p $(LIBDIR)

$(LIBDIR)/libmad.a : $(SRCDIR)/.libs/libmad.a | $(LIBDIR)
	$(CMD_CP) $< $@

$(DOCDIR):
	$(CMD_MKDIR) -p $(DOCDIR)

$(DST_LICENSE) : $(FBFROGHEADER) $(SRC_LICENSE) | $(DOCDIR)
	$(CMD_CAT) $(FBFROGHEADER) $(SRC_LICENSE) > $@
	$(CMD_U2D) $@

.phony : clean
clean: clean-build
	$(CMD_RM) -f $(TARGETS)

.phony : clean-build
clean-build:
	$(CMD_RM) -rf $(SRCDIR)
