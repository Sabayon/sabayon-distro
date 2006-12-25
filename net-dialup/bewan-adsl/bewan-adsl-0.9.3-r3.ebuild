# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dialup/bewan-adsl/bewan-adsl-0.9.3-r2.ebuild,v 1.4 2006/12/20 19:33:17 mrness Exp $

inherit eutils linux-mod

DESCRIPTION="Bewan ADSL PCI&USB st driver"
SRC_URI="http://www.bewan.com/bewan/drivers/A1012-A1006-A904-A888-A983-${PV}.tgz
	mirror://gentoo/${P}-patches-20061220.tar.gz"
HOMEPAGE="http://www.bewan.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86"
IUSE="usb pcitimer slowpcibridge kt400"

DEPEND="virtual/linux-sources"
RDEPEND=""

S="${WORKDIR}/unicorn"

PCI_S="${S}/unicorn_pci"
USB_S="${S}/unicorn_usb"
BUILD_PARAMS="KERNEL_SOURCES=${KV_DIR} KVERS=${KV_FULL}"
BUILD_TARGETS="modules"
CONFIG_CHECK="ATM"
ATM_ERROR="This driver requires you to build your kernel with support for Asynchronous Transfer Mode (ATM)"

pkg_setup() {
	MODULE_NAMES="unicorn_pci_atm(extra:${PCI_S}) unicorn_pci_eth(extra:${PCI_S})"
	use usb && MODULE_NAMES="${MODULE_NAMES} unicorn_usb_atm(extra:${USB_S}) unicorn_usb_eth(extra:${USB_S})"

	linux-mod_pkg_setup
}

src_unpack() {
	unpack ${A}

	cd "${S}"
	# Fix "unresolved symbol set_cpus_allowed" on SMP kernels (#122103)
	# Upstream consider actual version to be thread safe
	epatch "${WORKDIR}/patches/${P}-smp.patch"

	local f
	for f in msw/*.cpp amu/*.cpp ; do
		mv ${f} ${f%pp}
	done
	epatch "${WORKDIR}/patches/${P}-kernel-changes.patch"
	epatch "${WORKDIR}/patches/${P}-no-strip.patch"

	# 2.6.19 support
	epatch ${FILESDIR}/${PN}-2.6.19.patch

	# Declare desired COPTIONS in the Makefile for the PCI module
	use kt400 && sed -i 's/^\(COPTIONS *= *\)/\1 -DKT400/g' "${PCI_S}/Makefile"
	use pcitimer && sed -i 's/^\(COPTIONS *= *\)/\1 -DUSE_HW_TIMER/g' "${PCI_S}/Makefile"
	use slowpcibridge && sed -i 's/^\(COPTIONS *= *\)/\1 -DPCI_BRIDGE_WORKAROUND/g' "${PCI_S}/Makefile"

	# Fix up broken Makefiles
	convert_to_m "${PCI_S}/Makefile"
	use usb && convert_to_m "${USB_S}/Makefile"
}

src_compile() {
	einfo "Build common library"
	cd "${S}/libm"
	emake CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" || die

	einfo "Building tools"
	cd "${S}/tools"
	emake CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"
	cd "${S}/unicorntest"
	emake CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"

	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install

	cd "${S}"
	#Install tools
	dodir /usr/bin
	cd "${S}/tools" && einstall DESTDIR="${D}" prefix=/usr || \
		die "Cannot install tools"
	cd "${S}/unicorntest" && einstall DESTDIR="${D}" prefix=/usr || \
		die "Cannot install unicorntest"
	doman "${S}/Documentation/unicorntest.8"

	#Install documantation	
	cd "${S}"
	dodoc README
	docinto RFCs
	dodoc RFCs/*
	docinto scripts
	dodoc scripts/*
}

pkg_postinst() {
	einfo "To load the driver do 'modprobe unicorn_atm' and 'modprobe unicorn_pci' "
	einfo "and then do what you want with it (configure your pppd)"
	einfo "OR"
	einfo "it's time to look at the README file, the scripts directory gives you"
	einfo "two comprehensive ways to load the driver, configure pppd and launch it."

	linux-mod_pkg_postinst
}
