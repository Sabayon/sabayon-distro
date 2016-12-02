# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

# Does not work with py3 here
# It might work with py:2.5 but I didn't test that
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="sqlite"

inherit eutils linux-info python-single-r1 multiprocessing autotools systemd toolchain-funcs user

LIBDVDCSS_COMMIT="2f12236bc1c92f73c21e973363f79eb300de603f"
LIBDVDREAD_COMMIT="17d99db97e7b8f23077b342369d3c22a6250affd"
LIBDVDNAV_COMMIT="43b5f81f5fe30bceae3b7cecf2b0ca57fc930dac"
CODENAME="Krypton"
case ${PV} in
9999)
	EGIT_REPO_URI="git://github.com/xbmc/xbmc.git"
	inherit git-r3
	;;
*|*_p*)
	MY_PV=${PV/_p/_r}
	MY_PVB=${MY_PV/_beta/b}
	MY_P="kodi-${MY_PVB}"

	SRC_URI="https://github.com/xbmc/xbmc/archive/${MY_PVB}-${CODENAME}.tar.gz -> ${MY_P}.tar.gz
		https://github.com/xbmc/libdvdcss/archive/${LIBDVDCSS_COMMIT}.tar.gz -> libdvdcss-${LIBDVDCSS_COMMIT}.tar.gz
		https://github.com/xbmc/libdvdread/archive/${LIBDVDREAD_COMMIT}.tar.gz -> libdvdread-${LIBDVDREAD_COMMIT}.tar.gz
		https://github.com/xbmc/libdvdnav/archive/${LIBDVDNAV_COMMIT}.tar.gz -> libdvdnav-${LIBDVDNAV_COMMIT}.tar.gz
		!java? ( https://github.com/candrews/gentoo-kodi/raw/master/${MY_P}-generated-addons.tar.xz )"
	KEYWORDS="~amd64 ~x86 ~arm"

	S=${WORKDIR}/xbmc-${MY_PVB}-${CODENAME}
	;;
esac

DESCRIPTION="Kodi is a free and open source media-player and entertainment hub"
HOMEPAGE="http://kodi.tv/ http://kodi.wiki/"

LICENSE="GPL-2"
SLOT="0"
IUSE="airplay airtunes +alsa avahi bluetooth bluray caps +cec dbus debug gles opengl java midi mysql +nfs profile -projectm pulseaudio +samba sftp test +texturepacker udisks upnp upower +usb vaapi vdpau webserver -X"
REQUIRED_USE="
	|| ( gles opengl )
	gles? ( !vaapi )
	vaapi? ( !gles )
	udisks? ( dbus )
	upower? ( dbus )
"
RESTRICT="mirror"

COMMON_DEPEND="${PYTHON_DEPS}
	app-arch/bzip2
	app-arch/unzip
	app-arch/zip
	app-i18n/enca
	airplay? ( app-pda/libplist )
	airtunes? ( net-misc/shairplay )
	dev-libs/expat
	dev-libs/fribidi
	dev-libs/libcdio[-minimal]
	cec? ( >=dev-libs/libcec-raspberrypi-3.0 )
	dev-libs/libpcre[cxx]
	dev-libs/libxml2
	sys-apps/lsb-release
	dev-libs/libxslt
	>=dev-libs/lzo-2.04
	dev-libs/tinyxml[stl]
	>=dev-libs/yajl-2
	dev-python/simplejson[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	media-fonts/anonymous-pro
	media-fonts/corefonts
	media-fonts/dejavu
	alsa? ( media-libs/alsa-lib )
	media-libs/flac
	media-libs/fontconfig
	media-libs/freetype
	media-libs/jasper
	x11-apps/xrefresh
	media-libs/jbigkit
	>=media-libs/libass-0.9.7
	net-libs/libssh
	bluray? ( >=media-libs/libbluray-0.7.0 )
	media-libs/libmad
	media-libs/libmodplug
	media-libs/libmpeg2
	media-libs/libsamplerate
	>=media-libs/taglib-1.9
	media-libs/tiff:0=
	media-sound/wavpack
	media-video/omxplayer
	!media-video/raspberrypi-omxplayer
	avahi? ( net-dns/avahi )
	nfs? ( net-fs/libnfs:= )
	webserver? ( net-libs/libmicrohttpd[messages] )
	sftp? ( net-libs/libssh[sftp] )
	net-misc/curl
	samba? ( >=net-fs/samba-3.4.6[smbclient(+)] )
	bluetooth? ( net-wireless/bluez )
	dbus? ( sys-apps/dbus )
	caps? ( sys-libs/libcap )
	sys-libs/zlib
	virtual/jpeg:0=
	usb? ( virtual/libusb:1 )
	mysql? ( virtual/mysql )
	media-libs/mesa[gles2]
	vaapi? ( x11-libs/libva[opengl] )
	vdpau? (
		|| ( >=x11-libs/libvdpau-1.1 >=x11-drivers/nvidia-drivers-180.51 )
	)
	X? (
		x11-apps/xdpyinfo
		x11-apps/mesa-progs
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
	)"
RDEPEND="${COMMON_DEPEND}
	!media-tv/xbmc
	!media-tv/kodi
	udisks? ( sys-fs/udisks:0 )
	upower? ( || ( sys-power/upower sys-power/upower-pm-utils ) )"
DEPEND="${COMMON_DEPEND}
	app-arch/xz-utils
	dev-lang/swig
	dev-libs/crossguid
	dev-util/gperf
	X? ( x11-proto/xineramaproto )
	dev-util/cmake
	x86? ( dev-lang/nasm )
	java? ( virtual/jre )
	test? ( dev-cpp/gtest )
	texturepacker? ( media-libs/giflib )
	virtual/pkgconfig"
# Force java for latest git version to avoid having to hand maintain the
# generated addons package.  #488118
[[ ${PV} == "9999" ]] && DEPEND+=" virtual/jre"

CONFIG_CHECK="~IP_MULTICAST"
ERROR_IP_MULTICAST="
In some cases Kodi needs to access multicast addresses.
Please consider enabling IP_MULTICAST under Networking options.
"

pkg_setup() {
	check_extra_config
	python-single-r1_pkg_setup
	enewgroup kodi
	enewuser kodi -1 -1 /home/kodi kodi
	if ! egetent group video | grep -q kodi; then
					local g=$(groups kodi)
					elog "Adding user kodi to video group"
					usermod -G video,${g// /,} kodi || die "Adding user kodi to video group failed"
	fi
	if ! egetent group input | grep -q kodi; then
					local g=$(groups kodi)
					elog "Adding user kodi to input group"
					usermod -G input,${g// /,} kodi || die "Adding user kodi to input group failed"
	fi
	if ! egetent group audio | grep -q kodi; then
					local g=$(groups kodi)
					elog "Adding user kodi to audio group"
					usermod -G audio,${g// /,} kodi || die "Adding user kodi to audio group failed"
	fi
}

src_unpack() {
	[[ ${PV} == 9999 ]] && git-r3_src_unpack || default
	cp "${DISTDIR}/libdvdcss-${LIBDVDCSS_COMMIT}.tar.gz" "${S}/tools/depends/target/libdvdcss/libdvdcss-master.tar.gz" || die
	cp "${DISTDIR}/libdvdread-${LIBDVDREAD_COMMIT}.tar.gz" "${S}/tools/depends/target/libdvdread/libdvdread-master.tar.gz" || die
	cp "${DISTDIR}/libdvdnav-${LIBDVDNAV_COMMIT}.tar.gz" "${S}/tools/depends/target/libdvdnav/libdvdnav-master.tar.gz" || die
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-9999-no-arm-flags.patch #400617
	epatch "${FILESDIR}"/${PN}-9999-texturepacker.patch

	# some dirs ship generated autotools, some dont
	multijob_init
	local d dirs=(
		tools/depends/native/TexturePacker/src/configure
		$(printf 'f:\n\t@echo $(BOOTSTRAP_TARGETS)\ninclude bootstrap.mk\n' | emake -f - f)
	)
	for d in "${dirs[@]}" ; do
		[[ -e ${d} ]] && continue
		pushd ${d/%configure/.} >/dev/null || die
		AT_NOELIBTOOLIZE="yes" AT_TOPLEVEL_EAUTORECONF="yes" \
		multijob_child_init eautoreconf
		popd >/dev/null
	done
	multijob_finish
	elibtoolize

	# Cross-compiler support
	# We need JsonSchemaBuilder and TexturePacker binaries for the host system
	# Later we need libsquish for the target system
	if tc-is-cross-compiler ; then
		mkdir "${WORKDIR}"/${CBUILD} || die
		pushd "${WORKDIR}"/${CBUILD} >/dev/null || die
		einfo "Building host tools"
		cp -a "${S}"/{tools,xbmc} ./ || die
		local tool tools=( JsonSchemaBuilder )
		use texturepacker && tools+=( TexturePacker )
		for tool in "${tools[@]}" ; do
			tc-env_build emake -C tools/depends/native/$tool
			mkdir "${S}"/tools/depends/native/$tool/bin || die
			ln -s "${WORKDIR}"/${CBUILD}/tools/depends/native/$tool/bin/$tool \
				"${S}"/tools/depends/native/$tool/bin/$tool || die
		done
		popd >/dev/null || die

		emake -f codegenerator.mk
		# Binary kodi.bin links against libsquish,
		# so we need libsquish compiled for the target system
		emake -C tools/depends/native/libsquish-native/ CXX=$(tc-getCXX)
	elif [[ ${PV} == 9999 ]] || use java ; then #558798
		tc-env_build emake -f codegenerator.mk
	fi


	# Disable internal func checks as our USE/DEPEND
	# stuff handles this just fine already #408395
	export ac_cv_lib_avcodec_ff_vdpau_vc1_decode_picture=yes

	# Fix the final version string showing as "exported"
	# instead of the SVN revision number.
	export HAVE_GIT=no GIT_REV=${EGIT_VERSION:-exported}

	# avoid long delays when powerkit isn't running #348580
	sed -i \
		-e '/dbus_connection_send_with_reply_and_block/s:-1:3000:' \
		xbmc/linux/*.cpp || die

	epatch_user #293109

	# Tweak autotool timestamps to avoid regeneration
	find . -type f -exec touch -r configure {} +
}

src_configure() {
	# Disable documentation generation
	export ac_cv_path_LATEX=no
	# Avoid help2man
	export HELP2MAN=$(type -P help2man || echo true)
	# No configure flage for this #403561
	export ac_cv_lib_bluetooth_hci_devid=$(usex bluetooth)
	# Requiring java is asine #434662
	[[ ${PV} != 9999 ]] && export ac_cv_path_JAVA_EXE=$(which $(usex java java true))

	econf \
		--docdir=/usr/share/doc/${PF} \
		--disable-gl \
		--enable-gles \
		--disable-yasm \
		--with-platform=raspberry-pi \
		--disable-sdl \
		--enable-optimizations \
		--disable-x11 \
		--disable-goom \
		--disable-xrandr \
		--disable-mid \
		--enable-nfs \
		--disable-profiling \
		--enable-rsxs \
		--disable-debug \
		--disable-vaapi \
		--disable-vdpau \
		--disable-avahi \
		--enable-libcec \
		--disable-pulse \
		--disable-projectm \
		--disable-optical-drive \
		--disable-vtbdecoder \
		--enable-alsa \
		--enable-player=omxplayer
}

src_compile() {
	emake V=1
}

src_install() {
	default
	rm "${ED}"/usr/share/doc/*/{LICENSE.GPL,copying.txt}* || die

	domenu tools/Linux/kodi.desktop
	newicon media/icon48x48.png kodi.png

	insinto /etc/udev/rules.d
	newins "${FILESDIR}/99-input.rules" 99-input.rules
	insinto /usr/share/polkit-1/rules.d/
	newins "${FILESDIR}/kodi.rules" 99-kodi.rules

	# Remove fontconfig settings that are used only on MacOSX.
	# Can't be patched upstream because they just find all files and install
	# them into same structure like they have in git.
	rm -rf "${ED%/}"/usr/share/kodi/system/players/dvdplayer/etc || die

	# Replace bundled fonts with system ones.
	rm "${ED%/}"/usr/share/kodi/addons/skin.estouchy/fonts/DejaVuSans-Bold.ttf || die
	dosym /usr/share/fonts/dejavu/DejaVuSans-Bold.ttf \
		/usr/share/kodi/addons/skin.estouchy/fonts/DejaVuSans-Bold.ttf
	rm "${ED%/}"/usr/share/kodi/addons/skin.estuary/fonts/AnonymousPro.ttf || die
	dosym /usr/share/fonts/anonymous-pro/Anonymous\ Pro.ttf \
		/usr/share/kodi/addons/skin.estuary/fonts/AnonymousPro.ttf
	#lato is also present but cannot be unbundled because
	#lato isn't (yet) in portage: https://bugs.gentoo.org/show_bug.cgi?id=589288


	python_domodule tools/EventClients/lib/python/xbmcclient.py
	python_newscript "tools/EventClients/Clients/Kodi Send/kodi-send.py" kodi-send
	dobin "${FILESDIR}"/startkodi
	systemd_dounit "${FILESDIR}"/${PN}.service

	insinto /etc/sudoers.d/
	newins "${FILESDIR}/chvt.sudoers" chvt

}
