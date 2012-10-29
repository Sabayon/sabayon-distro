# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils versionator

DESCRIPTION="AMD Catalyst Control Center Linux Edition"
HOMEPAGE="http://www.amd.com"
MY_V=( $(get_version_components) )
#RUN="${WORKDIR}/amd-driver-installer-9.00-x86.x86_64.run"
SRC_URI="http://www2.ati.com/drivers/linux/amd-driver-installer-catalyst-${PV}-x86.x86_64.zip"
FOLDER_PREFIX="common/"
IUSE=""

LICENSE="QPL-1.0 as-is"
KEYWORDS="~amd64 ~x86"
SLOT="1"

RDEPEND="~x11-drivers/ati-drivers-${PV}[-qt4(-)]
	~x11-drivers/ati-userspace-${PV}
	x11-libs/qt-core
	x11-libs/qt-gui"

DEPEND=""
S="${WORKDIR}"

QA_EXECSTACK="opt/bin/amdcccle"

src_unpack() {
	if [[ ${A} =~ .*\.tar\.gz ]]; then
		unpack ${A}
	else
		#please note, RUN may be insanely assigned at top near SRC_URI
		if [[ ${A} =~ .*\.zip ]]; then
			unpack ${A}
			[[ -z "$RUN" ]] && RUN="${S}/${A/%.zip/.run}"
		else
			RUN="${DISTDIR}/${A}"
		fi
		sh ${RUN} --extract "${S}" 2>&1 > /dev/null || die
	fi
}

src_compile() {
	echo
}

src_install() {
	insinto /usr/share
	doins -r ${FOLDER_PREFIX}usr/share/ati
	insinto /usr/share/pixmaps
	doins ${FOLDER_PREFIX}usr/share/icons/ccc_large.xpm
	make_desktop_entry amdcccle 'ATI Catalyst Control Center' \
		ccc_large System

	use x86 && ARCH_BASE="x86"
	use amd64 && ARCH_BASE="x86_64"
        into /opt
        dobin arch/${ARCH_BASE}/usr/X11R6/bin/amdcccle
	dosbin arch/${ARCH_BASE}/usr/sbin/amdnotifyui
}
