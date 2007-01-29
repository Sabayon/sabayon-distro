#lacie/lightscribe/lightscribe-1.4.113.1.ebuild
LICENSE="non-free" # What is the license for this software?
RESTRICT="nomirror"
HOMEPAGE="http://www.lacie.com/lightscribe/"
SRC_URI="http://www.lacie.com/download/drivers/${P}-linux-2.6-intel.rpm"

KEYWORDS="amd64"
DESCRIPTION="LightScribe Host Software for Linux"

DEPEND="app-emulation/emul-linux-x86-compat
        sys-devel/gcc
        sys-libs/glibc
        app-arch/rpm"

SLOT="0"
IUSE=""


src_unpack() {
        rpm2cpio ${DISTDIR}/${A} | cpio -id
}

src_compile() {
        chmod a+rx $(find ${WORKDIR} -type d)
        chmod -R a+r ${WORKDIR}
        mkdir -p ${WORKDIR}/usr/lib32
        mv ${WORKDIR}/usr/lib/*.so* ${WORKDIR}/usr/lib32/
}

src_install() {
        mv ${WORKDIR}/* ${D}/
} 
