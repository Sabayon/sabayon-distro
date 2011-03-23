# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils toolchain-funcs fdo-mime flag-o-matic versionator scons-utils

DESCRIPTION="multi-track hard disk recording software"
HOMEPAGE="http://ardour.org/"

SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="aubio austate oldfonts debug dmalloc fft_analysis freesound fpu_optimization liblo nls surfaces wiimote lv2 vst sys-libs tranzport"

RDEPEND=">=media-libs/liblrdf-0.4.0
	media-libs/aubio
	>=gnome-base/libgnomecanvas-2.0
	>=media-libs/raptor-1.4.2
	>=media-sound/jack-audio-connection-kit-0.116.2
	>=dev-libs/glib-2.10.3
	>=x11-libs/gtk+-2.8.8
	>=media-libs/alsa-lib-1.0.14a-r1
	>=media-libs/libsamplerate-0.1.2
	media-libs/liblo
	>=dev-libs/libxml2-2.6.0
	dev-libs/libxslt
	media-libs/vamp-plugin-sdk
	=sci-libs/fftw-3*
	freesound? ( net-misc/curl )
	lv2? ( >=media-libs/slv2-0.6.1 )
	liblo? ( media-libs/liblo )
	tranzport? ( dev-libs/libusb )
	wiimote? ( app-misc/cwiid )
	sys-libs? ( >=dev-libs/libsigc++-2.0
		>=dev-cpp/glibmm-2.4
		>=dev-cpp/cairomm-1.0
		>=dev-cpp/gtkmm-2.8
		>=dev-libs/atk-1.6
		>=x11-libs/pango-1.4
		>=dev-cpp/libgnomecanvasmm-2.12.0
		>=media-libs/libsndfile-1.0.16
		>=media-libs/libsoundtouch-1.0 )"
		# currently internal rubberband is used
		# that needs fftw3 and vamp-sdk, but it rocks, so enable by default"

DEPEND="${RDEPEND}
	sys-devel/libtool
	dev-libs/boost
	dev-util/pkgconfig
	dev-util/scons
	nls? ( sys-devel/gettext )"

S=${WORKDIR}/${P%_p*}

pkg_setup(){
	einfo "this ebuild fetches from the svn maintaince"
	einfo "ardour-2.X branch"
	# issue with ACLOCAL_FLAGS if set to a wrong value
	if use sys-libs;then
		ewarn "You are trying to use the system libraries"
		ewarn "instead the ones provided by ardour"
		ewarn "No upstream support for doing so. Use at your own risk!!!"
		ewarn "To use the ardour provided libs remerge with:"
		ewarn "USE=\"-sys-libs\" emerge =${P}"

		epause 3s
	fi

	if use amd64 && use vst; then
		eerror "${P} currently does not compile with VST support on amd64!"
		eerror "Please unset VST useflag."
		die
	fi
}

src_prepare() {
	ewarn "You need to manually download the source from http://ardour.org to"
	ewarn "use this ebuild. Place it in your distfiles directory."
	use sys-libs && epatch "${FILESDIR}/${PN}-2.0.3-sndfile-external.patch"
#	Doesn't apply to 2.8 anymore. Do we need a new patch ?
# 	how can we extract the -march flag from our system CFLAGS and add it to the
# 	scons ARCH variable ?
#	epatch "${FILESDIR}/${PN}-2.4-cflags.patch"
}

src_compile() {
	# Required for scons to "see" intermediate install location
	mkdir -p "${D}"

	cd "${S}"
	escons DESTDIR="${D}" PREFIX=/usr \
		$(use_scons aubio AUBIO) $(use_scons austate AUSTATE) $(use_scons dmalloc DMALLOC) \
		$(use_scons fft_analysis FFT_ANALYSIS) $(use_scons freesound FREESOUND) \
		$(use_scons fpu_optimization FPU_OPTIMIZATION) $(use_scons oldfonts OLDFONTS) \
		$(use_scons liblo LIBLIO) $(use_scons surfaces SURFACES) $(use_scons wiimote WIIMOTE) \
		$(use_scons tranzport TRANZPORT) $(use_scons debug DEBUG) $(use_scons nls NLS) \
		$(use_scons vst VST) $(use_scons lv2 LV2) $(use_scons sys-libs SYS-LIBS) || die "compilation failed"
}

src_install() {
	scons install || die "make install failed"
	if use vst;then
		mv "${D}"/usr/bin/ardourvst "${D}"/usr/bin/ardour2
	fi

	dodoc DOCUMENTATION/*

	newicon "${S}/icons/icon/ardour_icon_mac.png" "ardour2.png"
	make_desktop_entry "ardour2" "Ardour2" "ardour2" "AudioVideo;Audio"
}

pkg_postinst() {
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update

	ewarn "---------------- WARNING -------------------"
	ewarn ""
	ewarn "MAKE BACKUPS OF THE SESSION FILES BEFORE TRYING THIS VERSION."
	ewarn ""
	ewarn "The simplest way to address this is to make a copy of the session file itself"
	ewarn "(e.g mysession/mysession.ardour) and make that file unreadable using chmod(1)."
	ewarn ""
}
