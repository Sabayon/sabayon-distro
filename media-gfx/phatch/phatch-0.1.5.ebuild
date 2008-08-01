# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils fdo-mime gnome2-utils

DESCRIPTION="Phatch is a simple to use cross-platform GUI Photo Batch Processor"
HOMEPAGE="http://photobatch.stani.be/"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

SRC_URI="http://sd-2986.dedibox.fr/photobatch/download/package/${P}.tar.gz"

DEPEND="dev-lang/python
	x11-libs/wxGTK
	dev-python/imaging
	sys-apps/findutils"

RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd ${S}

	# Don't update mimetypes, let's the portage do it.
	epatch ${FILESDIR}/dont-update-mimetypes.patch
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
