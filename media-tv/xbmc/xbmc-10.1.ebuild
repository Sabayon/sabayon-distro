# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/xbmc/xbmc-10.1.ebuild,v 1.8 2011/10/12 22:53:27 vapier Exp $

EAPI="2"

inherit eutils python flag-o-matic

# Use XBMC_ESVN_REPO_URI to track a different branch
ESVN_REPO_URI=${XBMC_ESVN_REPO_URI:-http://xbmc.svn.sourceforge.net/svnroot/xbmc/trunk}
ESVN_PROJECT=${ESVN_REPO_URI##*/svnroot/}
ESVN_PROJECT=${ESVN_PROJECT%/*}
if [[ ${PV} == "9999" ]] ; then
	inherit subversion autotools
	KEYWORDS=""
else
	inherit autotools
	SRC_URI="http://mirrors.xbmc.org/releases/source/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="XBMC is a free and open source media-player and entertainment hub"
HOMEPAGE="http://xbmc.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="alsa altivec avahi css debug joystick midi profile pulseaudio rtmp sse sse2 udev vaapi vdpau webserver +xrandr"

COMMON_DEPEND="virtual/opengl
	app-arch/bzip2
	app-arch/unzip
	app-arch/zip
	app-i18n/enca
	dev-libs/boost
	dev-libs/fribidi
	dev-libs/libcdio[-minimal]
	dev-libs/libpcre[cxx]
	>=dev-libs/lzo-2.04
	>=dev-python/pysqlite-2
	media-libs/alsa-lib
	media-libs/faad2
	media-libs/flac
	media-libs/fontconfig
	media-libs/freetype
	>=media-libs/glew-1.5.6
	media-libs/jasper
	media-libs/jbigkit
	virtual/jpeg
	>=media-libs/libass-0.9.7
	css? ( media-libs/libdvdcss )
	media-libs/libmad
	media-libs/libmms
	media-libs/libmodplug
	media-libs/libmpeg2
	media-libs/libogg
	media-libs/libpng
	media-libs/libsamplerate
	media-libs/libsdl[audio,opengl,video,X]
	alsa? ( media-libs/libsdl[alsa] )
	media-libs/libvorbis
	media-libs/sdl-gfx
	>=media-libs/sdl-image-1.2.10[gif,jpeg,png]
	media-libs/sdl-mixer
	media-libs/sdl-sound
	media-libs/tiff
	pulseaudio? ( media-sound/pulseaudio )
	media-sound/wavpack
	>=virtual/ffmpeg-0.6
	rtmp? ( media-video/rtmpdump )
	avahi? ( net-dns/avahi )
	webserver? ( net-libs/libmicrohttpd )
	net-misc/curl
	|| ( >=net-fs/samba-3.4.6[smbclient] <net-fs/samba-3.3 )
	sys-apps/dbus
	sys-libs/zlib
	virtual/mysql
	x11-apps/xdpyinfo
	x11-apps/mesa-progs
	vaapi? ( x11-libs/libva )
	vdpau? (
		|| ( x11-libs/libvdpau >=x11-drivers/nvidia-drivers-180.51 )
		virtual/ffmpeg[vdpau]
	)
	x11-libs/libXinerama
	xrandr? ( x11-libs/libXrandr )
	x11-libs/libXrender"
RDEPEND="${COMMON_DEPEND}
	udev? (	sys-fs/udisks sys-power/upower )"
DEPEND="${COMMON_DEPEND}
	app-text/dos2unix
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
		subversion_src_unpack
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
	epatch "${FILESDIR}"/${PN}-10.0-python-2.7.patch #350098
	epatch "${FILESDIR}"/${PN}-10.1-gcc-4.6.patch #367261
	epatch "${FILESDIR}"/${P}-libpng-1.5.patch #380127
	epatch "${FILESDIR}"/${PN}-10.1-headers.patch #380127
	# Fix runtime SEGV, Sabayon bug #2968
	dos2unix -o "${S}/xbmc/lib/cximage-6.0/CxImage/ximapng.cpp"
	epatch "${FILESDIR}"/${PN}-9999-libpng-1.5-fix-plt-trn-get.patch
	unix2dos -o "${S}/xbmc/lib/cximage-6.0/CxImage/ximapng.cpp"

	# some dirs ship generated autotools, some dont
	local d
	for d in . xbmc/cores/dvdplayer/Codecs/{libdts,libdvd/lib*/} lib/cpluff ; do
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
		xbmc/lib/libsquish/Makefile.in || die

	# Fix XBMC's final version string showing as "exported"
	# instead of the SVN revision number.
	export SVN_REV=${ESVN_WC_REVISION:-exported}

	# Avoid lsb-release dependency
	sed -i \
		-e 's:lsb_release -d:cat /etc/gentoo-release:' \
		xbmc/utils/SystemInfo.cpp

	# Do not use termcap #262822
	sed -i 's:-ltermcap::' xbmc/lib/libPython/Python/configure

	# avoid long delays when powerkit isn't running #348580
	sed -i \
		-e '/dbus_connection_send_with_reply_and_block/s:-1:3000:' \
		xbmc/linux/*.cpp || die

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
		--enable-gl \
		--disable-liba52 \
		--disable-libdts \
		$(use_enable avahi) \
		$(use_enable css dvdcss) \
		$(use_enable debug) \
		--disable-hal \
		$(use_enable joystick) \
		$(use_enable midi mid) \
		$(use_enable profile profiling) \
		$(use_enable pulseaudio pulse) \
		$(use_enable rtmp) \
		$(use_enable vaapi) \
		$(use_enable vdpau) \
		$(use_enable webserver) \
		$(use_enable xrandr)
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc keymapping.txt README.linux
	rm "${D}"/usr/share/doc/${PF}/{copying.txt,LICENSE.GPL} || die

#	insinto /usr/share/applications
#	doins tools/Linux/xbmc.desktop
#	doicon tools/Linux/xbmc.png

	insinto "$(python_get_sitedir)" #309885
	doins tools/EventClients/lib/python/xbmcclient.py || die
	newbin "tools/EventClients/Clients/XBMC Send/xbmc-send.py" xbmc-send || die
}

pkg_postinst() {
	elog "Visit http://wiki.xbmc.org/?title=XBMC_Online_Manual"
}
