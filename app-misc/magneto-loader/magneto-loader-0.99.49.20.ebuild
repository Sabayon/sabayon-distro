# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit eutils multilib

DESCRIPTION="Official Sabayon Linux Entropy Notification Applet Loader"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
SRC_URI="http://distfiles.sabayon.org/sys-apps/entropy-${PV}.tar.bz2"
RESTRICT="mirror"
S="${WORKDIR}/entropy-${PV}/magneto"

DEPEND="~sys-apps/magneto-core-${PV}"
RDEPEND="${DEPEND}"

src_compile() {
	einfo "nothing to compile"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="usr/$(get_libdir)" magneto-loader-install || die "make install failed"
}
