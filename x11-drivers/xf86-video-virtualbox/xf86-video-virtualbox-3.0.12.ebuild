# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-video-virtualbox/xf86-video-virtualbox-3.0.12.ebuild,v 1.3 2009/11/30 11:15:58 maekke Exp $

EAPI=2

inherit x-modular eutils linux-mod multilib

MY_P=VirtualBox-${PV}-OSE
DESCRIPTION="VirtualBox video driver"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="http://download.virtualbox.org/virtualbox/${PV}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="dri"

RDEPEND="x11-base/xorg-server"
DEPEND="${RDEPEND}
		>=dev-util/kbuild-0.1.5-r1
		>=dev-lang/yasm-0.6.2
		sys-devel/dev86
		sys-power/iasl
		x11-proto/fontsproto
		x11-proto/randrproto
		x11-proto/renderproto
		x11-proto/xextproto
		x11-proto/xineramaproto
		x11-proto/xproto
		x11-libs/libXdmcp
		x11-libs/libXcomposite
		x11-libs/libXau
		x11-libs/libX11
		x11-libs/libXfixes
		x11-libs/libXext
	    dri? (  x11-proto/xf86driproto
				>=x11-libs/libdrm-2.4.5 )"

BUILD_TARGETS="all"
BUILD_TARGET_ARCH="${ARCH}"
MODULE_NAMES="vboxvideo(misc:${WORKDIR}/vboxvideo_drm:${WORKDIR}/vboxvideo_drm)"

S=${WORKDIR}/${MY_P/-OSE/_OSE}

QA_TEXTRELS_x86="usr/lib/VBoxOGL.so"

pkg_setup() {
		linux-mod_pkg_setup
		BUILD_PARAMS="KERN_DIR=${KV_DIR} KERNOUT=${KV_OUT_DIR}"
}

src_unpack() {
		unpack ${A}

		# Prepare the vboxvideo_drm sources and Makefile in ${WORKDIR}
		cp -a "${MY_P/-OSE/_OSE}"/src/VBox/Additions/linux/drm \
		"${WORKDIR}/vboxvideo_drm"
		cp "${FILESDIR}/${PN}-3-vboxvideo_drm.makefile" \
		"${WORKDIR}/vboxvideo_drm/Makefile"
}

src_prepare() {
		# Remove shipped binaries (kBuild,yasm), see bug #232775
		rm -rf kBuild/bin tools

		# Disable things unused or splitted into separate ebuilds
		cp "${FILESDIR}/${PN}-3-localconfig" LocalConfig.kmk

		# Ugly hack to build the opengl part of the video driver
		epatch "${FILESDIR}/${PN}-2.2.0-enable-opengl.patch"

		# unset useless/problematic mesa checks in configure
		epatch "${FILESDIR}/${PN}-3.0.0-mesa-check.patch"
}

src_configure() {
		# build the user-space tools, warnings are harmless
		./configure --nofatal \
		--disable-xpcom \
		--disable-sdl-ttf \
		--disable-pulse \
		--disable-alsa \
		--build-headless || die "configure failed"
		source ./env.sh
}

src_compile() {
		if use dri; then
			linux-mod_src_compile
		fi

		for each in /src/VBox/{Runtime,Additions/common/VBoxGuestLib} \
		/src/VBox/{GuestHost/OpenGL,Additions/x11/x11stubs,Additions/common/crOpenGL} \
		/src/VBox/Additions/x11/vboxvideo ; do
			cd "${S}"${each}
			MAKE="kmk" emake TOOL_YASM_AS=yasm \
			KBUILD_PATH="${S}/kBuild" \
			|| die "kmk failed"
		done
}

src_install() {
		if use dri; then
			linux-mod_src_install
		fi

		cd "${S}/out/linux.${ARCH}/release/bin/additions"
		insinto /usr/$(get_libdir)/xorg/modules/drivers

		# xorg-server-1.6.x
		if has_version ">=x11-base/xorg-server-1.6" ; then
				newins vboxvideo_drv_16.so vboxvideo_drv.so
		# xorg-server-1.5.x
		else
				newins vboxvideo_drv_15.so vboxvideo_drv.so
		fi

		# Guest OpenGL driver
		insinto /usr/$(get_libdir)
		doins -r VBoxOGL* || die

		if use dri ; then
			dosym /usr/$(get_libdir)/VBoxOGL.so /usr/$(get_libdir)/dri/vboxvideo_dri.so
		fi
}

pkg_postinst() {
		elog "You need to edit the file /etc/X11/xorg.conf and set:"
		elog ""
		elog "  Driver  \"vboxvideo\""
		elog ""
		elog "in the Graphics device section (Section \"Device\")"
		elog ""
		if use dri; then
			elog "To use the kernel drm video driver, please add:"
			elog "\"vboxvideo\" to:"
			if has_version sys-apps/openrc; then
				elog "/etc/conf.d/modules"
			else
				elog "/etc/modules.autoload.d/kernel-${KV_MAJOR}.${KV_MINOR}"
			fi
			elog ""
		fi
}
