# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools-utils systemd toolchain-funcs

DESCRIPTION="Graphical boot animation (splash) and logger"
HOMEPAGE="http://cgit.freedesktop.org/plymouth/"
SRC_URI="http://www.freedesktop.org/software/plymouth/releases/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE_VIDEO_CARDS="video_cards_intel video_cards_radeon"
IUSE="${IUSE_VIDEO_CARDS} debug gdm +gtk +libkms +openrc +pango static-libs systemd"

CDEPEND=">=media-libs/libpng-1.2.16
	gtk? ( dev-libs/glib
	>=x11-libs/gtk+-2.12:2 )
	libkms? ( x11-libs/libdrm[libkms] )
	pango? ( >=x11-libs/pango-1.21 )
	video_cards_intel? ( x11-libs/libdrm[video_cards_intel] )
	video_cards_radeon? ( x11-libs/libdrm[video_cards_radeon] )
	"
DEPEND="${CDEPEND}
	virtual/pkgconfig
	"
RDEPEND="${CDEPEND}
	>=sys-kernel/dracut-008-r1[dracut_modules_plymouth]
	openrc? ( sys-boot/plymouth-openrc-plugin !sys-apps/systemd )
	>=x11-themes/sabayon-artwork-core-11-r3
	"

DOCS=(AUTHORS README TODO)

src_prepare() {
	sed -i 's:/bin/systemd-tty-ask-password-agent:/usr/bin/systemd-tty-ask-password-agent:g' \
		systemd-units/systemd-ask-password-plymouth.service.in || die \
		'sed bin failed'
	autotools-utils_src_prepare
}

src_configure() {
	local myeconfargs=(
		--with-system-root-install
		--localstatedir=/var
		$(use_enable debug tracing)
		$(use_enable gtk gtk)
		$(use_enable libkms)
		$(use_enable pango)
		$(use_enable gdm gdm-transition)
		$(use_enable video_cards_intel libdrm_intel)
		$(use_enable video_cards_radeon libdrm_radeon)
		$(use_enable systemd systemd-integration)
		)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install

	if use static-libs; then
		mv "${D}/$(get_libdir)"/libply{,-splash-core}.a \
			"${D}/usr/$(get_libdir)"/ || die 'mv *.a files failed'
		gen_usr_ldscript libply.so libply-splash-core.so
	fi

	# Provided by sabayon-artwork-core
	rm "${D}/usr/share/plymouth/bizcom.png"
}

pkg_postinst() {
	elog "Follow instructions on"
	elog ""
	elog "  http://dev.gentoo.org/~aidecoe/doc/en/plymouth.xml"
	elog ""
	elog "to set up Plymouth."
}
