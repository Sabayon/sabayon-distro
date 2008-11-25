# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/libvirt/libvirt-0.4.6.ebuild,v 1.2 2008/11/23 22:54:37 marineam Exp $

inherit eutils autotools

DESCRIPTION="C toolkit to manipulate virtual machines"
HOMEPAGE="http://www.libvirt.org/"
SRC_URI="http://libvirt.org/sources/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="avahi iscsi lvm kvm openvz parted qemu sasl selinux xen" #policykit is in package.mask

DEPEND="sys-libs/readline
	sys-libs/ncurses
	>=dev-libs/libxml2-2.5
	>=net-libs/gnutls-1.0.25
	dev-lang/python
	sys-fs/sysfsutils
	net-misc/bridge-utils
	net-analyzer/netcat
	net-dns/dnsmasq
	avahi? ( >=net-dns/avahi-0.6 )
	iscsi? ( sys-block/open-iscsi )
	kvm? ( app-emulation/kvm )
	lvm? ( sys-fs/lvm2 )
	openvz? ( sys-kernel/openvz-sources )
	parted? ( >=sys-apps/parted-1.8 )
	qemu? ( app-emulation/qemu )
	sasl? ( dev-libs/cyrus-sasl )
	selinux? ( sys-libs/libselinux )
	xen? ( app-emulation/xen-tools app-emulation/xen )
	"
	#policykit? ( >=sys-auth/policykit-0.6 )

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/"${P}"-qemu-img-name.patch
	epatch "${FILESDIR}"/"${P}"-parallel-build-fix.patch
	if use amd64; then
		epatch "${FILESDIR}"/"${P}"-numa-fix.patch
	fi
	eautoreconf
}

pkg_setup() {
	if ! use qemu && ! use xen && ! use openvz && ! use kvm ; then
		local msg="You must enable one of these USE flags: qemu xen openvz kvm"
		eerror "$msg"
		die "$msg"
	fi
}

src_compile() {
	local my_conf=""
	if use qemu || use kvm ; then
		# fix path for kvm-img but use qemu-img if the useflag is set
		my_conf="--with-qemu \
			$(use_with !qemu qemu-img-name kvm-img)"
	else
		my_conf="--without-qemu"
	fi

	econf \
		$(use_with avahi) \
		$(use_with iscsi storage-iscsi) \
		$(use_with lvm storage-lvm) \
		$(use_with openvz) \
		$(use_with parted storage-disk) \
		$(use_with sasl) \
		$(use_with selinux) \
		$(use_with xen) \
		${my_conf} \
		--with-remote \
		--disable-iptables-lokkit \
		--localstatedir=/var \
		--with-remote-pid-file=/var/run/libvirtd.pid \
		|| die "econf failed"
		#$(use_with policykit) \
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die
	mv "${D}"/usr/share/doc/{${PN}-python*,${P}/python}
	newinitd "${FILESDIR}"/libvirtd.init libvirtd
	newconfd "${FILESDIR}"/libvirtd.confd libvirtd
}
