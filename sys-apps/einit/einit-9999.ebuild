ECVS_SERVER="einit.cvs.sourceforge.net:/cvsroot/einit"
ECVS_MODULE="einit"
inherit cvs

DESCRIPTION="eINIT - an alternate /sbin/init"
HOMEPAGE="http://einit.sourceforge.net/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="-*"
IUSE="doc"

RDEPEND="dev-libs/expat
	doc? ( app-text/docbook-sgml app-doc/doxygen )"
DEPEND="${RDEPEND}"
PDEPEND=""

S=${WORKDIR}/einit

src_unpack() {
	cvs_src_unpack
	cd "${S}"
}

src_compile() {
	econf \
		--enable-linux \
		--use-posix-regex \
		--prefix=/ \
		 || die
#	./configure --enable-linux || die
	emake || die
	if use doc ; then
		make documentation ||die
	fi
}

src_install() {
	emake -j1 install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog COPYING
	if use doc ; then
		dohtml build/documentation/html/*
	fi
}
