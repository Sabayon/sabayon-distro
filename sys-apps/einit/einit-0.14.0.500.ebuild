# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: 

inherit autotools

DESCRIPTION="eINIT - an alternate /sbin/init"
HOMEPAGE="http://einit.sourceforge.net/"
SRC_URI="mirror://sourceforge/einit/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="dev-libs/expat
	doc? ( app-text/docbook-sgml app-doc/doxygen )"
DEPEND="${RDEPEND}"
PDEPEND=""

S=${WORKDIR}/einit

src_compile() {
	cd ${S}
	./configure --enable-linux --use-posix-regex --prefix=/ --ebuild || 
die
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

pkg_postinst() {

	ebeep
	einfo
	einfo "The main (default) configuration file is"
	einfo "/etc/einit/default.xml, the file you should" 
	einfo "modify is /etc/einit/rc.xml."
	einfo "To use and finalize, you must ln -sf einit /sbin/init"
	einfo "and you must modify grub or lilo and this"
	einfo "takes the place of fstab too."
	einfo "Please read the documentation provided!!!"
	einfo

}
