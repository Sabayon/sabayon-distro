# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils eutils

EGIT_REPO_URI="git://git.quassel-irc.org/quassel"
[[ "${PV}" == "9999" ]] && inherit git-r3
MY_P=${P/-client}
# MY_PN=${PN/-client}

DESCRIPTION="Qt4/KDE IRC client supporting a remote daemon for 24/7 connectivity (client only)"
HOMEPAGE="http://quassel-irc.org/"
[[ "${PV}" == "9999" ]] || SRC_URI="http://quassel-irc.org/pub/${MY_P/_/-}.tar.bz2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="ayatana crypt dbus debug -kde -phonon +ssl webkit X"

GUI_RDEPEND="
	dev-qt/qtgui:4
	ayatana? ( dev-libs/libindicate-qt )
	dbus? (
		dev-qt/qtdbus:4
		dev-libs/libdbusmenu-qt
	)
	kde? (
		kde-base/kdelibs:4
		ayatana? ( kde-misc/plasma-widget-message-indicator )
	)
	phonon? ( || ( media-libs/phonon dev-qt/qtphonon:4 ) )
	webkit? ( dev-qt/qtwebkit:4 )
"

RDEPEND="
	~net-irc/quassel-common-${PV}
	dev-qt/qtcore:4[ssl?]
	${GUI_RDEPEND}
	"
DEPEND="${RDEPEND}
	kde? ( dev-util/automoc )"

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

	rm -r "${ED}"usr/share/apps/
	rm -r "${ED}"usr/share/pixmaps
	rm -r "${ED}"usr/share/icons

	insinto /usr/share/applications
	doins data/quasselclient.desktop
}

pkg_postinst() {
	elog "To make use of quasselclient, install server, too."
	elog "It is provided by net-irc/quassel-core and net-irc/quassel-core-bin."
}
