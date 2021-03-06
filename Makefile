RM := rm

INSTALL := install
INSTALLDATA := install -D -m 644

prefix = /usr/local
# Prefix for each installed program,
# normally empty or `g'.
binprefix =
# The directory to install tar in.
bindir = $(prefix)/bin
datadir = $(prefix)/share
# Binary output extension
BINEXT :=

.PHONY: clean doc install git_submodule

# Compile rules
all: smlrc-tr3200${BINEXT} vlink${BINEXT} vasm-tr3200${BINEXT}

smlrc-tr3200${BINEXT}:
	cd SmallerC && make CPPFLAGS=-DTR3200 smlrc
	mv SmallerC/smlrc smlrc-tr3200${BINEXT}

vlink${BINEXT}: vlink_src
	cd vlink_src && make -f Makefile
	mv vlink_src/vlink vlink${BINEXT}

vasm-tr3200${BINEXT}: vasm
	cd vasm && make -f Makefile CPU=tr3200 SYNTAX=oldstyle
	mv vasm/vasmtr3200_oldstyle vasm-tr3200${BINEXT}

# Grab source code
vlink_src:
	wget http://sun.hasenbraten.de/vlink/daily/vlink.tar.gz
	tar -xvzf vlink.tar.gz
	mv vlink vlink_src
#	cp vlink_makefilewin32 ./vlink_src/Makefile.Win32FromLinux

git_submodule:
	git submodule init
	git submodule update
	cd SmallerC && ./configure

vasm:
	wget http://sun.hasenbraten.de/vasm/daily/vasm.tar.gz
	tar -xvzf vasm.tar.gz
#	cd vasm && patch -p1 < ../patches/fix_rjmp.patch


# Generate doc rules
doc:
	mkdir -p ./doc/vasm
	mkdir -p ./doc/vlink
	cd vasm && make -f Makefile doc/vasm.html
	mv vasm/doc/*.html ./doc/vasm/
	cd vlink_src && make -f Makefile vlink.html
	mv vlink_src/*.html ./doc/vlink/

# Install rules
install: all
	$(INSTALL) smlrc-tr3200 $(bindir)/$(binprefix)smlrc-tr3200
	$(INSTALL) vasm-tr3200 $(bindir)/$(binprefix)vasm-tr3200
	$(INSTALL) vlink $(bindir)/$(binprefix)vlink
	$(INSTALL) ./WaveAsm/WaveAsm.pl $(bindir)/$(binprefix)WaveAsm.pl
	$(INSTALLDATA) ./WaveAsm/tr3200.isf $(datadir)/WaveAsm/tr3200.isf

# Clean rules
clean:
	$(RM) -f smlrc-tr3200${BINEXT}
	cd SmallerC && make clean
	$(RM) -f vlink${BINEXT}
	$(RM) -f vlink_src/objects/*.o
	$(RM) -f vasm-tr3200${BINEXT}
	cd vasm && make clean
	$(RM) -f vasm/obj/*.o
