# makefile for FBImage version 0.0
# - build static libraries
# - copy includes
# - copy license

FBLOPACKAGE=FBImage-20171102

include ./scripts/common.mk

ifeq ($(FBCTARGET),win32)
    LIBNAME=libFBImage-32-static
else ifeq ($(FBCTARGET),win64)
    LIBNAME=libFBImage-64-static
else
    $(error $(FBCTARGET) not supported)
endif

# Sources are in a sub-directory
SRC_SUBDIR := $(addsuffix /FBImage-src,$(SRCDIR))

SRC_LICENSE := $(PATDIR)/FBImage-license.txt
DST_LICENSE := $(DOCDIR)/FBImage-license.txt

TARGETS := $(LIBDIR)/$(LIBNAME).a
TARGETS += $(INCDIR)/FBImage.bi
TARGETS += $(DST_LICENSE)

CSOURCES := FBImage.c
CSOURCES += image_DXT.c
CSOURCES += image_helper.c
CSOURCES += stb_image_aug.c

COBJS := $(patsubst %.c,%.o,$(CSOURCES))
OBJDIR := $(SRC_SUBDIR)/obj

CFLAGS := -O2 -DNDEBUG -DSTB_IMAGE_WRITE_IMPLEMENTATION -fno-ident
CFLAGS += -Wall -Wno-misleading-indentation

VPATH=.

.SUFFIXES:

.phony : all
all: $(TARGETS)

$(INCDIR):
	$(CMD_MKDIR) -p $(INCDIR)

$(INCDIR)/FBImage.bi : $(SRCDIR)/FBImage.bi | $(INCDIR)
	$(CMD_CP) $< $@

$(OBJDIR):
	$(CMD_MKDIR) -p $@

$(OBJDIR)/%.o : $(SRC_SUBDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(LIBDIR) :
	$(CMD_MKDIR) -p $(LIBDIR)

$(LIBDIR)/$(LIBNAME).a : $(addprefix $(OBJDIR)/,$(COBJS)) | $(LIBDIR)
	$(AR) -r $@ $^

$(DOCDIR):
	$(CMD_MKDIR) -p $(DOCDIR)

$(DST_LICENSE) : $(SRC_LICENSE) | $(DOCDIR)
	$(CMD_CP) $< $@

.phony : clean
clean: clean-build
	$(CMD_RM) -rf $(TARGETS)

.phony : clean-build
clean-build:
	$(CMD_RM) -rf $(SRCDIR)
