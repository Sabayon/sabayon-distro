# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

EGIT_REPO_URI="git://anongit.freedesktop.org/plymouth"
EGIT_COMMIT="37d2e400d25e6b4716d77d26fb7d40de8a8c1a8a"
AUTOTOOLS_AUTORECONF="true"

inherit autotools-utils readme.gentoo systemd toolchain-funcs git-2

DESCRIPTION="Graphical boot animation (splash) and logger"
HOMEPAGE="http://cgit.freedesktop.org/plymouth/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug gdm +gtk +libkms +pango static-libs"

CDEPEND="
	>=media-libs/libpng-1.2.16
	gtk? (
		dev-libs/glib:2
		>=x11-libs/gtk+-2.12:2 )
	libkms? ( x11-libs/libdrm[libkms] )
	pango? ( >=x11-libs/pango-1.21 )
"
DEPEND="${CDEPEND}
	virtual/pkgconfig
"
RDEPEND="${CDEPEND}
	virtual/udev
"

DOC_CONTENTS="
	Follow the following instructions to set up Plymouth:\n
	http://dev.gentoo.org/~aidecoe/doc/en/plymouth.xml
"

src_prepare() {
	epatch_user

	autotools-utils_src_prepare
}

src_configure() {
	local myeconfargs=(
		--with-system-root-install=no
		--localstatedir=/var
		--without-rhgb-compat-link
		--enable-systemd-integration
		$(use_enable debug tracing)
		$(use_enable gtk gtk)
		$(use_enable libkms drm)
		$(use_enable pango)
		$(use_enable gdm gdm-transition)
		)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install

	# Sabayon: provided by sabayon-artwork-plymouth-base
	rm "${D}/usr/share/plymouth/bizcom.png"
	rm "${D}/etc/plymouth/plymouthd.conf"


	# Install compatibility symlinks as some rdeps hardcode the paths
	dosym /usr/bin/plymouth /bin/plymouth
	dosym /usr/sbin/plymouth-set-default-theme /sbin/plymouth-set-default-theme
	dosym /usr/sbin/plymouthd /sbin/plymouthd
	
	# Soft services that enables smooth transition from plymouth to login service
	systemd_newunit "${FILESDIR}"/lightdm-plymouth.service lightdm-plymouth.service
        systemd_newunit "${FILESDIR}"/lxdm-plymouth.service lxdm-plymouth.service
        systemd_newunit "${FILESDIR}"/gdm-plymouth.service gdm-plymouth.service
        systemd_newunit "${FILESDIR}"/kdm-plymouth.service kdm-plymouth.service
        systemd_newunit "${FILESDIR}"/slim-plymouth.service slim-plymouth.service

	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
	if ! has_version "sys-kernel/dracut[dracut_modules_plymouth]" && ! has_version "sys-kernel/genkernel-next[plymouth]"; then
		ewarn "If you want initramfs builder with plymouth support, please emerge"
		ewarn "sys-kernel/dracut[dracut_modules_plymouth] or sys-kernel/genkernel-next[plymouth]."
	fi
}
