# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit autotools libtool eutils

IUSE="mmx dri freetype"
DESCRIPTION="Beryl window manager for AIGLX and XGL"
HOMEPAGE="http://beryl-project.org"
SRC_URI="
	http://www.sabayonlinux.org/distfiles/x11-wm/${P}/${P/_/-}.tar.bz2
	"

LICENSE="MIT"
SLOT="0"
RESTRICT="nomirror"
KEYWORDS="~x86 ~amd64 ~ppc ~ppc64"

DEPEND="
	>=x11-base/xorg-server-1.1.1-r1
	>=x11-libs/gtk+-2.8.0
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXrandr
	x11-libs/startup-notification
	x11-libs/nucleo
	"

RDEPEND="${DEPEND}"
PDEPEND=""

S=${WORKDIR}/${P/_/-}

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch ${FILESDIR}/${PN}-20061130-background.patch
	epatch ${FILESDIR}/${PN}-20061201-a11y.patch
	epatch ${FILESDIR}/${PN}-defaults.patch
	epatch ${FILESDIR}/${PN}-20070112-64bit-fixes.patch
	epatch ${FILESDIR}/${P/_/-}-fixglx.patch
	epatch ${FILESDIR}/fvwm-insitu-20070117-fixkdetray.patch
	epatch ${FILESDIR}/${P/_/-}-fixpagerborder.patch

}

src_compile() {
	cd ${S}

	ECONF_OPTS=""
	if use mmx || use amd64; then
		ECONF_OPTS="${ECONF_OPTS} --enable-mmx"
	fi

	if use dri; then
		ECONF_OPTS="${ECONF_OPTS} --enable-glx"
	fi

	if use freetype; then
		ECONF_OPTS="${ECONF_OPTS} --enable-freetype"
	fi

	eautoreconf || die "eautoreconf failed"
	econf ${ECONF_OPTS} || die "econf failed"
	emake || die "make failed"

}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	# Install X Sessions
	insinto /usr/share/xsessions
        doins ${FILESDIR}/${PN}-session/*.desktop
	
	# Install handlers
	exeinto /usr/share/metisse
        doexe ${FILESDIR}/${PN}-session/metisse-session
        doexe ${FILESDIR}/${PN}-session/metisse-session-kde
        doexe ${FILESDIR}/${PN}-session/metisse-session-gnome

}
