# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/ffmpeg/ffmpeg-0.4.9_p20070330.ebuild,v 1.4 2007/04/05 19:28:18 aballier Exp $

inherit eutils flag-o-matic multilib toolchain-funcs

DESCRIPTION="Complete solution to record, convert and stream audio and video.
Includes libavcodec. SVN revision 8560"
HOMEPAGE="http://ffmpeg.org/"
MY_P=${P/_/-}
S=${WORKDIR}/ffmpeg

SRC_URI="mirror://gentoo/${MY_P}.tar.bz2
	amr? ( http://www.3gpp.org/ftp/Specs/archive/26_series/26.104/26104-510.zip
		   http://www.3gpp.org/ftp/Specs/archive/26_series/26.204/26204-510.zip )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ppc64 sparc ~x86 ~x86-fbsd"
IUSE="aac altivec amr debug doc ieee1394 a52 encode imlib mmx ogg vorbis oss
	test theora threads truetype v4l x264 xvid dts network zlib sdl X"

RDEPEND="imlib? ( media-libs/imlib2 )
	truetype? ( >=media-libs/freetype-2 )
	sdl? ( >=media-libs/libsdl-1.2.10 )
	encode? ( media-sound/lame
		vorbis? ( media-libs/libvorbis )
		theora? ( media-libs/libtheora ) )
	ogg? ( media-libs/libogg )
	aac? ( media-libs/faad2 media-libs/faac )
	a52? ( >=media-libs/a52dec-0.7.4-r4 )
	xvid? ( >=media-libs/xvid-1.1.0 )
	zlib? ( sys-libs/zlib )
	dts? ( media-libs/libdts )
	ieee1394? ( =media-libs/libdc1394-1*
				sys-libs/libraw1394 )
	x264? ( >=media-libs/x264-svn-20061014 )
	X? ( x11-libs/libX11 x11-libs/libXext )"

DEPEND="${RDEPEND}
	doc? ( app-text/texi2html )
	test? ( net-misc/wget )
	amr? ( app-arch/unzip )"
# Make sure the mmx USE flag is unmasked
# Remove this once default-linux/amd64/2006.1 is deprecated
DEPEND="${DEPEND} amd64? ( >=sys-apps/portage-2.1.2 )"

src_unpack() {
	unpack ${A} || die
	cd ${S}

	# amr (float) support
	if use amr; then
		einfo "Including amr wide and narrow band (float) support ... "

		# narrow band codec
		mkdir ${S}/libavcodec/amr_float
		cd ${S}/libavcodec/amr_float
		unzip -q ${WORKDIR}/26104-510_ANSI_C_source_code.zip

		# wide band codec
		mkdir ${S}/libavcodec/amrwb_float
		cd ${S}/libavcodec/amrwb_float
		unzip -q ${WORKDIR}/26204-510_ANSI-C_source_code.zip

		# Patch if we're on 64-bit
		if useq alpha || useq amd64 || useq ia64 || useq ppc64; then
			cd ${S}
			epatch "${FILESDIR}/ffmpeg-0.4.9_p20060302-amr-64bit.patch"
		fi
	fi

	cd ${S}

	#Append -fomit-frame-pointer to avoid some common issues
	use debug || append-flags "-fomit-frame-pointer"

	# for some reason it tries to #include <X11/Xlib.h>, but doesn't use it
	sed -i s:\#define\ HAVE_X11:\#define\ HAVE_LINUX: ffplay.c

	# .pc files contain wrong libdir path
	epatch ${FILESDIR}/${PN}-libdir-2007.patch
	sed -i -e "s:GENTOOLIBDIR:$(get_libdir):" configure

	# Make it use pic always since we don't need textrels
	sed -i -e "s:LIBOBJFLAGS=\"\":LIBOBJFLAGS=\'\$\(PIC\)\':" configure

	# To make sure the ffserver test will work
	sed -i -e "s:-e debug=off::" tests/server-regression.sh

	epatch "${FILESDIR}/${PN}-shared-gcc4.1.patch"
	# disable non pic safe asm, bug #172877, bug #172845 and dupes
	epatch "${FILESDIR}/${P}-asmpic.patch"

	# fix INT64_C compile avcodec issues
	epatch ${FILESDIR}/ffmpeg-0.4.9_p20070330-stdin.h.patch

}

src_compile() {
	replace-flags -O0 -O2
	#x86, what a wonderful arch....
	replace-flags -O1 -O2
	local myconf="${EXTRA_ECONF}"

	#disable mmx accelerated code if not requested, or if PIC is required
	# as the provided asm decidedly is not PIC.
	if ( gcc-specs-pie || ! use mmx ) ; then
		myconf="${myconf} --disable-mmx"
	fi

	# enabled by default
	use altivec || myconf="${myconf} --disable-altivec"
	use debug || myconf="${myconf} --disable-debug"
	use oss || myconf="${myconf} --disable-audio-oss"
	use v4l || myconf="${myconf} --disable-v4l --disable-v4l2"
	use ieee1394 || myconf="${myconf} --disable-dv1394"
	use network || myconf="${myconf} --disable-network"
	use zlib || myconf="${myconf} --disable-zlib"
	use sdl || myconf="${myconf} --disable-ffplay"

	myconf="${myconf} --disable-opts"

	# disabled by default
	if use encode
	then
		myconf="${myconf} --enable-libmp3lame"
		use vorbis && myconf="${myconf} --enable-libvorbis --enable-libogg"
		use theora && myconf="${myconf} --enable-libtheora --enable-libogg"
	fi
	use a52 && myconf="${myconf} --enable-liba52"
	use ieee1394 && myconf="${myconf} --enable-dc1394"
	use threads && myconf="${myconf} --enable-pthreads"
	use xvid && myconf="${myconf} --enable-xvid"
	use X && myconf="${myconf} --enable-x11grab"
	use ogg && myconf="${myconf} --enable-libogg"
	use dts && myconf="${myconf} --enable-libdts"
	use x264 && myconf="${myconf} --enable-x264"
	use aac && myconf="${myconf} --enable-libfaad --enable-libfaac"
	use amr && myconf="${myconf} --enable-amr-nb --enable-amr-wb \
								 --enable-amr-if2"

	myconf="${myconf} --enable-gpl --enable-pp --disable-strip"

	tc-is-cross-compiler && myconf="${myconf} --cross-compile --arch=$(tc-arch-kernel)"

	# Specific workarounds for too-few-registers arch...
	if [[ $(tc-arch) == "x86" ]]; then
		filter-flags -fforce-addr -momit-leaf-frame-pointer
		append-flags -fomit-frame-pointer
		is-flag -O? || append-flags -O2
		if (use debug); then
			# no need to warn about debug if not using debug flag
			ewarn ""
			ewarn "Debug information will be almost useless as the frame pointer is omitted."
			ewarn "This makes debugging harder, so crashes that has no fixed behavior are"
			ewarn "difficult to fix. Please have that in mind."
			ewarn ""
		fi
	fi

	cd ${S}
	./configure \
		--prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		--shlibdir=/usr/$(get_libdir) \
		--mandir=/usr/share/man \
		--enable-static --enable-shared \
		"--cc=$(tc-getCC)" \
		${myconf} || die "configure failed"

	emake -j1 depend || die "depend failed"
	emake || die "make failed"
}

src_install() {
	emake -j1 LDCONFIG=true DESTDIR=${D} install || die "Install Failed"

	use doc && emake -j1 documentation
	dodoc Changelog README INSTALL
	dodoc doc/*
}

# Never die for now...
src_test() {
	cd ${S}/tests
	for t in "codectest libavtest test-server" ; do
		make ${t} || ewarn "Some tests in ${t} failed"
	done
}

pkg_postinst() {
	ewarn "ffmpeg may had ABI changes, if ffmpeg based programs"
	ewarn "like xine-lib or vlc stop working as expected please"
	ewarn "rebuild them."
}
