# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pykde/pykde-3.16.0.ebuild,v 1.1 2006/10/22 15:40:05 carlo Exp $

inherit eutils distutils

MY_P="PyKDE-${PV/*_pre/snapshot}"
MY_P=${MY_P/_/}
S=${WORKDIR}/${MY_P}

DESCRIPTION="PyKDE is a set of Python bindings for kdelibs."
HOMEPAGE="http://www.riverbankcomputing.co.uk/pykde/"
SRC_URI="mirror://gentoo/${MY_P}.tar.gz"
#SRC_URI="http://www.riverbankcomputing.com/Downloads/PyKDE3/${MY_P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE="debug doc examples"

RDEPEND=">=dev-python/sip-4.4.5
	>=dev-python/PyQt-3.16.0
	kde-base/kdelibs
	!kde-base/pykde"

src_compile() {
	distutils_python_version

	local myconf="-d ${ROOT}/usr/$(get_libdir)/python${PYVER}/site-packages \
			-v ${ROOT}/usr/share/sip \
			-k $(kde-config --prefix)
			-L $(get_libdir)"

	use debug && myconf="${myconf} -u"

	python configure.py ${myconf}
	emake || die
}

src_install() {
	dodir /usr/kde/3.5/lib/
	sed -i -e 's:/usr/kde/3.5/lib/libkonsolepart.so:$(DESTDIR)/usr/kde/3.5/lib/libkonsolepart.so:' Makefile
	make DESTDIR=${D} install || die
#	find ${D}/usr/share/sip -not -type d -not -iname *.sip -exec rm '{}' \;

	dodoc AUTHORS ChangeLog NEWS README THANKS
	use doc && dohtml -r doc/*
	if use examples ; then
		cp -r examples ${D}/usr/share/doc/${PF}
		cp -r templates ${D}/usr/share/doc/${PF}
	fi
}
