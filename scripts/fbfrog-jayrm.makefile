# makefile for fbfrog (jayrm fork)
# - build fbfrog.exe
#

FBLOPACKAGE=fbfrog-jayrm

include ./scripts/common.mk

TARGETS := $(DOCDIR)/fbfrog-license.txt

# only build fbfrog.exe for 32-bit, it will work on 64-bit too
ifeq ($(FBCTARGET),win32)
    TARGETS += $(ROOTDIR)/fbfrog.exe
endif

.phony : all
all: $(TARGETS)

$(ROOTDIR) :
	$(CMD_MKDIR) -p $(ROOTDIR)

$(ROOTDIR)/fbfrog.exe : $(SRCDIR)/fbfrog.exe | $(ROOTDIR)
	$(CMD_CP) $< $@

$(DOCDIR) :
	$(CMD_MKDIR) -p $(DOCDIR)

$(DOCDIR)/fbfrog-license.txt : $(SRCDIR)/license.txt | $(DOCDIR)
	$(CMD_CP) $< $@
	$(CMD_U2D) $@

$(TOPDIR)/$(ROOTDIR) :
	$(CMD_MKDIR) -p $(TOPDIR)/$(ROOTDIR)

$(SRCDIR)/fbfrog.exe : $(SRCDIR)/makefile | $(TOPDIR)/$(ROOTDIR)
	$(CMD_CD) $(SRCDIR) && \
		GCC=${CC} $(CMD_MAKE) ENABLE_STANDALONE=1 && \
		$(CMD_MAKE) ENABLE_STANDALONE=1 ENABLE_COMMON_PATHDIV=1 install prefix=$(TOPDIR)/$(ROOTDIR)

.phony : clean
clean: clean-build
	$(CMD_RM) -f $(TARGETS)
	$(CMD_RM) -r $(ROOTDIR)/fbfrog

.phony : clean-build
clean-build:
	$(CMD_RM) -rf $(SRCDIR)
