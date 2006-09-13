## Package by jhawk of Sabayon Linux ##
## Ebuild by cvill64/rubengonc of Sabayon Linux ##

# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
inherit eutils 

DESCRIPTION="A GUI configuration tool for XGL under KDE"
SRC_URI=" http://sabayonlinuxdev.com/distfiles/x11-apps/pyXgl.tar.gz "
HOMEPAGE="http://sabayonlinuxdev.com/xglconfig/"
SLOT="0"
LICENSE="GPL-2"
GENTOO_MIRRORS=""
KEYWORDS="~x86 ~amd64"
RDEPEND="${DEPEND}
		kde-base/kdelibs
		dev-lang/python
		x11-base/xgl
		dev-python/PyQt
		"
S=${WORKDIR}/${PN}		 
src_unpack() {
    unpack ${A}
    }
    
src_compile() {
	einfo "Nothing to compile"
    }
    
src_install() {

	dodir /usr/share/pyXgl
	cp -dPR pyXgl ${D}/usr/share/pyXgl
	dosymlink -s /usr/bin/pyXgl

# install to menu using eutils.eclass
	domenu pyXgl.desktop
	doicon pyXgl.png
}

pkg_postinst() {
    echo
    einfo "The program requires that you are using Xgl."
    einfo "For further information about Xgl settings"
    einfo "visit http://gentoo-wiki.com/Xgl"
    einfo "This version works best in KDE."
    einfo "Installed to /usr/share/pyXgl"
    }
