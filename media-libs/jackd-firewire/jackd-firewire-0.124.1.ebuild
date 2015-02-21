# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit multilib

MY_PN="jack-audio-connection-kit"
DESCRIPTION="FFADO backend for JACK Audio Connection Kit"
HOMEPAGE="http://www.jackaudio.org"
SRC_URI="http://www.jackaudio.org/downloads/${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

RDEPEND="
	>=media-libs/alsa-lib-1.0.18
	media-libs/libffado
	~media-sound/${MY_PN}-${PV}[-ffado]
"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	sed -i \
		-e "s:\$(top_builddir)/libjack/libjack.la:${ROOT}usr/$(get_libdir)/libjack.la:" \
		-e "s:\$(top_builddir)/jackd/libjackserver.la:${ROOT}usr/$(get_libdir)/libjackserver.la:" \
		drivers/firewire/Makefile.in || die
}

src_configure() {
	# use !doc equivalent
	export ac_cv_prog_HAVE_DOXYGEN=false

	econf \
		--enable-firewire \
		--disable-altivec \
		--disable-alsa \
		--disable-coreaudio \
		--disable-debug \
		--disable-mmx \
		--disable-oss \
		--disable-portaudio \
		--disable-sse \
		--with-html-dir=/usr/share/doc/${PF} \
		--disable-dependency-tracking \
		|| die "configure failed"
}

src_compile() {
	emake -C drivers/firewire || die
}

src_install() {
	emake -C drivers/firewire DESTDIR="${D}" install || die "install failed"
}
