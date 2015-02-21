# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils eutils

EGIT_REPO_URI="git://git.quassel-irc.org/quassel"
[[ "${PV}" == "9999" ]] && inherit git-r3

DESCRIPTION="Qt/KDE IRC client - monolithic client only (no remote daemon)"
HOMEPAGE="http://quassel-irc.org/"
[[ "${PV}" == "9999" ]] || SRC_URI="http://quassel-irc.org/pub/${P/_/-}.tar.bz2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
# monolithic USE flag must be enabled for this package
IUSE="ayatana crypt dbus debug kde monolithic phonon postgres qt5 +server +ssl syslog webkit X"

SERVER_RDEPEND="
	qt5? (
		dev-qt/qtscript:5
		postgres? ( dev-qt/qtsql:5[postgres] )
		!postgres? ( dev-qt/qtsql:5[sqlite] dev-db/sqlite:3[threadsafe(+),-secure-delete] )
	)
	!qt5? (
		dev-qt/qtscript:4
		crypt? (
			app-crypt/qca:2[qt4(+)]
			|| ( app-crypt/qca-ossl:2 app-crypt/qca:2[openssl] )
		)
		postgres? ( dev-qt/qtsql:4[postgres] )
		!postgres? ( dev-qt/qtsql:4[sqlite] dev-db/sqlite:3[threadsafe(+),-secure-delete] )
	)
	syslog? ( virtual/logger )
"

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
	monolithic? (
		${SERVER_RDEPEND}
		${GUI_RDEPEND}
	)
	!monolithic? (
		server? ( ${SERVER_RDEPEND} )
		X? ( ${GUI_RDEPEND} )
	)
"
DEPEND="${RDEPEND}
	qt5? ( dev-qt/linguist-tools:5 )
"

DOCS=( AUTHORS ChangeLog README )

S="${WORKDIR}/${P/_/-}"

REQUIRED_USE="
	|| ( X server monolithic )
	ayatana? ( || ( X monolithic ) )
	crypt? ( || ( server monolithic ) )
	dbus? ( || ( X monolithic ) )
	kde? ( phonon || ( X monolithic ) )
	phonon? ( || ( X monolithic ) )
	postgres? ( || ( server monolithic ) )
	qt5? ( !ayatana !crypt !kde phonon )
	syslog? ( || ( server monolithic ) )
	webkit? ( || ( X monolithic ) )
"

pkg_setup() {
	# sanity check for the split ebuild
	use monolithic || die "The 'monolithic' flag must be enabled!"
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_find_package ayatana IndicateQt)
		$(cmake-utils_use_find_package crypt QCA2)
		$(cmake-utils_use_find_package dbus dbusmenu-qt)
		$(cmake-utils_use_find_package dbus dbusmenu-qt5)
		$(cmake-utils_use_with kde)
		"-DWITH_OXYGEN=OFF"
		"-DWANT_MONO=ON"
		$(cmake-utils_use_find_package phonon)
		$(cmake-utils_use_find_package phonon Phonon4Qt5)
		$(cmake-utils_use_use qt5)
		"-DWANT_CORE=OFF"
		$(cmake-utils_use_with webkit)
		"-DWANT_QTCLIENT=OFF"
		"-DEMBED_DATA=OFF"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rm -r "${ED}"usr/share/apps || die
	rm -r "${ED}"usr/share/pixmaps || die
	rm -r "${ED}"usr/share/icons || die
	rm -r "${ED}"usr/share/applications || die

	insinto /usr/share/applications
	doins data/quassel.desktop
}

pkg_postinst() {
	if use monolithic && use ssl ; then
		elog "Information on how to enable SSL support for client/core connections"
		elog "is available at http://bugs.quassel-irc.org/wiki/quassel-irc."
	fi

	if use server || use monolithic ; then
		einfo "Quassel can use net-misc/oidentd package if installed on your system."
		einfo "Consider installing it if you want to run quassel within identd daemon."
	fi
}
