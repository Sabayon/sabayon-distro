# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xscreensaver/xscreensaver-5.07.ebuild,v 1.1 2008/09/09 02:42:50 robbat2 Exp $

inherit autotools eutils flag-o-matic multilib pam

DESCRIPTION="A modular screen saver and locker for the X Window System"
SRC_URI="http://www.jwz.org/xscreensaver/${P}.tar.gz"
HOMEPAGE="http://www.jwz.org/xscreensaver"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="jpeg new-login opengl pam suid xinerama"

RDEPEND="x11-libs/libXmu
	x11-libs/libXxf86vm
	x11-libs/libXrandr
	x11-libs/libXxf86misc
	x11-libs/libXt
	x11-libs/libX11
	x11-libs/libXext
	x11-apps/xwininfo
	x11-apps/appres
	media-libs/netpbm
	>=dev-libs/libxml2-2.5
	>=x11-libs/gtk+-2
	>=gnome-base/libglade-1.99
	pam? ( virtual/pam )
	jpeg? ( media-libs/jpeg )
	opengl? ( virtual/opengl )
	xinerama? ( x11-libs/libXinerama )
	new-login? ( gnome-base/gdm )"
DEPEND="${RDEPEND}
	x11-proto/xf86vidmodeproto
	x11-proto/xextproto
	x11-proto/scrnsaverproto
	x11-proto/recordproto
	x11-proto/xf86miscproto
	sys-devel/bc
	dev-util/pkgconfig
	sys-devel/gettext
	dev-util/intltool
	xinerama? ( x11-proto/xineramaproto )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	EPATCH_FORCE="yes" EPATCH_SUFFIX="patch" epatch "${FILESDIR}"/${PV}
	eautoreconf # bug 113681
}

src_compile() {
	if use ppc || use ppc64; then
		# Still fails to build "flurry" screensaver.
		filter-flags -mabi=altivec
		filter-flags -maltivec
		append-flags -U__VEC__
	fi

	unset BC_ENV_ARGS

	econf \
		--with-x-app-defaults=/usr/share/X11/app-defaults \
		--with-hackdir=/usr/$(get_libdir)/misc/${PN} \
		--with-configdir=/usr/share/${PN}/config \
		--x-libraries=/usr/$(get_libdir) \
		--x-includes=/usr/include \
		--with-dpms-ext \
		--with-xf86vmode-ext \
		--with-xf86gamma-ext \
		--with-randr-ext \
		--with-proc-interrupts \
		--with-xpm \
		--with-xshm-ext \
		--with-xdbe-ext \
		--enable-locking \
		--without-kerberos \
		--without-gle \
		--with-gtk \
		--with-pixbuf \
		$(use_with suid setuid-hacks) \
		$(use_with new-login login-manager) \
		$(use_with xinerama xinerama-ext) \
		$(use_with pam) \
		$(use_with opengl gl) \
		$(use_with jpeg)

	emake -j1 || die "emake failed." # bug 155049
}

src_install() {
	emake install_prefix="${D}" install || die "emake install failed."

	dodoc README{,.hacking}

	use pam && fperms 755 /usr/bin/${PN}
	pamd_mimic_system ${PN} auth

	# bug 135549
	rm -f "${D}"/usr/share/${PN}/config/{electricsheep,fireflies}.xml
	dodir /usr/share/man/man6x
	mv "${D}"/usr/share/man/man6/worm.6 \
		"${D}"/usr/share/man/man6x/worm.6x
}
