# make file for libvorbis version 1.3.7
#
#

FBLOPACKAGE=libvorbis-1.3.7

include ./scripts/common.mk

FBFROG_SCRIPT := ./scripts/$(FBLOPACKAGE).fbfrog
TRANSLATOR    := ./scripts/translator.txt
FBFROGHEADER  := $(SRCDIR)/fbfrog-header.tmp

SRC_LICENSE := $(SRCDIR)/COPYING
DST_LICENSE := $(DOCDIR)/vorbis-license.txt

OGGINCDIR := build/libogg-1.3.2/include
OGGLIBDIR := $(TOPDIR)/$(LIBDIR)

TARGETS := $(DST_LICENSE)
TARGETS += $(INCDIR)/vorbis/vorbis.bi
TARGETS += $(INCDIR)/vorbis/vorbisenc.bi
TARGETS += $(INCDIR)/vorbis/vorbisfile.bi
TARGETS += $(LIBDIR)/libvorbis.a
TARGETS += $(LIBDIR)/libvorbisenc.a
TARGETS += $(LIBDIR)/libvorbisfile.a

BI_NEEDS := $(SRCDIR)/include/vorbis/vorbis.h
BI_NEEDS += $(SRCDIR)/include/vorbis/vorbisenc.h
BI_NEEDS += $(SRCDIR)/include/vorbis/vorbisfile.h
BI_NEEDS += $(TOPDIR)/$(OGGINCDIR)/ogg/ogg.h
BI_NEEDS += $(FBFROG_SCRIPT)
BI_NEEDS += $(FBFROGHEADER)
BI_NEEDS += $(SRC_LICENSE)

.phony : all
all: $(TARGETS)

$(FBFROGHEADER) : $(SRC_LICENSE)
	$(CMD_CP) $< $@
	$(CMD_U2D) $@

$(INCDIR)/vorbis :
	$(CMD_MKDIR) -p $(INCDIR)/vorbis

$(INCDIR)/vorbis/vorbis.bi \
$(INCDIR)/vorbis/vorbisenc.bi \
$(INCDIR)/vorbis/vorbisfile.bi \
&: $(BI_NEEDS) | $(INCDIR)/vorbis
	$(FBFROG) \
		-o $(INCDIR) \
		-incdir $(SRCDIR)/include/vorbis \
		-incdir $(OGGINCDIR) \
		$(FBFROG_SCRIPT) \
		-title $(FBLOPACKAGE) $(FBFROGHEADER) $(TRANSLATOR)

$(SRCDIR)/config.log \
$(SRCDIR)/Makefile \
$(SRCDIR)/include/vorbis/vorbis.h \
$(SRCDIR)/include/vorbis/vorbisenc.h \
$(SRCDIR)/include/vorbis/vorbisfile.h \
$(SRCDIR)/lib/.libs/libvorbisfile.a \
$(SRCDIR)/lib/.libs/libvorbisenc.a \
$(SRCDIR)/lib/.libs/libvorbis.a \
&: $(SRCDIR)/configure
	$(CMD_CD) $(SRCDIR) && \
		CC=$(CC) CXX=$(CC) \
		./configure \
			--with-ogg-libraries=$(OGGLIBDIR) \
			--with-ogg-includes=$(TOPDIR)/$(OGGINCDIR) \
			--enable-static \
			--disable-shared \
			--build=$(BUILD_TRIPLET)
	$(CMD_CD) $(SRCDIR) && \
		$(CMD_MAKE) CFLAGS="-Wall -O2 -fno-ident"

$(LIBDIR) :
	$(CMD_MKDIR) -p $(LIBDIR)

$(LIBDIR)/libvorbis.a : $(SRCDIR)/lib/.libs/libvorbis.a | $(LIBDIR)
	$(CMD_CP) $< $@

$(LIBDIR)/libvorbisenc.a : $(SRCDIR)/lib/.libs/libvorbisenc.a | $(LIBDIR)
	$(CMD_CP) $< $@

$(LIBDIR)/libvorbisfile.a : $(SRCDIR)/lib/.libs/libvorbisfile.a | $(LIBDIR)
	$(CMD_CP) $< $@

$(DOCDIR):
	$(CMD_MKDIR) -p $(DOCDIR)

$(DST_LICENSE) : $(FBFROGHEADER) | $(DOCDIR)
	$(CMD_CP) $< $@
	$(CMD_U2D) $@

.phony : clean
clean: clean-build
	$(CMD_RM) -f $(TARGETS)

.phony : clean-build
clean-build:
	$(CMD_RM) -rf $(SRCDIR)
