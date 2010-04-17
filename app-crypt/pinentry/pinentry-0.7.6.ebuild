# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit multilib eutils flag-o-matic

DESCRIPTION="Collection of simple PIN or passphrase entry dialogs which utilize the Assuan protocol (meta-package)"
HOMEPAGE="http://www.gnupg.org/aegypten/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="gtk qt4"

DEPEND="~app-crypt/pinentry-base-${PV}
	gtk? ( ~app-crypt/pinentry-gtk2-${PV} )
	qt4? ( ~app-crypt/pinentry-qt4-${PV} )"
RDEPEND="${DEPEND}"
