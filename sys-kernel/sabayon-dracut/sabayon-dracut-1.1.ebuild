# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="Sabayon Dracut Configuration"
HOMEPAGE="https://www.sabayon.org/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack () {
	mkdir -p "${S}" || die
}

src_install () {
	insinto /etc/dracut.conf.d/
	newins "${FILESDIR}"/sabayon.conf 99-sabayon.conf

	exeinto /usr/bin/
	doexe "${FILESDIR}"/sabayon-dracut
}

pkg_postinst () {
	einfo "Rebuilding all initrd images..."
	sabayon-dracut --rebuild-all
}
