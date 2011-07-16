# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
WANT_AUTOCONF="2.1"

inherit eutils toolchain-funcs mozconfig-3 autotools flag-o-matic fdo-mime multilib mozextension java-pkg-opt-2

DESCRIPTION="A web authoring system combining web file management and WYSIWYG editing"
HOMEPAGE="http://kompozer.net/"

LANGS="en-US ca de eo es-ES fi fr hsb hu it ja nl pl pt-PT ru zh-CN zh-TW"
# manque sur serveur : cs sl
NOSHORTLANGS="es-ES pt-PT xh-CN zh-TW"

DICTS="ca cs de dsb en-GB en-US eo es-ES fi fr hsb hu it nl pl pt-BR pt-PT ru uk"
NOSHORTDICTS="en-GB en-US es-ES pt-BR pt-PT"

MY_P="${P/_beta3/b3}"
MY_D="myspell-dict"

# Recommended using ${PN}??
SRC_URI="http://downloads.sourceforge.net/kompozer/${MY_P}-src.tar.bz2"
REL_URI="http://kompozer.sourceforge.net/l10n/langpacks/kompozer-0.8b3"
DICT_URI="http://kompozer.sourceforge.net/l10n/myspell"

RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~x86"
IUSE="gnome java ldap"

# linguas
for X in ${LANGS} ; do
	if [ "${X}" != "en" ] && [ "${X}" != "en-US" ]; then
		SRC_URI="${SRC_URI}
			linguas_${X/-/_}? ( ${REL_URI}/${MY_P}.${X}.xpi -> ${MY_P}-${X}.xpi )"
	fi
	IUSE="${IUSE} linguas_${X/-/_}"
	# english is handled internally
	if [ "${#X}" == 5 ] && ! has ${X} ${NOSHORTLANGS}; then
		if [ "${X}" != "en-US" ]; then
			SRC_URI="${SRC_URI}
				linguas_${X%%-*}? ( ${REL_URI}/${MY_P}.${X}.xpi -> ${MY_P}-${X}.xpi )"
		fi
		IUSE="${IUSE} linguas_${X%%-*}"
	fi
done


# myspell dictionaries
for X in ${DICTS} ; do
	SRC_URI="${SRC_URI}
	linguas_${X/-/_}? ( ${DICT_URI}/${MY_D}.${X}.xpi -> ${MY_D}-${X}.xpi )"
	IUSE="${IUSE} linguas_${X/-/_}"
	if [ "${#X}" == 5 ] && ! has ${X} ${NOSHORTDICTS}; then
		SRC_URI="${SRC_URI}
		linguas_${X%%-*}? ( ${DICT_URI}/${MY_D}.${X}.xpi -> ${MY_D}-${X}.xpi )"
		IUSE="${IUSE} linguas_${X%%-*}"
	fi
done


RDEPEND="java? ( virtual/jre )
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12.2
	>=dev-libs/nspr-4.8
	>=app-text/hunspell-1.2
	>=x11-libs/gtk+-2.10.0:2
	>=x11-libs/cairo-1.8.8[X]
	>=x11-libs/pango-1.14.0[X]"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-apps/gawk
	dev-lang/perl
	app-doc/doxygen
	app-arch/unzip
	x11-misc/makedepend
	>=media-libs/freetype-2.1.9-r1
	java? ( >=virtual/jdk-1.4 )"


S=${WORKDIR}/mozilla

