# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils fdo-mime gnome2-utils rpm multilib versionator

IUSE="gnome java kde linguas_en"

BUILDID="5"
UREVER="1.7.0"
MY_PV="${PV/_/}" # download file name
MY_PV1="${PV/_/-}" # download uri
MY_PV3="${PV/_*/}-${BUILDID}" # for rpm file names
MY_PVM1=$(get_major_version)
MY_PVM2=$(get_version_component_range 1-2)
BASIS="libobasis${MY_PVM2}"

if [ "${ARCH}" = "amd64" ] ; then
	LOARCH="x86_64"
	UP="LibO_${MY_PV}_Linux_x86-64_install-rpm_en-US/RPMS"
	LANGP="LibO_${MY_PV}_Linux_x86-64_langpack-rpm_"
else
	LOARCH="i586"
	UP="LibO_${MY_PV}_Linux_x86_install-rpm_en-US/RPMS"
	LANGP="LibO_${MY_PV}_Linux_x86_langpack-rpm_"
fi

FILEPATH="http://download.documentfoundation.org/libreoffice/testing/${MY_PV1}/rpm"

S="${WORKDIR}"
DESCRIPTION="LibreOffice productivity suite."

SRC_URI="amd64? ( ${FILEPATH}/x86_64/LibO_${MY_PV}_Linux_x86-64_install-rpm_en-US.tar.gz )
	x86? ( ${FILEPATH}/x86/LibO_${MY_PV}_Linux_x86_install-rpm_en-US.tar.gz )"

# echo $(wget -qO-
# http://download.documentfoundation.org/libreoffice/testing/3.3.0-rc1/rpm/x86/
# | grep langpack | sed 's/.*langpack-rpm_\(.\+\).tar.gz.*/\1/' | sort -u | sed
# 's/-/_/' )
LANGS="af ar as ast be_BY bg bn bo br brx bs ca ca_XV cs cy da de dgo dz el
en_GB en_ZA eo es et eu fa fi fr ga gd gl gu he hi hr hu id is it ja ka kk km kn
ko kok ks ku ky lo lt lv mai mk ml mn mni mr ms my nb ne nl nn nr ns oc om or
pa_IN pap pl ps pt pt_BR ro ru rw sa_IN sat sd sh si sk sl sq sr ss st sv sw_TZ
ta te tg th ti tn tr ts ug uk ur uz ve vi xh zh_CN zh_TW zu"

for X in ${LANGS} ; do
	SRC_URI="${SRC_URI} linguas_${X}? (
		x86? ( "${FILEPATH}"/x86/LibO_${MY_PV}_Linux_x86_langpack-rpm_${X/_/-}.tar.gz )
		amd64? ( "${FILEPATH}"/x86_64/LibO_${MY_PV}_Linux_x86-64_langpack-rpm_${X/_/-}.tar.gz ) )"
	IUSE="${IUSE} linguas_${X}"
done

HOMEPAGE="http://www.libreoffice.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="!app-office/openoffice
	!app-office/openoffice-bin
	!app-office/openoffice-infra
	!app-office/openoffice-infra-bin
	x11-libs/libXaw
	sys-libs/glibc
	>=dev-lang/perl-5.0
	app-arch/zip
	app-arch/unzip
	x11-libs/libXinerama
	>=media-libs/freetype-2.1.10-r2
	linguas_ja? ( >=media-fonts/kochi-substitute-20030809-r3 )
	linguas_zh_CN? ( >=media-fonts/arphicfonts-0.1-r2 )
	linguas_zh_TW? ( >=media-fonts/arphicfonts-0.1-r2 )"

DEPEND="${RDEPEND}
	sys-apps/findutils"

PDEPEND="java? ( >=virtual/jre-1.5 )"

PROVIDE="virtual/ooo"
RESTRICT="strip binchecks"

