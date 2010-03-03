# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/alsa-lib/alsa-lib-1.0.22-r1.ebuild,v 1.1 2010/02/12 16:10:20 chainsaw Exp $

inherit eutils libtool

MY_P="${P/_rc/rc}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Advanced Linux Sound Architecture Library"
HOMEPAGE="http://www.alsa-project.org/"
SRC_URI="mirror://alsaproject/lib/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="doc debug alisp python"

RDEPEND="python? ( dev-lang/python )"
DEPEND="${RDEPEND}
	>=media-sound/alsa-headers-${PV}
	doc? ( >=app-doc/doxygen-1.2.6 )"

IUSE_PCM_PLUGIN="copy linear route mulaw alaw adpcm rate plug multi shm file
null empty share meter mmap_emul hooks lfloat ladspa dmix dshare dsnoop asym iec958
softvol extplug ioplug"

for plugin in ${IUSE_PCM_PLUGIN}; do
	IUSE="${IUSE} alsa_pcm_plugins_${plugin}"
done

pkg_setup() {
	if [ -z "${ALSA_PCM_PLUGINS}" ] ; then
		ewarn "You haven't selected _any_ PCM plugins. Either you set it to something like the default"
		ewarn "(which is being set in the profile UNLESS you unset them) or alsa based applications"
		ewarn "are going to *misbehave* !"
		epause 5
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Say thanks to Ubuntu ;-)
	# Properly setup configuration files, even if they don't exist
	# in this way, if other pkgs (pulseaudio for instance) are
	# installed, alsa will use them out-of-the-box
	epatch "${FILESDIR}/pulseaudio_configuration.patch"
	# net-wireless/bluez settings, this makes bluetooth headset working
	epatch "${FILESDIR}/bluetooth_configuration.patch"
	# Now the rest of 1.0.22 patchset taken from Ubuntu
	epatch "${FILESDIR}"/${PV}-ubuntu/*.patch


	epatch "${FILESDIR}/${P}-fd-leak.patch"
	elibtoolize
	epunt_cxx
}

src_compile() {
	local myconf
	use elibc_uclibc && myconf="--without-versioned"

	econf \
		--enable-static \
		--enable-shared \
		--disable-resmgr \
		--enable-rawmidi \
		--enable-seq \
		--enable-aload \
		$(use_with debug) \
		$(use_enable alisp) \
		$(use_enable python) \
		--with-pcm-plugins="${ALSA_PCM_PLUGINS}" \
		--disable-dependency-tracking \
		${myconf} \
		|| die "configure failed"

	emake || die "make failed"

	if use doc; then
		emake doc || die "failed to generate docs"
		fgrep -Zrl "${S}" "${S}/doc/doxygen/html" | \
			xargs -0 sed -i -e "s:${S}::"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc ChangeLog TODO || die
	use doc && dohtml -r doc/doxygen/html/*
}

pkg_postinst() {
	elog "Please try in-kernel ALSA drivers instead of the alsa-drivers ebuild."
	elog "If alsa-drivers works for you where a *recent* kernel does not, we want "
	elog "to know about this. Our e-mail address is alsa-bugs@gentoo.org"
	elog "However, if you notice no sound output or instability, please try to "
	elog "upgrade your kernel to a newer version first."
}
