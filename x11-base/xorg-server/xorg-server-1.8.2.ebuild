# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-base/xorg-server/xorg-server-1.8.2.ebuild,v 1.2 2010/09/05 11:59:11 remi Exp $

EAPI=3
XORG_EAUTORECONF="yes"
inherit xorg-2 multilib versionator
EGIT_REPO_URI="git://anongit.freedesktop.org/git/xorg/xserver"

OPENGL_DIR="xorg-x11"

DESCRIPTION="X.Org X servers"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"

IUSE_SERVERS="dmx kdrive xorg"
IUSE="${IUSE_SERVERS} doc hal ipv6 minimal nptl tslib +udev"
RDEPEND=">=app-admin/eselect-opengl-1.0.8
	dev-libs/openssl
	media-libs/freetype
	>=x11-apps/iceauth-1.0.2
	>=x11-apps/rgb-1.0.3
	>=x11-apps/xauth-1.0.3
	x11-apps/xkbcomp
	>=x11-libs/libpciaccess-0.10.3
	>=x11-libs/libXau-1.0.4
	>=x11-libs/libXdmcp-1.0.2
	>=x11-libs/libXfont-1.3.3
	>=x11-libs/libxkbfile-1.0.4
	>=x11-libs/pixman-0.15.20
	>=x11-libs/xtrans-1.2.2
	>=x11-misc/xbitmaps-1.0.1
	>=x11-misc/xkeyboard-config-1.4
	dmx? (
		x11-libs/libXt
		>=x11-libs/libdmx-1.0.99.1
		>=x11-libs/libX11-1.1.5
		>=x11-libs/libXaw-1.0.4
		>=x11-libs/libXext-1.0.5
		>=x11-libs/libXfixes-4.0.3
		>=x11-libs/libXi-1.2.99.1
		>=x11-libs/libXmu-1.0.3
		>=x11-libs/libXres-1.0.3
		>=x11-libs/libXtst-1.0.3
	)
	!udev? ( hal? ( sys-apps/hal ) )
	kdrive? (
		>=x11-libs/libXext-1.0.5
		x11-libs/libXv
	)
	!minimal? (
		>=x11-libs/libX11-1.1.5
		>=x11-libs/libXext-1.0.5
		>=media-libs/mesa-7.8_rc[nptl=]
	)
	tslib? ( >=x11-libs/tslib-1.0 x11-proto/xcalibrateproto )
	udev? ( sys-fs/udev )"

DEPEND="${RDEPEND}
	!<x11-apps/xinit-1.2.1-r1
	sys-devel/flex
	>=x11-proto/bigreqsproto-1.1.0
	>=x11-proto/compositeproto-0.4
	>=x11-proto/damageproto-1.1
	>=x11-proto/fixesproto-4.1
	>=x11-proto/fontsproto-2.0.2
	>=x11-proto/glproto-1.4.11
	>=x11-proto/inputproto-1.9.99.902
	>=x11-proto/kbproto-1.0.3
	>=x11-proto/randrproto-1.2.99.3
	>=x11-proto/recordproto-1.13.99.1
	>=x11-proto/renderproto-0.11
	>=x11-proto/resourceproto-1.0.2
	>=x11-proto/scrnsaverproto-1.1
	>=x11-proto/trapproto-3.4.3
	>=x11-proto/videoproto-2.2.2
	>=x11-proto/xcmiscproto-1.2.0
	>=x11-proto/xextproto-7.0.99.3
	>=x11-proto/xf86dgaproto-2.0.99.1
	>=x11-proto/xf86rushproto-1.1.2
	>=x11-proto/xf86vidmodeproto-2.2.99.1
	>=x11-proto/xineramaproto-1.1.3
	>=x11-proto/xproto-7.0.13
	dmx? ( >=x11-proto/dmxproto-2.2.99.1 )
	doc? ( >=app-doc/doxygen-1.6.1 )
	!minimal? (
		>=x11-proto/xf86driproto-2.1.0
		>=x11-proto/dri2proto-2.1
		>=x11-libs/libdrm-2.3.0
	)"

PDEPEND="
	>=x11-apps/xinit-1.2.1-r1
	xorg? ( >=x11-base/xorg-drivers-$(get_version_component_range 1-2) )"

EPATCH_FORCE="yes"
EPATCH_SUFFIX="patch"

# These have been sent upstream
#UPSTREAMED_PATCHES=(
#	"${WORKDIR}/patches/"
#	)

PATCHES=(
	"${UPSTREAMED_PATCHES[@]}"
	"${FILESDIR}"/${PN}-disable-acpi.patch
	"${FILESDIR}"/${PN}-1.8-nouveau-default.patch
	# close Sabayon bug #1649
	"${FILESDIR}/fglrx"/${PN}-1.8-backclear.patch
	)

