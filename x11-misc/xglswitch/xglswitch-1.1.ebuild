## Package by jhawk of SabayonLinux ##
## Ebuild by cvill64 of SabayonLinux ##

# Distributed under the terms of the GNU General Public License v2
# $Header: $
inherit eutils 

DESCRIPTION="A GUI configuration tool to switch XGL, logon manager, and opengl settings"
SRC_URI="http://sabayonlinuxdev.com/distfiles/x11-misc/${PN}-1.1.tar.gz"
HOMEPAGE="http://sabayonlinuxdev.com/xglswitch/"
GENTOO_MIRRORS="http://sabayonlinuxdev.com/distfiles/"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
RDEPEND="${DEPEND}
             dev-lang/python
             x11-base/xgl
             "
S=${WORKDIR}/${PN}
src_unpack() {
    unpack ${A}
    }
    
src_compile() {
       einfo "Nothing to compile"
    }
    
src_install() {

	dodir /usr/share/xglswitch
	cp -dPR ${S} ${D}/usr/share/
	dosym /usr/share/xglswitch/xglswitch /usr/bin/xglswitch
	dodoc README

# install to menu using eutils.eclass
       domenu xglswitch.desktop
       doicon compiz.png
}

pkg_postinst() {
    echo
    einfo "The program requires that you are using Xgl and it is preconfigured."
    einfo "For further information about Xgl settings visit http://gentoo-wiki.com/Xgl."
    }