# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-base/xorg-server/xorg-server-1.5.2.ebuild,v 1.8 2008/11/01 23:40:59 solar Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

inherit x-modular multilib

OPENGL_DIR="xorg-x11"

SRC_URI="${SRC_URI}
	http://xorg.freedesktop.org/releases/individual/xserver/${P}.tar.bz2"
DESCRIPTION="X.Org X servers"
KEYWORDS="~amd64 ~ia64 ~ppc ~sparc ~x86 ~x86-fbsd"
IUSE_INPUT_DEVICES="
	input_devices_acecad
	input_devices_aiptek
	input_devices_calcomp
	input_devices_citron
	input_devices_digitaledge
	input_devices_dmc
	input_devices_dynapro
	input_devices_elo2300
	input_devices_elographics
	input_devices_evdev
	input_devices_fpit
	input_devices_hyperpen
	input_devices_jamstudio
	input_devices_joystick
	input_devices_keyboard
	input_devices_magellan
	input_devices_microtouch
	input_devices_mouse
	input_devices_mutouch
	input_devices_palmax
	input_devices_penmount
	input_devices_spaceorb
	input_devices_summa
	input_devices_tek4957
	input_devices_tslib
	input_devices_ur98
	input_devices_vmmouse
	input_devices_void

	input_devices_synaptics
	input_devices_wacom"
IUSE_VIDEO_CARDS="
	video_cards_apm
	video_cards_ark
	video_cards_ast
	video_cards_chips
	video_cards_cirrus
	video_cards_cyrix
	video_cards_dummy
	video_cards_epson
	video_cards_fbdev
	video_cards_geode
	video_cards_glint
	video_cards_i128
	video_cards_i740
	video_cards_intel
	video_cards_impact
	video_cards_imstt
	video_cards_mach64
	video_cards_mga
	video_cards_neomagic
	video_cards_newport
	video_cards_nsc
	video_cards_nv
	video_cards_r128
	video_cards_radeon
	video_cards_radeonhd
	video_cards_rendition
	video_cards_s3
	video_cards_s3virge
	video_cards_savage
	video_cards_siliconmotion
	video_cards_sis
	video_cards_sisusb
	video_cards_sunbw2
	video_cards_suncg14
	video_cards_suncg3
	video_cards_suncg6
	video_cards_sunffb
	video_cards_sunleo
	video_cards_suntcx
	video_cards_tdfx
	video_cards_tga
	video_cards_trident
	video_cards_tseng
	video_cards_v4l
	video_cards_vermilion
	video_cards_vesa
	video_cards_vga
	video_cards_via
	video_cards_vmware
	video_cards_voodoo
	video_cards_xgi
	video_cards_fglrx
	video_cards_nvidia"
IUSE_SERVERS="dmx kdrive xorg"
IUSE="${IUSE_VIDEO_CARDS}
	${IUSE_INPUT_DEVICES}
	${IUSE_SERVERS}
	3dfx tslib
	dri hal ipv6 minimal nptl sdl"
RDEPEND="hal? ( sys-apps/hal )
	tslib? ( x11-libs/tslib )
	>=x11-libs/libXfont-1.3.3
	>=x11-libs/xtrans-1.2.2
	>=x11-libs/libXau-1.0.4
	>=x11-libs/libXext-1.0.4
	>=x11-libs/libX11-1.1.5
	>=x11-libs/libxkbfile-1.0.4
	>=x11-libs/libXdmcp-1.0.2
	>=x11-libs/libXmu-1.0.3
	>=x11-libs/libXrender-0.9.4
	>=x11-libs/libXi-1.1.3
	>=x11-libs/pixman-0.12
	media-libs/freetype
	>=media-libs/mesa-7.1
	media-fonts/font-adobe-75dpi
	media-fonts/font-misc-misc
	media-fonts/font-cursor-misc
	>=x11-misc/xbitmaps-1.0.1
	>=x11-misc/xkeyboard-config-1.3
	>=x11-apps/iceauth-1.0.2
	>=x11-apps/rgb-1.0.3
	>=x11-apps/xauth-1.0.3
	>=x11-apps/xinit-1.0.8-r3
	app-admin/eselect-opengl
	>=x11-libs/libXaw-1.0.4
	>=x11-libs/libXpm-3.5.7
	>=x11-libs/libXxf86misc-1.0.1
	>=x11-libs/libXxf86vm-1.0.2
	>=x11-libs/libpciaccess-0.10.3
	dmx? ( >=x11-libs/libdmx-1.0.2
			>=x11-libs/libXfixes-4.0.3 )
	!minimal? ( >=x11-libs/libXtst-1.0.3
		>=x11-libs/libXres-1.0.3 )
	>=x11-libs/libxkbui-1.0.2
	>=x11-libs/liblbxutil-1.0.1
	kdrive? ( sdl? ( media-libs/libsdl ) )"
	# Xres is dmx-dependent, xkbui is xorgcfg-dependent
	# Xaw is dmx- and xorgcfg-dependent
	# Xpm is dmx- and xorgcfg-dependent, pulls in Xt
	# Xxf86misc and Xxf86vm are xorgcfg-dependent
	# liblbxutil is lbx- dependent
