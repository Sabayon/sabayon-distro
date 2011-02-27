# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
KDE_MINIMAL="4.2"
inherit eutils kde4-base

DESCRIPTION="Official Sabayon Linux Entropy Package Manager KDE4 kioslaves (tagged release)"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
SRC_URI="mirror://sabayon/sys-apps/entropy-${PV}.tar.bz2"
RESTRICT="mirror"
S="${WORKDIR}/entropy-${PV}"

RDEPEND=">=app-admin/sulfur-${PV}"

src_prepare() {
	einfo "nothing to prepare"
}

src_configure() {
	einfo "nothing to configure"
}

src_compile() {
	einfo "nothing to compile"
}

src_install() {
	dodir "/${KDEDIR}/share/kde4/services/"
	insinto "/${KDEDIR}/share/kde4/services/"
	doins "${S}/sulfur/misc/entropy.protocol"
}

pkg_postinst() {
	kde4-base_pkg_postinst
}

pkg_postrm() {
	kde4-base_pkg_postrm
}

