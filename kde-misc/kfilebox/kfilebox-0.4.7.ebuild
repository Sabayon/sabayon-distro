# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

CMAKE_REQUIRED="never"
inherit kde4-base qt4-r2

DESCRIPTION="A KDE dropbox client"
HOMEPAGE="http://kdropbox.deuteros.es/"
SRC_URI="mirror://sourceforge/kdropbox/${P}.tar.gz"
LICENSE="GPL-3"

SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="$(add_kdebase_dep kdelibs)"
RDEPEND="${DEPEND}"

src_install() {
	qt4-r2_src_install

	cd locale || die
	local lang
	for lang in ${LINGUAS}; do
		if [[ -f ${lang}/${PN}.mo ]]; then
			insinto /usr/share/locale/"${lang}"/LC_MESSAGES
			doins "${lang}/${PN}.mo"
		fi
	done
}
