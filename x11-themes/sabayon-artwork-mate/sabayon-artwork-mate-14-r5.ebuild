# Copyright 1999-2015 Sabayon
# Distributed under the terms of the GNU General Public License v2
# Header: $

EAPI=5

inherit gnome2-utils

DESCRIPTION="Sabayon Linux Official MATE artwork"
HOMEPAGE="http://www.sabayon.org/"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""
RDEPEND="
	!<x11-themes/sabayon-artwork-core-14-r2
	media-fonts/ubuntu-font-family
	x11-themes/faenza-icon-theme"
S="${WORKDIR}/"

src_install() {
	dodir /usr/share/glib-2.0/schemas
	insinto /usr/share/glib-2.0/schemas
	newins "${FILESDIR}/org.sabayon.mate.gschema.override" "org.sabayon.mate.gschema.override"
}

pkg_preinst() {
	# taken from gnome2_schemas_savelist
	has ${EAPI:-0} 0 1 2 && ! use prefix && ED="${D}"
	pushd "${ED}" &>/dev/null
	export GNOME2_ECLASS_GLIB_SCHEMAS="/usr/share/glib-2.0/schemas/org.sabayon.mate.gschema.override"
	popd &>/dev/null
}

pkg_postinst() {
	gnome2_schemas_update
}

pkg_postrm() {
	gnome2_schemas_update --uninstall
}
