# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils
DESCRIPTION="Simple ASDF-BINARY-LOCATIONS configuration for Gentoo Common Lisp ports."
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/common-lisp/guide.xml"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S=${WORKDIR}

DEPEND="dev-lisp/asdf-binary-locations"
RDEPEND="${DEPEND}"

src_prepare() {
	cp "${FILESDIR}"/gentoo-init.lisp "${T}/" || die
	# bug 411453
	# One can say it's silly to patch a file from FILESDIR,
	# but it's better for maint. and bug tracking reasons.
	epatch "-d${T}" "${FILESDIR}"/maxima-build.patch
}

src_install() {
	insinto /etc
	doins "${T}"/gentoo-init.lisp
}
