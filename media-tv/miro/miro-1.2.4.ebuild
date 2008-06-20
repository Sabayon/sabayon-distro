# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils multilib distutils confutils fdo-mime

MY_P="${P/m/M}"
DESCRIPTION="Open source video player"
HOMEPAGE="http://www.getmiro.com/"
SRC_URI="http://ftp.osuosl.org/pub/pculture.org/miro/src/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
#IUSE="doc libnotify"

# FIXME: This is simply rewritten from setup.cfg. Adding version requirements is strongly recommended.
# FIXME: the following deps were removed because setup.py isn't clear about it.
# dev-libs/nss -> present through xulrunner
# media-libs/libfame
# libnotify ( dev-python/notify-python )
# doc? ( dev-util/devhelp )
# net-libs/xulrunner -> gecko is present through g-p-e check
RDEPEND=">=dev-python/pygtk-2.10
	|| ( >=dev-lang/python-2.5
	     >=dev-python/pysqlite-2 )
	>=dev-libs/boost-1.34.1-r1
	dev-python/gnome-python-extras
	dev-python/dbus-python
	>=dev-python/pyrex-0.9.6.4
	media-libs/xine-lib"
DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}/platform/gtk-x11"

pkg_setup() {
	confutils_require_built_with_any dev-python/gnome-python-extras xulrunner firefox seamonkey

	if ! built_with_use dev-lang/python berkdb; then
		eerror "You must reemerge dev-lang/python with \"berkdb\" flag set."
		die "berkbd missing in dev-lang/python"
	fi

	if has_version ">=dev-lang/python-2.5" &&
		! has_version ">=dev-python/pysqlite-2" &&
		! built_with_use dev-lang/python sqlite ; then
		eerror "You must reemerge dev-lang/python with \"sqlite\" flag set."
		die "sqlite missing in dev-lang/python"
	fi
}

pkg_postinst() {
	distutils_pkg_postinst
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update

	MOZSETUP="/usr/$(get_libdir)/python${PYVER}/site-packages/${PN}/mozsetup.py"
	elog ""
	elog "To increase the font size of the main display area, add:"
	elog "user_pref(\"font.minimum-size.x-western\", 15);"
	elog ""
	elog "to the following file:"
	elog "${MOZSETUP}"
	elog ""
}
