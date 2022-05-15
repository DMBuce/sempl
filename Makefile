export PATH := ./bin:$(PATH)
SHELL = /bin/bash

# root for installation
prefix      = /usr/local
exec_prefix = ${prefix}

# system paths
bindir      = ${exec_prefix}/bin
datarootdir = ${prefix}/share
sysconfdir  = ${prefix}/etc

# man paths
mandir      = ${datarootdir}/man
man1dir     = $(mandir)/man1
man2dir     = $(mandir)/man2
man3dir     = $(mandir)/man3
man4dir     = $(mandir)/man4
man5dir     = $(mandir)/man5
man6dir     = $(mandir)/man6
man7dir     = $(mandir)/man7
man8dir     = $(mandir)/man8
man9dir     = $(mandir)/man9

INSTALL         = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA    = ${INSTALL} -m 644

PACKAGE   = sempl
PROG      = sempl
BUGREPORT = https://github.com/DMBuce/$(PACKAGE)/issues
URL       = https://github.com/DMBuce/$(PACKAGE)

# source, dest files
BINFILES         = $(wildcard bin/*)
BINFILES_INSTALL = $(BINFILES:bin/%=$(DESTDIR)$(bindir)/%)
DOCFILES         = README.asciidoc

# install files
INSTALL_FILES = $(BINFILES_INSTALL) $(DOCFILES_INSTALL)
INSTALL_DIRS  = $(sort $(dir $(INSTALL_FILES)))

# test/check files
TESTSCRIPTS = $(wildcard test/*.test)
TESTFILES   = $(TESTSCRIPTS:.test=.out)

.PHONY: all
all:

.PHONY: install
install: all installdirs $(INSTALL_FILES)

.PHONY: installdirs
installdirs: $(INSTALL_DIRS)

.PHONY: doc
doc: $(DOCFILES)

.PHONY: check
check: $(TESTFILES)

$(INSTALL_DIRS):
	$(INSTALL) -d $@

$(DESTDIR)$(bindir)/%: bin/%
	$(INSTALL_PROGRAM) $< $@

%: %.sempl
	./bin/sempl $< $@

# based on https://chrismorgan.info/blog/make-and-git-diff-test-harness/
%.out: %.test
	./$< > $@ 2>&1 \
		|| (touch --date=@0 $@; false)
	git diff --exit-code --src-prefix=expected: --dst-prefix=actual: \
		$@ \
		|| (touch --date=@0 $@; false)

# vim: set ft=make:
