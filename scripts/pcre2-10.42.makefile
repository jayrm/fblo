# makefile for pcre2 version 10.42
#
#

FBLOPACKAGE=pcre2-10.42

include ./scripts/common.mk

FBFROG_SCRIPT := ./scripts/$(FBLOPACKAGE).fbfrog
TRANSLATOR    := ./scripts/translator.txt
FBFROGHEADER1 := $(SRCDIR)/fbfrog-header1.tmp
FBFROGHEADER2 := $(SRCDIR)/fbfrog-header2.tmp

SRC_LICENSE := $(SRCDIR)/LICENCE
DST_LICENSE := $(DOCDIR)/pcre2-license.txt

SRC_STATIC_LIBS := \
$(SRCDIR)/.libs/libpcre2-8.a \
$(SRCDIR)/.libs/libpcre2-16.a \
$(SRCDIR)/.libs/libpcre2-32.a \
$(SRCDIR)/.libs/libpcre2-posix.a

DST_STATIC_LIBS := \
$(LIBDIR)/libpcre2-8.a \
$(LIBDIR)/libpcre2-16.a \
$(LIBDIR)/libpcre2-32.a \
$(LIBDIR)/libpcre2-posix.a

TARGETS := $(DST_LICENSE)
TARGETS += $(INCDIR)/pcre2.bi
TARGETS += $(INCDIR)/pcre2posix.bi
TARGETS += $(DST_STATIC_LIBS)

BI_NEEDS := $(SRCDIR)/src/pcre2.h
BI_NEEDS += $(SRCDIR)/src/pcre2posix.h
BI_NEEDS += $(FBFROG_SCRIPT)
BI_NEEDS += $(FBFROGHEADER1)
BI_NEEDS += $(FBFROGHEADER2)
BI_NEEDS += $(SRC_LICENSE)
BI_NEEDS += $(SRC_STATIC_LIBS)

LIB_NEEDS := $(SRCDIR)/src/pcre2.h
LIB_NEEDS += $(SRCDIR)/Makefile

.phony : all
all: $(TARGETS)

$(FBFROGHEADER1) : $(SRCDIR)/src/pcre2.h
	$(CMD_HEAD) -n 38 $< > $@
	$(CMD_U2D) $@

$(FBFROGHEADER2) : $(SRCDIR)/src/pcre2posix.h
	$(CMD_HEAD) -n 42 $< > $@
	$(CMD_U2D) $@

$(INCDIR) :
	$(CMD_MKDIR) -p $(INCDIR)

$(INCDIR)/pcre2.bi : $(BI_NEEDS)  | $(INCDIR)
	$(FBFROG) $(SRCDIR)/src/pcre2.h \
		-o $@ \
		-incdir $(SRCDIR) \
		$(FBFROG_SCRIPT) \
		-title $(FBLOPACKAGE) $(FBFROGHEADER1) $(TRANSLATOR) \
		-selectversion \
		-case 8  -inclib pcre \
		-case 16 -inclib pcre16 \
		-case 32 -inclib pcre32 \
		-endselect

$(INCDIR)/pcre2posix.bi : $(BI_NEEDS)  | $(INCDIR)
	$(FBFROG) $(SRCDIR)/src/pcre2posix.h \
		-o $@ \
		-incdir $(SRCDIR) \
		$(FBFROG_SCRIPT) \
		-title $(FBLOPACKAGE) $(FBFROGHEADER2) $(TRANSLATOR) \
		-inclib pcreposix

$(SRCDIR)/config.h \
$(SRCDIR)/src/pcre2.h \
$(SRCDIR)/Makefile \
$(SRCDIR)/config.log : $(SRCDIR)/configure
	$(CMD_CD) $(SRCDIR) && \
		CC=$(CC) CXX=$(CC) \
		./configure --build=$(BUILD_TRIPLET) \
		--enable-shared=yes \
		--enable-static=yes \
		--enable-newline-is-any \
		--enable-pcre2-8 --enable-pcre2-16 --enable-pcre2-32

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

