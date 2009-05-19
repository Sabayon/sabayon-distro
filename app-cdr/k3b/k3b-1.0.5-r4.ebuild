# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/k3b/k3b-1.0.5-r3.ebuild,v 1.7 2009/03/10 20:02:18 beandog Exp $

EAPI="2"
inherit kde eutils multilib

MY_P=${P/_/}
S="${WORKDIR}/${MY_P}"

DESCRIPTION="K3b, KDE CD Writing Software"
HOMEPAGE="http://www.k3b.org/"
SRC_URI="mirror://sourceforge/k3b/${MY_P}.tar.bz2"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="amd64 ppc ppc64 x86 ~x86-fbsd"
IUSE="alsa css dvd dvdr encode ffmpeg flac hal mp3 musepack musicbrainz
	sndfile vcd vorbis emovix"

DEPEND="!<app-cdr/k3b-1.0.5-r4
	alsa? ( media-libs/alsa-lib )
	flac? ( media-libs/flac[cxx] )
	dvd? ( media-libs/libdvdread )
	mp3? ( media-libs/libmad )
	musepack? ( media-libs/libmpcdec )
	media-libs/libsamplerate
	sndfile? ( media-libs/libsndfile )
	vorbis? ( media-libs/libvorbis )
	musicbrainz? ( =media-libs/musicbrainz-2* )
	media-libs/taglib
	>=media-sound/cdparanoia-3.9.8
	encode? ( media-sound/lame )
	ffmpeg? ( >=media-video/ffmpeg-0.4.9_p20080326 )
	hal? ( sys-apps/hal )"

RDEPEND="${DEPEND}
	virtual/cdrtools
	>=app-cdr/cdrdao-1.1.7-r3
	media-sound/normalize
	dvdr? ( >=app-cdr/dvd+rw-tools-7.0 )
	css? ( media-libs/libdvdcss )
	encode? ( media-sound/sox
				media-video/transcode[dvd] )
	vcd? ( media-video/vcdimager )
	emovix? ( media-video/emovix )"

DEPEND="${DEPEND}
	dev-util/pkgconfig"

need-kde 3.5

PATCHES=(	"${FILESDIR}/${P}-desktop-entry.diff"
		"${FILESDIR}/${P}-ffmpeg-0.4.9_p20080326-API.patch"
		"${FILESDIR}/${P}-ffmpeg-0.4.9_p20081014-API.patch"
		"${FILESDIR}/${P}-transcode-1.1.patch"
	)

I18N="${PN}-i18n-${PV}"

# Supported languages and translated documentation
LANGS="af ar bg br bs ca cs cy da de el en_GB es et eu fa fi fr ga gl he hi hu is it ja ka lt mk ms nb nds nl nn pa pl pt pt_BR ru rw se sk sr sr@Latn sv ta tr uk uz zh_CN zh_TW"
for X in ${LANGS}; do
	SRC_URI="${SRC_URI} linguas_${X}? ( mirror://sourceforge/k3b/${I18N}.tar.bz2 )"
	IUSE="${IUSE} linguas_${X}"
done

src_unpack() {
	kde_src_unpack

	if [ -d "${WORKDIR}/${I18N}" ]; then
		cd "${WORKDIR}/${I18N}"
		for X in ${LANGS}; do
			use linguas_${X} || rm -rf "${X}"
		done
		rm -f configure
	fi
	rm -f "${S}/configure"
}

src_configure() {

	# XXX
	# kde.eclass adds extra configure arguments which are
	# not recognized by k3b configure. So the manual route
	# has been choosen.

	# econf automatically sets --prefix=/usr, which is going
	# to be overridden by "kde_src_configure configure" code

	local myconf="	--with-external-libsamplerate
			--without-resmgr
			--without-cdrecord-suid-root
			--without-k3bsetup
			--with-qt-dir=${QTDIR}
			--enable-mt
			--with-qt-libraries=${QTDIR}/$(get_libdir)
			--disable-dependency-tracking
			--without-arts
			$(use_enable debug)
			$(use_with hal)
			$(use_with encode lame)
			$(use_with ffmpeg)
			$(use_with flac)
			$(use_with vorbis oggvorbis)
			$(use_with sndfile)
			$(use_with mp3 libmad)
			$(use_with musepack)
			$(use_with musicbrainz)
			$(use_with dvd libdvdread)
			$(use_with alsa)"

	# Build process of K3b
	kde_src_configure configure

	# Build process of K3b-i18n
	if [ -d "${WORKDIR}/${I18N}" ]; then

		local myconf="--with-qt-dir=${QTDIR}
			--with-qt-libraries=${QTDIR}/$(get_libdir)
			--disable-dependency-tracking
			--without-arts
			$(use_enable debug)"

		KDE_S="${WORKDIR}/${I18N}" \
		kde_src_configure configure
	fi
}

src_install() {
	kde_src_install
	dodoc FAQ KNOWNBUGS PERMISSIONS || die "dodoc failed"

	if [ -d "${WORKDIR}/${I18N}" ]; then
		KDE_S="${WORKDIR}/${I18N}" \
		kde_src_install
	fi
}

pkg_postinst() {
	echo
	elog "We don't install k3bsetup anymore because Gentoo doesn't need it."
	elog "If you get warnings on start-up, uncheck the \"Check system"
	elog "configuration\" option in the \"Misc\" settings window."
	echo

	local group=cdrom
	use kernel_linux || group=operator
	elog "Make sure you have proper read/write permissions on the cdrom device(s)."
	elog "Usually, it is sufficient to be in the ${group} group."
	echo
}