DEPEND="${RDEPEND}
	!net-dialup/dtrace
	>=x11-proto/randrproto-1.2.2
	>=x11-proto/renderproto-0.9.3
	>=x11-proto/fixesproto-4
	>=x11-proto/damageproto-1.1
	>=x11-proto/xextproto-7.0.3
	>=x11-proto/xproto-7.0.13
	>=x11-proto/xf86dgaproto-2.0.3
	>=x11-proto/xf86miscproto-0.9.2
	>=x11-proto/xf86rushproto-1.1.2
	>=x11-proto/xf86vidmodeproto-2.2.2
	>=x11-proto/xf86bigfontproto-1.1.2
	>=x11-proto/compositeproto-0.4
	>=x11-proto/recordproto-1.13.2
	>=x11-proto/resourceproto-1.0.2
	>=x11-proto/videoproto-2.2.2
	>=x11-proto/scrnsaverproto-1.1.0
	>=x11-proto/evieext-1.0.2
	>=x11-proto/trapproto-3.4.3
	>=x11-proto/xineramaproto-1.1.2
	>=x11-proto/fontsproto-2.0.2
	>=x11-proto/kbproto-1.0.3
	>=x11-proto/inputproto-1.4.4
	>=x11-proto/bigreqsproto-1.0.2
	>=x11-proto/xcmiscproto-1.1.2
	>=x11-proto/glproto-1.4.9
	dmx? ( >=x11-proto/dmxproto-2.2.2 )
	dri? ( >=x11-proto/xf86driproto-2.0.4
		>=x11-libs/libdrm-2.3 )"

