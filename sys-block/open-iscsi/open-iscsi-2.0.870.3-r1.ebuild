# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-block/open-iscsi/open-iscsi-2.0.870.3-r1.ebuild,v 1.1 2009/10/27 19:47:34 dertobi123 Exp $

inherit distutils versionator linux-mod eutils flag-o-matic

DESCRIPTION="Open-iSCSI is a high performance, transport independent, multi-platform implementation of RFC3720"
HOMEPAGE="http://www.open-iscsi.org/"
MY_PV="${PN}-$(replace_version_separator 2 "-" $MY_PV)"
SRC_URI="http://www.open-iscsi.org/bits/${MY_PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc ~mips"
IUSE="modules utils debug"
DEPEND="virtual/linux-sources app-doc/doxygen"
RDEPEND="virtual/modutils sys-apps/util-linux"

S="${WORKDIR}/${MY_PV}"

MODULE_NAMES_ARG="kernel/drivers/scsi:${S}/kernel"
MODULE_NAMES="iscsi_tcp(${MODULE_NAMES_ARG}) scsi_transport_iscsi(${MODULE_NAMES_ARG}) libiscsi(${MODULE_NAMES_ARG})"
BUILD_TARGETS="all"
CONFIG_CHECK="CRYPTO_CRC32C"
ERROR_CFG="open-iscsi needs CRC32C support in your kernel."

src_unpack() {
	unpack ${A}
	export EPATCH_OPTS="-d${S}"
	if [ $KV_PATCH -lt 15 ]; then
		die "Sorry, your kernel must be 2.6.16-rc5 or newer!"
	fi
	epatch "${FILESDIR}"/CVE-2009-1297.patch

	# add RH patches, we need libiscsi for anaconda
	epatch "${FILESDIR}"/redhat/iscsi-initiator-utils-update-initscripts-and-docs.patch
	epatch "${FILESDIR}"/redhat/iscsi-initiator-utils-use-var-for-config.patch
	epatch "${FILESDIR}"/redhat/iscsi-initiator-utils-use-red-hat-for-name.patch
	epatch "${FILESDIR}"/redhat/iscsi-initiator-utils-ibft-sysfs.patch
	epatch "${FILESDIR}"/redhat/iscsi-initiator-utils-print-ibft-net-info.patch
	epatch "${FILESDIR}"/redhat/iscsi-initiator-utils-only-root-use.patch
	epatch "${FILESDIR}"/redhat/iscsi-initiator-utils-start-iscsid.patch

	epatch "${FILESDIR}"/redhat/${PN}-2.0-870.1-add-libiscsi.patch
	epatch "${FILESDIR}"/redhat/${PN}-2.0-870.1-no-exit.patch
	epatch "${FILESDIR}"/redhat/${PN}-2.0-870.1-ibft-newer-kernel.patch
	epatch "${FILESDIR}"/redhat/${PN}-2.0-870.1-485217.patch
	epatch "${FILESDIR}"/redhat/${PN}-2.0-870.1-fwparam-ppc-crash.patch
	epatch "${FILESDIR}"/redhat/${PN}-2.0-870.1-compile-fix.patch

	# >=2.6.36 kernel support
	epatch "${FILESDIR}"/${PN}-2.0.870-null-sysfs-str.patch

}

src_compile() {
	use debug && append-flags -DDEBUG_TCP -DDEBUG_SCSI

	if use modules; then
		einfo "Building kernel modules"
		export KSRC="${KERNEL_DIR}"
		linux-mod_src_compile || die "failed to build modules"
	fi

	einfo "Building fwparam_ibft"
	cd "${S}"/utils/fwparam_ibft && \
	CFLAGS="" emake OPTFLAGS="${CFLAGS}" \
		|| die "emake failed"

	einfo "Building userspace"
	cd "${S}"/usr && \
	CFLAGS="" emake OPTFLAGS="${CFLAGS}" \
		|| die "emake failed"

	einfo "Building libiscsi"
	cd "${S}"/libiscsi && \
	CFLAGS="" emake OPTFLAGS="${CFLAGS}" \
		|| die "emake failed"
	cd "${S}/libiscsi" && \
		distutils_src_compile

	if use utils; then
		einfo "Building utils"
		cd "${S}"/utils && \
		CFLAGS="" emake OPTFLAGS="${CFLAGS}" \
			|| die "emake failed"
	fi
}

src_install() {
	if use modules; then
		einfo "Installing kernel modules"
		export KSRC="${KERNEL_DIR}"
		linux-mod_src_install
	fi

	einfo "Installing userspace"
	dosbin usr/iscsid usr/iscsiadm usr/iscsistart

	einfo "Installing libiscsi"
	dodir /usr/$(get_libdir)
	exeinto /usr/$(get_libdir)
	doexe "${S}"/libiscsi/libiscsi.so.0
	dosym /usr/$(get_libdir)/libiscsi.so.0 /usr/$(get_libdir)/libiscsi.so

	dodir /usr/include
	insinto /usr/include
	doins "${S}"/libiscsi/libiscsi.h

	cd "${S}/libiscsi"
	distutils_src_install
	cd "${S}"

	if use utils; then
		einfo "Installing utilities"
		dosbin utils/iscsi-iname utils/iscsi_discovery
	fi

	einfo "Installing docs"
	doman doc/*[1-8]
	dodoc README THANKS
	docinto test
	dodoc test/*

	einfo "Installing configuration"
	insinto /etc/iscsi
	doins etc/iscsid.conf

	# only contains iscsi initiatorname, no need to update
	if [ ! -e /etc/iscsi/initiatorname.iscsi ]; then
		doins "${FILESDIR}"/initiatorname.iscsi
	fi

	# if there is a special conf.d for this version, use it
	# otherwise, use the default: iscsid-conf.d
	insinto /etc/conf.d
	if [ -e "${FILESDIR}"/iscsid-${PV}.conf.d ]; then
		newins "${FILESDIR}"/iscsid-${PV}.conf.d iscsid
	else
		newins "${FILESDIR}"/iscsid-conf.d iscsid
	fi

	# same for init.d
	if [ -e "${FILESDIR}"/iscsid-${PV}.init.d ]; then
		newinitd "${FILESDIR}"/iscsid-${PV}.init.d iscsid
	else
		newinitd "${FILESDIR}"/iscsid-init.d iscsid
	fi

	keepdir /var/db/iscsi
	fperms 700 /var/db/iscsi
	fperms 600 /etc/iscsi/iscsid.conf
}

pkg_postinst() {
	linux-mod_pkg_postinst
}
