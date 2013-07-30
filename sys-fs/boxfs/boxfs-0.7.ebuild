# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=4

inherit eutils

DESCRIPTION="A FUSE filesystem to access files on your box.net account"
HOMEPAGE="http://code.google.com/p/boxfs/"

if [[ ${PV} == "9999" ]] ; then
	inherit subversion
	KEYWORDS=""
	ESVN_REPO_URI="http://boxfs.googlecode.com/svn/trunk/"
else
	KEYWORDS="~amd64 ~x86"
	MY_PV=${PV/\./_}
	SRC_URI="http://boxfs.googlecode.com/files/${P}.tgz"
fi

LICENSE="GPL3"
SLOT="0.7"

IUSE="gnome X"

DEPEND="sys-fs/fuse
	dev-libs/libxml2
	dev-libs/libzip
	dev-libs/libapp
	net-misc/curl"

RDEPEND="${DEPEND}"

src_install() {
	dodir /usr/local/bin
	into /usr/local
	dobin boxfs || die "Install failed"
}
