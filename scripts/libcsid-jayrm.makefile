# makefile for libcsid (jayrm fork)
#
#

FBLOPACKAGE=libcsid-jayrm

include ./scripts/common.mk

FBFROG_SCRIPT := ./scripts/$(FBLOPACKAGE).fbfrog
TRANSLATOR    := ./scripts/translator.txt
FBFROGHEADER  := $(SRCDIR)/fbfrog-header.tmp

SRC_LICENSE := $(FBFROGHEADER)
DST_LICENSE := $(DOCDIR)/libcsid-license.txt

TARGETS := $(DST_LICENSE)
TARGETS += $(INCDIR)/csid/libcsidlight.bi
TARGETS += $(LIBDIR)/libcsidlight.a

BI_NEEDS := $(SRCDIR)/include/libcsid.h
BI_NEEDS += $(FBFROGHEADER)

LIB_NEEDS := $(SRCDIR)/include/libcsid.h

OBJDIR := $(SRCDIR)/obj

CFLAGS := -I$(SRCDIR)/include -O2 -fno-ident
CFLAGS += -fno-strict-aliasing -frounding-math -fno-math-errno -fwrapv -fno-exceptions -fno-asynchronous-unwind-tables -funwind-tables

SRCS:=$(SRCDIR)/src/libcsidlight.c
OBJS := $(addprefix $(OBJDIR)/, $(notdir $(patsubst %.c, %.o, $(SRCS))))

.phony : all
all: $(TARGETS)

$(INCDIR)/csid :
	$(CMD_MKDIR) -p $(INCDIR)/csid

$(INCDIR)/csid/libcsidlight.bi : $(BI_NEEDS) | $(INCDIR)/csid
	$(FBFROG) \
		-o $@ $(SRCDIR)/include/libcsid.h \
		$(FBFROG_SCRIPT) \
		-title $(FBLOPACKAGE) $(FBFROGHEADER) $(TRANSLATOR)

$(FBFROGHEADER) : $(SRCDIR)/src/libcsidlight.c
	$(CMD_HEAD) -n 6 $< > $@
	$(CMD_U2D) $@

$(OBJDIR):
	$(CMD_MKDIR) -p $(OBJDIR)

$(OBJDIR)/%.o: $(SRCDIR)/src/%.c $(SRCDIR)/include/libcsid.h | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(LIBDIR):
	$(CMD_MKDIR) -p $(LIBDIR)

$(LIBDIR)/libcsidlight.a: $(OBJS) $(LIB_NEEDS) | $(LIBDIR)
	$(AR) rs $@ $^

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
