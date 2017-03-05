# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

# Does not work with py3 here
# It might work with py:2.5 but I didn't test that
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="sqlite"

inherit eutils flag-o-matic linux-info python-single-r1 multiprocessing autotools systemd toolchain-funcs user

LIBDVDCSS_COMMIT="2f12236bc1c92f73c21e973363f79eb300de603f"
LIBDVDREAD_COMMIT="17d99db97e7b8f23077b342369d3c22a6250affd"
LIBDVDNAV_COMMIT="43b5f81f5fe30bceae3b7cecf2b0ca57fc930dac"
MY_PN="kodi"
CODENAME="Krypton"
SRC_URI="https://github.com/xbmc/libdvdcss/archive/${LIBDVDCSS_COMMIT}.tar.gz -> libdvdcss-${LIBDVDCSS_COMMIT}.tar.gz
	https://github.com/xbmc/libdvdread/archive/${LIBDVDREAD_COMMIT}.tar.gz -> libdvdread-${LIBDVDREAD_COMMIT}.tar.gz
	https://github.com/xbmc/libdvdnav/archive/${LIBDVDNAV_COMMIT}.tar.gz -> libdvdnav-${LIBDVDNAV_COMMIT}.tar.gz"
case ${PV} in
9999)
	EGIT_REPO_URI="git://github.com/xbmc/xbmc.git"
	inherit git-r3
	;;
