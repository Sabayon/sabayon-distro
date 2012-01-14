# Copyright 1999-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2
# Header: $

EAPI=4

inherit gnome2-utils

DESCRIPTION="Sabayon Linux Official GNOME artwork"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${PN}-6_beta3.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="~x11-themes/sabayon-artwork-core-${PV}
	x11-themes/equinox-themes
	x11-themes/elementary-icon-theme[monochrome,branding]"

S="${WORKDIR}/${PN}"

src_install() {
	dodir /usr/share/themes

	# GNOME & GTK Theme
	cd "${S}"/gtk
	dodir /usr/share/themes
	insinto /usr/share/themes
	doins -r ./*

	# Metacity
	cd "${S}"/metacity
	insinto /usr/share/themes
	doins -r ./*

	# GNOME 3 config settings
	dodir /usr/share/glib-2.0/schemas
	insinto /usr/share/glib-2.0/schemas
	doins "${FILESDIR}/org.sabayon.gschema.override"
}

pkg_preinst() {
	# taken from gnome2_schemas_savelist
	has ${EAPI:-0} 0 1 2 && ! use prefix && ED="${D}"
	pushd "${ED}" &>/dev/null
	export GNOME2_ECLASS_GLIB_SCHEMAS="/usr/share/glib-2.0/schemas/org.sabayon.gschema.override"
	popd &>/dev/null
}

pkg_postinst() {
	gnome2_schemas_update
}

pkg_postrm() {
	gnome2_schemas_update --uninstall
}
