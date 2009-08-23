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
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/entropy-${PV}.tar.bz2"
RESTRICT="mirror"
S="${WORKDIR}/entropy-${PV}"

DEPEND="~sys-apps/magneto-core-${PV}"
RDEPEND="${DEPEND}"

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	# Fix 0.98 bug
	mkdir -p ${D}/usr/$(get_libdir)/entropy/magneto
	emake DESTDIR="${D}" LIBDIR="usr/$(get_libdir)" magneto-loader-install || die "make install failed"
}
