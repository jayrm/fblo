# makefile for pcre version 8.45
#
#

FBLOPACKAGE=pcre-8.45

include ./scripts/common.mk

FBFROG_SCRIPT := ./scripts/$(FBLOPACKAGE).fbfrog
TRANSLATOR    := ./scripts/translator.txt
FBFROGHEADER1 := $(SRCDIR)/fbfrog-header1.tmp
FBFROGHEADER2 := $(SRCDIR)/fbfrog-header2.tmp

SRC_LICENSE := $(SRCDIR)/LICENCE
DST_LICENSE := $(DOCDIR)/pcre-license.txt

SRC_STATIC_LIBS := \
$(SRCDIR)/.libs/libpcre.a \
$(SRCDIR)/.libs/libpcre16.a \
$(SRCDIR)/.libs/libpcre32.a \
$(SRCDIR)/.libs/libpcreposix.a

DST_STATIC_LIBS := \
$(LIBDIR)/libpcre.a \
$(LIBDIR)/libpcre16.a \
$(LIBDIR)/libpcre32.a \
$(LIBDIR)/libpcreposix.a

TARGETS := $(DST_LICENSE)
TARGETS += $(INCDIR)/pcre.bi
TARGETS += $(INCDIR)/pcreposix.bi
TARGETS += $(DST_STATIC_LIBS)

BI_NEEDS := $(SRCDIR)/pcre.h
BI_NEEDS += $(SRCDIR)/pcreposix.h
BI_NEEDS += $(FBFROG_SCRIPT)
BI_NEEDS += $(FBFROGHEADER1)
BI_NEEDS += $(FBFROGHEADER2)
BI_NEEDS += $(SRC_LICENSE)
BI_NEEDS += $(SRC_STATIC_LIBS)

LIB_NEEDS := $(SRCDIR)/pcre.h
LIB_NEEDS += $(SRCDIR)/Makefile

.phony : all
all: $(TARGETS)

$(FBFROGHEADER1) : $(SRCDIR)/pcre.h
	$(CMD_HEAD) -n 38 $< > $@
	$(CMD_U2D) $@

$(FBFROGHEADER2) : $(SRCDIR)/pcreposix.h
	$(CMD_HEAD) -n  4 $< > $@
	$(CMD_HEAD) -n 42 $< | $(CMD_TAIL) -n 35 >> $@
	$(CMD_U2D) $@

$(INCDIR) :
	$(CMD_MKDIR) -p $(INCDIR)

$(INCDIR)/pcre.bi : $(BI_NEEDS)  | $(INCDIR)
	$(FBFROG) $(SRCDIR)/pcre.h \
		-o $@ \
		-incdir $(SRCDIR) \
		$(FBFROG_SCRIPT) \
		-title $(FBLOPACKAGE) $(FBFROGHEADER1) $(TRANSLATOR) \
		-selectversion \
		-case 8  -inclib pcre \
		-case 16 -inclib pcre16 \
		-case 32 -inclib pcre32 \
		-endselect

$(INCDIR)/pcreposix.bi : $(BI_NEEDS)  | $(INCDIR)
	$(FBFROG) $(SRCDIR)/pcreposix.h \
		-o $@ \
		-incdir $(SRCDIR) \
		$(FBFROG_SCRIPT) \
		-title $(FBLOPACKAGE) $(FBFROGHEADER2) $(TRANSLATOR) \
		-inclib pcreposix

$(SRCDIR)/config.h \
$(SRCDIR)/pcre.h \
$(SRCDIR)/Makefile \
$(SRCDIR)/config.log : $(SRCDIR)/configure
	$(CMD_CD) $(SRCDIR) && \
		CC=$(CC) CXX=$(CC) \
		./configure --build=$(BUILD_TRIPLET) \
		--enable-shared=no \
		--disable-cpp \
		--enable-utf \
		--enable-newline-is-any \
		--enable-pcre16 --enable-pcre32

$(SRC_STATIC_LIBS) : $(LIB_NEEDS)
	$(CMD_CD) $(SRCDIR) && \
		$(CMD_MAKE) CFLAGS="-Wall -O2 -fno-ident"

$(LIBDIR) :
	$(CMD_MKDIR) -p $(LIBDIR)

$(DST_STATIC_LIBS) : $(SRC_STATIC_LIBS) | $(LIBDIR)
	$(CMD_CP) -t $(LIBDIR) $^

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
