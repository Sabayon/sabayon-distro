# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
PYTHON_DEPEND="2"
inherit eutils python

DESCRIPTION="Entropy Package Manager notification applet GTK2 frontend"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

SRC_URI="mirror://sabayon/sys-apps/entropy-${PV}.tar.bz2"
S="${WORKDIR}/entropy-${PV}/magneto"

RDEPEND="~app-misc/magneto-loader-${PV}
	dev-python/notify-python
	dev-python/pygtk:2
"
DEPEND=""

src_compile() {
	einfo "nothing to compile"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="usr/lib" magneto-gtk-install || die "make install failed"
}

pkg_postinst() {
	python_mod_optimize "/usr/lib/entropy/magneto/magneto/gtk"
}

pkg_postrm() {
	python_mod_cleanup "/usr/lib/entropy/magneto/magneto/gtk"
}
