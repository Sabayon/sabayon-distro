# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools mount-boot

DESCRIPTION="Graphical boot animation (splash) and logger"
HOMEPAGE="http://cgit.freedesktop.org/plymouth/"
SRC_URI="http://cgit.freedesktop.org/${PN}/snapshot/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pango gdm"

DEPEND="x11-libs/libdrm
	>=media-libs/libpng-1.2.16
	>=x11-libs/gtk+-2.12.0
	pango? ( >=x11-libs/pango-1.21 )
	"
RDEPEND="${DEPEND}
	>=sys-kernel/dracut-007
	"

src_prepare() {
	epatch "${FILESDIR}"/${PV}-gentoo-fb.patch
	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	econf $(use_enable pango) $(use_enable gdm gdm-transition)
}

src_install() {
	emake install DESTDIR="${D}" || die "install failed"

	cd "${S}"/scripts
	mkdir -p "${D}"/boot
	chmod a+x ./plymouth-generate-initrd
	PLYMOUTH_DESTDIR="${D}/boot" ./plymouth-generate-initrd
	cd "${S}"

	#work around qa warning
	find "${D}" -type f -name '*.la' -exec rm -rf '{}' '+' || die "la removal failed"
	local libdir
	for libdir in "${D}"/lib "${D}"/lib64; do
		[[ -d ${libdir} ]] && {
			rm "${libdir}"/libply.a
			rm "${libdir}"/libply-splash-core.a
		}
	done
}

pkg_postinst() {
	elog "This version of ${PN} has stopped installing .la files. This may"
	elog "cause compilation failures in other packages. To fix this problem,"
	elog "install dev-util/lafilefixer and run:"
	elog "lafilefixer --justfixit"
}
