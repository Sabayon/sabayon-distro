# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit gnome2-utils

DESCRIPTION="Elementary gnome icon theme"
HOMEPAGE="https://launchpad.net/elementaryicons"
SRC_URI="http://launchpad.net/elementaryicons/2.0/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="monochrome"

DEPEND=""
RDEPEND=""
RESTRICT="binchecks strip"

src_install() {
	insinto /usr/share/icons
	cd "${WORKDIR}/${PN}"
	doins -r elementary
	use monochrome && doins -r elementary-mono-dark
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}

