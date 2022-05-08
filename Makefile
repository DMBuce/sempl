SHELL = /bin/sh

# root for installation
prefix      = /usr/local
exec_prefix = ${prefix}

# executables
bindir     = ${exec_prefix}/bin
sbindir    = ${exec_prefix}/sbin
libexecdir = ${exec_prefix}/libexec

# data
datarootdir    = ${prefix}/share
datadir        = ${datarootdir}
sysconfdir     = ${prefix}/etc
sharedstatedir = ${prefix}/com
localstatedir  = ${prefix}/var

# misc
includedir    = ${prefix}/include
oldincludedir = /usr/include
docdir        = ${datarootdir}/doc/${PACKAGE_TARNAME}
infodir       = ${datarootdir}/info
libdir        = ${exec_prefix}/lib
localedir     = ${datarootdir}/locale
mandir        = ${datarootdir}/man
man1dir       = $(mandir)/man1
man2dir       = $(mandir)/man2
man3dir       = $(mandir)/man3
man4dir       = $(mandir)/man4
man5dir       = $(mandir)/man5
man6dir       = $(mandir)/man6
man7dir       = $(mandir)/man7
man8dir       = $(mandir)/man8
man9dir       = $(mandir)/man9
manext        = .1
srcdir        = .

INSTALL         = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA    = ${INSTALL} -m 644

PACKAGE   = sempl
PROG      = sempl
BUGREPORT = https://github.com/DMBuce/sempl/issues
URL       = https://github.com/DMBuce/sempl

BINFILES         = $(wildcard bin/*)
DOCFILES         = README.md
BINFILES_INSTALL = $(BINFILES:bin/%=$(DESTDIR)$(bindir)/%)
INSTALL_FILES    = $(BINFILES_INSTALL) $(DOCFILES_INSTALL)
INSTALL_DIRS     = $(sort $(dir $(INSTALL_FILES)))

.PHONY: all
all:

.PHONY: install
install: all installdirs $(INSTALL_FILES)

.PHONY: installdirs
installdirs: $(INSTALL_DIRS)

.PHONY: doc
doc: $(DOCFILES)

.PHONY: check
check:
	./bin/sempl test.txt.sempl | diff -u test.txt -
	./bin/sempl README.md.sempl | diff -u README.md -

$(INSTALL_DIRS):
	$(INSTALL) -d $@

$(DESTDIR)$(bindir)/%: bin/%
	$(INSTALL_PROGRAM) $< $@

%: %.sempl
	./bin/sempl $< $@

# vim: set ft=make: