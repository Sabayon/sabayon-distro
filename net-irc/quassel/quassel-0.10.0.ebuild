# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils eutils

EGIT_REPO_URI="git://git.quassel-irc.org/quassel"
[[ "${PV}" == "9999" ]] && inherit git-r3

DESCRIPTION="Qt4/KDE IRC client - monolithic client only (no remote daemon)"
HOMEPAGE="http://quassel-irc.org/"
[[ "${PV}" == "9999" ]] || SRC_URI="http://quassel-irc.org/pub/${P/_/-}.tar.bz2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
# monolithic USE flag is not used, but let's have it here to be compatible
# with Portage ebuild
IUSE="ayatana crypt dbus debug -kde monolithic -phonon postgres +server +ssl syslog webkit X"

SERVER_RDEPEND="
	dev-qt/qtscript:4
	crypt? (
		app-crypt/qca:2
		app-crypt/qca-ossl
	)
	!postgres? ( dev-qt/qtsql:4[sqlite] dev-db/sqlite:3[threadsafe(+),-secure-delete] )
	postgres? ( dev-qt/qtsql:4[postgres] )
	syslog? ( virtual/logger )
"

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
	${SERVER_RDEPEND}
	${GUI_RDEPEND}
	"
DEPEND="${RDEPEND}
	kde? ( dev-util/automoc )"

S="${WORKDIR}/${P/_/-}"

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_with ayatana LIBINDICATE)
		"-DWANT_CORE=OFF"
		"-DWANT_QTCLIENT=OFF"
		"-DWANT_MONO=ON"
		$(cmake-utils_use_with webkit)
		$(cmake-utils_use_with phonon)
		$(cmake-utils_use_with kde)
		$(cmake-utils_use_with dbus)
		$(cmake-utils_use_with ssl OPENSSL)
		$(cmake-utils_use_with syslog)
		"-DWITH_OXYGEN=OFF"
		$(cmake-utils_use_with crypt)
		"-DEMBED_DATA=OFF"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rm -r "${ED}"usr/share/apps
	rm -r "${ED}"usr/share/pixmaps
	rm -r "${ED}"usr/share/icons
	rm -r "${ED}"usr/share/applications

	insinto /usr/share/applications
	doins data/quassel.desktop
}

pkg_postinst() {
	if use ssl ; then
		elog "Information on how to enable SSL support for client/core connections"
		elog "is available at http://bugs.quassel-irc.org/wiki/quassel-irc."
	fi

	# server || monolithic
	einfo "Quassel can use net-misc/oidentd package if installed on your system."
	einfo "Consider installing it if you want to run quassel within identd daemon."
}
