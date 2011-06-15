# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

SLREV=4
inherit gnome2-utils

DESCRIPTION="Elementary gnome icon theme"
HOMEPAGE="https://launchpad.net/elementaryicons"
SRC_URI="http://launchpad.net/elementaryicons/2.0/${PV}/+download/${P}.tar.gz
	branding? ( mirror://sabayon/x11-themes/fdo-icons-sabayon${SLREV}.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="monochrome branding"

DEPEND=""
RDEPEND=""
RESTRICT="binchecks strip"

src_install() {
	cd "${WORKDIR}/${PN}"
	insinto /usr/share/icons
	doins -r elementary
	use monochrome && doins -r elementary-mono-dark

	if use branding ; then
		cd "${WORKDIR}"
		insinto /usr/share/icons/elementary
		doins -r fdo-icons-sabayon/*

		if use monochrome ; then
			insinto /usr/share/icons/elementary-mono-dark
			doins -r fdo-icons-sabayon/*
		fi

		# ugly fix, while Ian is ZzZ
		for target in $(find "${D}"/usr/share/icons/*/panel/ -name start-here.svg); do
			cp fdo-icons-sabayon/scalable/places/start-here.svg "${target}" || die
		done
	fi
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

