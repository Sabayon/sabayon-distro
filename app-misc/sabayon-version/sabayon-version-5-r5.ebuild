# Copyright 2004-2011 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Sabayon Linux Release version file"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""
DEPEND=""
# Listing default packages for the current release
RDEPEND="dev-lang/python:2.7
	sys-devel/gcc:4.5"

SABAYON_VER="${PV}"
SABAYON_HEADER="Sabayon Linux"
SABAYON_RELEASE="sabayon-release"

src_unpack () {
	if use x86; then
		echo "${SABAYON_HEADER} x86 ${SABAYON_VER}" > "${SABAYON_RELEASE}"
	else
		echo "${SABAYON_HEADER} amd64 ${SABAYON_VER}" > "${SABAYON_RELEASE}"
	fi
}

src_install () {
	insinto /etc/
	doins sabayon-release
	dosym /etc/sabayon-release /etc/system-release
}
