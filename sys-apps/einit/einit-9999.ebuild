inherit subversion flag-o-matic eutils toolchain-funcs

DESCRIPTION="eINIT - an alternate /sbin/init"
HOMEPAGE="http://einit.sourceforge.net/"
ESVN_REPO_URI="http://einit.svn.sourceforge.net/svnroot/einit/trunk/${PN}"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="-*"
IUSE="doc efl"

RDEPEND="dev-libs/expat
	doc? ( app-text/docbook-sgml app-doc/doxygen )
	efl? ( media-libs/edje x11-libs/evas x11-libs/ecore )"
DEPEND="${RDEPEND}"
PDEPEND=""

S=${WORKDIR}/einit

src_unpack() {
	subversion_src_unpack
	cd "${S}"
}

src_compile() {
	local myconf
	myconf="--svn --ebuild"
	if use efl ; then
		myconf="${myconf} --enable-linux --use-posix-regex --prefix=${ROOT} --enable-efl"
	else
		myconf="${myconf} --enable-linux --use-posix-regex --prefix=${ROOT}"
	fi
	econf ${myconf} || die "Configuration failed"
	emake || die "Make failed"
	if use doc ; then
		make documentation || die "Documentation faile"
	fi
}

src_install() {
	emake -j1 install DESTDIR="${D}" || die "Installation failed"
	dodoc AUTHORS ChangeLog COPYING
	if use doc ; then
		dohtml build/documentation/html/*
	fi
}
