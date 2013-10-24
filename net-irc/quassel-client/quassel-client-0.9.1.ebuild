# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit cmake-utils eutils

EGIT_REPO_URI="git://git.quassel-irc.org/quassel.git"
EGIT_BRANCH="master"
MY_P=${P/-client}
# MY_PN=${PN/-client}
[[ "${PV}" == "9999" ]] && inherit git-2

QT_MINIMAL="4.6.0"
KDE_MINIMAL="4.4"

DESCRIPTION="Qt4/KDE4 IRC client supporting a remote daemon for 24/7 connectivity (client only)."
HOMEPAGE="http://quassel-irc.org/"
[[ "${PV}" == "9999" ]] || SRC_URI="http://quassel-irc.org/pub/${MY_P/_/-}.tar.bz2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="ayatana crypt dbus debug -kde -phonon +ssl webkit X"

GUI_RDEPEND="
	>=dev-qt/qtgui-${QT_MINIMAL}:4
	ayatana? ( dev-libs/libindicate-qt )
	dbus? (
		>=dev-qt/qtdbus-${QT_MINIMAL}:4
		dev-libs/libdbusmenu-qt
	)
	kde? (
		>=kde-base/kdelibs-${KDE_MINIMAL}
		ayatana? ( kde-misc/plasma-widget-message-indicator )
	)
	phonon? ( || ( media-libs/phonon >=dev-qt/qtphonon-${QT_MINIMAL} ) )
	webkit? ( >=dev-qt/qtwebkit-${QT_MINIMAL}:4 )
	"

RDEPEND="
	~net-irc/quassel-common-${PV}
	>=dev-qt/qtcore-${QT_MINIMAL}:4[ssl?]
	${GUI_RDEPEND}
	"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P/_/-}"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_with ayatana LIBINDICATE)
		"-DWANT_QTCLIENT=ON"
		"-DWANT_CORE=OFF"
		"-DWANT_MONO=OFF"
		$(cmake-utils_use_with webkit)
		$(cmake-utils_use_with phonon)
		$(cmake-utils_use_with kde)
		$(cmake-utils_use_with dbus)
		$(cmake-utils_use_with ssl OPENSSL)
		"-DWITH_OXYGEN=OFF"
		$(cmake-utils_use_with crypt)
		"-DEMBED_DATA=OFF"
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rm -rf "${ED}"usr/share/apps/
	rm -rf "${ED}"usr/share/pixmaps
	rm -rf "${ED}"usr/share/icons

	insinto /usr/share/applications
	doins data/quasselclient.desktop
}

pkg_postinst() {
	elog "To make use of quasselclient, install server, too."
	elog "It is provided by net-irc/quassel-core and net-irc/quassel-core-bin."
}
