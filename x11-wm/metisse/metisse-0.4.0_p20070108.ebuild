# Copyright 2004-2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit autotools eutils

METISSE_BUILD="20070108"
IUSE="mmx dri freetype"
DESCRIPTION="Beryl window manager for AIGLX and XGL"
HOMEPAGE="http://beryl-project.org"
SRC_URI="
	http://www.sabayonlinux.org/distfiles/x11-wm/${PN}-${PV/_*/}/${PN}-${METISSE_BUILD}.tar.bz2
	http://www.sabayonlinux.org/distfiles/x11-wm/${PN}-${PV/_*/}/fvwm-insitu-${METISSE_BUILD}.tar.bz2
	"

LICENSE="MIT"
SLOT="0"
RESTRICT="nomirror"
KEYWORDS="~x86 ~amd64 ~ppc ~ppc64"
S=${WORKDIR}/${PN}-${METISSE_BUILD}

DEPEND="
	>=x11-base/xorg-server-1.1.1-r1
	>=x11-libs/gtk+-2.8.0
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXrandr
	x11-libs/startup-notification
	"

RDEPEND="${DEPEND}"
PDEPEND=""

src_unpack() {
	unpack ${A}
	cd ${S}
	for patch in ${FILESDIR}/${PN}-*.patch; do
		epatch ${patch}
	done

	unpack fvwm-insitu-${METISSE_BUILD}.tar.bz2
}

src_compile() {
	cd ${S}
	WANT_AUTOMAKE="1.7" ./bootstrap

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

	econf ${ECONF_OPTS} || die "econf failed"
	emake || die "make failed"

}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