pkg_setup() {
	local myconf

	xorg-2_pkg_setup

	use minimal || ensure_a_server_is_building

	# HAL shebang
	if use hal; then
		ewarn "Usage of hal is strongly discouraged. Please migrate to udev."
		ewarn "From next major release on the hal support will be fully disabled."
	fi
	if use hal && use udev; then
		ewarn "Both hal and udev flags are enabled."
		ewarn "Enabling only udev!"
		myconf="
			$(use_enable udev config-udev)
			--disable-config-hal
		"
	else
		myconf="
			$(use_enable hal config-hal)
			$(use_enable udev config-udev)
		"
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
		$(use_enable tslib xcalibrate)
		$(use_enable !minimal xvfb)
		$(use_enable !minimal xnest)
		$(use_enable !minimal record)
		$(use_enable !minimal xfree86-utils)
		$(use_enable !minimal install-libxf86config)
		$(use_enable !minimal dri)
		$(use_enable !minimal dri2)
		$(use_enable !minimal glx)
		$(use_enable xorg)
		$(use_enable nptl glx-tls)
		$(use_with doc doxygen)
		${myconf}
		--sysconfdir=/etc/X11
		--localstatedir=/var
		--enable-install-setuid
		--with-fontrootdir=/usr/share/fonts
		--with-xkb-output=/var/lib/xkb
		--without-dtrace
		--with-os-vendor=Gentoo
		${conf_opts}"

	# Due to the limitations of CONFIGURE_OPTIONS, we have to export this.
	mkdir -p "${T}/mesa-symlinks/GL"
	pushd "${T}/mesa-symlinks/GL" &> /dev/null
	for i in gl glx glxmd glxproto glxtokens; do
		ln -s "${EROOT}usr/$(get_libdir)/opengl/xorg-x11/include/$i.h" $i.h
	done
	for i in  glext glxext; do
		ln -s "${EROOT}usr/$(get_libdir)/opengl/global/include/$i.h" $i.h
	done
	popd &> /dev/null
	export CPPFLAGS="${CPPFLAGS:+${CPPFLAGS} }-I${T}/mesa-symlinks"

	# (#121394) Causes window corruption
	filter-flags -fweb

	# Incompatible with GCC 3.x SSP on x86, bug #244352
	if use x86 ; then
		if [[ $(gcc-major-version) -lt 4 ]]; then
			filter-flags -fstack-protector
		fi
	fi

	# Incompatible with GCC 3.x CPP, bug #314615
	if [[ $(gcc-major-version) -lt 4 ]]; then
		ewarn "GCC 3.x C preprocessor may cause build failures. Use GCC 4.x"
		ewarn "or set CPP=cpp-4.3.4 (replace with the actual installed version)"
	fi

	# detect if we should inform user about ebuild breakage
	if ! has_version "x11-base/xorg-server" ||
			has_version "<x11-base/xorg-server-$(get_version_component_range 1-2)"; then
		INFO="yes"
	fi
}

src_install() {
	xorg-2_src_install

	dynamic_libgl_install

	server_based_install

	if ! use minimal && use xorg; then
		# Install xorg.conf.example into docs
		dodoc hw/xfree86/xorg.conf.example \
			|| die "couldn't install xorg.conf.example"
	fi

	# install the xdm.init
	cp "${FILESDIR}"/xdm.initd "${T}"
	if use hal && ! use udev; then
		sed -i \
			-e "s/@HALD_DEPEND@/need hald/g" \
			"${T}"/xdm.initd \
			|| die "sed failed"
	else
		sed -i \
			-e "/@HALD_DEPEND@/ d" \
			"${T}"/xdm.initd \
			|| die "sed failed"
	fi
	newinitd "${T}"/xdm.initd xdm || die "initd file install failed"
	newinitd "${FILESDIR}"/xdm-setup.initd-1 xdm-setup || die
	newconfd "${FILESDIR}"/xdm.confd-3 xdm.example || die
}

CONFD_XDM="${ROOT}/etc/conf.d/xdm"
pkg_preinst() {
	# backup user /etc/conf.d/xdm
	if [ -f "${CONFD_XDM}" ]; then
		cp -p "${CONFD_XDM}" "${CONFD_XDM}.backup"
	fi
}

pkg_postinst() {

	# Copy config file over
	if [ -f "${CONFD_XDM}.backup" ]; then
		cp ${CONFD_XDM}.backup ${CONFD_XDM} -p
	else
		if [ -f "${CONFD_XDM}.example" ] && [ ! -f "${CONFD_XDM}" ]; then
			cp ${CONFD_XDM}.example ${CONFD_XDM} -p
		fi
	fi

	# sets up libGL and DRI2 symlinks if needed (ie, on a fresh install)
	eselect opengl set --use-old xorg-x11

	if [[ ${INFO} = yes ]]; then
		einfo "You should consider reading upgrade guide for this release:"
		einfo "	http://www.gentoo.org/proj/en/desktop/x/x11/xorg-server-$(get_version_component_range 1-2)-upgrade-guide.xml"
		echo
		ewarn "You must rebuild all drivers if upgrading from <xorg-server-$(get_version_component_range 1-2)"
		ewarn "because the ABI changed. If you cannot start X because"
		ewarn "of module version mismatch errors, this is your problem."

		echo
		ewarn "You can generate a list of all installed packages in the x11-drivers"
		ewarn "category using this command:"
		ewarn "	emerge portage-utils; qlist -I -C x11-drivers/"
	fi

	ewarn
	ewarn "/etc/conf.d/xdm is no longer provided, /etc/conf.d/xdm.example is"
	ewarn "Your current /etc/conf.d/xdm has been used as new default"
	ewarn

}

pkg_postrm() {
	# Get rid of module dir to ensure opengl-update works properly
	if ! has_version x11-base/xorg-server; then
		if [[ -e ${ROOT}/usr/$(get_libdir)/xorg/modules ]]; then
			rm -rf "${ROOT}"/usr/$(get_libdir)/xorg/modules
		fi
	fi
}

dynamic_libgl_install() {
	# next section is to setup the dynamic libGL stuff
	ebegin "Moving GL files for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/extensions
		local x=""
		for x in "${D}"/usr/$(get_libdir)/xorg/modules/extensions/lib{glx,dri,dri2}*; do
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

ensure_a_server_is_building() {
	for server in ${IUSE_SERVERS}; do
		use ${server} && return;
	done
	eerror "You need to specify at least one server to build."
	eerror "Valid servers are: ${IUSE_SERVERS}."
	die "No servers were specified to build."
}
