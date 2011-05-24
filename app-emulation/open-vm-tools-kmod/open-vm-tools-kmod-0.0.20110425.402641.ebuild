# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/open-vm-tools-kmod/open-vm-tools-kmod-0.0.20110328.387002.ebuild,v 1.1 2011/04/19 15:28:32 vadimk Exp $

EAPI="2"

inherit linux-mod versionator

MY_DATE="$(get_version_component_range 3)"
MY_BUILD="$(get_version_component_range 4)"
MY_PN="${PN/-kmod}"
MY_PV="${MY_DATE:0:4}.${MY_DATE:4:2}.${MY_DATE:6:2}-${MY_BUILD}"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="Opensourced tools for VMware guests"
HOMEPAGE="http://open-vm-tools.sourceforge.net/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}
	virtual/linux-sources
	"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	linux-mod_pkg_setup

	VMWARE_MOD_DIR="modules/linux"
	VMWARE_MODULE_LIST="vmblock vmci vmhgfs vmsync vmxnet vsock"

	MODULE_NAMES=""
	BUILD_TARGETS="auto-build HEADER_DIR=${KERNEL_DIR}/include BUILD_DIR=${KV_OUT_DIR} OVT_SOURCE_DIR=${S}"

	for mod in ${VMWARE_MODULE_LIST};
	do
		if [ "${mod}" == "vmxnet" ];
		then
			MODTARGET="net"
		else
			MODTARGET="openvmtools"
		fi
		MODULE_NAMES="${MODULE_NAMES} ${mod}(${MODTARGET}:${S}/${VMWARE_MOD_DIR}/${mod})"
	done
}

src_prepare() {
	sed -i.bak -e '/\smake\s/s/make/$(MAKE)/g' modules/linux/{vmblock,vmci,vmhgfs,vmsync,vmxnet,vsock}/Makefile\
		|| die "Sed failed."
}

src_configure() {
	:				# do nothing at all
}

src_install() {
	linux-mod_src_install

	local udevrules="${T}/60-vmware.rules"
	cat > "${udevrules}" <<-EOF
		KERNEL=="vsock", GROUP="vmware", MODE=660
	EOF
	insinto /etc/udev/rules.d/
	doins "${udevrules}"
}

pkg_postinst() {
	linux-mod_pkg_postinst
	elog "vmxnet3 for Linux is now upstream (as of Linux 2.6.32)"
	elog "pvscsi for Linux is now upstream (vmw_pvscsi) (as of Linux 2.6.33)"
	elog "vmmemctl for Linux is now upstream (vmw_balloon) (as of Linux 2.6.34)"
}
