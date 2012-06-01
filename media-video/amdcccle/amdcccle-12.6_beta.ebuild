# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils versionator

DESCRIPTION="AMD Catalyst Control Center Linux Edition"
HOMEPAGE="http://www.amd.com"
# 8.ble will be used for beta releases.
if [[ $(get_major_version) -gt 8 ]]; then
	ATI_URL="http://www2.ati.com/drivers/hotfix/catalyst_12.6_hotfixes"
	ZIP_NAME="amd-driver-installer-8.98-x86.x86_64.zip"
	SRC_URI="${ATI_URL}/${ZIP_NAME}"
	FOLDER_PREFIX="common/"
else
	SRC_URI="https://launchpad.net/ubuntu/natty/+source/fglrx-installer/2:${PV}-0ubuntu1/+files/fglrx-installer_${PV}.orig.tar.gz"
	FOLDER_PREFIX=""
fi
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
	if [[ $(get_major_version) -gt 8 ]]; then
		unpack ${A}
		# Switching to a standard way to extract the files since otherwise no signature file
		# would be created
		local src="${S}/${ZIP_NAME/.zip/.run}"
		sh "${src}" --extract "${S}"  2&>1 /dev/null
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
        dobin arch/${ARCH_BASE}/usr/X11R6/bin/amdcccle
	dosbin arch/${ARCH_BASE}/usr/sbin/amdnotifyui
}
