# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit multilib toolchain-funcs

DESCRIPTION="V4L userspace libraries"
HOMEPAGE="http://people.atrpms.net/~hdegoede/
	http://hansdegoede.livejournal.com/3636.html"
SRC_URI="http://people.atrpms.net/~hdegoede/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc ~ppc64 ~x86"
IUSE="multilib"

EMULTILIB_PKG="true"

src_unpack() {
	unpack ${A}

	if use multilib && has_multilib_profile; then
		for ABI in $(get_install_abis); do
			cp -pr "${S}" "${S}-${ABI}"
		done
	fi
}

make_libv4l() {
	tc-export CC
	emake PREFIX="/usr" LIBDIR="/usr/$(get_libdir)" CFLAGS="${CFLAGS}" \
		|| die "emake failed"
}

src_compile() {
	if use multilib && has_multilib_profile; then
		einfo "Building multilib libv4l for ABIs: $(get_install_abis)"
		for ABI in $(get_install_abis); do
			cd "${S}-${ABI}"
			make_libv4l
		done
	else
		make_libv4l
	fi
}

make_install_libv4l() {
	emake PREFIX="/usr" LIBDIR="/usr/$(get_libdir)" \
		DESTDIR="${D}" install || die "emake install failed"
}

src_install() {
	dodoc ChangeLog README* TODO
	if use multilib && has_multilib_profile; then
		for ABI in $(get_install_abis); do
			cd "${S}-${ABI}"
			make_install_libv4l
		done
	else
		make_install_libv4l
	fi
}

pkg_postinst() {
	elog
	elog "libv4l includes wrapper libraries for compatibility and pixel format"
	elog "conversion, which are especially useful for users of the gspca usb"
	elog "webcam driver in kernel 2.6.27 and higher."
	elog
	elog "To add v4l2 compatibility to a v4l application 'myapp', launch it via"
	if use multilib && has_multilib_profile; then
		elog "one of the following:"
		for ABI in $(get_install_abis); do
			elog "LD_PRELOAD=/usr/$(get_libdir)/libv4l/v4l1compat.so myapp"
		done
		elog
	else
		elog "LD_PRELOAD=/usr/$(get_libdir)/libv4l/v4l1compat.so myapp"
	fi
	elog "To add automatic pixel format conversion to a v4l2 application, use"
	if use multilib && has_multilib_profile; then
		elog "one of the following:"
		for ABI in $(get_install_abis); do
			elog "LD_PRELOAD=/usr/$(get_libdir)/libv4l/v4l2convert.so myapp"
		done
	else
		elog "LD_PRELOAD=/usr/$(get_libdir)/libv4l/v4l2convert.so myapp"
	fi
	elog
}
