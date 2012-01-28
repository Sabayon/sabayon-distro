# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/xbmc/xbmc-9999.ebuild,v 1.94 2011/12/21 03:42:04 vapier Exp $

EAPI="2"

inherit autotools eutils python flag-o-matic

EGIT_REPO_URI="git://github.com/xbmc/xbmc.git"
if [[ ${PV} == "9999" ]] ; then
	inherit git-2
else
	if [[ ${PV} == *beta* ]] ; then 
		inherit versionator
		CODENAME="Eden"
		MY_PV=`get_version_component_range 1-2`-${CODENAME}_`get_version_component_range 3`
		MY_P="${PN}-${MY_PV}"
	else
		MY_P=${P/_/-}
	fi
	SRC_URI="http://mirrors.xbmc.org/releases/source/${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~x86"
	S=${WORKDIR}/${MY_P}
fi

DESCRIPTION="XBMC is a free and open source media-player and entertainment hub"
HOMEPAGE="http://xbmc.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="airplay alsa altivec avahi bluray css debug goom joystick midi profile +projectm pulseaudio +rsxs rtmp +samba sse sse2 udev vaapi vdpau webserver +xrandr"

COMMON_DEPEND="
	app-arch/bzip2
	app-arch/unzip
	app-arch/zip
	app-i18n/enca
	dev-libs/boost
	dev-libs/fribidi
	dev-libs/libcdio[-minimal]
	dev-libs/libpcre[cxx]
	>=dev-libs/lzo-2.04
	dev-libs/yajl
	>=dev-python/pysqlite-2
	dev-python/simplejson
	media-libs/alsa-lib
	media-libs/flac
	media-libs/fontconfig
	media-libs/freetype
	media-libs/glew
	media-libs/jasper
	media-libs/jbigkit
	media-libs/libass
	media-libs/libmad
	media-libs/libmodplug
	media-libs/libmpeg2
	media-libs/libogg
	media-libs/libpng
	media-libs/libsamplerate
	media-libs/libsdl[audio,opengl,video,X]
	media-libs/libvorbis
	media-libs/sdl-gfx
	media-libs/sdl-image[gif,jpeg,png]
	media-libs/sdl-mixer
	media-libs/sdl-sound
	media-libs/tiff
	media-sound/wavpack
	>=virtual/ffmpeg-0.6
	net-misc/curl
	=net-wireless/bluez-4.96
	sys-apps/dbus
	sys-libs/zlib
	virtual/jpeg
	virtual/opengl
	virtual/mysql
	x11-apps/xdpyinfo
	x11-apps/mesa-progs
	x11-libs/libXinerama
	x11-libs/libXrender
	airplay? ( app-pda/libplist )
	alsa? ( media-libs/libsdl[alsa] )
	avahi? ( net-dns/avahi )
	bluray? ( media-libs/libbluray )
	css? ( media-libs/libdvdcss )
	pulseaudio? ( media-sound/pulseaudio )
	projectm? ( media-libs/libprojectm )
	rtmp? ( media-video/rtmpdump )
	samba? ( >=net-fs/samba-3.4.6[smbclient] )
	vaapi? ( x11-libs/libva )
	vdpau? (
		|| ( x11-libs/libvdpau >=x11-drivers/nvidia-drivers-180.51 )
		media-video/ffmpeg[vdpau]
	)
	webserver? ( net-libs/libmicrohttpd )
	xrandr? ( x11-libs/libXrandr )"

RDEPEND="${COMMON_DEPEND}
	udev? (	sys-fs/udisks sys-power/upower )"
DEPEND="${COMMON_DEPEND}
	dev-util/gperf
	x11-proto/xineramaproto
	dev-util/cmake
	x86? ( dev-lang/nasm )"

pkg_setup() {
	# nasty runtime things might happen otherwise
	# /usr/lib64/xbmc/system/players/dvdplayer/avcodec-52-x86_64-linux.so:
	# undefined symbol: NeAACDecSetConfiguration
	append-ldflags $(no-as-needed)
	python_pkg_setup
}

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		git-2_src_unpack
		cd "${S}"
		rm -f configure
	else
		unpack ${A}
		cd "${S}"
	fi

	# Fix case sensitivity
	mv media/Fonts/{a,A}rial.ttf || die
	mv media/{S,s}plash.png || die
}

