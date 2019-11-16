# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="Sabayon Mirrors Updater"
HOMEPAGE="https://www.sabayon.org/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm arm64"

RDEPEND="net-misc/wget
	dev-python/shyaml
"
DEPEND="${RDEPEND}"

src_unpack () {
	mkdir -p "${S}" || die
}

src_install () {
	exeinto /usr/bin/
	doexe "${FILESDIR}"/sabayon-mirrors-updater
}

pkg_postinst () {
	einfo "Please, update mirrors list of our repository"
	einfo "through sabayon-mirrors-updater binary."
}