linguas() {
	local LANG SLANG
	for LANG in ${LINGUAS}; do
		if has ${LANG} en en_US; then
			has en ${linguas} || linguas="${linguas:+"${linguas} "}en"
			continue
		elif has ${LANG} ${LANGS//-/_}; then
			has ${LANG//_/-} ${linguas} || linguas="${linguas:+"${linguas} "}${LANG//_/-}"
			continue
		elif [[ " ${LANGS} " == *" ${LANG}-"* ]]; then
			for X in ${LANGS}; do
				if [[ "${X}" == "${LANG}-"* ]] && \
					[[ " ${NOSHORTLANGS} " != *" ${X} "* ]]; then
					has ${X} ${linguas} || linguas="${linguas:+"${linguas} "}${X}"
					continue 2
				fi
			done
		fi
		ewarn "Sorry, but ${PN} does not support the ${LANG} LINGUA"
	done
}

dicts() {
	local LANG SLANG
	for LANG in ${LINGUAS}; do
		if has ${LANG} ${DICTS//-/_}; then
			has ${LANG//_/-} ${dicts} || dicts="${dicts:+"${dicts} "}${LANG//_/-}"
			continue
		elif [[ " ${DICTS} " == *" ${LANG}-"* ]]; then
			for X in ${DICTS}; do
				if [[ "${X}" == "${LANG}-"* ]] && \
					[[ " ${NOSHORTDICTS} " != *" ${X} "* ]]; then
					has ${X} ${dicts} || dicts="${dicts:+"${dicts} "}${X}"
					continue 2
				fi
			done
		fi
		ewarn "Sorry, but ${PN} does not support the ${LANG} dictionary"
	done
}

src_unpack() {
	unpack ${A}

	linguas
	for X in ${linguas}; do
		# FIXME: Add support for unpacking xpis to portage
		[[ ${X} != "en" ]] && xpi_unpack "${MY_P}-${X}.xpi"
	done
	if [[ ${linguas} != "" && ${linguas} != "en" ]]; then
		einfo "Selected language packs (first will be default): ${linguas}"
	fi

	dicts
	for X in ${dicts}; do
		# FIXME: Add support for unpacking xpis to portage
		xpi_unpack "${MY_D}-${X}.xpi"
	done
}

pkg_setup() {
	export BUILD_OFFICIAL=1
	export MOZILLA_OFFICIAL=1

	java-pkg-opt-2_pkg_setup

	append-ldflags $(no-as-needed)
}

src_prepare() {
	java-pkg-opt-2_src_prepare
	eautoreconf
}

src_configure() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"
	MEXTENSIONS=""

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init
	mozconfig_config

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"
	MEXTENSIONS="default,spellcheck,webdav"
	if ! use gnome ; then
		MEXTENSIONS="${MEXTENSIONS},-gnomevfs"
		else MEXTENSIONS="${MEXTENSIONS},gnomevfs"
	fi

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --enable-application=composer
	mozconfig_annotate '' --enable-default-toolkit=gtk2
	mozconfig_annotate '' --enable-system-myspell
	mozconfig_annotate '' --enable-jsd
	mozconfig_annotate '' --enable-xterm-updates
	mozconfig_annotate '' --enable-pango
	mozconfig_annotate '' --enable-image-encoder=all
	mozconfig_annotate '' --enable-canvas
	mozconfig_annotate '' --with-system-nspr
	mozconfig_annotate '' --with-system-nss
	mozconfig_annotate '' --enable-oji --enable-mathml
	mozconfig_annotate 'places' --enable-storage --enable-places
	mozconfig_annotate '' --disable-installer
	mozconfig_annotate '' --with-default-mozilla-five-home=${MOZILLA_FIVE_HOME}

	# Enable/Disable based on USE flags
	mozconfig_use_enable java javaxpcom
	mozconfig_use_enable ldap
	mozconfig_use_enable ldap ldap-experimental

	# Finalize and report settings
	mozconfig_final

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	fi

	####################################
	#
	#  Configure and build
	#
	####################################

	# Work around breakage in makeopts with --no-print-directory
	MAKEOPTS="${MAKEOPTS/--no-print-directory/}"

	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" econf
}

src_compile() {
	# Should the build use multiprocessing? Not enabled by default, as it tends to break.
	[ "${WANT_MP}" = "true" ] && jobs=${MAKEOPTS} || jobs="-j1"
	emake ${jobs} || die
}

xpi_dict_install() {
	local emid

	# You must tell xpi_install which xpi to use
	[[ ${#} -ne 1 ]] && die "$FUNCNAME takes exactly one argument, please specify an xpi to unpack"

	x="${1}"
	cd ${x}
	# determine id for extension
	emid=$(sed -n -e '/<\?em:id>\?/!d; s/.*\([\"{].*[}\"]\).*/\1/; s/\"//g; p; q' ${x}/install.rdf) || die "failed to determine extension id"
	insinto "${MOZILLA_FIVE_HOME}"/${emid}
	doins -r "${x}"/* || die "failed to copy extension"
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"
	declare emid

	#Dirty Bugfix by unregistr3d (ignore nsModules.o):
	cd xpfe/components/
	cp Makefile.in Makefile.in_backup
	cat Makefile.in_backup | grep -v build2 > Makefile.in
	cd ../..


	emake DESTDIR="${D}" install || die "emake install failed"

	linguas
	elog "The following language packs will be installed: ${linguas}"
	for X in ${linguas}; do
		[[ ${X} != "en" ]] && xpi_install "${WORKDIR}"/"${MY_P}-${X}"
	done

	dicts
	elog "The following dictionaries will be installed: ${dicts}"
	for X in ${dicts}; do
		xpi_dict_install "${WORKDIR}"/"${MY_D}-${X}"
	done

	# Install icon and .desktop for menu entry
	newicon "${S}"/composer/app/mozicon256.png kompozer.png
	domenu "${FILESDIR}"/kompozer.desktop
}

pkg_postinst() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update

	elog "This package has a very dirty bugfix!!! If you want to fill"
	elog "a Bugreport to the mainstream developers, at least be sure"
	elog "to refer to http://bugs.gentoo.org/show_bug.cgi?id=146761#c39 "
	elog "Thanks"
}
