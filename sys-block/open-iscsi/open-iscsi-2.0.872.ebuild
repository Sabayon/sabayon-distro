# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit distutils versionator linux-info eutils flag-o-matic autotools

DESCRIPTION="Open-iSCSI is a high performance, transport independent, multi-platform implementation of RFC3720"
HOMEPAGE="http://www.open-iscsi.org/"
MY_PV="${PN}-$(replace_version_separator 2 "-" $MY_PV)"
SRC_URI="mirror://kernel/linux/kernel/people/mnc/open-iscsi/releases/${MY_PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
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

	# add RH patches, we need libiscsi for anaconda
	epatch "${FILESDIR}"/redhat-${PV}/iscsi-initiator-utils-update-initscripts-and-docs.patch
	epatch "${FILESDIR}"/redhat-${PV}/iscsi-initiator-utils-use-var-for-config.patch
	epatch "${FILESDIR}"/redhat-${PV}/iscsi-initiator-utils-use-red-hat-for-name.patch
	epatch "${FILESDIR}"/redhat-${PV}/iscsi-initiator-utils-add-libiscsi.patch
	epatch "${FILESDIR}"/redhat-${PV}/iscsi-initiator-utils-disable-isns-for-lib.patch
	epatch "${FILESDIR}"/redhat-${PV}/iscsi-initiator-utils-fix-lib-sysfs-init.patch

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
	# build system is broken...
	emake DESTDIR="${D}" sbindir="/usr/sbin" install_user || die "emake install_user failed"
	# this doesn't get installed
	dosbin usr/iscsistart

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

	einfo "Installing libiscsi"
	dodir /usr/$(get_libdir)
	exeinto /usr/$(get_libdir)
	doexe "${S}"/libiscsi/libiscsi.so.0
	dosym libiscsi.so.0 /usr/$(get_libdir)/libiscsi.so

	dodir /usr/include
	insinto /usr/include
	doins "${S}"/libiscsi/libiscsi.h

	cd "${S}"/libiscsi || die
	distutils_src_install

}

pkg_postinst() {
	in='/etc/iscsi/initiatorname.iscsi'
	if [ ! -f "${ROOT}${in}" -a -f "${ROOT}${in}.example" ]; then
		cp -f "${ROOT}${in}.example" "${ROOT}${in}"
	fi
}
