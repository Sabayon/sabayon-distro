## Package by jhawk of Sabayon Linux ##
## Ebuild by cvill64/rubengonc of Sabayon Linux ##
# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
inherit eutils

DESCRIPTION="A GUI configuration tool for XGL under gnome"
SRC_URI=" http://sabayonlinuxdev.com/distfiles/x11-apps/wxXgl-0.1.tar.gz "
HOMEPAGE="http://sabayonlinuxdev.com/xglconfig/"
SLOT="0"
LICENSE="GPL-2"
GENTOO_MIRRORS=""
KEYWORDS="~x86 ~amd64"
RDEPEND="${DEPEND}
             gnome-base/libgnome
             dev-lang/python
             dev-python/wxpython
             x11-base/xgl
	     x11-libs/gksu
             "

S=${WORKDIR}/${PN}
src_unpack() {
    unpack ${A}
    }

src_compile() {
	einfo "Nothing to compile"
    }

src_install() {
# no need to compile, just moving programs to the correct places
	dodir /usr/share/wxXgl
	cp -dPR wxXgl ${D}/usr/share/wxXgl
	dosymlink /usr/bin/wxXgl

# install to menu using eutils.eclass
domenu wxXgl.desktop
doicon wxXgl.png
}

pkg_postinst() {
    echo
    einfo "The program requires that you are using Xgl."
    einfo "For further information about Xgl settings"
    einfo "visit http://gentoo-wiki.com/Xgl"
    einfo "This version works best in gnome."
    einfo "Installed to /usr/share/wxXgl"
    }