# makefile for fbpng version 3.2.z
# - build static library
# - copy include files

FBLOPACKAGE=fbpng-3.2.z

include ./scripts/common.mk

ZLIBDIR := $(TOPDIR)/$(LIBDIR)

SRC_LICENSE := $(SRCDIR)/doc/license.txt
DST_LICENSE := $(DOCDIR)/fbpng-license.txt

BI_FILES := fbpng.bi
BI_FILES += fbmld.bi
BI_FILES += fbpng_gfxlib2.bi
BI_FILES += fbpng_opengl.bi
BI_FILES += png_image.bi

SRC_BI_FILES := $(addprefix $(SRCDIR)/inc/,$(BI_FILES))
INC_BI_FILES := $(addprefix $(INCDIR)/fbpng/,$(BI_FILES))

TARGETS := $(DST_LICENSE)
TARGETS += $(INC_BI_FILES)
TARGETS += $(LIBDIR)/libfbpng.a

FBCFLAGS :=  -O 2 -Wc -fno-ident

.phony : all
all: $(TARGETS) $(INCDIR)

$(INCDIR)/fbpng :
	$(CMD_MKDIR) -p $(INCDIR)/fbpng

$(INC_BI_FILES) &: $(SRC_BI_FILES) $(SRCDIR)/libfbpng.a | $(INCDIR)/fbpng
	$(CMD_CP) -t $(INCDIR)/fbpng $(SRC_BI_FILES)
	$(CMD_U2D) $(INC_BI_FILES)

$(SRCDIR)/libfbpng.a :
	$(CMD_CD) $(SRCDIR) && GCC=$(CC) $(FBC) $(FBCFLAGS) -lib -x libfbpng.a src/*.bas -i inc

$(LIBDIR) :
	$(CMD_MKDIR) -p $(LIBDIR)

$(LIBDIR)/libfbpng.a : $(SRCDIR)/libfbpng.a | $(LIBDIR)
	$(CMD_CP) $< $@

$(DOCDIR) :
	$(CMD_MKDIR) -p $(DOCDIR)

$(DST_LICENSE) : $(SRC_LICENSE) $(SRCDIR)/libfbpng.a | $(DOCDIR)
	$(CMD_CP) $< $@
	$(CMD_U2D) $@

.phony : clean
clean: clean-build
	$(CMD_RM) -rf $(TARGETS)

.phony : clean-build
clean-build:
	$(CMD_RM) -rf $(SRCDIR)
