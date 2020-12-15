# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
SLREV=4
inherit gnome2-utils

DESCRIPTION="Colorized icons shared between all gnome-colors iconsets"
HOMEPAGE="http://code.google.com/p/gnome-colors/"

SRC_URI="http://gnome-colors.googlecode.com/files/gnome-colors-${PV}.tar.gz
	branding? ( mirror://sabayon/x11-themes/fdo-icons-sabayon${SLREV}.tar.gz )"

LICENSE="
	GPL-2
	branding? ( CC-BY-SA-4.0 )
"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+branding"

RDEPEND="x11-themes/adwaita-icon-theme"
DEPEND=""
RESTRICT="binchecks strip"

S="${WORKDIR}"

src_prepare() {
	if use branding; then
		cp -r fdo-icons-sabayon/* ${PN} || die "Sabayon branding failed"
	fi
	default
}

src_compile() {
	einfo "Nothing to compile"
}

src_install() {
	dodir /usr/share/icons
	insinto /usr/share/icons
	doins -r "${WORKDIR}/${PN}" || die "Installing icons failed"
	dodoc AUTHORS ChangeLog README
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
