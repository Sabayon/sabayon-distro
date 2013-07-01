# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils multilib toolchain-funcs versionator wxwidgets multiprocessing autotools

MY_P=${P/-gui}
DESCRIPTION="Tools to create, alter, and inspect Matroska files"
HOMEPAGE="http://www.bunkus.org/videotools/mkvtoolnix"
SRC_URI="http://www.bunkus.org/videotools/mkvtoolnix/sources/${MY_P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE="debug pch"

RDEPEND="~media-video/mkvtoolnix-${PV}
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	x11-libs/wxGTK:2.8[X]
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

pkg_pretend() {
	# http://bugs.gentoo.org/419257
	local ver=4.6
	local msg="You need at least GCC ${ver}.x for C++11 range-based 'for' and nullptr support."
	if ! version_is_at_least ${ver} $(gcc-version); then
		eerror ${msg}
		die ${msg}
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${PN/-gui}-5.8.0-system-pugixml.patch \
		"${FILESDIR}"/${PN/-gui}-5.8.0-boost-configure.patch
	eautoreconf
}

src_configure() {
	local myconf

	#if use wxwidgets ; then
		WX_GTK_VER="2.8"
		need-wxwidgets unicode
		myconf="--with-wx-config=${WX_CONFIG}"
	#fi

	econf \
		$(use_enable debug) \
		$(usex pch "" --disable-precompiled-headers) \
		${myconf} \
		--enable-qt \
		--enable-wxwidgets \
		--disable-optimization \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		--with-boost="${EPREFIX}"/usr \
		--with-boost-libdir="${EPREFIX}"/usr/$(get_libdir) \
		--without-curl
}

src_compile() {
	./drake V=1 -j$(makeopts_jobs) || die
}

src_install() {
	DESTDIR="${D}" ./drake -j$(makeopts_jobs) install || die

	dodoc AUTHORS ChangeLog README TODO
	doman doc/man/*.1

	docompress -x /usr/share/doc/${PF}/guide

	find "${ED}usr/share/man" -not -name 'mmg.*' -type f -exec rm {} +
	rm -r "${ED}usr/share/locale" || die
	rm "${ED}usr/share/doc/${PF}/"{AUTHORS*,ChangeLog*,README*,TODO*} || die
	rm "${ED}"usr/bin/{mkvextract,mkvmerge,mkvpropedit} || die
	mv "${ED}usr/bin/mkvinfo" "${ED}usr/bin/mkvinfo-gui" || die
}
