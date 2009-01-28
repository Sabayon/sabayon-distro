# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxcb/libxcb-1.1.90.1.ebuild,v 1.1 2008/07/30 22:38:05 dberkholz Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular eutils

DESCRIPTION="X C-language Bindings library"
HOMEPAGE="http://xcb.freedesktop.org/"
SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"
LICENSE="X11"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc selinux"
SLOPPY_ENV_FILE="/etc/env.d/00xcbsloppy"
RDEPEND="x11-libs/libXau
	x11-libs/libXdmcp
	dev-libs/libpthread-stubs"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	dev-libs/libxslt
	>=x11-proto/xcb-proto-1.2"

CONFIGURE_OPTIONS="$(use_enable doc build-docs)
	$(use_enable selinux xselinux)
	--enable-xinput"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch "${FILESDIR}/libxcb-1.1.90.1-xhost-fix.patch"
}

src_install() {
        x-modular_src_install
        dodir /etc/env.d
        echo "LIBXCB_ALLOW_SLOPPY_LOCK=1" > ${D}/${SLOPPY_ENV_FILE}
}

pkg_postinst() {
	x-modular_pkg_postinst

	elog "libxcb-1.1 added the LIBXCB_ALLOW_SLOPPY_LOCK variable to allow"
	elog "broken applications to keep running instead of being aborted."
	elog "Set this variable if you need to use broken packages such as Java"
	elog "(for example, add LIBXCB_ALLOW_SLOPPY_LOCK=1 to /etc/env.d/00local"
	elog "and run env-update)."
}
