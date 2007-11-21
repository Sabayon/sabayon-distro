# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-accessibility/festival/festival-1.96_beta.ebuild,v 1.1 2007/08/28 05:17:33 williamh Exp $

inherit eutils toolchain-funcs

DESCRIPTION="Festival Text to Speech engine"
HOMEPAGE="http://www.cstr.ed.ac.uk/"
SITE="http://www.festvox.org/packed/festival/latest"
MY_P=${PN}-1.96-beta
SRC_URI="${SITE}/${MY_P}.tar.gz
	${SITE}/festlex_CMU.tar.gz
	${SITE}/festlex_OALD.tar.gz
	${SITE}/festlex_POSLEX.tar.gz
	${SITE}/festvox_cmu_us_awb_arctic_hts.tar.gz
	${SITE}/festvox_cmu_us_bdl_arctic_hts.tar.gz
	${SITE}/festvox_cmu_us_jmk_arctic_hts.tar.gz
	${SITE}/festvox_cmu_us_slt_arctic_hts.tar.gz
	${SITE}/festvox_kallpc16k.tar.gz
	${SITE}/festvox_kedlpc16k.tar.gz
	mbrola? (
		${SITE}/festvox_us1.tar.gz
		${SITE}/festvox_us2.tar.gz
		${SITE}/festvox_us3.tar.gz )"
LICENSE="FESTIVAL BSD as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="mbrola"

RDEPEND="mbrola? ( >=app-accessibility/mbrola-3.0.1h-r2 )
	>=app-accessibility/speech-tools-1.2.96_beta"

DEPEND="${RDEPEND}"

S=${WORKDIR}/festival

pkg_setup() {
	enewuser festival -1 -1 -1 audio
}

src_unpack() {
	unpack ${A}

	# tell festival to use the speech-tools we have installed.
	sed -i -e "s:\(EST=\).*:\1/usr/share/speech-tools:" ${S}/config/config.in
	sed -i -e "s:\$(EST)/lib:/usr/$(get_libdir):" ${S}/config/project.mak

	# disable the multisyn modules
	sed -i -e "s:\(ALSO_INCLUDE.*=.*MultiSyn\):# \1:" ${S}/config/config.in

	# fix the reference  to /usr/lib/festival
	sed -i -e "s:\(FTLIBDIR.*=.*\)\$.*:\1/usr/share/festival:" ${S}/config/project.mak

	# Fix path for examples in festival.scm
	sed -i -e "s:\.\./examples/:/usr/share/doc/${PF}/examples/:" ${S}/lib/festival.scm

	# patch init.scm to look for siteinit.scm and sitevars.scm in /etc/festival
	epatch ${FILESDIR}/${P}-init-scm.patch
}

src_compile() {
	econf || die
	emake -j1 PROJECT_LIBDEPS="" REQUIRED_LIBDEPS="" LOCAL_LIBDEPS="" OPTIMISE_CXXFLAGS="${CXXFLAGS}" OPTIMISE_CCFLAGS="${CFLAGS}" CC="$(tc-getCC)" CXX="$(tc-getCXX)" || die
}

src_install() {
	# Install the binaries
	dobin src/main/festival
	dobin lib/etc/*Linux*/audsp
	dolib.a src/lib/libFestival.a

	# Install the main libraries
	insinto /usr/share/festival
	doins -r lib/*

	# Install the examples
	insinto /usr/share/doc/${PF}
	doins -r examples

	# Need to fix saytime, etc. to look for festival in the correct spot
	for ex in ${D}/usr/share/doc/${PF}/examples/*.sh; do
		exnoext=${ex%%.sh}
		chmod a+x ${exnoext}
		dosed "s:${S}/bin/festival:/usr/bin/festival:" ${exnoext##$D}
	done

	# Install the header files
	insinto /usr/include/festival
	doins src/include/*.h

	insinto /etc/festival
	# Sample server.scm configuration for the server
	doins ${FILESDIR}/server.scm
	doins lib/site*

	# Install the init script
	newinitd ${FILESDIR}/festival.rc festival

	# Install the docs
	dodoc ${S}/{ACKNOWLEDGMENTS,NEWS,README}
	doman ${S}/doc/{festival.1,festival_client.1}

	# create the directory where our log file will go.
	diropts -m 0755 -o festival -g audio
	keepdir /var/log/festival

	use mbrola && mbrola_voices
}

pkg_postinst() {
	elog
	elog "    Useful examples include saytime, text2wave. For example, try:"
	elog "        \"/usr/share/doc/${PF}/examples/saytime\""
	elog
	elog "    Or for something more fun:"
	elog '        "echo "Gentoo can speak" | festival --tts"'
	elog
	elog "    To enable the festival server at boot, run"
	elog "       rc-update add festival default"
	elog
	elog "    You must setup the server's port, access list, etc in this file:"
	elog "       /etc/festival/server.scm"
	elog
	elog "This version also allows configuration of site specific"
	elog "initialization in /etc/festival/siteinit.scm and"
	elog "variables in /etc/festival/sitevars.scm."
	elog
}

# Fix mbrola databases: create symbolic links from festival voices
# directories to MBROLA install dirs.
mbrola_voices() {

	# This is in case there is no mbrola voice for a particular language.
	local shopts=$(shopt -p nullglob)
	shopt -s nullglob

	# This assumes all mbrola voices are named after the voices defined
	# in MBROLA, i.e. if MBROLA contains a voice fr1, then the Festival
	# counterpart should be named fr1_mbrola.
	for language in ${S}/lib/voices/*; do
		for mvoice in ${language}/*_mbrola; do
			voice=${mvoice##*/}
			database=${voice%%_mbrola}
			dosym /opt/mbrola/${database} /usr/share/festival/voices/${language##*/}/${voice}/${database}
		done
	done

	# Restore shopts
	${shopts}
}
