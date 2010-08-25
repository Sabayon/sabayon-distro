# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/amarok/amarok-2.3.1-r2.ebuild,v 1.5 2010/08/24 01:44:26 jmbsvicetto Exp $

EAPI="2"

# Translations are only in the tarballs, not the git repo
if [[ ${PV} != *9999* ]]; then
	KDE_LINGUAS="bg ca cs da de en_GB es et eu fi fr it ja km nb nds nl
	pa pl pt pt_BR ru sl sr sr@latin sv th tr uk wa zh_TW"
	SRC_URI="mirror://kde/stable/${PN}/${PV}/src/${P}.tar.bz2"
else
	EGIT_REPO_URI="git://git.kde.org/${PN}/${PN}.git"
	GIT_ECLASS="git"
fi

KDE_REQUIRED="never"
inherit flag-o-matic kde4-base ${GIT_ECLASS}

DESCRIPTION="Advanced audio player based on KDE framework."
HOMEPAGE="http://amarok.kde.org/"

LICENSE="GPL-2"
KEYWORDS="amd64 ~ppc ~ppc64 x86"
SLOT="4"
IUSE="cdda daap debug embedded ipod lastfm mp3tunes mtp opengl +player semantic-desktop +utils"

# Tests require gmock - http://code.google.com/p/gmock/
# It's not in the tree yet
RESTRICT="test"

# ipod requires gdk enabled and also gtk compiled in libgpod
DEPEND="
	>=media-libs/taglib-1.6.1[asf,mp4]
	>=media-libs/taglib-extras-1.0.1
	player? (
		app-crypt/qca:2
		>=app-misc/strigi-0.5.7[dbus,qt4]
		|| ( >=dev-db/mysql-5.0.76 =virtual/mysql-5.1 )
		>=kde-base/kdelibs-${KDE_MINIMAL}[opengl?,semantic-desktop?]
		sys-libs/zlib
		x11-libs/qt-script
		>=x11-libs/qtscriptgenerator-0.1.0
		cdda? (
			>=kde-base/libkcddb-${KDE_MINIMAL}
			>=kde-base/libkcompactdisc-${KDE_MINIMAL}
			>=kde-base/kdemultimedia-kioslaves-${KDE_MINIMAL}
		)
		embedded? ( dev-db/mysql[embedded,-minimal,pic] )
		ipod? ( >=media-libs/libgpod-0.7.0[gtk] )
		lastfm? ( >=media-libs/liblastfm-0.3.0 )
		mp3tunes? (
			dev-libs/glib:2
			dev-libs/libxml2
			dev-libs/openssl
			net-libs/loudmouth
			net-misc/curl
			x11-libs/qt-core[glib]
		)
		mtp? ( >=media-libs/libmtp-0.3.0 )
		opengl? ( virtual/opengl )
	)
	utils? (
		x11-libs/qt-core
		x11-libs/qt-dbus
	)
	!player? ( !utils? ( media-sound/amarok[player] ) )
"
RDEPEND="${DEPEND}
	!media-sound/amarok-utils
	player? ( >=kde-base/phonon-kde-${KDE_MINIMAL} )
"

# The fix trayicon patch was assembled from the 4 patches committed by Kevin Funk to fix
# upstream bug at https://bugs.kde.org/show_bug.cgi?id=232578#c13 and available from
# http://krf.kollide.net/files/work/amarok/
# They correspond to the following 4 git commits:
# http://gitweb.kde.org/amarok/amarok.git/commit/e959e75a8f028eb36406d65118885c32e3eff3c8
# http://gitweb.kde.org/amarok/amarok.git/commit/26104cd35fd50222c354f3afc9fce6bba093c05f
# http://gitweb.kde.org/amarok/amarok.git/commit/4995f14cefbbe78e9dd3c42af00188e6c82e6f94
# http://gitweb.kde.org/amarok/amarok.git/commit/74ea4c1f9e69952ac274be44ab37ed073e61c1e6
PATCHES=( "${FILESDIR}/${PN}-fix-accessibility-dep.patch" "${FILESDIR}/${P}-fix-trayicon.patch")

src_prepare() {
	if ! use player; then
		# Disable po processing
		sed -e "s:include(MacroOptionalAddSubdirectory)::" \
			-i "${S}/CMakeLists.txt" \
			|| die "Removing include of MacroOptionalAddSubdirectory failed."
		sed -e "s:macro_optional_add_subdirectory( po )::" \
			-i "${S}/CMakeLists.txt" \
			|| die "Removing include of MacroOptionalAddSubdirectory failed."
	fi

	kde4-base_src_prepare
}

src_configure() {
	# Append minimal-toc cflag for ppc64, see bug 280552 and 292707
	use ppc64 && append-flags -mminimal-toc

	if use player; then
		mycmakeargs=(
			-DWITH_PLAYER=ON
			-DWITH_Libgcrypt=OFF
			$(cmake-utils_use embedded WITH_MYSQL_EMBEDDED)
			$(cmake-utils_use_with ipod)
			$(cmake-utils_use_with ipod Gdk)
			$(cmake-utils_use_with lastfm LibLastFm)
			$(cmake-utils_use_with mtp)
			$(cmake-utils_use_with mp3tunes MP3Tunes)
		)
	else
		mycmakeargs=(
			-DWITH_PLAYER=OFF
		)
	fi

	mycmakeargs+=(
		$(cmake-utils_use_with utils UTILITIES)
	)
		# $(cmake-utils_use_with semantic-desktop Nepomuk)
		# $(cmake-utils_use_with semantic-desktop Soprano)

	kde4-base_src_configure
}

pkg_postinst() {
	kde4-base_pkg_postinst

	if use player; then

		if use daap; then
			echo
			elog "You have installed amarok with daap support."
			elog "You may be interested in installing www-servers/mongrel as well."
			echo
		fi

		if ! use embedded; then
			echo
			elog "You've disabled the amarok support for embedded mysql DBs."
			elog "You'll have to configure amarok to use an external db server."
			echo
			elog "Please read http://amaroklive.com/wiki/MySQL_Server for details on how"
			elog "to configure the external db and migrate your data from the embedded database."
			echo

			if has_version "dev-db/mysql[minimal]"; then
				elog "You built mysql with the minimal use flag, so it doesn't include the server."
				elog "You won't be able to use the local mysql installation to store your amarok collection."
				echo
			fi
		fi
	fi
}
