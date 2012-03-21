# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils multilib linux-info linux-mod toolchain-funcs versionator

DESCRIPTION="AMD kernel drivers for radeon r600 (HD Series) and newer chipsets"
HOMEPAGE="http://www.amd.com"
# 8.ble will be used for beta releases.
if [[ $(get_major_version) -gt 8 ]]; then
	ATI_URL="http://www2.ati.com/drivers/linux/"
	SRC_URI="${ATI_URL}/amd-driver-installer-${PV/./-}-x86.x86_64.run"
	FOLDER_PREFIX="common/"
else
	SRC_URI="https://launchpad.net/ubuntu/natty/+source/fglrx-installer/2:${PV}-0ubuntu1/+files/fglrx-installer_${PV}.orig.tar.gz"
	FOLDER_PREFIX=""
fi
IUSE="debug multilib pax_kernel"

LICENSE="AMD GPL-2 as-is"
KEYWORDS="~amd64 ~x86"
SLOT="1"

RDEPEND="multilib? ( ~x11-drivers/ati-userspace-${PV}[multilib] )
	~x11-drivers/ati-userspace-${PV}
	sys-power/acpid"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

_check_kernel_config() {
	local failed=0
	local error=""
	if ! kernel_is ge 2 6; then
		eerror "You need a 2.6 linux kernel to compile against!"
		die "No 2.6 Kernel found"
	fi

	if ! linux_chkconfig_present MTRR; then
		ewarn "You don't have MTRR support enabled in the kernel."
		ewarn "Direct rendering will not work."
	fi

	if linux_chkconfig_builtin DRM; then
		ewarn "You have DRM support built in to the kernel"
		ewarn "Direct rendering will not work."
	fi

	if ! linux_chkconfig_present AGP && \
		! linux_chkconfig_present PCIEPORTBUS; then
		ewarn "You don't have AGP and/or PCIe support enabled in the kernel"
		ewarn "Direct rendering will not work."
	fi

	if ! linux_chkconfig_present ACPI; then
		eerror "${P} requires the ACPI support in the kernel"
		eerror "Please enable it:"
		eerror "    CONFIG_ACPI=y"
		eerror "in /usr/src/linux/.config or"
		eerror "    Power management and ACPI options --->"
		eerror "        [*] Power Management support"
		eerror "in the 'menuconfig'"
		error+=" CONFIG_ACPI disabled;"
		failed=1
	fi

	if ! linux_chkconfig_present PCI_MSI; then
		eerror "${P} requires MSI in the kernel."
		eerror "Please enable it:"
		eerror "    CONFIG_PCI_MSI=y"
		eerror "in /usr/src/linux/.config or"
		eerror "    Bus options (PCI etc.)  --->"
		eerror "        [*] Message Signaled Interrupts (MSI and MSI-X)"
		eerror "in the kernel config."
		error+=" CONFIG_PCI_MSI disabled;"
		failed=1
	fi

	if linux_chkconfig_present LOCKDEP; then
		eerror "You've enabled LOCKDEP -- lock tracking -- in the kernel."
		eerror "Unfortunately, this option exports the symbol lock_acquire as GPL-only."
		eerror "This prevents ${P} from compiling with an error like this:"
		eerror "FATAL: modpost: GPL-incompatible module fglrx.ko uses GPL-only symbol 'lock_acquire'"
		eerror "Please make sure the following options have been unset:"
		eerror "    Kernel hacking  --->"
		eerror "        [ ] Lock debugging: detect incorrect freeing of live locks"
		eerror "        [ ] Lock debugging: prove locking correctness"
		eerror "        [ ] Lock usage statistics"
		eerror "in 'menuconfig'"
		error+=" LOCKDEP enabled;"
		failed=1
	fi

	use amd64 && if ! linux_chkconfig_present COMPAT; then
		eerror "${P} requires COMPAT."
		eerror "Please enable the 32 bit emulation:"
		eerror "Executable file formats / Emulations  --->"
		eerror "    [*] IA32 Emulation"
		eerror "in the kernel config."
		eerror "if this doesn't enable CONFIG_COMPAT add"
		eerror "    CONFIG_COMPAT=y"
		eerror "in /usr/src/linux/.config"
		error+=" COMPAT disabled;"
		failed=1
	fi

	kernel_is ge 2 6 37 && kernel_is le 2 6 38 && if ! linux_chkconfig_present BKL ; then
		eerror "${P} requires BKL."
		eerror "Please enable the Big Kernel Lock:"
		eerror "Kernel hacking  --->"
		eerror "    [*] Big Kernel Lock"
		eerror "in the kernel config."
		eerror "or add"
		eerror "    CONFIG_BKL=y"
		eerror "in /usr/src/linux/.config"
		error+=" BKL disabled;"
		failed=1
	fi

	[[ ${failed} -ne 0 ]] && die "${error}"
}