# Drivers
PDEPEND="
	xorg? (
		input_devices_acecad? ( >=x11-drivers/xf86-input-acecad-1.2.2 )
		input_devices_aiptek? ( >=x11-drivers/xf86-input-aiptek-1.1.1 )
		input_devices_calcomp? ( >=x11-drivers/xf86-input-calcomp-1.1.2 )
		input_devices_citron? ( >=x11-drivers/xf86-input-citron-2.2.1 )
		input_devices_digitaledge? ( >=x11-drivers/xf86-input-digitaledge-1.1.1 )
		input_devices_dmc? ( >=x11-drivers/xf86-input-dmc-1.1.2 )
		input_devices_dynapro? ( >=x11-drivers/xf86-input-dynapro-1.1.2 )
		input_devices_elo2300? ( >=x11-drivers/xf86-input-elo2300-1.1.2 )
		input_devices_elographics? ( >=x11-drivers/xf86-input-elographics-1.2.2 )
		input_devices_evdev? ( >=x11-drivers/xf86-input-evdev-2.0.6 )
		input_devices_fpit? ( >=x11-drivers/xf86-input-fpit-1.2.0 )
		input_devices_hyperpen? ( >=x11-drivers/xf86-input-hyperpen-1.2.0 )
		input_devices_jamstudio? ( >=x11-drivers/xf86-input-jamstudio-1.2.0 )
		input_devices_joystick? ( >=x11-drivers/xf86-input-joystick-1.3.2 )
		input_devices_keyboard? ( >=x11-drivers/xf86-input-keyboard-1.3.1 )
		input_devices_magellan? ( >=x11-drivers/xf86-input-magellan-1.2.0 )
		input_devices_microtouch? ( >=x11-drivers/xf86-input-microtouch-1.2.0 )
		input_devices_mouse? ( >=x11-drivers/xf86-input-mouse-1.3.0 )
		input_devices_mutouch? ( >=x11-drivers/xf86-input-mutouch-1.2.1 )
		input_devices_palmax? ( >=x11-drivers/xf86-input-palmax-1.2.0 )
		input_devices_penmount? ( >=x11-drivers/xf86-input-penmount-1.3.0 )
		input_devices_spaceorb? ( >=x11-drivers/xf86-input-spaceorb-1.1.1 )
		input_devices_summa? ( >=x11-drivers/xf86-input-summa-1.2.0 )
		input_devices_tek4957? ( >=x11-drivers/xf86-input-tek4957-1.2.0 )
		input_devices_tslib? ( x11-drivers/xf86-input-tslib )
		input_devices_ur98? ( >=x11-drivers/xf86-input-ur98-1.1.0 )
		input_devices_vmmouse? ( >=x11-drivers/xf86-input-vmmouse-12.5.0 )
		input_devices_void? ( >=x11-drivers/xf86-input-void-1.1.1 )
		input_devices_synaptics? ( >=x11-drivers/xf86-input-synaptics-0.15.0 )
		input_devices_wacom? ( x11-drivers/linuxwacom )

		video_cards_apm? ( >=x11-drivers/xf86-video-apm-1.2.0  )
		video_cards_ark? ( >=x11-drivers/xf86-video-ark-0.7.0 )
		video_cards_ast? ( >=x11-drivers/xf86-video-ast-0.85.0 )
		video_cards_chips? ( >=x11-drivers/xf86-video-chips-1.2.0 )
		video_cards_cirrus? ( >=x11-drivers/xf86-video-cirrus-1.2.1 )
		video_cards_dummy? ( >=x11-drivers/xf86-video-dummy-0.3.0 )
		video_cards_fbdev? ( >=x11-drivers/xf86-video-fbdev-0.4.0 )
		video_cards_geode? ( >=x11-drivers/xf86-video-geode-2.9.0  )
		video_cards_glint? ( >=x11-drivers/xf86-video-glint-1.2.1 )
		video_cards_i128? ( >=x11-drivers/xf86-video-i128-1.3.1 )
		video_cards_i740? ( >=x11-drivers/xf86-video-i740-1.2.0 )
		video_cards_intel? ( >=x11-drivers/xf86-video-intel-2.4.2-r1 )
		video_cards_mach64? ( >=x11-drivers/xf86-video-mach64-6.8.0 )
		video_cards_mga? ( >=x11-drivers/xf86-video-mga-1.4.9 )
		video_cards_neomagic? ( >=x11-drivers/xf86-video-neomagic-1.2.1 )
		video_cards_nv? ( >=x11-drivers/xf86-video-nv-2.1.12 )
		video_cards_nvidia? ( >=x11-drivers/nvidia-drivers-173.14.09 )
		video_cards_r128? ( >=x11-drivers/xf86-video-r128-6.8.0 )
		video_cards_radeon? ( >=x11-drivers/xf86-video-ati-6.9.0 )
		video_cards_radeonhd? ( >=x11-drivers/xf86-video-radeonhd-1.2.1 )
		video_cards_rendition? ( >=x11-drivers/xf86-video-rendition-4.2.0 )
		video_cards_s3? ( >=x11-drivers/xf86-video-s3-0.6.0 )
		video_cards_s3virge? ( >=x11-drivers/xf86-video-s3virge-1.10.1 )
		video_cards_savage? ( >=x11-drivers/xf86-video-savage-2.2.1 )
		video_cards_siliconmotion? ( >=x11-drivers/xf86-video-siliconmotion-1.6.0 )
		video_cards_sis? ( >=x11-drivers/xf86-video-sis-0.10.0 )
		video_cards_sisusb? ( >=x11-drivers/xf86-video-sisusb-0.9.0 )
		video_cards_sunffb? ( >=x11-drivers/xf86-video-sunffb-1.2.0 )
		video_cards_sunleo? ( >=x11-drivers/xf86-video-sunleo-1.2.0 )
		video_cards_tdfx? ( >=x11-drivers/xf86-video-tdfx-1.4.0 )
		video_cards_tga? ( >=x11-drivers/xf86-video-tga-1.2.0 )
		video_cards_trident? ( >=x11-drivers/xf86-video-trident-1.3.0 )
		video_cards_tseng? ( >=x11-drivers/xf86-video-tseng-1.2.0 )
		video_cards_v4l? ( >=x11-drivers/xf86-video-v4l-0.2.0 )
		video_cards_vesa? ( >=x11-drivers/xf86-video-vesa-2.0.0 )
		video_cards_via? ( >=x11-drivers/xf86-video-openchrome-0.2.903 )
		video_cards_vmware? ( >=x11-drivers/xf86-video-vmware-10.16.5 )
		video_cards_voodoo? ( >=x11-drivers/xf86-video-voodoo-1.2.0 )
		video_cards_xgi? ( >=x11-drivers/xf86-video-xgi-1.5.0 )

		video_cards_tdfx? ( 3dfx? ( >=media-libs/glide-v3-3.10 ) )
		video_cards_fglrx? ( >=x11-drivers/ati-drivers-8.542 )

		!x11-drivers/xf86-video-impact
		!x11-drivers/xf86-video-imstt
		!x11-drivers/xf86-video-newport
		!x11-drivers/xf86-video-sunbw2
		!x11-drivers/xf86-video-suncg14
		!x11-drivers/xf86-video-suncg3
		!x11-drivers/xf86-video-suncg6
		!x11-drivers/xf86-video-suntcx
		!x11-drivers/xf86-video-vermilion

		!x11-drivers/xf86-video-cyrix
		!x11-drivers/xf86-video-nsc
		!x11-drivers/xf86-video-vga
	)"
