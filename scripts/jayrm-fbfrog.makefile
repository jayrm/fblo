# makefile for fbfrog (jayrm fork)
# - build fbfrog.exe

PACKAGE=jayrm-fbfrog

include ./scripts/common.mk

TARGETS := $(ROOTDIR)/fbfrog.exe
TARGETS += $(DOCDIR)/fbfrog-license.txt

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
