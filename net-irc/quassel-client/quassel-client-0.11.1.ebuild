# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils eutils

EGIT_REPO_URI="git://git.quassel-irc.org/quassel"
[[ "${PV}" == "9999" ]] && inherit git-r3
MY_P=${P/-client}
# MY_PN=${PN/-client}

DESCRIPTION="Qt/KDE IRC client supporting a remote daemon for 24/7 connectivity (client only)"
HOMEPAGE="http://quassel-irc.org/"
[[ "${PV}" == "9999" ]] || SRC_URI="http://quassel-irc.org/pub/${MY_P/_/-}.tar.bz2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="ayatana crypt dbus debug kde phonon qt5 +ssl webkit"

GUI_RDEPEND="
	qt5? (
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
		dbus? (
			dev-libs/libdbusmenu-qt[qt5]
			dev-qt/qtdbus:5
		)
		phonon? ( media-libs/phonon[qt5] )
		webkit? ( dev-qt/qtwebkit:5 )
	)
	!qt5? (
		dev-qt/qtgui:4
		ayatana? ( dev-libs/libindicate-qt )
		dbus? (
			dev-libs/libdbusmenu-qt[qt4(+)]
			dev-qt/qtdbus:4
			kde? (
				kde-base/kdelibs:4
				ayatana? ( kde-misc/plasma-widget-message-indicator )
			)
		)
		phonon? ( || ( media-libs/phonon[qt4] dev-qt/qtphonon:4 ) )
		webkit? ( dev-qt/qtwebkit:4 )
	)
"

RDEPEND="
	~net-irc/quassel-common-${PV}
	sys-libs/zlib
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtnetwork:5[ssl?]
	)
	!qt5? ( dev-qt/qtcore:4[ssl?] )
	${GUI_RDEPEND}
"
DEPEND="${RDEPEND}
	qt5? ( dev-qt/linguist-tools:5 )
"

S="${WORKDIR}/${MY_P/_/-}"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_find_package ayatana IndicateQt)
		$(cmake-utils_use_find_package crypt QCA2)
		$(cmake-utils_use_find_package dbus dbusmenu-qt)
		$(cmake-utils_use_find_package dbus dbusmenu-qt5)
		$(cmake-utils_use_with kde)
		"-DWITH_OXYGEN=OFF"
		"-DWANT_MONO=OFF"
		$(cmake-utils_use_find_package phonon)
		$(cmake-utils_use_find_package phonon Phonon4Qt5)
		$(cmake-utils_use_use qt5)
		"-DWANT_CORE=OFF"
		$(cmake-utils_use_with webkit)
		"-DWANT_QTCLIENT=ON"
		"-DEMBED_DATA=OFF"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rm -r "${ED}"usr/share/apps/ || die
	rm -r "${ED}"usr/share/pixmaps || die
	rm -r "${ED}"usr/share/icons || die

	insinto /usr/share/applications
	doins data/quasselclient.desktop
}

pkg_postinst() {
	elog "To make use of quasselclient, install server, too."
	elog "It is provided by net-irc/quassel-core and net-irc/quassel-core-bin."
}