LICENSE="${LICENSE} MIT"

EPATCH_FORCE="yes"
EPATCH_SUFFIX="patch"

# Local customizations, unsuitable for upstream
GENTOO_PATCHES=(
	"${FILESDIR}/1.4-fpic-libxf86config.patch"
	"${FILESDIR}/1.4-fix-kdrive-automake.patch"
	)

# These have been sent upstream
UPSTREAMED_PATCHES=(
	"${FILESDIR}/1.5.2-force-LC_ALL-C-when-running-awk.patch"
	"${FILESDIR}/1.5.2-fix-xvesa-with-new-kernels.patch"
)

PATCHES=(
	"${GENTOO_PATCHES[@]}"
	"${UPSTREAMED_PATCHES[@]}"
	)

pkg_setup() {
	use minimal || ensure_a_server_is_building

	# SDL only available in kdrive build
	if use kdrive && use sdl; then
		conf_opts="${conf_opts} --enable-xsdl"
	else
		conf_opts="${conf_opts} --disable-xsdl"
	fi

	# localstatedir is used for the log location; we need to override the default
	# from ebuild.sh
	# sysconfdir is used for the xorg.conf location; same applies
	# --enable-install-setuid needed because sparcs default off
	CONFIGURE_OPTIONS="
		$(use_enable ipv6)
		$(use_enable dmx)
		$(use_enable kdrive)
		$(use_enable tslib)
		$(use_enable !minimal xvfb)
		$(use_enable !minimal xnest)
		$(use_enable !minimal xtrap)
		$(use_enable !minimal record)
		$(use_enable !minimal xfree86-utils)
		$(use_enable !minimal install-libxf86config)
		$(use_enable dri)
		$(use_enable xorg)
		$(use_enable nptl glx-tls)
		$(use_enable !minimal xorgcfg)
		$(use_enable hal config-dbus)
		$(use_enable hal config-hal)
		--disable-dri2
		--sysconfdir=/etc/X11
		--localstatedir=/var
		--enable-install-setuid
		--with-fontdir=/usr/share/fonts
		--with-xkb-output=/var/lib/xkb
		${conf_opts}"

	local diemsg="You must build xorg-server and mesa with the same nptl USE setting."
	if built_with_use media-libs/mesa nptl; then
		use nptl || die "${diemsg}"
	else
		use nptl && die "${diemsg}"
	fi

	# (#121394) Causes window corruption
	filter-flags -fweb

	# Nothing else provides new enough glxtokens.h
	ewarn "Forcing on xorg-x11 for new enough glxtokens.h..."
	OLD_IMPLEM="$(eselect opengl show)"
	eselect opengl set --impl-headers ${OPENGL_DIR}
}

src_unpack() {
	x-modular_specs_check
	x-modular_dri_check
	x-modular_unpack_source
	x-modular_patch_source

	# Set up kdrive servers to build
	if use kdrive; then
		kdrive_setup
	fi

	# Make sure eautoreconf gets run if we need the autoconf/make
	# changes.
	if [[ ${SNAPSHOT} != "yes" ]]; then
		if use kdrive || use dmx; then
			SNAPSHOT="yes"
		fi
	fi

	if use hal; then
		sed -i \
			-e "s:^\(dbusconfigdir = \).*\(dbus-1.*\):\1/etc/\2:g" \
			"${S}"/config/Makefile.am \
			|| die "failed to fix DBUS config directory"
		SNAPSHOT="yes"
	fi

	x-modular_reconf_source
}

src_install() {
	x-modular_src_install

	dynamic_libgl_install

	server_based_install

	# Install video mode files for system-config-display
	insinto /usr/share/xorg
	doins hw/xfree86/common/{extra,vesa}modes \
		|| die "couldn't install extra modes"

	# Bug #151421 - this file is not built with USE="minimal"
	# Bug #151670 - this file is also not build if USE="-xorg"
	if ! use minimal &&	use xorg; then
		# Install xorg.conf.example
		insinto /etc/X11
		doins hw/xfree86/xorg.conf.example \
			|| die "couldn't install xorg.conf.example"
	fi
}

