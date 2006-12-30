# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: 

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="eINIT - an alternate /sbin/init"
HOMEPAGE="http://einit.sourceforge.net/"
SRC_URI="mirror://sourceforge/einit/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc efl"

RDEPEND="dev-libs/expat
	doc? ( app-text/docbook-sgml app-doc/doxygen )"
DEPEND="${RDEPEND}"
PDEPEND=""

S=${WORKDIR}/einit-${PV}

src_compile() {
	local myconf
	myconf="--enable-linux --use-posix-regex --prefix=${ROOT} --ebuild"
	
	if use efl ; then
		myconf="${myconf} --enable-efl"
	fi
	
	econf || die "Configure failed"
	emake || die "Make failed"

	if use doc ; then
		make documentation || die "Failed to make documentation"
	fi
}

src_install() {
	emake -j1 install DESTDIR="${D}" || die "Installation died"
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
