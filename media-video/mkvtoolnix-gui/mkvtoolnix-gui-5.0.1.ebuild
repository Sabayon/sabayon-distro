# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit wxwidgets autotools

MY_P=${P/-gui}
DESCRIPTION="Tools to create, alter, and inspect Matroska files"
HOMEPAGE="http://www.bunkus.org/videotools/mkvtoolnix"
SRC_URI="http://www.bunkus.org/videotools/mkvtoolnix/sources/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE="bzip2 debug lzo pch wxwidgets"

RDEPEND="
	>=dev-libs/libebml-1.2.2
	>=media-libs/libmatroska-1.3.0
	>=dev-libs/boost-1.36.0
	dev-libs/expat
	media-libs/flac
	media-libs/libogg
	media-libs/libvorbis
	sys-apps/file
	sys-libs/zlib
	bzip2? ( app-arch/bzip2 )
	lzo? ( dev-libs/lzo )
	x11-libs/wxGTK:2.8[X] ~media-video/mkvtoolnix-${PV}[-wxwidgets]
"
DEPEND="${RDEPEND}
	dev-ruby/rake
"
S=${WORKDIR}/${MY_P}

src_prepare() {
	sed -i -e '/^Exec/   s/mkvinfo/mkvinfo-gui/' \
		share/desktop/mkvinfo.desktop || die
	# Disable automagic curl dep used for online update checking
	sed -i -e '/curl/d' configure.in
	export CURL_CFLAGS="" CURL_LIBS=""

	eautoreconf
}

src_configure() {
	local myconf

	use pch || myconf="${myconf} --disable-precompiled-headers"

	WX_GTK_VER="2.8"
	need-wxwidgets unicode
	myconf="${myconf} --with-wx-config=${WX_CONFIG}"

	econf \
		$(use_enable lzo) \
		$(use_enable bzip2 bz2) \
		--enable-wxwidgets \
		$(use_enable debug) \
		--disable-qt \
		${myconf} \
		--with-boost-regex=boost_regex \
		--with-boost-filesystem=boost_filesystem \
		--with-boost-system=boost_system
}

src_compile() {
	rake || die "rake failed"
}

src_install() {
	# Don't run strip while installing stuff, leave to portage the job.
	DESTDIR="${D}" rake install || die

	find "${ED}usr/share/man" -not -name 'mmg.*' -type f -exec rm {} +
	rm -r "${ED}usr/share/locale" || die
	rm "${ED}"usr/bin/{mkvextract,mkvmerge,mkvpropedit} || die
	mv "${ED}usr/bin/mkvinfo" "${ED}usr/bin/mkvinfo-gui" || die
}
