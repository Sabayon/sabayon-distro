# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools qmake-utils multilib eutils flag-o-matic toolchain-funcs

MY_PN=${PN/-qt5}
MY_P=${P/-qt5}
DESCRIPTION="Qt5 frontend for pinentry"
HOMEPAGE="http://gnupg.org/aegypten2/index.html"
SRC_URI="mirror://gnupg/${MY_PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm ~amd64 ~x86"
IUSE="caps"

RDEPEND="
	~app-crypt/pinentry-base-${PV}
	!app-crypt/pinentry-base[static]
	!app-crypt/pinentry-qt4
	caps? ( sys-libs/libcap )
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}/${MY_P}-require-CPP11-for-qt-5-7.patches"
	eautoreconf
}

src_configure() {
	local myconf=()
	[[ "$(gcc-major-version)" -ge 5 ]] && append-cxxflags -std=gnu++11

	QT_MOC=""
	myconf+=( --enable-pinentry-qt )
	QT_MOC="$(qt5_get_bindir)"/moc
	# Issues finding qt on multilib systems
	export QTLIB="$(qt5_get_libdir)"

	econf \
		--disable-pinentry-tty \
		--disable-pinentry-emacs \
		--disable-pinentry-gtk2 \
		--disable-pinentry-curses \
		--disable-fallback-curses \
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
	# -qt4 is not a typo: see dosym above.
	eselect pinentry set pinentry-qt4
	# eselect pinentry update ifunset
}

pkg_postrm() {
	eselect pinentry update ifunset
}