pkg_postinst() {
	switch_opengl_implem

	# Bug #135544
	ewarn "Users of reduced blanking now need:"
	ewarn "   Option \"ReducedBlanking\""
	ewarn "In the relevant Monitor section(s)."
	ewarn "Make sure your reduced blanking modelines are safe!"

	echo
	ewarn "You must rebuild all drivers if upgrading from xorg-server 1.4.1"
	ewarn "or earlier, because the ABI changed. If you cannot start X because"
	ewarn "of module version mismatch errors, this is your problem."

	echo
	ewarn "You can generate a list of all installed packages in the x11-drivers"
	ewarn "category using this command:"
	ewarn "emerge portage-utils; qlist -I -C x11-drivers/"

	ebeep 5
	epause 10
}

pkg_postrm() {
	# Get rid of module dir to ensure opengl-update works properly
	if ! has_version x11-base/xorg-server; then
		if [[ -e ${ROOT}/usr/$(get_libdir)/xorg/modules ]]; then
			rm -rf "${ROOT}"/usr/$(get_libdir)/xorg/modules
		fi
	fi
}

kdrive_setup() {
	local card real_card disable_card kdrive_fbdev kdrive_vesa

	einfo "Removing unused kdrive drivers ..."

	# Some kdrive servers require fbdev and vesa
	kdrive_fbdev="radeon neomagic sis siliconmotion"
	# Some kdrive servers require just vesa
	kdrive_vesa="chips mach64 mga nv glint r128 via"

	for card in ${IUSE_VIDEO_CARDS}; do
		real_card=${card#video_cards_}

		# Differences between VIDEO_CARDS name and kdrive server name
		real_card=${real_card/glint/pm2}
		real_card=${real_card/radeon/ati}
		real_card=${real_card/%nv/nvidia}
		real_card=${real_card/siliconmotion/smi}
		real_card=${real_card/%sis/sis300}

		disable_card=0

		# Check whether it's a valid kdrive server before we waste time
		# on the rest of this
		if ! grep -q -o "\b${real_card}\b" "${S}"/hw/kdrive/Makefile.am; then
			continue
		fi

		if ! use ${card}; then
			if use x86; then
				# Some kdrive servers require fbdev and vesa
				for i in ${kdrive_fbdev}; do
					if use video_cards_${i}; then
						if [[ ${real_card} = fbdev ]] \
							|| [[ ${real_card} = vesa ]]; then
							continue 2 # Don't disable
						fi
						fi
				done

				# Some kdrive servers require just vesa
				for i in ${kdrive_vesa}; do
					if use video_cards_${i}; then
						if [[ ${real_card} = vesa ]]; then
							continue 2 # Don't disable
						fi
					fi
				done
			fi
			disable_card=1
		# Bug #150052
		# fbdev is the only VIDEO_CARDS setting that works on non-x86
		elif ! use x86 \
			&& [[ ${real_card} != fbdev ]]; then
			ewarn "  $real_card does not work on your architecture; disabling."
			disable_card=1
		fi

		if [[ $disable_card = 1 ]]; then
			ebegin "  ${real_card}"
			sed -i \
				-e "s:\b${real_card}\b::g" \
				"${S}"/hw/kdrive/Makefile.am \
				|| die "sed of ${real_card} failed"
			eend
		fi

	done
}

dynamic_libgl_install() {
	# next section is to setup the dynamic libGL stuff
	ebegin "Moving GL files for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/extensions
		local x=""
		for x in "${D}"/usr/$(get_libdir)/xorg/modules/extensions/libglx*; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f ${x} "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/extensions
			fi
		done
	eend 0
}

server_based_install() {
	if ! use xorg; then
		rm "${D}"/usr/share/man/man1/Xserver.1x \
			"${D}"/usr/$(get_libdir)/xserver/SecurityPolicy \
			"${D}"/usr/$(get_libdir)/pkgconfig/xorg-server.pc \
			"${D}"/usr/share/man/man1/Xserver.1x
	fi
}

switch_opengl_implem() {
		# Switch to the xorg implementation.
		# Use new opengl-update that will not reset user selected
		# OpenGL interface ...
		echo
#		eselect opengl set --use-old ${OPENGL_DIR}
		eselect opengl set ${OLD_IMPLEM}
}

ensure_a_server_is_building() {
	for server in ${IUSE_SERVERS}; do
		use ${server} && return;
	done
	eerror "You need to specify at least one server to build."
	eerror "Valid servers are: ${IUSE_SERVERS}."
	die "No servers were specified to build."
}
