# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils versionator

DESCRIPTION="AMD Catalyst Control Center Linux Edition"
HOMEPAGE="http://www.amd.com"
MY_V=( $(get_version_components) )
SLOT="1"
[[ "${MY_V[2]}" =~  beta.* ]] && BETADIR="beta/" || BETADIR="linux/"
if [[ legacy != ${SLOT} ]]; then
	DRIVERS_URI="http://www2.ati.com/drivers/${BETADIR}amd-driver-installer-catalyst-13-6-beta-x86.x86_64.zip"
else
	DRIVERS_URI="http://www2.ati.com/drivers/legacy/amd-driver-installer-catalyst-$(get_version_component_range 1-2)-$(get_version_component_range 3)-legacy-linux-x86.x86_64.zip"
fi
XVBA_SDK_URI="http://developer.amd.com/wordpress/media/2012/10/xvba-sdk-0.74-404001.tar.gz"
SRC_URI="${DRIVERS_URI} ${XVBA_SDK_URI}"
FOLDER_PREFIX="common/"
IUSE=""

LICENSE="QPL-1.0 as-is"
KEYWORDS="~amd64 ~x86"

RDEPEND="~x11-drivers/ati-drivers-${PV}[-qt4(-)]
	~x11-drivers/ati-userspace-${PV}
	dev-qt/qtcore
	dev-qt/qtgui"

DEPEND=""
S="${WORKDIR}"

QA_EXECSTACK="opt/bin/amdcccle"

src_unpack() {
	local DRIVERS_DISTFILE XVBA_SDK_DISTFILE
	DRIVERS_DISTFILE=${DRIVERS_URI##*/}
	XVBA_SDK_DISTFILE=${XVBA_SDK_URI##*/}

	if [[ ${DRIVERS_DISTFILE} =~ .*\.tar\.gz ]]; then
		unpack ${DRIVERS_DISTFILE}
	else
		#please note, RUN may be insanely assigned at top near SRC_URI
		if [[ ${DRIVERS_DISTFILE} =~ .*\.zip ]]; then
			unpack ${DRIVERS_DISTFILE}
			[[ -z "$RUN" ]] && RUN="${S}/${DRIVERS_DISTFILE/%.zip/.run}"
		else
			RUN="${DISTDIR}/${DRIVERS_DISTFILE}"
		fi
		sh ${RUN} --extract "${S}" 2>&1 > /dev/null || die
	fi

	mkdir xvba_sdk
	cd xvba_sdk
	unpack ${XVBA_SDK_DISTFILE}
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