QA_EXECSTACK="usr/$(get_libdir)/libreoffice/basis${MY_PVM2}/program/*
	usr/$(get_libdir)/libreoffice/ure/lib/*"
QA_TEXTRELS="usr/$(get_libdir)/libreoffice/ure/lib/*"

RESTRICT="mirror strip"

src_unpack() {

	unpack ${A}

	for i in base binfilter calc core01 core02 core03 core04 core05 core06 \
		core07 draw graphicfilter images impress math ogltrans ooofonts \
		ooolinguistic pyuno testtool writer xsltfilter ; do
		rpm_unpack "./${UP}/${BASIS}-${i}-${MY_PV3}.${LOARCH}.rpm"
	done

	for j in base calc draw impress math writer; do
		rpm_unpack "./${UP}/libreoffice${MY_PVM1}-${j}-${MY_PV3}.${LOARCH}.rpm"
	done

	rpm_unpack "./${UP}/libreoffice${MY_PVM1}-${MY_PV3}.${LOARCH}.rpm"
	rpm_unpack "./${UP}/libreoffice${MY_PVM1}-ure-${UREVER}-${BUILDID}.${LOARCH}.rpm"

	rpm_unpack "./${UP}/desktop-integration/libreoffice${MY_PVM2}-freedesktop-menus-${MY_PVM2}-${BUILDID}.noarch.rpm"

	use gnome && rpm_unpack "./${UP}/${BASIS}-gnome-integration-${MY_PV3}.${LOARCH}.rpm"
	use kde && rpm_unpack "./${UP}/${BASIS}-kde-integration-${MY_PV3}.${LOARCH}.rpm"
	use java && rpm_unpack "./${UP}/${BASIS}-javafilter-${MY_PV3}.${LOARCH}.rpm"

	# Extensions
	for j in mediawiki-publisher nlpsolver pdf-import presentation-minimizer presenter-screen report-builder; do
		rpm_unpack "./${UP}/${BASIS}-extension-${j}-${MY_PV3}.${LOARCH}.rpm"
	done

	strip-linguas ${LANGS}

	if [[ -z "${LINGUAS}" ]]; then
		export LINGUAS="en"
	fi

	for k in ${LINGUAS}; do
		i="${k/_/-}"
		if [[ ${i} = "en" ]] ; then
			i="en-US"
			LANGDIR="${UP}"
		else
			LANGDIR="${LANGP}${i}/RPMS/"
		fi
		rpm_unpack "./${LANGDIR}/${BASIS}-${i}-${MY_PV3}.${LOARCH}.rpm"
		rpm_unpack "./${LANGDIR}/libreoffice${MY_PVM1}-${i}-${MY_PV3}.${LOARCH}.rpm"
		rpm_unpack "./${LANGDIR}/libreoffice${MY_PVM1}-dict-${i%-*}"*"-${MY_PV3}.${LOARCH}.rpm"
		for j in base binfilter calc math res writer; do
			rpm_unpack "./${LANGDIR}/${BASIS}-${i}-${j}-${MY_PV3}.${LOARCH}.rpm"
		done
	done
}

src_install () {

	INSTDIR="/usr/$(get_libdir)/libreoffice"

	einfo "Installing OpenOffice.org into build root..."
	dodir ${INSTDIR}
	mv "${WORKDIR}"/opt/libreoffice/* "${D}${INSTDIR}" || die

	#Menu entries, icons and mime-types
	cd "${D}${INSTDIR}/share/xdg/"

	for desk in base calc draw impress javafilter math printeradmin qstart startcenter writer; do
		if [ "${desk}" = "javafilter" ] ; then
			use java || { rm javafilter.desktop; continue; }
		fi
		mv ${desk}.desktop libreoffice-${desk}.desktop
		sed -i -e s/Exec=libreoffice/Exec=loffice/g libreoffice-${desk}.desktop || die
		domenu libreoffice-${desk}.desktop
	done
	insinto /usr/share
	doins -r "${WORKDIR}"/usr/share/icons
	doins -r "${WORKDIR}"/usr/share/mime

	# Make sure the permissions are right
	fowners -R root:0 /

	# Install wrapper script
	newbin "${FILESDIR}/wrapper.in" loffice
	sed -i -e s/LIBDIR/$(get_libdir)/g "${D}/usr/bin/loffice" || die

	# Component symlinks
	for app in base calc draw impress math writer; do
		dosym ${INSTDIR}/program/s${app} /usr/bin/lo${app}
	done

	dosym ${INSTDIR}/program/spadmin /usr/bin/loffice-printeradmin
	dosym ${INSTDIR}/program/soffice /usr/bin/soffice

	rm -f "${D}${INSTDIR}/basis-link" || die
	dosym ${INSTDIR}/basis${MY_PVM2} ${INSTDIR}/basis-link

	# Change user install dir
	sed -i -e "s/.libreoffice\/${MY_PVM1}/.lo${MY_PVM1}/g" "${D}${INSTDIR}/program/bootstraprc" || die

	# Non-java weirdness see bug #99366
	use !java && rm -f "${D}${INSTDIR}/ure/bin/javaldx"

	# prevent revdep-rebuild from attempting to rebuild all the time
	insinto /etc/revdep-rebuild && doins "${FILESDIR}/50-libreoffice-bin"

}

pkg_preinst() {
	use gnome && gnome2_icon_savelist
}

pkg_postinst() {

	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	use gnome && gnome2_icon_cache_update

	[[ -x /sbin/chpax ]] && [[ -e /usr/$(get_libdir)/libreoffice/program/soffice.bin ]] && chpax -zm /usr/$(get_libdir)/libreoffice/program/soffice.bin

	elog " libreoffice-bin does not provide integration with system spell "
	elog " dictionaries. Please install them manually through the Extensions "
	elog " Manager (Tools > Extensions Manager) or use the source based "
	elog " package instead. "
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	use gnome && gnome2_icon_cache_update
}
