# makefile for libdumb version 0.9.3
#
#

FBLOPACKAGE=libdumb-0.9.3

include ./scripts/common.mk

FBFROG_SCRIPT := ./scripts/$(FBLOPACKAGE).fbfrog
TRANSLATOR    := ./scripts/translator.txt
FBFROGHEADER  := $(SRCDIR)/fbfrog-header.tmp

SRC_LICENSE := $(SRCDIR)/licence.txt
DST_LICENSE := $(DOCDIR)/libdumb-license.txt

TARGETS := $(DST_LICENSE)
TARGETS += $(INCDIR)/dumb/dumb.bi
TARGETS += $(LIBDIR)/libdumb.a

BI_NEEDS := $(SRCDIR)/include/dumb.h
BI_NEEDS += $(FBFROGHEADER)

LIB_NEEDS := $(SRCDIR)/include/dumb.h

OBJDIR := $(SRCDIR)/obj

CFLAGS := -I$(SRCDIR)/include -O2 -fno-ident

SRCS:=$(addprefix $(SRCDIR)/core/,$(addsuffix .c, atexit duhlen duhtag dumbfile \
	loadduh makeduh rawsig readduh register rendduh rendsig unload ) )
SRCS+=$(addprefix $(SRCDIR)/helpers/,$(addsuffix .c, clickrem memfile resample \
	sampbuf silence stdfile ) )
SRCS+=$(addprefix $(SRCDIR)/it/,$(addsuffix .c, itload itread itload2 itread2 \
	itrender itunload loads3m reads3m loadxm readxm loadmod readmod loads3m2 \
	reads3m2 loadxm2 readxm2 loadmod2 readmod2 xmeffect itorder itmisc ) )

OBJS := $(addprefix $(OBJDIR)/, $(notdir $(patsubst %.c, %.o, $(SRCS))))

.phony : all
all: $(TARGETS)

$(INCDIR)/dumb :
	$(CMD_MKDIR) -p $(INCDIR)/dumb

$(INCDIR)/dumb/dumb.bi : $(BI_NEEDS) | $(INCDIR)/dumb
	$(FBFROG) \
		-o $@ $(SRCDIR)/include/dumb.h \
		$(FBFROG_SCRIPT) \
		-title $(FBLOPACKAGE) $(FBFROGHEADER) $(TRANSLATOR)

$(FBFROGHEADER) : $(SRCDIR)/include/dumb.h
	$(CMD_HEAD) -n 19 $< > $@
	$(CMD_U2D) $@

$(OBJDIR):
	$(CMD_MKDIR) -p $(OBJDIR)

$(OBJDIR)/%.o: $(SRCDIR)/src/core/%.c $(SRCDIR)/include/dumb.h $(SRCDIR)/include/internal/dumb.h | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJDIR)/%.o: $(SRCDIR)/src/helpers/%.c $(SRCDIR)/include/dumb.h | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJDIR)/%.o: $(SRCDIR)/src/it/%.c $(SRCDIR)/include/dumb.h $(SRCDIR)/include/internal/dumb.h | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(LIBDIR):
	$(CMD_MKDIR) -p $(LIBDIR)

$(LIBDIR)/libdumb.a: $(OBJS) $(LIB_NEEDS) | $(LIBDIR)
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
