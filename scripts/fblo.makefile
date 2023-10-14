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

$(DST_README) : $(SRC_README)
	$(QUIET_CP) $< $@

$(DOCDIR):
	$(QUIET_MKDIR) -p $(DOCDIR)

$(DST_LICENSE) : $(SRC_LICENSE) | $(DOCDIR)
	$(QUIET_CP) $< $@

.phony : clean
clean: clean-build
	# $(QUIET_RM) -rf $(TARGETS)

.phony : clean-build
clean-build:
	$(QUIET_RM) -rf $(SRCDIR)
