# makefile for fblo specifics
#
#

FBLOPACKAGE=fblo-$(FBLO_VERSION)

include ./scripts/common.mk

SRC_LICENSE := $(TOPDIR)/LICENSE.txt
DST_LICENSE := $(DOCDIR)/fblo-license.txt

SRC_README := README.md
DST_README := $(ROOTDIR)/fblo-readme.txt

TARGETS := $(DST_README)
TARGETS += $(DST_LICENSE)

.phony : all
all: $(TARGETS)

$(ROOTDIR):
	$(CMD_MKDIR) -p $(ROOTDIR)

$(DST_README) : $(SRC_README) | $(ROOTDIR)
	$(CMD_CP) $< $@

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
