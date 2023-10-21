# makefile for fbsound version 1.2
#
#

FBLOPACKAGE=fbsound-1.2

include ./scripts/common.mk

SRC_LICENSE := $(SRCDIR)/license.txt
DST_LICENSE := $(DOCDIR)/fbsound-license.txt

# Sources are in a sub-directory
SRC_SUBDIR := $(addsuffix /src,$(SRCDIR))
INC_SUBDIR := $(addsuffix /inc,$(SRCDIR))

SRC_INCLUDES := $(wildcard $(INC_SUBDIR)/fbsound/*.bi)
SRC_BI_FILES := $(wildcard $(INC_SUBDIR)/fbsound/fbs*.bi)
DST_BI_FILES := $(patsubst $(INC_SUBDIR)/fbsound/%,$(INCDIR)/fbsound/%,$(SRC_BI_FILES))

SRC_LIBDIR := $(SRCDIR)/lib/$(FBCTARGET)
SRC_BINDIR := $(SRCDIR)/bin/$(FBCTARGET)

TARGETS := $(DST_LICENSE)
TARGETS += $(DST_INCLUDES)
TARGETS += $(DST_BI_FILES)

STATIC_LIBS := \
    libfbscpu.a \
    libfbsdsp.a \
    libfbsound.a

ifeq ($(FBCTARGET),win32)
    SHARED_LIBS := \
        fbsound-32.dll \
        fbsound-mm-32.dll \
        fbsound-ds-32.dll
else ifeq ($(FBCTARGET),win64)
    SHARED_LIBS := \
        fbsound-64.dll \
        fbsound-mm-64.dll \
        fbsound-ds-64.dll
else
    $(errot TARGET $(FBCTARGET) not supported)
endif

SRC_STATIC_LIBS := $(addprefix $(SRC_LIBDIR)/,$(STATIC_LIBS))
DST_STATIC_LIBS := $(addprefix $(LIBDIR)/,$(STATIC_LIBS))

SRC_SHARED_LIBS := $(addprefix $(SRC_BINDIR)/,$(SHARED_LIBS))
DST_SHARED_LIBS := $(addprefix $(BINDIR)/,$(SHARED_LIBS))

.phony : all
all: $(TARGETS) $(DST_STATIC_LIBS) $(DST_SHARED_LIBS)

$(SRC_STATIC_LIBS) :
	cd $(SRCDIR) && \
		GCC=$(CC) \
		FBCFLAGS="-i $(TOPDIR)/$(INCDIR) -p $(TOPDIR)/$(LIBDIR)" \
		$(CMD_MAKE) TARGET=$(FBCTARGET)

$(SRC_SHARED_LIBS) :
	cd $(SRCDIR) && \
		GCC=$(CC) \
		FBCFLAGS="-i $(TOPDIR)/$(INCDIR) -p $(TOPDIR)/$(LIBDIR)" \
		$(CMD_MAKE) TARGET=$(FBCTARGET) SHARED=1

$(LIBDIR):
	$(CMD_MKDIR) -p $(LIBDIR)

$(DST_STATIC_LIBS) : $(SRC_STATIC_LIBS) | $(LIBDIR)
	$(CMD_CP) -t $(LIBDIR) $(SRC_STATIC_LIBS)

$(BINDIR):
	$(CMD_MKDIR) -p $(BINDIR)

$(DST_SHARED_LIBS) : $(SRC_SHARED_LIBS) | $(BINDIR)
	$(CMD_CP) -t $(BINDIR) $(SRC_SHARED_LIBS)

$(INCDIR)/fbsound:
	$(CMD_MKDIR) -p $(INCDIR)/fbsound

$(DST_BI_FILES) : $(SRC_BI_FILES) | $(INCDIR)/fbsound
	$(CMD_CP) -t $(INCDIR)/fbsound $(SRC_BI_FILES)
	$(CMD_U2D) $(SRC_BI_FILES)

$(DOCDIR):
	$(CMD_MKDIR) -p $(DOCDIR)

$(DST_LICENSE) : $(SRC_LICENSE) | $(DOCDIR)
	$(CMD_CP) $< $@
	$(CMD_U2D) $(DST_LICENSE)

.phony : clean
clean: clean-build
	$(CMD_RM) -rf $(TARGETS)

.phony : clean-build
clean-build:
	$(CMD_RM) -rf $(SRCDIR)