*|*_p*)
	MY_PV=${PV/_p/_r}
	MY_PV=${MY_PV/_alpha/a}
	MY_PV=${MY_PV/_beta/b}
	MY_PV=${MY_PV/_rc/rc}
	MY_P="${MY_PN}-${MY_PV}"
	SRC_URI+=" https://github.com/xbmc/xbmc/archive/${MY_PV}-${CODENAME}.tar.gz -> ${MY_P}.tar.gz
		 !java? ( https://github.com/candrews/gentoo-kodi/raw/master/${MY_P}-generated-addons.tar.xz )"
	KEYWORDS="~amd64 ~arm ~x86"

	S=${WORKDIR}/xbmc-${MY_PV}-${CODENAME}
	;;
esac

DESCRIPTION="Kodi is a free and open source media-player and entertainment hub"
HOMEPAGE="http://kodi.tv/ http://kodi.wiki/"

LICENSE="GPL-2"
SLOT="0"
IUSE="airplay airtunes +alsa avahi bluetooth bluray caps +cec dbus debug dvd gles opengl java libressl libusb lirc midi mysql +nfs profile -projectm pulseaudio +samba ssl sftp test +texturepacker udev udisks upnp upower +usb vaapi vdpau webserver -X xslt zeroconf"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	|| ( gles opengl )
	udev? ( !libusb )
	udisks? ( dbus )
	upower? ( dbus )
"
RESTRICT="mirror"

COMMON_DEPEND="${PYTHON_DEPS}
	airplay? ( app-pda/libplist )
	alsa? ( media-libs/alsa-lib )
	bluetooth? ( net-wireless/bluez )
	bluray? ( >=media-libs/libbluray-0.7.0 )
	caps? ( sys-libs/libcap )
	dbus? ( sys-apps/dbus )
	dev-db/sqlite
	dev-libs/expat
	dev-libs/fribidi
	cec? ( >=dev-libs/libcec-raspberrypi-3.0 )
	dev-libs/libpcre[cxx]
	dev-libs/libxml2
	>=dev-libs/lzo-2.04
	dev-libs/tinyxml[stl]
	>=dev-libs/yajl-2
	dev-python/pillow[${PYTHON_USEDEP}]
	dvd? ( dev-libs/libcdio[-minimal] )
	gles? ( media-libs/mesa[gles2] )
	libusb? ( virtual/libusb:1 )
	media-fonts/corefonts
	media-fonts/noto
	media-fonts/roboto
	media-libs/fontconfig
	media-libs/freetype
	>=media-libs/libass-0.9.8
	media-libs/mesa[egl]
	media-libs/raspberrypi-userland
	>=media-libs/taglib-1.11.1
	media-video/raspberrypi-omxplayer
	!media-video/omxplayer
	mysql? ( virtual/mysql )
	>=net-misc/curl-7.51.0
	nfs? ( net-fs/libnfs:= )
	opengl? ( media-libs/glu )
	ssl? (
		!libressl? ( >=dev-libs/openssl-1.0.2j:0= )
		libressl? ( dev-libs/libressl:0= )
	)
	pulseaudio? ( media-sound/pulseaudio )
	samba? ( >=net-fs/samba-3.4.6[smbclient(+)] )
	sftp? ( net-libs/libssh[sftp] )
	sys-libs/zlib
	udev? ( virtual/udev )
	vaapi? ( x11-libs/libva[opengl] )
	vdpau? (
		|| ( >=x11-libs/libvdpau-1.1 >=x11-drivers/nvidia-drivers-180.51 )
		media-video/ffmpeg[vdpau]
	)
	webserver? ( >=net-libs/libmicrohttpd-0.9.50[messages] )
	X? (
		x11-libs/libdrm
		x11-libs/libX11
		x11-libs/libXrandr
		x11-libs/libXrender
	)
	xslt? ( dev-libs/libxslt )
	zeroconf? ( net-dns/avahi )
"
RDEPEND="${COMMON_DEPEND}
	lirc? (
		|| ( app-misc/lirc app-misc/inputlircd )
	)
	!media-tv/xbmc
	!media-tv/kodi
	udisks? ( sys-fs/udisks:0 )
	upower? ( || ( sys-power/upower sys-power/upower-pm-utils ) )"
DEPEND="${COMMON_DEPEND}
	app-arch/bzip2
	app-arch/unzip
	app-arch/xz-utils
	app-arch/zip
	dev-lang/swig
	dev-libs/crossguid
	dev-util/cmake
	dev-util/gperf
	java? ( virtual/jre )
	media-libs/giflib
	>=media-libs/libjpeg-turbo-1.5.1:=
	>=media-libs/libpng-1.6.26:0=
	test? ( dev-cpp/gtest )
	virtual/pkgconfig
	x86? ( dev-lang/nasm )
"
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
	# https://github.com/xbmc/xbmc/pull/11400/commits/db26dd8f619d76cf459b87c2e003e3cd33b96b79
	touch "${S}"/xbmc/cores/AudioEngine/AEDefines_override.h || die

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
		--docdir=${EPREFIX}/usr/share/doc/${PF} \
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

	newicon media/icon48x48.png kodi.png

	# Remove fontconfig settings that are used only on MacOSX.
	# Can't be patched upstream because they just find all files and install
	# them into same structure like they have in git.
	rm -rf "${ED%/}"/usr/share/kodi/system/players/dvdplayer/etc || die

	# Replace bundled fonts with system ones.
	rm "${ED%/}"/usr/share/kodi/addons/skin.estouchy/fonts/NotoSans-Regular.ttf || die
	dosym /usr/share/fonts/noto/NotoSans-Regular.ttf \
		usr/share/kodi/addons/skin.estouchy/fonts/NotoSans-Regular.ttf

	local f
	for f in NotoMono-Regular.ttf NotoSans-Bold.ttf NotoSans-Regular.ttf ; do
		rm "${ED%/}"/usr/share/kodi/addons/skin.estuary/fonts/"${f}" || die
		dosym /usr/share/fonts/noto/"${f}" \
			usr/share/kodi/addons/skin.estuary/fonts/"${f}"
	done

	rm "${ED%/}"/usr/share/kodi/addons/skin.estuary/fonts/Roboto-Thin.ttf || die
	dosym /usr/share/fonts/roboto/Roboto-Thin.ttf \
		usr/share/kodi/addons/skin.estuary/fonts/Roboto-Thin.ttf

	python_domodule tools/EventClients/lib/python/xbmcclient.py
	python_newscript "tools/EventClients/Clients/Kodi Send/kodi-send.py" kodi-send
	dobin "${FILESDIR}"/startkodi
	systemd_dounit "${FILESDIR}"/${PN}.service

	insinto /etc/sudoers.d/
	newins "${FILESDIR}/chvt.sudoers" chvt

}
