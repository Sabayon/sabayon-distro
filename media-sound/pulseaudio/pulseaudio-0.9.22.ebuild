# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/pulseaudio/pulseaudio-0.9.22.ebuild,v 1.6 2010/12/22 06:22:26 ford_prefect Exp $

EAPI=3

inherit autotools eutils libtool flag-o-matic versionator

DESCRIPTION="A networked sound server with an advanced plugin system"
HOMEPAGE="http://www.pulseaudio.org/"

SRC_URI="http://0pointer.de/lennart/projects/${PN}/${P}.tar.gz"

LICENSE="LGPL-2 GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux"
IUSE="+alsa avahi +caps jack lirc oss tcpd +X hal dbus libsamplerate gnome bluetooth +asyncns +glib test doc +udev ipv6 system-wide realtime"

RDEPEND="app-admin/eselect-esd
	X? (
		|| ( >=x11-libs/libX11-1.4.0 <x11-libs/libX11-1.4.0[xcb] )
		x11-libs/xcb-util
		x11-libs/libSM
		x11-libs/libICE
		x11-libs/libXtst
	)
	caps? ( sys-libs/libcap )
	libsamplerate? ( >=media-libs/libsamplerate-0.1.1-r1 )
	alsa? ( >=media-libs/alsa-lib-1.0.19 )
	glib? ( >=dev-libs/glib-2.4.0 )
	avahi? ( >=net-dns/avahi-0.6.12[dbus] )
	jack? ( >=media-sound/jack-audio-connection-kit-0.100 )
	tcpd? ( sys-apps/tcp-wrappers )
	lirc? ( app-misc/lirc )
	dbus? ( >=sys-apps/dbus-1.0.0 )
	gnome? ( >=gnome-base/gconf-2.4.0 )
	hal? (
		>=sys-apps/hal-0.5.11
		>=sys-apps/dbus-1.0.0
	)
	bluetooth? (
		>=net-wireless/bluez-4
		>=sys-apps/dbus-1.0.0
	)
	asyncns? ( net-libs/libasyncns )
	udev? ( >=sys-fs/udev-143[extras] )
	realtime? ( sys-auth/rtkit )
	>=media-libs/audiofile-0.2.6-r1
	>=media-libs/speex-1.2_beta
	>=media-libs/libsndfile-1.0.20
	sys-libs/gdbm
	>=sys-devel/libtool-2.2.4" # it's a valid RDEPEND, libltdl.so is used

DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	X? (
		x11-proto/xproto
		|| ( >=x11-libs/libXtst-1.0.99.2 <x11-proto/xextproto-7.0.99 )
	)
	dev-libs/libatomic_ops
	dev-util/pkgconfig
	system-wide? ( || ( dev-util/unifdef sys-freebsd/freebsd-ubin ) )
	dev-util/intltool"

# alsa-utils dep is for the alsasound init.d script (see bug #155707)
# bluez dep is for the bluetooth init.d script
RDEPEND="${RDEPEND}
	X? ( gnome-extra/gnome-audio )
	system-wide? (
		sys-apps/openrc
		alsa? ( media-sound/alsa-utils )
		bluetooth? ( >=net-wireless/bluez-4 )
	)"

pkg_setup() {
	enewgroup audio 18 # Just make sure it exists
	enewgroup pulse-access
	enewgroup pulse
	enewuser pulse -1 -1 /var/run/pulse pulse,audio

	if use udev && use hal; then
		elog "Please note that enabling both udev and hal will build both"
		elog "discover modules, but only udev will be used automatically."
		elog "If you wish to use hal you have to enable it explicitly"
		elog "or you might just disable the hal USE flag entirely."
	fi
}

