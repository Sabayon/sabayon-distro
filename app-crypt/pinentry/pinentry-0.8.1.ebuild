# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Collection of simple PIN or passphrase entry dialogs which utilize the Assuan protocol (meta package)"
HOMEPAGE="http://gnupg.org/aegypten2/index.html"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# ncurses use flag is fake, used to mimic portage ebuild USE flags
IUSE="gtk ncurses qt4 caps static"

RDEPEND="
	caps? ( ~app-crypt/pinentry-base-${PV}[caps] )
	static? (
		~app-crypt/pinentry-base-${PV}[static]
		gtk? ( ~app-crypt/pinentry-gtk2-${PV}[static] )
		qt4? ( ~app-crypt/pinentry-qt4-${PV}[static] )
	)
	!static? (
		~app-crypt/pinentry-base-${PV}
		gtk? ( ~app-crypt/pinentry-gtk2-${PV} )
		qt4? ( ~app-crypt/pinentry-qt4-${PV} )
	)"
DEPEND=""
