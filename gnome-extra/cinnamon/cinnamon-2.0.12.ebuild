# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{2_6,2_7} )
PYTHON_REQ_USE="xml"

inherit autotools eutils gnome2 multilib pax-utils python-single-r1

DESCRIPTION="A fork of GNOME Shell with layout similar to GNOME 2"
HOMEPAGE="http://cinnamon.linuxmint.com/"

MY_PV="${PV/_p/-UP}"
MY_P="${PN}-${MY_PV}"

SRC_URI="https://github.com/linuxmint/Cinnamon/archive/${MY_PV}.tar.gz -> ${MY_P}.tar.gz
	http://dev.gentoo.org/~pacho/gnome/cinnamon-1.8/gnome-3.8.patch"

LICENSE="GPL-2+"
SLOT="0"
IUSE="+l10n"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="
	>=dev-libs/glib-2.29.10:2
	>=dev-libs/cjs-1.9.0
	>=dev-libs/gobject-introspection-0.10.1
	x11-libs/gdk-pixbuf:2[introspection]
	>=x11-libs/gtk+-3.0.0:3[introspection]
	>=media-libs/clutter-1.7.5:1.0[introspection]
	app-misc/ca-certificates
	>=dev-libs/json-glib-0.13.2
	>=gnome-extra/cinnamon-desktop-2.0.3
	>=gnome-base/gsettings-desktop-schemas-2.91.91
	>=media-libs/gstreamer-0.10.16:0.10
	>=media-libs/gst-plugins-base-0.10.16:0.10
	net-libs/libsoup:2.4[introspection]
	>=sys-auth/polkit-0.100[introspection]
	>=x11-wm/muffin-1.9.1[introspection]

	dev-libs/dbus-glib
	dev-libs/libxml2:2
	x11-libs/pango[introspection]
	>=dev-libs/libcroco-0.6.2:0.6

	gnome-base/gconf:2[introspection]
	gnome-base/librsvg
	media-libs/libcanberra
	media-sound/pulseaudio

	>=x11-libs/startup-notification-0.11
	x11-libs/libX11
	>=x11-libs/libXfixes-5.0
	x11-apps/mesa-progs

	${PYTHON_DEPS}

	>=net-misc/networkmanager-0.9
	>=net-wireless/cinnamon-bluetooth-3.8.2
"
RDEPEND="${COMMON_DEPEND}
	>=gnome-base/dconf-0.4.1
	>=gnome-base/libgnomekbd-2.91.4[introspection]
	sys-power/upower[introspection]

	>=gnome-extra/cinnamon-control-center-2.0.7
	>=gnome-extra/cinnamon-screensaver-2.0.3
	>=gnome-extra/cinnamon-session-2.0.5
	>=gnome-extra/cinnamon-settings-daemon-2.0.7

	>=sys-apps/accountsservice-0.6.14[introspection]

	>=app-accessibility/caribou-0.3

	x11-misc/xdg-utils

	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/gconf-python:2
	virtual/python-imaging
	dev-python/lxml

	dev-python/pypam
	dev-python/pexpect

	x11-themes/gnome-icon-theme-symbolic

	dev-python/pygobject:3[${PYTHON_USEDEP}]

	gnome-extra/nemo
"
DEPEND="${COMMON_DEPEND}
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	>=dev-util/intltool-0.40
	gnome-base/gnome-common
	!!=dev-lang/spidermonkey-1.8.2*
"
PDEPEND="l10n? ( >=gnome-extra/cinnamon-translations-2.0.2 )"

