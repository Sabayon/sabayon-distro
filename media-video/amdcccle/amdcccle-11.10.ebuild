# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils versionator

DESCRIPTION="AMD Catalyst Control Center Linux Edition"
HOMEPAGE="http://ati.amd.com"
# 8.ble will be used for beta releases.
if [[ $(get_major_version) -gt 8 ]]; then
	ATI_URL="http://www2.ati.com/drivers/linux/"
	SRC_URI="${ATI_URL}/ati-driver-installer-${PV/./-}-x86.x86_64.run"
	FOLDER_PREFIX="common/"
else
	SRC_URI="https://launchpad.net/ubuntu/natty/+source/fglrx-installer/2:${PV}-0ubuntu1/+files/fglrx-installer_${PV}.orig.tar.gz"
	FOLDER_PREFIX=""
fi
IUSE=""

LICENSE="QPL-1.0 as-is"
KEYWORDS="~amd64 ~x86"
SLOT="1"

RDEPEND="x11-drivers/ati-drivers[-qt4(-)]
	x11-libs/qt-core
	x11-libs/qt-gui"

DEPEND=""
S="${WORKDIR}"

QA_EXECSTACK="opt/bin/amdcccle"

src_unpack() {
	if [[ $(get_major_version) -gt 8 ]]; then
		# Switching to a standard way to extract the files since otherwise no signature file
		# would be created
		local src="${DISTDIR}/${A}"
		sh "${src}" --extract "${S}"
	else
		unpack ${A}
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
        dobin arch/"${ARCH_BASE}"/usr/X11R6/bin/amdcccle
}
