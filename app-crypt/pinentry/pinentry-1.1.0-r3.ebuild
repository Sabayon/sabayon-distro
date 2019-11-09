# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Simple passphrase entry dialogs which utilize the Assuan protocol (meta package)"
HOMEPAGE="https://gnupg.org/aegypten2/index.html"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
# some use flags are fake, used to mimic portage ebuild USE flags
IUSE="caps emacs gnome-keyring fltk gtk ncurses qt5 static"

RDEPEND="
	~app-crypt/pinentry-base-${PV}
	caps? ( ~app-crypt/pinentry-base-${PV}[caps] )
	gnome-keyring? ( ~app-crypt/pinentry-gnome-${PV} )
	gtk? ( ~app-crypt/pinentry-gtk2-${PV} )
	qt5? ( ~app-crypt/pinentry-qt5-${PV} )
	static? ( ~app-crypt/pinentry-base-${PV}[static] )
	gnome-keyring? ( app-crypt/gcr )"
DEPEND=""

REQUIRED_USE="
	gtk? ( !static )
	qt5? ( !static )
"
