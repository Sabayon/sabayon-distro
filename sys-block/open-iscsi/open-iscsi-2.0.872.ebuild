# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-block/open-iscsi/open-iscsi-2.0.871.3.ebuild,v 1.3 2010/08/24 13:48:01 ssuominen Exp $

EAPI=2
inherit versionator linux-info eutils flag-o-matic autotools

DESCRIPTION="Open-iSCSI is a high performance, transport independent, multi-platform implementation of RFC3720"
HOMEPAGE="http://www.open-iscsi.org/"
MY_PV="${PN}-$(replace_version_separator 2 "-" $MY_PV)"
SRC_URI="mirror://kernel/linux/kernel/people/mnc/open-iscsi/releases/${MY_PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug slp"
DEPEND="net-libs/openslp"
RDEPEND="${DEPEND}
		sys-apps/util-linux"

S="${WORKDIR}/${MY_PV}"

pkg_setup() {
	linux-info_pkg_setup

	if [ $KV_PATCH -lt 15 ]; then
		die "Sorry, your kernel must be 2.6.16-rc5 or newer!"
	fi
}

src_prepare() {
	export EPATCH_OPTS="-d${S}"
	epatch "${FILESDIR}"/${PN}-2.0.872-makefile-cleanup.patch
	epatch "${FILESDIR}"/${P}-glibc212.patch
	epatch "${FILESDIR}"/${P}-slp.patch
	epatch "${FILESDIR}"/${P}-omg-calling-configure.patch
	if use slp; then
		# workaround bug with lslp
		cd "${S}"/utils/open-isns || die
		eautoreconf
		sed -i "s:-lisns:-lisns -lslp:g" "${S}"/usr/Makefile || die
	fi
}

src_configure() {
	einfo "Configuring userpsace"
	cd "${S}/utils/open-isns" || die
	econf $(use_with slp) || die
}

src_compile() {
	use debug && append-flags -DDEBUG_TCP -DDEBUG_SCSI
	einfo "Building userspace"
	cd "${S}" || die
	CFLAGS="" emake OPTFLAGS="${CFLAGS}" user || die "emake failed"
}

src_install() {
	einfo "Installing userspace"
	dosbin usr/iscsid usr/iscsiadm usr/iscsistart

	einfo "Installing utilities"
	dosbin utils/iscsi-iname utils/iscsi_discovery

	einfo "Installing docs"
	doman doc/*[1-8]
	dodoc README THANKS
	docinto test
	dodoc test/*

	einfo "Installing configuration"
	insinto /etc/iscsi
	doins etc/iscsid.conf
	newins "${FILESDIR}"/initiatorname.iscsi initiatorname.iscsi.example
	insinto /etc/iscsi/ifaces
	doins etc/iface.example

	newconfd "${FILESDIR}"/iscsid-conf.d iscsid
	newinitd "${FILESDIR}"/iscsid-2.0.871-r1.init.d iscsid

	keepdir /var/db/iscsi
	fperms 700 /var/db/iscsi
	fperms 600 /etc/iscsi/iscsid.conf
}

pkg_postinst() {
	in='/etc/iscsi/initiatorname.iscsi'
	if [ ! -f "${ROOT}${in}" -a -f "${ROOT}${in}.example" ]; then
		cp -f "${ROOT}${in}.example" "${ROOT}${in}"
	fi
}
