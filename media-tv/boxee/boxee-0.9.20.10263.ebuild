# Copyright 1999-2009 Sabayon Foundation
# Distributed under the terms of the GNU General Public License v2
#
EAPI="2"

inherit eutils autotools multilib python

SRC_URI="http://dl.boxee.tv/${P}-source.tar.bz2
	 http://distfiles.sabayon.org/${CATEGORY}/xmbc-linux-tools-git20100110.tar.gz"
KEYWORDS=""
DESCRIPTION="Cross-platform media center software based on XBMC"
HOMEPAGE="http://boxee.tv/"
LICENSE="GPL-2"
SLOT="0"
IUSE="+aac +alsa altivec avahi +css debug joystick midi +opengl profile +pulseaudio sse sse2 +vdpau +xrandr"

RDEPEND="opengl? ( virtual/opengl )
	app-arch/bzip2
	|| ( app-arch/unrar app-arch/unrar-gpl )
	app-arch/unzip
	app-arch/zip
	app-i18n/enca
	>=dev-lang/python-2.4
	dev-libs/boost
	dev-libs/fribidi
	dev-libs/libcdio
	dev-libs/libpcre
	dev-libs/lzo
	>=dev-python/pysqlite-2
	media-libs/a52dec
	media-libs/alsa-lib
	aac? ( media-libs/faac )
	media-libs/faad2
	media-libs/flac
	media-libs/fontconfig
	media-libs/freetype
	media-libs/glew
	media-libs/jasper
	media-libs/jbigkit
	media-libs/jpeg
	>=media-libs/libass-0.9.7
	media-libs/libdca
	css? ( media-libs/libdvdcss )
	media-libs/libmad
	media-libs/libmms
	media-libs/libmpeg2
	media-libs/libogg
	media-libs/libsamplerate
	media-libs/libsdl[alsa,audio,video,X]
	media-libs/libvorbis
	media-libs/sdl-gfx
	media-libs/sdl-image[gif,jpeg,png]
	media-libs/sdl-mixer
	media-libs/sdl-sound
	media-libs/tiff
	pulseaudio? ( media-sound/pulseaudio )
	media-sound/wavpack
	media-video/ffmpeg
	avahi? ( net-dns/avahi )
	net-misc/curl
	net-fs/samba
	sys-apps/dbus
	sys-apps/hal
	sys-libs/zlib
	virtual/mysql
	x11-apps/xdpyinfo
	x11-apps/mesa-progs
	vdpau? ( || ( x11-libs/libvdpau <x11-drivers/nvidia-drivers-185.18.36-r1 ) )
	x11-libs/libXinerama
	xrandr? ( x11-libs/libXrandr )
	x11-libs/libXrender"
DEPEND="${RDEPEND}
	x11-proto/xineramaproto
	dev-util/cmake
	x86? ( dev-lang/nasm )
	>=app-emulation/emul-linux-x86-baselibs-20091231"

S=${WORKDIR}/${P}-source

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix case sensitivity
	mv media/Fonts/{a,A}rial.ttf || die
	mv media/{S,s}plash.png || die
}

src_prepare() {
	# Fix the broken stuff
	for patch in `ls ${FILESDIR}/${PN}*.patch ${FILESDIR}/xbmc*.patch`; do
		epatch $patch
	done

	# Use upstream XMBC's working linux tools
	cp -R ${WORKDIR}/Linux ${S}/tools || die "XMBC Linux Tools copy Failed"

	# *Awesome* sed voodoo
	# Fix Curl
	sed -i \
	-e 's:\(g_curlInterface.easy_setopt.*, \)\(NULL\):\1(void*)\2:g' \
		xbmc/FileSystem/FileCurl.cpp || die

	sed -i \
		-e 's: ftell64: dll_ftell64:' \
		xbmc/cores/DllLoader/exports/wrapper.c || die
	sed -i \
		-e '1i#include <stdlib.h>\n#include <string.h>\n' \
		xbmc/lib/libid3tag/libid3tag/metadata.c || die

	# some dirs ship generated autotools, some dont
	local d
	for d in . xbmc/cores/dvdplayer/Codecs/libbdnav xbmc/lib/libass; do
		[[ -d ${d} ]] || continue
		[[ -e ${d}/configure ]] && continue
		pushd ${d} >/dev/null
		einfo "Generating autotools in ${d}"
		eautoreconf
		popd >/dev/null
	done

	# Avoid lsb-release dependency
	sed -i \
		-e 's:/usr/bin/lsb_release -d:cat /etc/gentoo-release:' \
		xbmc/utils/SystemInfo.cpp

	# Do not use termcap #262822
	sed -i 's:-ltermcap::' xbmc/lib/libPython/Python/configure

	epatch_user #293109

	# Tweak autotool timestamps to avoid regeneration
	find . -type f -print0 | xargs -0 touch -r configure
}

src_configure() {
	# Disable documentation generation
	export ac_cv_path_LATEX=no
	# Avoid help2man
	export HELP2MAN=$(type -P help2man || echo true)

	# Run libPython configure first
	#cd xbmc/lib/libPython/Python
	#econf --prefix=/opt/boxee/xbmc/lib/libPython/Python|| die "python econf failed"
	#cd ${S}

	econf \
		--prefix=/opt/boxee \
		--disable-ccache \
		--disable-optimizations \
		--enable-external-libraries \
		--enable-goom \
		$(use_enable avahi) \
		$(use_enable css dvdcss) \
		$(use_enable debug) \
		$(use_enable aac faac) \
		$(use_enable joystick) \
		$(use_enable midi mid) \
		$(use_enable opengl gl) \
		$(use_enable profile profiling) \
		$(use_enable pulseaudio pulse) \
		$(use_enable vdpau) \
		$(use_enable xrandr)
}

src_install() {
	einstall || die "Install failed!"

	insinto /usr/share/xbmc/web/styles/
	doins -r "${S}"/web/*/styles/*/ || die

	insinto /usr/share/applications
	doins tools/Linux/xbmc.desktop
	doicon tools/Linux/xbmc.png

	dodoc README.linux known_issues.txt
	rm "${D}"/usr/share/xbmc/{README.linux,LICENSE.GPL,*.txt}
}

pkg_postinst() {
	elog "Visit http://xbmc.org/wiki/?title=XBMC_Online_Manual"
}