# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/mkvtoolnix/mkvtoolnix-4.0.0.ebuild,v 1.1 2010/06/05 22:20:22 beandog Exp $

EAPI="1"
inherit eutils wxwidgets flag-o-matic qt4 autotools

DESCRIPTION="Tools to create, alter, and inspect Matroska files"
HOMEPAGE="http://www.bunkus.org/videotools/mkvtoolnix"
SRC_URI="http://www.bunkus.org/videotools/mkvtoolnix/sources/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE="bzip2 debug doc flac lzo qt4 wxwidgets"

DEPEND=">=dev-libs/libebml-1.0.0
	>=media-libs/libmatroska-1.0.0
	media-libs/libogg
	media-libs/libvorbis
	dev-libs/expat
	sys-libs/zlib
	dev-libs/boost
	wxwidgets? ( x11-libs/wxGTK:2.8 )
	flac? ( media-libs/flac )
	bzip2? ( app-arch/bzip2 )
	lzo? ( dev-libs/lzo )
	qt4? ( x11-libs/qt-gui:4 )"
RDEPEND="${DEPEND}"

pkg_setup() {
	WX_GTK_VER="2.8"
	if use wxwidgets; then
		need-wxwidgets unicode
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	use qt4 && epatch "${FILESDIR}/${P}-show_console.patch"

	eautoreconf
}

src_compile() {
	use wxwidgets && myconf="--with-wx-config=${WX_CONFIG}"
	econf \
		$(use_enable lzo) \
		$(use_enable bzip2 bz2) \
		$(use_enable wxwidgets) \
		$(use_enable debug) \
		$(use_with flac) \
		$(use_enable qt4 qt) \
		${myconf} \
		--with-boost-regex=boost_regex \
		--with-boost-filesystem=boost_filesystem \
		--with-boost-system=boost_system

	# Don't run strip while installing stuff, leave to portage the job.
	emake STRIP="true" || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" STRIP="true" install || die "make install failed"
	dodoc AUTHORS ChangeLog README TODO || die "dodoc failed"
	doman doc/man/*.1 || die "doman failed"

	if use doc; then
		dohtml doc/guide/en/mkvmerge-gui.html || die "dohtml failed"
		docinto html/images
		dohtml doc/guide/en/images/* || die "dohtml failed"
		docinto examples
		dodoc examples/* || die "dodoc failed"
	fi
}
