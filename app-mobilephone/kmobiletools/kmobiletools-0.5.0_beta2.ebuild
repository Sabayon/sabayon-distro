# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit kde

MY_P=${P/_/-}
S=${WORKDIR}/${MY_P}

DESCRIPTION="KMobiletools is a KDE-based application that allows to control mobile phones with your PC."
SRC_URI="http://download2.berlios.de/kmobiletools/${MY_P}.tar.bz2"
HOMEPAGE="http://www.kmobiletools.org/"
LICENSE="GPL-2"

IUSE="kde"
KEYWORDS="~amd64 ~ppc ~x86"

RDEPEND="kde? ( || ( ( kde-base/libkcal kde-base/kontact ) kde-base/kdepim ) )"
DEPEND="${RDEPEND}"

need-kde 3.3

src_compile() {
	myconf="$(use_enable kde libkcal)
		$(use_enable kde kontact-plugin)"

	kde_src_compile
}

