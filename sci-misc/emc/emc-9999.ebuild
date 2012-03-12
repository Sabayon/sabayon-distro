EAPI="3"

PYTHON_DEPEND="2"

inherit linux-mod autotools python git flag-o-matic

DESCRIPTION="G-Code interpreter for Linux based CNC"
HOMEPAGE="http://www.linuxcnc.org/"
EGIT_REPO_URI="git://git.linuxcnc.org/git/emc2.git"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="+X +gtk nls +python +doc-pdf doc-html simulator"

RDEPEND="        
        x11-libs/gtk+
        x11-libs/fltk
        dev-lang/nasm
        dev-lang/tcl
        dev-lang/tk
        dev-lang/python
        dev-python/numpy
        dev-python/imaging        
        dev-python/pygtk
        dev-python/pyxml
        dev-tcltk/bwidget
        dev-tcltk/tkimg
        !simulator? ( sci-misc/rtai )
        X? ( x11-libs/libXinerama 
            x11-libs/libXmu 
            x11-libs/libXaw 
            x11-libs/libICE )"

DEPEND="${RDEPEND}
"

src_unpack() {
        git_src_unpack
}

src_configure () {
        cd src
        eautoreconf        
        econf \
                --with-module-dir="/lib/modules/${KV_FULL}/rtai/" \
                $(use_enable doc-pdf build-documentation build-documentation pdf) \
                $(use_enable doc-html build-documentation build-documentation html) \
                $(use_enable nls) \
                $(use_enable gtk) \
                $(use_enable python) \
                $(use_enable simulator) \
                $(use_with X x)
        # remove invalid ldconfig call
        sed -i -e 's:-ldconfig $(DESTDIR)$(libdir)::g' Makefile
        # replace pci_find_device to pci_get_device
        find . -type f -print0 | xargs -0 sed -i 's:pci_find_device:pci_get_device:g'
}

src_install () {
        cd src
        emake || die "compile failed"
        emake  DESTDIR="${D}" localedir="/usr/share/locale/" install || die "install failed"
}