S="${WORKDIR}/Cinnamon-${PV}"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}/background.patch"
	epatch "${FILESDIR}/screensaver.patch"
	epatch "${FILESDIR}/remove_GC.patch"
	epatch "${FILESDIR}/keyboard_applet-2.patch"
	epatch "${FILESDIR}/input_keybindings.patch"
	epatch "${FILESDIR}/lspci.patch"

	# Use Sabayon branding
	cp "${FILESDIR}"/start-here.png data/theme/menu.png || die "Could not copy image."

	# Gentoo uses /usr/$(get_libdir), not /usr/lib even for python
	sed -e "s:/usr/lib/:/usr/$(get_libdir)/:" \
		-e 's:"/usr/lib":"/usr/'"$(get_libdir)"'":' \
		-i files/usr/bin/cinnamon-menu-editor \
		-i files/usr/bin/cinnamon-settings \
		-i files/usr/bin/cinnamon-desktop-editor \
		-i files/usr/bin/cinnamon-json-makepot \
		-i files/usr/bin/cinnamon-screensaver-lock-dialog \
		-i files/usr/bin/cinnamon-settings-users \
		-i files/usr/bin/cinnamon-looking-glass \
		-i files/usr/lib/cinnamon-menu-editor/cme/MainWindow.py \
		-i files/usr/lib/cinnamon-menu-editor/cme/config.py \
		-i files/usr/lib/cinnamon-settings/modules/cs_backgrounds.py \
		-i files/usr/lib/cinnamon-settings/modules/cs_info.py \
		-i files/usr/lib/cinnamon-settings/data/spices/applet-detail.html \
		-i files/usr/lib/cinnamon-settings/cinnamon-settings.py \
		-i files/usr/lib/cinnamon-settings/bin/XletSettings.py \
		-i files/usr/lib/cinnamon-settings/bin/Spices.py \
		-i files/usr/lib/cinnamon-settings/bin/ExtensionCore.py \
		-i files/usr/lib/cinnamon-settings/bin/capi.py \
		-i files/usr/lib/cinnamon-desktop-editor/cinnamon-desktop-editor.py \
		-i files/usr/lib/cinnamon-screensaver-lock-dialog/cinnamon-screensaver-lock-dialog.py \
		-i files/usr/lib/cinnamon-settings-users/cinnamon-settings-users.py \
			|| die "sed 2 failed"
	if [[ "$(get_libdir)" != lib ]]; then
		mv files/usr/lib "files/usr/$(get_libdir)" || die "mv failed"
	fi

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	# Don't error out on warnings
	gnome2_src_configure \
		--disable-jhbuild-wrapper-script \
		--with-ca-certificates="${EPREFIX}/etc/ssl/certs/ca-certificates.crt" \
		BROWSER_PLUGIN_DIR="${EPREFIX}/usr/$(get_libdir)/nsbrowser/plugins"
}

src_install() {
	gnome2_src_install
	python_optimize "${ED}usr/$(get_libdir)/cinnamon-"{settings,menu-editor}
	# Fix broken shebangs
	sed -e "s%#!.*python%#!${PYTHON}%" \
		-i "${ED}usr/bin/cinnamon-"{launcher,menu-editor,settings} \
		-i "${ED}usr/$(get_libdir)/cinnamon-settings/cinnamon-settings.py" || die

	insinto /usr/share/applications
	doins "${FILESDIR}/cinnamon-screensaver.desktop"
	doins "${FILESDIR}/cinnamon2d-screensaver.desktop"

	# Required for gnome-shell on hardened/PaX, bug #398941
	pax-mark mr "${ED}usr/bin/cinnamon"

	# Avoid collisions with cinnamon-screensaver, upstream bug
	rm -f "${ED}usr/share/applications/cinnamon-screensaver.desktop"

	# Doesn't exist on Gentoo, causing this to be a dead symlink
	rm -f "${ED}etc/xdg/menus/cinnamon-applications-merged" || die
}

pkg_postinst() {
	gnome2_pkg_postinst

	if ! has_version '>=media-libs/gst-plugins-good-0.10.23:0.10' || \
	   ! has_version 'media-plugins/gst-plugins-vp8:0.10'; then
		ewarn "To make use of Cinnamon's built-in screen recording utility,"
		ewarn "you need to either install >=media-libs/gst-plugins-good-0.10.23:0.10"
		ewarn "and media-plugins/gst-plugins-vp8:0.10, or use dconf-editor to change"
		ewarn "org.cinnamon.recorder/pipeline to what you want to use."
	fi

	if ! has_version ">=x11-base/xorg-server-1.11"; then
		ewarn "If you use multiple screens, it is highly recommended that you"
		ewarn "upgrade to >=x11-base/xorg-server-1.11 to be able to make use of"
		ewarn "pointer barriers which will make it easier to use hot corners."
	fi

	if has_version "<x11-drivers/ati-drivers-12"; then
		ewarn "Cinnamon has been reported to show graphical corruption under"
		ewarn "x11-drivers/ati-drivers-11.*; you may want to switch to"
		ewarn "open-source drivers."
	fi

	if has_version "media-libs/mesa[video_cards_radeon]"; then
		elog "Cinnamon is unstable under classic-mode r300/r600 mesa drivers."
		elog "Make sure that gallium architecture for r300 and r600 drivers is"
		elog "selected using 'eselect mesa'."
		if ! has_version "media-libs/mesa[gallium]"; then
			ewarn "You will need to emerge media-libs/mesa with USE=gallium."
		fi
	fi
}
