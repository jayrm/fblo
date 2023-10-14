# makefile for cleaning the build directory

FBLOPACKAGE=none

include ./scripts/common.mk

.phony : all
all:

.phony : clean
clean: clean-build
	# $(QUIET_RM) -rf $(TARGETS)

.phony : clean-build
clean-build:
	$(QUIET_RM) -rf $(SRCDIR)
