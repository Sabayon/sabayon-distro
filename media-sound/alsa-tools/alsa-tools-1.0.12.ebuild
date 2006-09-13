# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/alsa-tools/alsa-tools-1.0.12.ebuild,v 1.2 2006/08/31 19:03:40 flameeyes Exp $

inherit eutils flag-o-matic autotools

MY_P="${P/_rc/rc}"

DESCRIPTION="Advanced Linux Sound Architecture tools"
HOMEPAGE="http://www.alsa-project.org"
SRC_URI="mirror://alsaproject/tools/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0.9"
KEYWORDS="~amd64 ~mips ~ppc ~ppc64 ~sparc ~x86"
IUSE="fltk gtk"

RDEPEND=">=media-libs/alsa-lib-1.0.0
	virtual/alsa
	fltk? ( =x11-libs/fltk-1.1* )
	gtk? ( =x11-libs/gtk+-2* )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	# This is a list of the tools in the package.
	# Some of the tools don't make proper use of CFLAGS, even though
	# all of them seem to use autoconf.	 This needs to be fixed.
	#
	# By default, all the supported tools will be compiled.
	# If you want to only compile for specific tool(s), set ALSA_TOOLS
	# environment to a space-separated list of tools that you want to build.
	# For example:
	#
	#	env ALSA_TOOLS='as10k1 ac3dec' emerge alsa-tools
	#
	if [ -z "${ALSA_TOOLS}" ]; then
		ALSA_TOOLS="ac3dec as10k1 hdsploader mixartloader seq/sbiload \
					sscape_ctl us428control usx2yloader vxloader"

		if use fltk; then
			ALSA_TOOLS="${ALSA_TOOLS} hdspconf hdspmixer"
		fi

		if use gtk; then
			ALSA_TOOLS="${ALSA_TOOLS} echomixer envy24control rmedigicontrol"
		fi

		# sb16_csp won't build on ppc64 _AND_ ppc (and is not needed)
		if	use !ppc64 && use !ppc; then
			ALSA_TOOLS="${ALSA_TOOLS} sb16_csp"
		fi

	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-1.0.11-asneeded.patch"

	for dir in echomixer envy24control rmedigicontrol; do
		pushd ${dir} &> /dev/null
		eautomake
		popd &> /dev/null
	done

	elibtoolize
}

src_compile() {
	if use fltk; then
		# hdspmixer requires fltk
		append-ldflags "-L/usr/$(get_libdir)/fltk-1.1"
		append-flags "-I/usr/include/fltk-1.1"
	fi

	# hdspmixer is missing depconf - copy from the hdsploader directory
	cp ${S}/hdsploader/depcomp ${S}/hdspmixer/

	local f
	for f in ${ALSA_TOOLS}
	do
		cd "${S}/${f}"
		econf || die "econf failed"
		make || die "make failed"
	done
}

src_install() {
	local f
	for f in ${ALSA_TOOLS}
	do
		# Install the main stuff
		cd "${S}/${f}"
		emake DESTDIR="${D}" install || die

		# Install the text documentation
		local doc
		for doc in README TODO ChangeLog AUTHORS
		do
			if [ -f "${doc}" ]
			then
			mv "${doc}" "${doc}.`basename ${f}`"
			dodoc "${doc}.`basename ${f}`"
			fi
		done
	done
}
