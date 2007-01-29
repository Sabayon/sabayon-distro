 	

#lacie/4L/4L-1.0-r6.ebuild
LICENSE="non-free" # What is the license for this software?
RESTRICT="nomirror"
HOMEPAGE="http://www.lacie.com/lightscribe/"
SRC_URI="http://www.lacie.com/download/drivers/${P}-r6.i586.rpm"

KEYWORDS="amd64"

DEPEND="app-emulation/emul-linux-x86-baselibs
        app-emulation/emul-linux-x86-compat
        app-emulation/emul-linux-x86-xlibs
        sys-devel/gcc
        sys-libs/glibc
        app-arch/rpm
        lacie/lightscribe"

DESCRIPTION="LaCie LightScribe Labeler for Linux"

SLOT="0"
IUSE=""

src_unpack() {
        rpm2cpio ${DISTDIR}/${A} | cpio -id
}

src_compile() {
        chmod a+rx $(find ${WORKDIR} -type d)
        chmod -R a+r ${WORKDIR}
}

src_install() {
        mv ${WORKDIR}/* ${D}/
} 
