# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/transkode/transkode-0.6_beta2.ebuild,v 1.5 2006/12/30 20:17:36 ticho Exp $

ARTS_REQUIRED="never"

inherit kde

S="${WORKDIR}/${PN}"

DESCRIPTION="KDE frontend for various audio transcoding tools"
HOMEPAGE="http://kde-apps.org/content/show.php?content=37669"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-fbsd"

IUSE="amarok shorten wavpack"

RDEPEND="media-libs/taglib
	amarok? ( media-sound/amarok )"
DEPEND="${RDEPEND}"
RDEPEND="${RDEPEND}
	shorten? ( media-sound/shorten )
	wavpack? ( media-sound/wavpack )
	media-video/mplayer"

need-kde 3.5

src_compile() {
	local myconf="$(use_enable amarok amarokscript)"

	kde_src_compile
}

pkg_postinst() {
	if use amarok; then
		elog "If you want to use TransKode to encode audio files on the fly"
		elog "when transferring music to a portable media device, remember"
		elog "to start the TransKode script through the Script Manager"
		elog "on the Tools menu."
	fi
}
