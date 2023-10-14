# makefile for fbfrog (jayrm fork)
# - build fbfrog.exe
#

FBLOPACKAGE=jayrm-fbfrog

include ./scripts/common.mk

TARGETS := $(DOCDIR)/fbfrog-license.txt

# only build fbfrog.exe for 32-bit, it will work on 64-bit too
ifeq ($(FBCTARGET),win32)
	TARGETS += $(ROOTDIR)/fbfrog.exe
endif

.phony : all
all: $(TARGETS)

$(ROOTDIR)/fbfrog.exe : $(SRCDIR)/fbfrog.exe
	$(QUIET_MKDIR) -p $(DOCDIR)
	$(QUIET_CP) $< $@

$(DOCDIR)/fbfrog-license.txt : $(SRCDIR)/license.txt
	$(QUIET_MKDIR) -p $(DOCDIR)
	$(QUIET_CP) $< $@

$(SRCDIR)/fbfrog.exe : $(SRCDIR)/makefile
	$(QUIET_MKDIR) -p $(TOPDIR)/$(ROOTDIR)
	cd $(SRCDIR) && \
		GCC=${CC} make ENABLE_STANDALONE=1 && \
		make ENABLE_STANDALONE=1 install prefix=$(TOPDIR)/$(ROOTDIR)

.phony : clean
clean: clean-build
	$(QUIET_RM) -rf $(TARGETS) $(ROOTDIR)/fbfrog

.phony : clean-build
clean-build:
	$(QUIET_RM) -rf $(SRCDIR)
