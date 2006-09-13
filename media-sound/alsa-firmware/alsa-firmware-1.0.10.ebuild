# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/alsa-firmware/alsa-firmware-1.0.10.ebuild,v 1.2 2006/01/13 01:49:44 gustavoz Exp $

DESCRIPTION="Advanced Linux Sound Architecture firmware"
HOMEPAGE="http://www.alsa-project.org/"
SRC_URI="mirror://alsaproject/firmware/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 sparc ~x86"
IUSE=""

DEPEND=""

src_compile() {
	econf \
		--with-hotplug-dir=/lib/firmware \
		|| die "configure failed"

	emake || die "make failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc README
}
