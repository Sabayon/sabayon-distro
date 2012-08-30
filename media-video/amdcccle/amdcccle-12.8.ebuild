# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils versionator

DESCRIPTION="AMD Catalyst Control Center Linux Edition"
HOMEPAGE="http://www.amd.com"
MY_V=( $(get_version_components) )
if [[ ${MY_V[2]} != beta ]]; then
	ATI_URL="http://www2.ati.com/drivers/linux/"
	SRC_URI="${ATI_URL}/amd-driver-installer-${PV/./-}-x86.x86_64.zip"
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
	unpack ${A}
	RUN="${S}/"*.run
	sh ${RUN} --extract "${S}" # 2>&1 > /dev/null || die
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
