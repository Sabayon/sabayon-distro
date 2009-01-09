# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $


inherit distutils

MY_P="Coherence-${PV}"

DESCRIPTION="Coherence is a framework written in Python for DLNA/UPnP components"
HOMEPAGE="https://coherence.beebits.net/"
SRC_URI="http://coherence.beebits.net/download/${MY_P}.tar.gz"
IUSE="web gstreamer"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

# dev-python/Louie is supplied inline now

DEPEND="
	>=dev-lang/python-2.5
	dev-python/twisted
	>=dev-python/configobj-4.3
	gstreamer? ( >=dev-python/gst-python-0.10.12 )
	web? ( dev-python/nevow )
	"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	epatch "${FILESDIR}/${PV}-bind_if_detection.patch"
}

src_install() {
	distutils_src_install
	dodoc docs/*
}


