# makefile for libogg version 1.3.2
#
#

FBLOPACKAGE=libogg-1.3.2

include ./scripts/common.mk

FBFROG_SCRIPT := ./scripts/$(FBLOPACKAGE).fbfrog
TRANSLATOR    := ./scripts/translator.txt
FBFROGHEADER  := $(SRCDIR)/fbfrog-header.tmp

SRC_LICENSE := $(SRCDIR)/COPYING
DST_LICENSE := $(DOCDIR)/libogg-license.txt

TARGETS := $(DST_LICENSE)
TARGETS += $(INCDIR)/ogg/ogg.bi
TARGETS += $(LIBDIR)/libogg.a

BI_NEEDS := $(SRCDIR)/include/ogg/ogg.h
BI_NEEDS += $(FBFROG_SCRIPT)
BI_NEEDS += $(FBFROGHEADER)
BI_NEEDS += $(SRC_LICENSE)
BI_NEEDS += $(LIBDIR)/libogg.a

LIB_NEEDS := $(SRCDIR)/include/ogg/ogg.h
LIB_NEEDS += $(SRCDIR)/Makefile

.phony : all
all: $(TARGETS)

$(FBFROGHEADER) : $(SRC_LICENSE)
	$(CMD_CP) $< $@
	$(CMD_U2D) $@

$(INCDIR)/ogg :
	$(CMD_MKDIR) -p $(INCDIR)/ogg

$(INCDIR)/ogg/ogg.bi : $(BI_NEEDS)  | $(INCDIR)/ogg
	$(FBFROG) \
		-o $@ \
		-incdir $(SRCDIR)/include \
		$(FBFROG_SCRIPT) \
		-title $(FBLOPACKAGE) $(FBFROGHEADER) $(TRANSLATOR)

$(SRCDIR)/Makefile \
$(SRCDIR)/include/Makefile \
$(SRCDIR)/include/ogg/Makefile \
$(SRCDIR)/config.log : $(SRCDIR)/configure
	$(CMD_CD) $(SRCDIR) && \
		CC=$(CC) CXX=$(CC) \
		./configure --build=$(BUILD_TRIPLET)

$(SRCDIR)/src/.libs/libogg.a : $(LIB_NEEDS)
	$(CMD_CD) $(SRCDIR) && \
		$(CMD_MAKE) CFLAGS="-Wall -O2 -fno-ident"

$(LIBDIR) :
	$(CMD_MKDIR) -p $(LIBDIR)

$(LIBDIR)/libogg.a : $(SRCDIR)/src/.libs/libogg.a | $(LIBDIR)
	$(CMD_CP) $< $@

$(DOCDIR):
	$(CMD_MKDIR) -p $(DOCDIR)

$(DST_LICENSE) : $(SRC_LICENSE) | $(DOCDIR)
	$(CMD_CP) $< $@
	$(CMD_U2D) $@

.phony : clean
clean: clean-build
	$(CMD_RM) -f $(TARGETS)

.phony : clean-build
clean-build:
	$(CMD_RM) -rf $(SRCDIR)
