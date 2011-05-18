# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

EGIT_REPO_URI="git://git.fedorahosted.org/python-meh.git"
EGIT_COMMIT="r${PV}-1"
inherit distutils git eutils

DESCRIPTION="Python exception handling library"
HOMEPAGE="http://git.fedoraproject.org/git/python-meh.git?p=python-meh.git;a=summary"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk"

COMMON_DEPEND="dev-util/intltool
	sys-devel/gettext"
DEPEND="${COMMON_DEPEND}"
# FIXME: missing RDEPENDs: rpm, yum
RDEPEND="${COMMON_DEPEND}
	dev-libs/newt
	gtk? ( dev-python/pygtk:2 )
	dev-python/dbus-python
	dev-python/python-report
	net-misc/openssh"

src_prepare() {
	cd "${S}"
	epatch "${FILESDIR}/${PN}-keep_exc_win_above.patch"
	distutils_src_prepare
}
