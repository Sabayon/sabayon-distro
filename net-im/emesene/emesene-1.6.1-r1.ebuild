# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=2
PYTHON_DEPEND="2"

inherit eutils python

DESCRIPTION="Platform independent MSN Messenger client written in Python+GTK"
HOMEPAGE="http://www.emesene.org"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+webcam"

DEPEND=">=x11-libs/gtk+-2.8.20
	>=dev-python/pygtk-2.8.6
	webcam? ( media-libs/libmimic[python] media-plugins/gst-plugins-v4l2 )"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"

src_install() {
	rm -f GPL PSF LGPL
	rm -r libmimic || die "rm failed!"

	insinto /usr/share/emesene
	doins -r * || die "doins failed"

	fperms a+x /usr/share/emesene/emesene || die "fperms failed"
	dosym /usr/share/emesene/emesene /usr/bin/emesene || die "dosym failed"

	doman misc/emesene.1 || die "doman failed"

	doicon misc/*.png misc/*.svg

	# install the desktop entry
	domenu misc/emesene.desktop
}

pkg_postinst() {
	python_mod_optimize /usr/share/emesene
}

pkg_postrm() {
	python_mod_cleanup /usr/share/emesene
}
