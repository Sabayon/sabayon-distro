# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

EAPI=2

inherit eutils toolchain-funcs flag-o-matic versionator

DESCRIPTION="multi-track hard disk recording software"
HOMEPAGE="http://ardour.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="altivec debug freesound nls sse"

RDEPEND="media-libs/liblo
	media-libs/aubio
	>=media-libs/liblrdf-0.4.0
	>=media-libs/raptor-1.4.2
	>=media-sound/jack-audio-connection-kit-0.109.2
	>=dev-libs/glib-2.10.3
	x11-libs/pango
	>=x11-libs/gtk+-2.8.8
	media-libs/flac
	media-libs/alsa-lib
	>=media-libs/libsamplerate-0.1.1-r1
	>=dev-libs/libxml2-2.6.0
	dev-libs/libxslt
	>=gnome-base/libgnomecanvas-2.20
	>=media-libs/libsndfile-1.0.16
	x11-themes/gtk-engines
	>=dev-cpp/gtkmm-2.12.3
	>=dev-cpp/glibmm-2.14.2
	>=dev-cpp/libgnomecanvasmm-2.20.0
	dev-cpp/cairomm
	>=dev-libs/libsigc++-2.0
	media-libs/libsoundtouch
	dev-libs/libusb
	=sci-libs/fftw-3*
	freesound? ( net-misc/curl )"
# slv2? ( >=media-libs/slv2-0.6.1 )

DEPEND="${RDEPEND}
	sys-devel/libtool
	dev-libs/boost
	dev-util/pkgconfig
	>=dev-util/scons-0.98.5
	nls? ( sys-devel/gettext )"

S=${WORKDIR}/${P%_p*}

src_prepare() {
	epatch "${FILESDIR}/${P}-sndfile-external.patch"
	epatch "${FILESDIR}/${P}-cflags.patch"
}

ardour_use_enable() {
	use ${2} && echo "${1}=1" || echo "${1}=0"
}

src_compile() {
	# Required for scons to "see" intermediate install location
	mkdir -p "${D}"

	local FPU_OPTIMIZATION=$((use altivec || use sse) && echo 1 || echo 0)
	cd "${S}"

	tc-export CC CXX

	scons \
		$(ardour_use_enable DEBUG debug) \
		FPU_OPTIMIZATION=${FPU_OPTIMIZATION} \
		DESTDIR="${D}" \
		$(ardour_use_enable NLS nls) \
		$(ardour_use_enable FREESOUND freesound) \
		FFT_ANALYSIS=1 \
		SYSLIBS=1 \
		CFLAGS="${CFLAGS}" \
		LV2=0 \
		PREFIX=/usr || die "scons failed"
}

src_install() {
	scons install || die "make install failed"

	dodoc DOCUMENTATION/*

	doicon "${S}/icons/icon/ardour_icon_mac.png"
	make_desktop_entry ardour2 Ardour2 ardour_icon_mac AudioVideo
}

pkg_postinst() {
	ewarn "---------------- WARNING -------------------"
	ewarn ""
	ewarn "Do not use Ardour 2.0 to open the only copy of sessions created with Ardour 0.99."
	ewarn "Ardour 2.0 saves the session file in a new format that Ardour 0.99 will"
	ewarn "not understand."
	ewarn ""
	ewarn "MAKE BACKUPS OF THE SESSION FILES."
	ewarn ""
	ewarn "The simplest way to address this is to make a copy of the session file itself"
	ewarn "(e.g mysession/mysession.ardour) and make that file unreadable using chmod(1)."
	ewarn ""
	ewarn "---------------- WARNING -------------------"
	ewarn ""
	ewarn "If you use KDE 3.5, be sure to uncheck 'Apply colors to non-KDE applications' in"
	ewarn "the colors configuration module if you want to be able to actually see various"
	ewarn "texts in Ardour 2."
}