src_prepare() {
	# some dirs ship generated autotools, some dont
	local d
	for d in \
		. \
		lib/{libdvd/lib*/,cpluff,libapetag,libid3tag/libid3tag} \
		xbmc/screensavers/rsxs-* \
		xbmc/visualizations/Goom/goom2k4-0
	do
		[[ -e ${d}/configure ]] && continue
		pushd ${d} >/dev/null
		einfo "Generating autotools in ${d}"
		eautoreconf
		popd >/dev/null
	done

	local squish #290564
	use altivec && squish="-DSQUISH_USE_ALTIVEC=1 -maltivec"
	use sse && squish="-DSQUISH_USE_SSE=1 -msse"
	use sse2 && squish="-DSQUISH_USE_SSE=2 -msse2"
	sed -i \
		-e '/^CXXFLAGS/{s:-D[^=]*=.::;s:-m[[:alnum:]]*::}' \
		-e "1iCXXFLAGS += ${squish}" \
		lib/libsquish/Makefile.in || die

	# Fix XBMC's final version string showing as "exported"
	# instead of the SVN revision number.
	export HAVE_GIT=no GIT_REV=${EGIT_VERSION:-exported}

	# Avoid lsb-release dependency
	sed -i \
		-e 's:lsb_release -d:cat /etc/gentoo-release:' \
		xbmc/utils/SystemInfo.cpp || die

	# avoid long delays when powerkit isn't running #348580
	sed -i \
		-e '/dbus_connection_send_with_reply_and_block/s:-1:3000:' \
		xbmc/linux/*.cpp || die

	epatch "${FILESDIR}"/xbmc-11.0_beta1-libpng-1.5-headers.patch
	epatch "${FILESDIR}"/xbmc-11.0_beta1-libpng-1.5.patch
	epatch "${FILESDIR}"/xbmc-11.0_beta1-libpng-1.5-fix-plt-trn-get.patch
	epatch "${FILESDIR}"/xbmc-9999-no-arm-flags.patch


	epatch_user #293109
	# Tweak autotool timestamps to avoid regeneration
	find . -type f -print0 | xargs -0 touch -r configure
}

src_configure() {
	# Disable documentation generation
	export ac_cv_path_LATEX=no
	# Avoid help2man
	export HELP2MAN=$(type -P help2man || echo true)

	# XBMC python mods only work with internal Python 2.4
	# ffmpeg is a moving target and newer version may
	# not work with xbmc, even if API compatible (vdpau in
	# ffmpeg is the main issue)
	# a52 support is deprecated
	# libdts support is deprecated
	econf \
		--docdir=/usr/share/doc/${PF} \
		--disable-ccache \
		--disable-optimizations \
		--disable-external-python \
		--disable-external-ffmpeg \
		--disable-external-libdts \
		--disable-external-liba52 \
		--enable-goom \
		--enable-gl \
		--disable-liba52 \
		--disable-libdts \
		$(use_enable airplay) \
		$(use_enable avahi) \
		$(use_enable bluray libbluray) \
		$(use_enable css dvdcss) \
		$(use_enable debug) \
		$(use_enable goom) \
		--disable-hal \
		$(use_enable joystick) \
		$(use_enable midi mid) \
		$(use_enable profile profiling) \
		$(use_enable projectm) \
		$(use_enable pulseaudio pulse) \
		$(use_enable rsxs) \
		$(use_enable rtmp) \
		$(use_enable samba) \
		$(use_enable vaapi) \
		$(use_enable vdpau) \
		$(use_enable webserver) \
		$(use_enable xrandr)
}

src_install() {
	emake install DESTDIR="${D}" || die
	prepalldocs

	insinto /usr/share/applications
	doins tools/Linux/xbmc.desktop
	doicon tools/Linux/xbmc.png

	insinto "$(python_get_sitedir)" #309885
	doins tools/EventClients/lib/python/xbmcclient.py || die
	newbin "tools/EventClients/Clients/XBMC Send/xbmc-send.py" xbmc-send || die
}

pkg_postinst() {
	elog "Visit http://wiki.xbmc.org/?title=XBMC_Online_Manual"
}
