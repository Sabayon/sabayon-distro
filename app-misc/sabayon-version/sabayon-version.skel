# Copyright 2004-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Sabayon system release virtual package"
HOMEPAGE="http://www.sabayon.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

IUSE=""
DEPEND=""
# Listing default packages for the current release
RDEPEND="app-admin/eselect-python
	dev-lang/python:2.7
	sys-apps/systemd
	sys-devel/base-gcc:4.7
	sys-devel/gcc-config"

src_unpack () {
	echo "Sabayon Linux ${ARCH} ${PV}" > "${T}/sabayon-release"
}

src_install () {
	insinto /etc
	doins "${T}"/sabayon-release
	dosym /etc/sabayon-release /etc/system-release
	# Bug 3459 - reduce the risk of fork bombs
	insinto /etc/security/limits.d
	doins "${FILESDIR}/00-sabayon-anti-fork-bomb.conf"
}

pkg_postinst() {
	# Setup Python 2.7
	eselect python update --ignore 3.0 --ignore 3.1 --ignore 3.2 --ignore 3.3 --ignore 3.4
}
