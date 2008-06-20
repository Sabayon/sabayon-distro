# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-video-i810/xf86-video-i810-2.3.1-r2.ebuild,v 1.1 2008/06/13 05:15:02 remi Exp $

# Must be before x-modular eclass is inherited
# Enable snapshot to get the man page in the right place
# This should be fixed with a XDP patch later
SNAPSHOT="yes"
XDPVER=-1

inherit x-modular

# This really needs a pkgmove...
SRC_URI="http://xorg.freedesktop.org/archive/individual/driver/xf86-video-intel-${PV}.tar.bz2"

S="${WORKDIR}/xf86-video-intel-${PV}"

DESCRIPTION="X.Org driver for Intel cards"

KEYWORDS="~amd64 ~arm ~ia64 ~sh ~x86 ~x86-fbsd"
IUSE="dri ubuntu-patches"

RDEPEND=">=x11-base/xorg-server-1.2
	x11-libs/libXvMC"
DEPEND="${RDEPEND}
	x11-proto/fontsproto
	x11-proto/randrproto
	x11-proto/renderproto
	x11-proto/xextproto
	x11-proto/xineramaproto
	x11-proto/xproto
	dri? ( x11-proto/xf86driproto
			x11-proto/glproto
			>=x11-libs/libdrm-2.2
			x11-libs/libX11 )"

CONFIGURE_OPTIONS="$(use_enable dri)"
PATCHES=(
"${FILESDIR}/2.3.1/0001-Skip-copying-on-FOURCC_XVMC-surfaces.patch"
"${FILESDIR}/2.3.1/0002-Only-use-FOURCC_XVMC-when-INTEL_XVMC-is-defined.patch"
"${FILESDIR}/2.3.1/0003-Panel-fitting-fix-letterbox-modes.patch"
"${FILESDIR}/2.3.1/0004-Add-glproto-to-DRI-dependencies.patch"
"${FILESDIR}/2.3.1/0005-Revert-Add-FIFO-watermark-regs-to-register-dumper.patch"
"${FILESDIR}/2.3.1/0006-Fix-typo-in-xvmc-block-destroy.patch"
"${FILESDIR}/2.3.1/0007-Define-DEFFILEMODE-for-OS-es-that-don-t-have-it.patch"
"${FILESDIR}/2.3.1/0008-Disable-a-bunch-of-clock-gating-disables-on-IGD_GM.patch"
"${FILESDIR}/2.3.1/0009-Fixup-power-saving-registers.patch"
"${FILESDIR}/2.3.1/0010-xvmc-remove-unused-dri-drawable.patch"
"${FILESDIR}/2.3.1/0011-xvmc-a-little-cleanup.patch"
"${FILESDIR}/2.3.1/0012-Set-SDVO-sync-polarity-to-default-on-965.patch"
"${FILESDIR}/2.3.1/0013-Just-remove-the-mprotect-kludge.patch"
"${FILESDIR}/2.3.1/0014-Replace-a-couple-of-wait-for-ring-idles-with-a-singl.patch"
"${FILESDIR}/2.3.1/0015-Remove-duplicated-i830_stop_ring-SetHWOperatingSta.patch"
"${FILESDIR}/2.3.1/0016-Remove-gratuitous-wait_ring_idle-after-I830Sync.-Sy.patch"
"${FILESDIR}/2.3.1/0017-Move-BIOS-scratch-register-setup-to-EnterVT-instead.patch"
"${FILESDIR}/2.3.1/0018-Initialize-clock-gating-from-EnterVT-and-save-restor.patch"
"${FILESDIR}/2.3.1/0019-Remove-SVG_WORK_CONTROL-init.patch"
"${FILESDIR}/2.3.1/0020-Move-debug-clock-printout-from-ErrorF-to-X_INFO.patch"
"${FILESDIR}/2.3.1/0021-Fix-TV-out-connection-type-detection.patch"
"${FILESDIR}/2.3.1/0022-Fix-TV-programming-add-vblank-wait-after-TV_CTL-wr.patch"
"${FILESDIR}/2.3.1/0023-Two-more-Dell-quirks.patch"
"${FILESDIR}/2.3.1/0024-Set-up-restore-PWRCTXA-from-enter-leavevt-not-server.patch"
"${FILESDIR}/2.3.1/0025-Fix-compiler-warning-when-disable-xvmc-config.patch")

pkg_setup() {
	if use dri && ! built_with_use x11-base/xorg-server dri; then
		die "Build x11-base/xorg-server with USE=dri."
	fi
	if use ubuntu-patches; then
		ewarn "Using ubuntu patches."
		for i in $( /bin/cat ${FILESDIR}/ubuntu-patches/${PV}/series ); do
			PATCHES=(${PATCHES[@]} "${FILESDIR}/ubuntu-patches/${PV}/${i}")
		done
	else
		einfo "Not using Ubuntu patches."
	fi
}
