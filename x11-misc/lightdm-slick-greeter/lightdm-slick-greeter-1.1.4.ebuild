# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
MY_PN="slick-greeter"
S="${WORKDIR}/${MY_PN}-${PV}"

inherit autotools vala gnome2-utils

DESCRIPTION="LightDM greeter forked from Unity by Linux Mint team"
HOMEPAGE="https://github.com/linuxmint/${MY_PN}"
SRC_URI="https://github.com/linuxmint/${MY_PN}/archive/${PV}.tar.gz -> ${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"

DEPEND="
	>=dev-util/intltool-0.35.0
	dev-lang/vala:0.34
	sys-devel/gettext
	sys-devel/automake-wrapper"

RDEPEND="
	x11-libs/cairo
	media-libs/freetype
	>=x11-libs/gtk+-3.20:3
	media-libs/libcanberra
	x11-libs/libXext
	>=x11-misc/lightdm-base-1.12[introspection,vala]
	x11-libs/pixman"

src_prepare() {
	export VALAC="$(type -P valac-0.34)"
	eautoreconf
	default
}

pkg_postinst() {
	gnome2_schemas_update
        # Make sure to have a greeter properly configured
        eselect lightdm set slick-greeter --use-old
}

pkg_postrm() {
	gnome2_schemas_update --uninstall
	eselect lightdm set 1  # hope some other greeter is installed
}

