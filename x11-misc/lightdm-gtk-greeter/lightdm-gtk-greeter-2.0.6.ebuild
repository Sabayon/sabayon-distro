# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools gnome2-utils eapi7-ver

DESCRIPTION="LightDM GTK+ Greeter"
HOMEPAGE="http://launchpad.net/lightdm-gtk-greeter"
SRC_URI="https://launchpad.net/lightdm-gtk-greeter/$(ver_cut 1-2)/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="ayatana"

# This ebuild needs custom Sabayon themes, thus it must depend on sabayon-artwork-core
COMMON_DEPEND="ayatana? ( dev-libs/libindicator:3 )
	x11-libs/gtk+:3
	>=x11-misc/lightdm-1.2.2"

DEPEND="${COMMON_DEPEND}
	dev-util/intltool
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
		-e 's:#xft-hintstyle=.*:xft-hintstyle=hintfull:' \
		-e 's:#xft-antialias=.*:xft-antialias=true:' \
		-e 's:#xft-rgba=.*:xft-rgba=rgb:' "data/${PN}.conf" || die
	# Add back the reboot/shutdown buttons
	echo 'indicators=~host;~spacer;~clock;~spacer;~session;~language;~a11y;~power;~' \
		>> data/${PN}.conf || die
	default

	# Fix docdir
	sed "/^docdir/s@${PN}@${PF}@" -i data/Makefile.am || die
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--enable-kill-on-sigterm
		-enable-at-spi-command="${EPREFIX}/usr/libexec/at-spi-bus-launcher --launch-immediately"
		$(use_enable ayatana libindicator)
	)
	econf "${myeconfargs[@]}"
}

pkg_postinst() {
	# Make sure to have a greeter properly configured
	eselect lightdm set lightdm-gtk-greeter --use-old
}

pkg_postrm() {
	eselect lightdm set 1  # hope some other greeter is installed
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