src_prepare() {
	# Add some Ubuntu patches
	epatch "${FILESDIR}"/pulse-ubuntu/*
	if use arm; then
		# Fix build on armv5 - bug #294599
		epatch "${FILESDIR}/${PN}-0.9.21-armv5-build-fix.patch"
		eautoreconf
	fi

	elibtoolize
}

src_configure() {
	# It's a binutils bug, once I can find time to fix that I'll add a
	# proper dependency and fix this up. — flameeyes
	append-ldflags $(no-as-needed)

	econf \
		--enable-largefile \
		$(use_enable glib glib2) \
		--disable-solaris \
		$(use_enable asyncns) \
		$(use_enable oss oss-output) \
		$(use_enable alsa) \
		$(use_enable lirc) \
		$(use_enable tcpd tcpwrap) \
		$(use_enable jack) \
		$(use_enable lirc) \
		$(use_enable avahi) \
		$(use_enable hal) \
		$(use_enable dbus) \
		$(use_enable gnome gconf) \
		$(use_enable libsamplerate samplerate) \
		$(use_enable bluetooth bluez) \
		$(use_enable X x11) \
		$(use_enable test default-build-tests) \
		$(use_enable udev) \
		$(use_enable ipv6) \
		$(use_with caps) \
		--localstatedir="${EPREFIX}"/var \
		--disable-per-user-esound-socket \
		--with-database=gdbm \
		--with-udev-rules-dir="${EPREFIX}/$(get_libdir)/udev/rules.d" \
		|| die "econf failed"

	if use doc; then
		pushd doxygen
		doxygen doxygen.conf || die
		popd
	fi
}

src_test() {
	# We avoid running the toplevel check target because that will run
	# po/'s tests too, and they are broken. Officially, it should work
	# with intltool 0.41, but that doesn't look like a stable release.
	emake -C src check || die
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "make install failed"

	# Drop the script entirely if X is disabled
	use X || rm "${ED}"/usr/bin/start-pulseaudio-x11

	if use system-wide; then
		newconfd "${FILESDIR}/pulseaudio.conf.d" pulseaudio

		use_define() {
			local define=${2:-$(echo $1 | tr '[:lower:]' '[:upper:]')}

			use "$1" && echo "-D$define" || echo "-U$define"
		}

		unifdef $(use_define hal) \
			$(use_define avahi) \
			$(use_define alsa) \
			$(use_define bluetooth) \
			$(use_define udev) \
			"${FILESDIR}/pulseaudio.init.d-4" \
			> "${T}/pulseaudio"

		doinitd "${T}/pulseaudio"
	fi

	use avahi && sed -i -e '/module-zeroconf-publish/s:^#::' "${ED}/etc/pulse/default.pa"

	if use hal && ! use udev; then
		sed -i -e 's:-udev:-hal:' "${ED}/etc/pulse/default.pa" || die
	fi

	dodoc README ChangeLog todo || die

	if use doc; then
		pushd doxygen/html
		dohtml * || die
		popd
	fi

	# Create the state directory
	use prefix || diropts -o pulse -g pulse -m0755
	keepdir /var/run/pulse

	find "${D}" -name '*.la' -delete
}

pkg_postinst() {
	if use system-wide; then
		elog "PulseAudio in Gentoo can use a system-wide pulseaudio daemon."
		elog "This support is enabled by starting the pulseaudio init.d ."
		elog "To be able to access that you need to be in the group pulse-access."
		elog "If you choose to use this feature, please make sure that you"
		elog "really want to run PulseAudio this way:"
		elog "   http://pulseaudio.org/wiki/WhatIsWrongWithSystemMode"
		elog "For more information about system-wide support, please refer to:"
		elog "	 http://pulseaudio.org/wiki/SystemWideInstance"
		if use gnome ; then
			elog
			elog "By enabling gnome USE flag, you enabled gconf support. Please note"
			elog "that you might need to remove the gnome USE flag or disable the"
			elog "gconf module on /etc/pulse/system.pa to be able to use PulseAudio"
			elog "with a system-wide instance."
		fi
		elog
		elog "To use the ESounD wrapper while using a system-wide daemon, you also"
		elog "need to enable auth-anonymous for the esound-unix module, or to copy"
		elog "/var/run/pulse/.esd_auth into each home directory."
		elog
	fi
	if use bluetooth; then
		elog
		elog "The BlueTooth proximity module is not enabled in the default"
		elog "configuration file. If you do enable it, you'll have to have"
		elog "your BlueTooth controller enabled and inserted at bootup or"
		elog "PulseAudio will refuse to start."
		elog
		elog "Please note that the BlueTooth proximity module seems itself"
		elog "still experimental, so please report to upstream if you have"
		elog "problems with it."
	fi
	if use alsa; then
		local pkg="media-plugins/alsa-plugins"
		if has_version ${pkg} && ! has_version "${pkg}[pulseaudio]"; then
			elog
			elog "You have alsa support enabled so you probably want to install"
			elog "${pkg} with pulseaudio support to have"
			elog "alsa using applications route their sound through pulseaudio"
		fi
	fi

	eselect esd update --if-unset
}
