# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

MY_PN="Numix"
DESCRIPTION="the Numix flat theme for gtk."
HOMEPAGE="https://github.com/shimmerproject/${MY_PN}"

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/shimmerproject/${MY_PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/shimmerproject/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~x86"
fi

LICENSE="GPL-3.0+"
SLOT="0"

DEPEND=">=x11-libs/gtk+-3.6
	x11-themes/gtk-engines-murrine"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"

src_install() {
	insinto /usr/share/themes/Numix
	doins -r *
	dodoc README.md
}
