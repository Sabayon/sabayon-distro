<<<<<<<
# Copyright 1999-2018 Gentoo Foundation
=======
# Copyright 1999-2019 Gentoo Authors
>>>>>>>
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools gnome2-utils eapi7-ver

DESCRIPTION="LightDM GTK+ Greeter"
<<<<<<<
=======
HOMEPAGE="https://launchpad.net/lightdm-gtk-greeter"
SRC_URI="https://launchpad.net/lightdm-gtk-greeter/$(ver_cut 1-2)/${PV}/+download/${P}.tar.gz
	branding? ( https://dev.gentoo.org/~polynomial-c/dist/lightdm-gentoo-patch-2.tar.gz )"

LICENSE="GPL-3 LGPL-3
	branding? ( CC-BY-3.0 )"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ppc ppc64 x86"
IUSE="ayatana branding"

COMMON_DEPEND="ayatana? ( dev-libs/libindicator:3 )
>>>>>>>
HOMEPAGE="http://launchpad.net/lightdm-gtk-greeter"
SRC_URI="http://launchpad.net/lightdm-gtk-greeter/$(get_version_component_range 1-2)/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="ayatana"

# This ebuild needs custom Sabayon themes, thus it must depend on sabayon-artwork-core
COMMON_DEPEND="ayatana? ( dev-libs/libindicator:3 )
	x11-libs/gtk+:3
	>=x11-misc/lightdm-1.2.2"

DEPEND="${COMMON_DEPEND}
	sys-devel/gettext
	xfce-base/exo"

RDEPEND="${COMMON_DEPEND}
	>=x11-misc/lightdm-1.2.2
	x11-themes/gnome-themes-standard
	>=x11-themes/adwaita-icon-theme-3.14.1
	x11-themes/sabayon-artwork-core
	app-eselect/eselect-lightdm"

src_prepare() {
	# Apply custom Sabayon theme
	sed -i \
		-e 's:#background=.*:background=/usr/share/backgrounds/kgdm.png:' \
<<<<<<<
		-e 's:#xft-hintstyle=.*:xft-hintstyle=hintfull:' \
		-e 's:#xft-antialias=.*:xft-antialias=true:' \
		-e 's:#xft-rgba=.*:xft-rgba=rgb:' "data/${PN}.conf" || die
=======
	# background
	# Bug #404467
	if use branding; then
		sed \
			-e "/xft-hintstyle/s:slight:hintslight:" \
			-e "/background/s:=.*:=/usr/share/lightdm/backgrounds/${GENTOO_BG}:" \
			-i "${WORKDIR}"/${PN}.conf || die
		# Add back the reboot/shutdown buttons
		echo 'indicators=~host;~spacer;~clock;~spacer;~session;~language;~a11y;~power;~' \
			>> "${WORKDIR}"/${PN}.conf || die
	fi
>>>>>>>
	default

	# Fix docdir
	sed "/^docdir/s@${PN}@${PF}@" -i data/Makefile.am || die
	eautoreconf
}

src_configure() {
	econf --enable-kill-on-sigterm \
		$(use_enable ayatana libindicator)
}

pkg_postinst() {
	# Make sure to have a greeter properly configured
	eselect lightdm set lightdm-gtk-greeter --use-old
}

pkg_postrm() {
	eselect lightdm set 1  # hope some other greeter is installed
<<<<<<<
=======
		doins "${WORKDIR}"/${PN}.conf
		insinto /usr/share/lightdm/backgrounds/
		doins "${WORKDIR}"/${GENTOO_BG}
		newdoc "${WORKDIR}"/README.txt README-background.txt
	fi
>>>>>>>
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
