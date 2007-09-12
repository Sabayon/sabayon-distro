# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/vnc/vnc-4.1.2-r4.ebuild,v 1.1 2007/09/04 13:20:37 armin76 Exp $

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"
inherit eutils toolchain-funcs multilib autotools

XSERVER_VERSION="1.4"
PATCH="${P}-r4-patches-0.1"

MY_P="vnc-4_1_2-unixsrc"
DESCRIPTION="Remote desktop viewer display system"
HOMEPAGE="http://www.realvnc.com/"
SRC_URI="http://ltsp.mirrors.tds.net/pub/ltsp/tarballs/${MY_P}.tar.gz
	http://ftp.plusline.de/FreeBSD/distfiles/xc/${MY_P}.tar.gz
	mirror://gentoo/${PATCH}.tar.bz2
	server? ( ftp://ftp.freedesktop.org/pub/xorg/individual/xserver/xorg-server-${XSERVER_VERSION}.tar.bz2	)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="server"

RDEPEND="sys-libs/zlib
	media-libs/freetype
	x11-libs/libSM
	x11-libs/libXtst
	server? (
		x11-libs/libXi
		x11-libs/libXfont
		x11-libs/libXmu
		x11-libs/libxkbfile
		x11-libs/libXrender
		x11-apps/xauth
		x11-apps/xsetroot
		media-fonts/font-adobe-100dpi
		media-fonts/font-adobe-75dpi
		media-fonts/font-alias
		media-fonts/font-cursor-misc
		media-fonts/font-misc-misc
		~x11-base/xorg-server-${XSERVER_VERSION}
	)
	!net-misc/tightvnc"
DEPEND="${RDEPEND}
	x11-proto/xextproto
	server?	(
		x11-proto/compositeproto
		x11-proto/damageproto
		x11-proto/fixesproto
		x11-proto/fontsproto
		x11-proto/inputproto
		x11-proto/randrproto
		x11-proto/resourceproto
		x11-proto/scrnsaverproto
		x11-proto/trapproto
		x11-proto/videoproto
		x11-proto/xineramaproto
		x11-proto/xf86bigfontproto
		x11-proto/xf86dgaproto
		x11-proto/xf86miscproto
		x11-proto/xf86vidmodeproto
	)"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	if ! use server ; then
		echo
		einfo "The 'server' USE flag will build vnc's server."
		einfo "If '-server' is chosen only the client is built to save space."
		einfo "Stop the build now if you need to add 'server' to USE flags.\n"
		ebeep
		epause 5
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	if use server ; then
		mv "${WORKDIR}"/xorg-server-${XSERVER_VERSION} unix/xorg-x11-server-source
	else
		rm -f "${WORKDIR}"/patch/*vnc-server*
	fi

	EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/patch

	cd common
	eautoreconf
	cd ../unix
	eautoreconf

	if use server ; then
		cp -RPp xc/programs/Xserver/vnc/Xvnc/xvnc.cc \
			xc/programs/Xserver/Xvnc.man \
			xc/programs/Xserver/vnc/*.{h,cc} \
			xorg-x11-server-source/hw/vnc
		cp -RPp xorg-x11-server-source/{cfb/cfb.h,hw/vnc}
		cp -RPp xorg-x11-server-source/{fb/fb.h,hw/vnc}
		cp -RPp xorg-x11-server-source/{fb/fbrop.h,hw/vnc}
		sed -i -e 's,xor,c_xor,' -e 's,and,c_and,' \
			xorg-x11-server-source/hw/vnc/{cfb,fb,fbrop}.h
		cd xorg-x11-server-source
		eautoreconf
	fi

	cd "${S}"
	epatch ${FILESDIR}/${P}-freebsd.patch
}

src_compile() {
	cd common
	econf || die "econf failed"
	emake || die "emake failed"
	cd ../unix
	econf || die "econf failed"
	emake || die "emake failed"

	if use server ; then
		cd xorg-x11-server-source
		econf \
			--enable-xorg \
			--disable-xnest --disable-xvfb --disable-dmx \
			--disable-xwin --disable-xephyr --disable-kdrive \
			--with-pic \
			--disable-xorgcfg \
			--disable-xprint \
			--disable-static \
			--enable-composite \
			--enable-xtrap \
			--enable-xcsecurity \
			--with-xkb-output=/usr/share/X11/xkb \
			--with-rgb-path=/usr/share/X11/rgb.txt \
			--disable-xevie \
			--disable-dri \
			--enable-glx \
			--with-int10=stub \
			--with-default-font-path=/usr/share/fonts/misc,/usr/share/fonts/75dpi,/usr/share/fonts/100dpi,/usr/share/fonts/TTF,/usr/share/fonts/Type1 \
			|| die "econf server failed"
		emake || die "emake server failed"
	fi
}

src_install() {
	cd common
	emake DESTDIR="${D}" install || die "emake install failed"
	cd ../unix
	emake DESTDIR="${D}" install || die "emake install failed"
	newman vncviewer/vncviewer.man vncviewer.1
	cd ..
	dodoc README

	doicon ${FILESDIR}/vncviewer.png
	make_desktop_entry vncviewer vncviewer vncviewer.png Network

	if use server ; then
		cd unix
		dobin vncserver || die "dobin failed"
		for f in vncviewer/vncviewer vncpasswd/vncpasswd \
			vncconfig/vncconfig vncserver x0vncserver/x0vncserver; do
			mv $f.man $f.1
			doman $f.1
		done

		cd xorg-x11-server-source/hw/vnc
		emake DESTDIR="${D}" install || die "emake install failed"

		newman Xvnc.man Xvnc.1
		newconfd "${FILESDIR}"/vnc.confd vnc
		newinitd "${FILESDIR}"/vnc.initd vnc

		rm "${D}"/usr/$(get_libdir)/xorg/modules/extensions/libvnc.la
	else
		cd "${D}"
		rm usr/bin/x0vncserver
		rm usr/bin/vncpasswd
		rm usr/bin/vncconfig
	fi

	rm ${D}/usr/$(get_libdir)/librfb.{a,la,so}
}
