# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Collection of simple PIN/passphrase entry dialogs which utilize the Assuan protocol (meta package)"
HOMEPAGE="http://gnupg.org/aegypten2/index.html"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm ~amd64 ~x86"
# ncurses use flag is fake, used to mimic portage ebuild USE flags
IUSE="gtk ncurses qt4 caps static"

RDEPEND="
	~app-crypt/pinentry-base-${PV}
	caps? ( ~app-crypt/pinentry-base-${PV}[caps] )
	gtk? ( ~app-crypt/pinentry-gtk2-${PV} )
	qt4? ( ~app-crypt/pinentry-qt4-${PV} )
	static? ( ~app-crypt/pinentry-base-${PV}[static] )"
DEPEND=""

REQUIRED_USE="
	|| ( ncurses gtk qt4 )
	gtk? ( !static )
	qt4? ( !static )
	static? ( ncurses )
"
