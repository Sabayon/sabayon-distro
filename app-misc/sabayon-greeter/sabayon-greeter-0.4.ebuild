# Copyright 2004-2016 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

DESCRIPTION="Sabayon Welcome screen"
HOMEPAGE="http://www.sabayon.org"
SRC_URI="https://github.com/Sabayon/${PN}/archive/v${PVR}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 arm x86"
IUSE=""
S="${WORKDIR}/${PN}-${PVR}"
DEPEND=""
RDEPEND="dev-python/pygobject-base:3
	dev-python/simplejson
	x11-libs/gtk+:3"

src_install() {
	emake DESTDIR="${D}" \
		install || die
}
