# Copyright 2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit kde

DESCRIPTION="Blended, Window Decoration native KDE 3.2 +"
HOMEPAGE="http://kde-look.org/content/show.php/Blended?content=32613"
SRC_URI="http://kde-look.org/CONTENT/content-files/32613-Blended-${PV}.tar.bz2"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="arts"

DEPEND="kde-base/kwin:3.5
	arts? ( kde-base/arts:3.5 )"
RDEPEND="$DEPEND"

S="${WORKDIR}/Blended-${PV}"
src_compile() {
	econf --prefix /usr/kde/3.5 $(use_with arts ) || die "econf failed"
}

#src_install() {
#	emake DESTDIR="${D}" install || die "install failed"
#}

