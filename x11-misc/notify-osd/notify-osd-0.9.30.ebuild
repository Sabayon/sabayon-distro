# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools eutils gnome2 versionator virtualx

MY_PV=$(get_version_component_range 1-2)

DESCRIPTION="Canonical's on-screen-display notification agent"
HOMEPAGE="https://launchpad.net/notify-osd"
SRC_URI="http://launchpad.net/${PN}/natty/natty-alpha3/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-libs/glib-2.16
	gnome-base/gconf:2
	>=dev-libs/dbus-glib-0.76
	>=x11-libs/gtk+-2.14
	>=x11-libs/libnotify-0.4.5
	x11-libs/libwnck"
DEPEND="${RDEPEND}
	dev-util/intltool
	!x11-misc/notification-daemon
	!x11-misc/xfce4-notifyd"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF} --without-examples"
}

src_prepare() {
	gnome2_src_prepare

	# Fix untested gconf behavior
	epatch "${FILESDIR}/gconf-client.patch"

	# Fix building tests when not needed
	epatch "${FILESDIR}/tests-makefile.patch"

	# Disable interactive test
	sed 's:^\(.*ADD_TEST(test_withlib_actions).*\):/*\1*/:' \
		-i tests/test-withlib.c || die "sed failed"
	sed 's:^\(.*TC(test_dnd_screensaver).*\):/*\1*/:' \
		-i tests/test-dnd.c || die "sed failed"

	eautoreconf
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	# Force use of Xvfb
	unset DISPLAY
	unset XAUTHORITY
	Xemake check || die "emake check failed"
}
