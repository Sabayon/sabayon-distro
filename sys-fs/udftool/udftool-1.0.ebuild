## Package by jhawk of SabayonLinux ##
## Ebuild by cvill64 of SabayonLinux ##

# Distributed under the terms of the GNU General Public License v2
# $Header: $
inherit eutils

DESCRIPTION="A GUI configuration tool to easily implement udftools for backups"
SRC_URI="http://sabayonlinuxdev.com/distfiles/sys-fs/${PN}-1.0.tar.gz"
HOMEPAGE="http://svn.sabayonlinuxdev.com/jhawk/udftool"
GENTOO_MIRRORS="http://sabayonlinuxdev.com/distfiles/"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
RDEPEND="${DEPEND}
	sys-fs/udftools
	dev-lang/python
             "
S=${WORKDIR}/${PN}
src_unpack() {
    unpack ${A}
    }

src_compile() {
       einfo "Nothing to compile"
    }

src_install() {
        dodir /usr/share/udftool
        cp -dPR ${S} ${D}/usr/share/
        dosym /usr/share/udftool /usr/bin/
	dobin udftool
	domenu udftool.desktop
        doicon cdwriter.png
}