pkg_pretend() {
	# workaround until bug 365543 is solved
	linux-info_pkg_setup
	require_configured_kernel
	_check_kernel_config
}

pkg_setup() {
	MODULE_NAMES="fglrx(video:${S}/${FOLDER_PREFIX}/lib/modules/fglrx/build_mod/2.6.x)"
	BUILD_TARGETS="kmod_build"
	linux-mod_pkg_setup
	BUILD_PARAMS="GCC_VER_MAJ=$(gcc-major-version) KVER=${KV_FULL} KDIR=${KV_DIR}"
	BUILD_PARAMS="${BUILD_PARAMS} CFLAGS_MODULE+=\"-DMODULE -DATI -DFGL\""
	if grep -q arch_compat_alloc_user_space ${KV_DIR}/arch/x86/include/asm/compat.h ; then
		BUILD_PARAMS="${BUILD_PARAMS} CFLAGS_MODULE+=-DCOMPAT_ALLOC_USER_SPACE=arch_compat_alloc_user_space"
	else
		BUILD_PARAMS="${BUILD_PARAMS} CFLAGS_MODULE+=-DCOMPAT_ALLOC_USER_SPACE=compat_alloc_user_space"
	fi

	# amd64/x86
	if use amd64 ; then
		MY_BASE_DIR="${BASE_DIR}_64a"
		PKG_LIBDIR=lib64
		ARCH_DIR="${S}/arch/x86_64"
	else
		MY_BASE_DIR="${BASE_DIR}"
		PKG_LIBDIR=lib
		ARCH_DIR="${S}/arch/x86"
	fi

	# Define module dir.
	MODULE_DIR="${S}/${FOLDER_PREFIX}/lib/modules/fglrx/build_mod"

	elog
	elog "Please note that this driver supports only graphic cards based on"
	elog "r600 chipset and newer."
	elog "This represent the AMD Radeon HD series at this moment."
	elog
	elog "If your card is older then usage of ${CATEGORY}/xf86-video-ati"
	elog "as replacement is highly recommended. Rather than staying with"
	elog "old versions of this driver."
	elog "For migration informations please reffer to:"
	elog "http://www.gentoo.org/proj/en/desktop/x/x11/ati-migration-guide.xml"
	einfo
}

src_unpack() {
	if [[ $(get_major_version) -gt 8 ]]; then
		# Switching to a standard way to extract the files since otherwise no signature file
		# would be created
		local src="${DISTDIR}/${A}"
		sh "${src}" --extract "${S}"  2&>1 /dev/null
	else
		unpack ${A}
	fi
}

src_prepare() {
	# version patches
	# epatch "${FILESDIR}"/kernel/${PV}-*.patch
	if use debug; then
		sed -i '/^#define DRM_DEBUG_CODE/s/0/1/' \
			"${MODULE_DIR}/firegl_public.c" \
			|| die "Failed to enable debug output."
	fi

	# fix needed for at least hardened-sources, see bug #392753
	use pax_kernel && epatch "${FILESDIR}"/ati-drivers-12.2-redefine-WARN.patch

	# Fix compilation with 3.2.8 and 3.3 kernels
	epatch "${FILESDIR}/ati-drivers-3.2.8+.patch"

	cd "${MODULE_DIR}"
	# bugged fglrx build system, this file should be copied by hand
	cp "${ARCH_DIR}"/lib/modules/fglrx/build_mod/libfglrx_ip.a 2.6.x

	convert_to_m 2.6.x/Makefile || die "convert_to_m failed"

	# When built with ati's make.sh it defines a bunch of macros if
	# certain .config values are set, falling back to less reliable
	# detection methods if linux/autoconf.h is not available. We
	# simply use the linux/autoconf.h settings directly, bypassing the
	# detection script.
	sed -i -e 's/__SMP__/CONFIG_SMP/' *.c *h || die "SMP sed failed"
	sed -i -e 's/ifdef MODVERSIONS/ifdef CONFIG_MODVERSIONS/' *.c *.h \
		|| die "MODVERSIONS sed failed"

	cd "${S}"
	mkdir extra || die "mkdir failed"
	cd extra
	unpack ./../${FOLDER_PREFIX}usr/src/ati/fglrx_sample_source.tgz
}

src_compile() {
	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install
}

pkg_postinst() {
	elog "If you experience unexplained segmentation faults and kernel crashes"
	elog "with this driver and multi-threaded applications such as wine,"
	elog "set UseFastTLS in xorg.conf to either 0 or 1, but not 2."
	linux-mod_pkg_postinst
}

pkg_preinst() {
	linux-mod_pkg_preinst
}

pkg_postrm() {
	linux-mod_pkg_postrm
}
