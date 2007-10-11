# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/truecrypt/truecrypt-4.3a.ebuild,v 1.1 2007/06/07 16:50:20 alonbl Exp $

#
# NOTES:
# - Upstream overwrite CFLAGS, and does not wish us to mess with them.
# - Upstream insist on hiding the Makefile commands... Don't wish to patch it
#   again.
# - Some issues with parallel make of user mode library.
# - Upstream is not responsive, even new kernel versions are not supported
#   by upstream, but by other users.
#

inherit linux-mod toolchain-funcs multilib

DESCRIPTION="Free open-source disk encryption software"
HOMEPAGE="http://www.truecrypt.org/"
SRC_URI="http://www.truecrypt.org/downloads/truecrypt-${PV}-source-code.tar.gz"

LICENSE="truecrypt-collective-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="sys-fs/device-mapper"
DEPEND="virtual/linux-sources
	${RDEPEND}"

S="${WORKDIR}/${P}-source-code"

src_unpack() {
    	unpack ${A}
    	cd "${S}"
	epatch ${FILESDIR}/truecrypt-kernel-2.6.23.patch
}
pkg_setup() {
	linux-mod_pkg_setup
	dmcrypt_check
	kernel_is lt 2 6 5 && die 'requires at least 2.6.5 kernel version'

	BUILD_PARAMS="KERNEL_SRC=${KERNEL_DIR} NO_WARNINGS=1"
	BUILD_TARGETS="truecrypt"
	MODULE_NAMES="truecrypt(block:${S}/Linux/Kernel)"

}

src_compile() {
	linux-mod_src_compile || die "Truecrypt module compilation failed."

	einfo "Building truecrypt utility"
	cd "${S}/Linux/Cli"
	MAKEOPTS="-j1" emake all NO_STRIP=1 NO_WARNINGS=1 CC="$(tc-getCC)" || die "Compile and/or linking of TrueCrypt Linux CLI application failed."
}

src_test() {
	"${S}/Linux/Cli/truecrypt" --test
}

pkg_preinst() {
	# unload truecrypt modules if already loaded
	/sbin/rmmod truecrypt >&- 2>&-
	grep -q "^truecrypt" /proc/modules && die "Please dismount all mounted TrueCrypt volumes"
}

src_install() {
	linux-mod_src_install

	einfo "Installing truecrypt utility"
	cd "${S}"
	dobin Linux/Cli/truecrypt
	doman Linux/Cli/Man/truecrypt.1
	dodoc Readme.txt 'Release/Setup Files/TrueCrypt User Guide.pdf'
	insinto "/$(get_libdir)/rcscripts/addons"
	newins "${FILESDIR}/${PN}-stop.sh" "${PN}-stop.sh"
}

pkg_postinst() {
	linux-mod_pkg_postinst
	elog " For TrueCrypt 4.2 to work you have to load a "
	elog " kernel module. This can be done in three ways: "
	elog
	elog " 1. Loading the module automatically by the running kernel. "
	elog "    For this 'Automatic kernel module loading' needs to be "
	elog "    enabled (CONFIG_KMOD=y). "
	elog " 2. Loading the module manually before mounting the volume. "
	elog "    Try 'modprobe truecrypt' as root to load the module. "
	elog " 3. Load the module during boot by listing it in "
	elog "    '/etc/modules.autoload.d/kernel-2.6' "
}

dmcrypt_check() {
	ebegin "Checking for Device mapper support (BLK_DEV_DM)"
	linux_chkconfig_present BLK_DEV_DM
	eend $?

	if [[ $? -ne 0 ]] ; then
		ewarn "TrueCrypt requires Device mapper support!"
		ewarn "Please enable Device mapper support in your kernel config, found at:"
		ewarn "(for 2.6 kernels)"
		ewarn
		ewarn "  Device Drivers"
		ewarn "    Multi-Device Support"
		ewarn "      <*> Device mapper support"
		ewarn
		ewarn "and recompile your kernel if you want this package to work."
		epause 10
	fi
}
