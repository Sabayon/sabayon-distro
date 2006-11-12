# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils subversion

ESVN_PROJECT=v19-devel

ESVN_OPTIONS="-r{${PV/*_pre}}"
ESVN_REPO_URI="https://www.portaudio.com/repos/portaudio/branches/${ESVN_PROJECT}"
ESVN_STORE_DIR="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}/svn-src/www.portaudio.com"

S=${WORKDIR}/${ESVN_PROJECT}



DESCRIPTION="An open-source cross platform audio API."
HOMEPAGE="http://www.portaudio.com"
#SRC_URI="http://www.portaudio.com/archives/${MY_P}.zip"

LICENSE="GPL-2"
SLOT="2"
#KEYWORDS="amd64 ~hppa ~mips ~ppc ~ppc-macos ~ppc64 ~sparc x86"
KEYWORDS="-*"
IUSE="oss alsa jack doc"

DEPEND="alsa? ( media-libs/alsa-lib )
	jack? ( media-sound/jack-audio-connection-kit )"

RDEPEND="virtual/libc
	${DEPEND}"

S=${WORKDIR}/${ECVS_MODULE}

src_compile () 
{
	myconf="$(use_with alsa) $(use_with oss) $(use_with jack)"
	econf ${myconf} || die "configure failed"
	emake || die "make failed"
}

src_install () 
{
	einstall || die "install failed"
	
	dodir /usr/include/${PN}-${SLOT}
	mv ${D}/usr/include/portaudio.h ${D}/usr/include/${PN}-${SLOT}

	mv ${D}/usr/$(get_libdir)/libportaudio$(get_libname 2.0.0) ${D}/usr/$(get_libdir)/libportaudio-${SLOT}$(get_libname 2.0.0)
	mv ${D}/usr/$(get_libdir)/libportaudio.a ${D}/usr/$(get_libdir)/libportaudio-${SLOT}.a
	
	rm ${D}/usr/$(get_libdir)/libportaudio$(get_libname 2) ${D}/usr/$(get_libdir)/libportaudio$(get_libname)
	
	dosym /usr/$(get_libdir)/libportaudio-${SLOT}$(get_libname 2.0.0) /usr/$(get_libdir)/libportaudio-${SLOT}$(get_libname 2)
	dosym /usr/$(get_libdir)/libportaudio-${SLOT}$(get_libname 2.0.0) /usr/$(get_libdir)/libportaudio-${SLOT}$(get_libname)
	
	mv ${D}/usr/$(get_libdir)/libportaudio.la ${D}/usr/$(get_libdir)/libportaudio-${SLOT}.la
	dosed -i -e "s:libportaudio:libportaudio-${SLOT}:g" /usr/$(get_libdir)/libportaudio-${SLOT}.la
	
	dosed -i -e "s:-lportaudio:-lportaudio-${SLOT}:g" /usr/$(get_libdir)/pkgconfig/portaudio-2.0.pc
	
	dodoc LICENSE.txt README.txt V19-devel-readme.txt

}
