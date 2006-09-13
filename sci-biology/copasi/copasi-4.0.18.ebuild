## Ebuild by cvill64 of SabayonLinux ##

# Distributed under the terms of the GNU General Public License v2
# $Header: $
inherit eutils 

DESCRIPTION="Copasi is a software application for simulation and analysis of biochemical networks."
SRC_URI="http://sabayonlinuxdev.com/distfiles/sci-biology/${PN}-4.0.18.tar.gz"
HOMEPAGE="http://www.copasi.org"
GENTOO_MIRRORS="http://sabayonlinuxdev.com/distfiles/"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
RDEPEND="${DEPEND}
	>=glibc-2.3.6
             "
S=${WORKDIR}/${PN}
src_unpack() {
    unpack ${A}
    }
    
src_compile() {
       check_license ${S}/LICENSE
    }
    
src_install() {

       dodir /usr/share/copasi
       cp -dPR ${S} ${D}/usr/share/
       dobin ${S}/bin/CopasiUI
       dosym /usr/share/copasi /usr/bin/copasi
       dodoc ${S}/doc/*

# install to menu using eutils.eclass
       doicon ${S}/icons/*
       export COPASI=${D}/usr/share/copasi
}

pkg_postinst() {
    echo
    einfo "http://www.copasi.org"
    }