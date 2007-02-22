# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/cryptsetup-luks/cryptsetup-luks-1.0.4-r1.ebuild,v 1.2 2007/01/27 02:18:18 strerror Exp $

inherit linux-info eutils flag-o-matic multilib

DESCRIPTION="Tool to setup encrypted devices with dm-crypt"
HOMEPAGE="http://luks.endorphin.org/"
SRC_URI="http://luks.endorphin.org/source/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="build dynamic nls selinux"
RESTRICT="confcache"

DEPEND=">=sys-fs/device-mapper-1.00.07-r1
	>=dev-libs/libgcrypt-1.1.42
	>=dev-libs/libgpg-error-1.0-r1
	>=dev-libs/popt-1.7
	selinux? ( sys-libs/libselinux )
	!sys-fs/cryptsetup"

dm-crypt_check() {
	local CONFIG_CHECK="~DM_CRYPT"
	local WARNING_DM_CRYPT="CONFIG_DM_CRYPT:\tis not set (required for cryptsetup-luks)"
	check_extra_config
	echo
}

crypto_check() {
	local CONFIG_CHECK="~CRYPTO"
	local WARNING_CRYPTO="CONFIG_CRYPTO:\tis not set (required for cryptsetup-luks)"
	check_extra_config
	echo
}

cbc_check() {
	local CONFIG_CHECK="~CRYPTO_CBC"
	local WARNING_CRYPTO_CBC="CONFIG_CRYPTO_CBC:\tis not set (required for Kernel 2.6.19)"
	check_extra_config
	echo
}

pkg_setup() {
	# Bug 148390
	if ! use build ; then
		linux-info_pkg_setup
		dm-crypt_check
		crypto_check
		cbc_check
	fi
}

src_compile() {
	if use dynamic ; then
		ewarn "If you need cryptsetup for an initrd or initramfs then you"
		ewarn "should NOT use the dynamic USE flag"
		epause 5
	fi

	econf \
		--sbindir=/sbin \
		$(use_enable !dynamic static) \
		--libdir=/usr/$(get_libdir) \
		$(use_enable nls) \
		$(use_enable selinux) \
		|| die

	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	rmdir "${D}"/usr/$(get_libdir)/cryptsetup
	insinto /lib/rcscripts/addons
	dosym /sbin/cryptsetup /bin/cryptsetup
	newins "${FILESDIR}"/1.0.3-dm-crypt-start.sh dm-crypt-start.sh || die
	newins "${FILESDIR}"/1.0.3-dm-crypt-stop.sh dm-crypt-stop.sh || die
	newconfd "${FILESDIR}"/1.0.3-cryptfs.confd cryptfs || die
}

pkg_postinst() {
	ewarn "This ebuild introduces a new set of scripts and configuration"
	ewarn "then the previous system. If you are currently using /etc/conf.d/crypfs"
	ewarn "then you *MUST* read the new /etc/conf.d/cryptfs for instructions"
	ewarn "on how to convert your previous cryptfs to the new syntax or your"
	ewarn "encrypted partitions will *NOT* work."
	einfo
	einfo "Please see the example for configuring a LUKS mountpoint"
	einfo "in /etc/conf.d/cryptfs"
	einfo
}
