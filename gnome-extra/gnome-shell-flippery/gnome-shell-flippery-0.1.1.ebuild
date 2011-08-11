# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

DESCRIPTION="Several GNOME Shell extensions that turns your Desktop into GNOME2 (kinda)"
HOMEPAGE="http://intgat.tigress.co.uk/rmy/extensions/index.html"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="gnome-base/gnome-shell"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

src_install()	{
	insinto /usr/share/gnome-shell/extensions
	doins -r *
}
