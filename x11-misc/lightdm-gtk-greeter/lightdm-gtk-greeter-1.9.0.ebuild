# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit versionator

DESCRIPTION="LightDM GTK+ Greeter"
HOMEPAGE="http://launchpad.net/lightdm-gtk-greeter"
SRC_URI="http://launchpad.net/lightdm-gtk-greeter/$(get_version_component_range 1-2)/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~x86"
IUSE=""

# This ebuild needs custom Sabayon themes, thus it must depend on sabayon-artwork-core
DEPEND="x11-libs/gtk+:3
	>=x11-misc/lightdm-1.2.2"
RDEPEND="!!<x11-misc/lightdm-1.1.1
	app-admin/eselect-lightdm
	x11-libs/gtk+:3
	>=x11-misc/lightdm-1.2.2
	x11-themes/gnome-themes-standard
	x11-themes/gnome-icon-theme
	x11-themes/sabayon-artwork-core"

src_prepare() {
	# Apply custom Sabayon theme
	sed -i \
		-e 's:#background=.*:background=/usr/share/backgrounds/kgdm.png:' \
		-e 's:#xft-hintstyle=.*:xft-hintstyle=hintfull:' \
		-e 's:#xft-antialias=.*:xft-antialias=true:' \
		-e 's:#xft-rgba=.*:xft-rgba=rgb:' "data/${PN}.conf" || die
}

pkg_postinst() {
	# Make sure to have a greeter properly configured
	eselect lightdm set lightdm-gtk-greeter --use-old
}

pkg_postrm() {
	eselect lightdm set 1  # hope some other greeter is installed
}
