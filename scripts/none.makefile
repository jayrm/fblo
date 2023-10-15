# makefile for cleaning the build directory

FBLOPACKAGE=none

include ./scripts/common.mk

.phony : all
all:

.phony : clean
clean: clean-build
	# $(CMD_RM) -f $(TARGETS)

.phony : clean-build
clean-build:
	# $(CMD_RM) -rf $(SRCDIR)
