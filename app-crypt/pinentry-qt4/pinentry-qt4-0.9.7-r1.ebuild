# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools qmake-utils multilib eutils flag-o-matic toolchain-funcs

MY_PN=${PN/-qt4}
MY_P=${P/-qt4}
DESCRIPTION="Qt4 frontend for pinentry"
HOMEPAGE="http://gnupg.org/aegypten2/index.html"
SRC_URI="mirror://gnupg/${MY_PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm ~amd64 ~x86"
IUSE="caps"

RDEPEND="
	~app-crypt/pinentry-base-${PV}
	!app-crypt/pinentry-base[static]
	!app-crypt/pinentry-qt5
	caps? ( sys-libs/libcap )
	>=dev-qt/qtgui-4.4.1:4
	sys-libs/ncurses:0=
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}/${MY_PN}-0.8.2-ncurses.patch"
	eautoreconf
}

src_configure() {
	local myconf=()
	[[ "$(gcc-major-version)" -ge 5 ]] && append-cxxflags -std=gnu++11

	QT_MOC=""
	myconf+=( --enable-pinentry-qt
		  --disable-pinentry-qt5
		)
	QT_MOC="$(qt4_get_bindir)"/moc
	# Issues finding qt on multilib systems
	export QTLIB="$(qt4_get_libdir)"

	econf \
		--disable-pinentry-tty \
		--disable-pinentry-emacs \
		--disable-pinentry-gtk2 \
		--disable-pinentry-curses \
		--enable-fallback-curses \
		$(use_with caps libcap) \
		--disable-libsecret \
		--disable-pinentry-gnome3 \
		"${myconf[@]}" \
		MOC="${QT_MOC}"
}

src_install() {
	cd qt || die
	emake DESTDIR="${D}" install

	dosym pinentry-qt /usr/bin/pinentry-qt4
}

pkg_postinst() {
	eselect pinentry set pinentry-qt4
	# eselect pinentry update ifunset
}

pkg_postrm() {
	eselect pinentry update ifunset
}
