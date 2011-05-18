# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

PYTHON_DEPEND="2"
inherit python distutils

DESCRIPTION="The Simple Library for Python packages"
HOMEPAGE="https://fedorahosted.org/python-slip/"
SRC_URI="https://fedorahosted.org/released/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk selinux"
# TODO: split package?
RDEPEND="selinux? ( sys-libs/libselinux )
	dev-python/dbus-python
	|| ( sys-auth/polkit sys-auth/policykit )
	dev-python/decorator
	gtk? ( dev-python/pygtk )"

src_compile() {
	emake || die "cannot run make"
	distutils_src_compile
}
