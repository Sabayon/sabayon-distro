# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# Thev00d00 06/09/2009

EAPI="2"

inherit kde4-base

MY_P=${P/_/-}
BRANDINGVER="1"

DESCRIPTION="Sysinfo Kioslave for KDE4"
HOMEPAGE="http://svn.opensuse/org/svn/kio_sysinfo"
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${P}.tar.lzma
	http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${PN}-sabayon-artwork-${BRANDINGVER}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

RDEPEND=""

src_prepare() {
  mv ../sabayon ${S}/src/about

  cd ${S}/src
  # Make it compile
  epatch ${FILESDIR}/${P}-fix-const-conv.patch
  # Add SL Branding
  epatch ${FILESDIR}/${PN}-sabayon-branding.patch
}

