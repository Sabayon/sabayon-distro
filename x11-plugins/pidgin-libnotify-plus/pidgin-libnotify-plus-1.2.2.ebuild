# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Provides libnotify interface to Pidgin"
HOMEPAGE="http://sardemff7.github.com/pidgin-libnotify-plus"
SRC_URI="https://github.com/downloads/sardemff7/${PN}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

DEPEND=">=x11-libs/libnotify-0.3.2
	>=net-im/pidgin-2.6.0[gtk]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P/-plus/+}"

src_configure() {
	econf $(use_enable debug)
}
