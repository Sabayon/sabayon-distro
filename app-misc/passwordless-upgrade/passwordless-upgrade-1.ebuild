# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Allow users in the entropy group to run system upgrades without password"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

S="${WORKDIR}"

src_install () {
	dodir /usr/share/polkit-1/rules.d
	insinto /usr/share/polkit-1/rules.d
	doins "${FILESDIR}/10-RigoDaemon.rules"
}
