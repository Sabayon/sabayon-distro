# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils multilib linux-info linux-mod toolchain-funcs versionator

DESCRIPTION="Ati precompiled drivers for Radeon Evergreen (HD5000 Series) and newer chipsets"
HOMEPAGE="http://www.amd.com"
MY_V=( $(get_version_components) )
#RUN="${WORKDIR}/amd-driver-installer-9.00-x86.x86_64.run"
SLOT="1"
[[ "${MY_V[2]}" =~  beta.* ]] && BETADIR="beta/" || BETADIR="linux/"
if [[ legacy != ${SLOT} ]]; then
	DRIVERS_URI="http://www2.ati.com/drivers/${BETADIR}amd-catalyst-${PV/_beta/-beta}-linux-x86.x86_64.zip"
else
	DRIVERS_URI="http://www2.ati.com/drivers/legacy/amd-driver-installer-catalyst-$(get_version_component_range 1-2)-$(get_version_component_range 3)-legacy-linux-x86.x86_64.zip"
fi
XVBA_SDK_URI="http://developer.amd.com/wordpress/media/2012/10/xvba-sdk-0.74-404001.tar.gz"
SRC_URI="${DRIVERS_URI} ${XVBA_SDK_URI}"
FOLDER_PREFIX="common/"
IUSE="debug multilib x-multilib pax_kernel disable-watermark"

LICENSE="AMD GPL-2 QPL-1.0"
KEYWORDS="-* ~amd64 ~x86"
RESTRICT="bindist test"

RDEPEND="x-multilib? ( ~x11-drivers/ati-userspace-${PV}[x-multilib] )
	multilib? ( ~x11-drivers/ati-userspace-${PV}[multilib] )
	~x11-drivers/ati-userspace-${PV}
	sys-power/acpid"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

CONFIG_CHECK="~MTRR ~!DRM ACPI PCI_MSI !LOCKDEP !PAX_KERNEXEC_PLUGIN_METHOD_OR"
use amd64 && CONFIG_CHECK="${CONFIG_CHECK} COMPAT"
ERROR_MTRR="CONFIG_MTRR required for direct rendering."
ERROR_DRM="CONFIG_DRM must be disabled or compiled as a module and not loaded for direct
	rendering to work."
ERROR_LOCKDEP="CONFIG_LOCKDEP (lock tracking) exports the symbol lock_acquire
	as GPL-only. This prevents ${P} from compiling with an error like this:
	FATAL: modpost: GPL-incompatible module fglrx.ko uses GPL-only symbol 'lock_acquire'"
ERROR_PAX_KERNEXEC_PLUGIN_METHOD_OR="This config option will cause
	kernel to reject loading the fglrx module with
	\"ERROR: could not insert 'fglrx': Exec format error.\"
	You may want to try CONFIG_PAX_KERNEXEC_PLUGIN_METHOD_BTS instead."

_check_kernel_config() {
	if ! linux_chkconfig_present AGP && \
		! linux_chkconfig_present PCIEPORTBUS; then
		ewarn "You don't have AGP and/or PCIe support enabled in the kernel"
		ewarn "Direct rendering will not work."
	fi

	kernel_is ge 2 6 37 && kernel_is le 2 6 38 && if ! linux_chkconfig_present BKL ; then
		die "CONFIG_BKL must be enabled for kernels 2.6.37-2.6.38."
	fi
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
	# Define module dir.
	MODULE_DIR="${S}/${FOLDER_PREFIX}/lib/modules/fglrx/build_mod"
	# get the xorg-server version and set BASE_DIR for that
	BASE_DIR="${S}/xpic"

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

	elog
	elog "Please note that this driver only supports graphic cards based on"
	elog "Evergreen chipset and newer."
	elog "This includes the AMD Radeon HD 5400+ series at this moment."
	elog
	elog "If your card is older then use ${CATEGORY}/xf86-video-ati"
	elog "For migration information please refer to:"
	elog "http://www.gentoo.org/proj/en/desktop/x/x11/ati-migration-guide.xml"
	einfo
}

src_unpack() {
	local DRIVERS_DISTFILE XVBA_SDK_DISTFILE
	DRIVERS_DISTFILE=${DRIVERS_URI##*/}
	XVBA_SDK_DISTFILE=${XVBA_SDK_URI##*/}

	if [[ ${DRIVERS_DISTFILE} =~ .*\.tar\.gz ]]; then
		unpack ${DRIVERS_DISTFILE}
	else
		#please note, RUN may be insanely assigned at top near SRC_URI
		if [[ ${DRIVERS_DISTFILE} =~ .*\.zip ]]; then
			unpack ${DRIVERS_DISTFILE}
			[[ -z "$RUN" ]] && RUN="${S}/${DRIVERS_DISTFILE/%.zip/.run}"
		else
			RUN="${DISTDIR}/${DRIVERS_DISTFILE}"
		fi
		sh ${RUN} --extract "${S}" 2>&1 > /dev/null || die
	fi

	mkdir xvba_sdk
	cd xvba_sdk
	unpack ${XVBA_SDK_DISTFILE}
}

src_prepare() {
	# version patches
	# epatch "${FILESDIR}"/kernel/${PV}-*.patch
	if use debug; then
		sed -i '/^#define DRM_DEBUG_CODE/s/0/1/' \
			"${MODULE_DIR}/firegl_public.c" \
			|| die "Failed to enable debug output."
	fi

	# see http://ati.cchtml.com/show_bug.cgi?id=495
	#epatch "${FILESDIR}"/ati-drivers-old_rsp.patch
	# first hunk applied upstream second (x32 related) was not
	epatch "${FILESDIR}"/ati-drivers-x32_something_something.patch

	# compile fix for AGP-less kernel, bug #435322
	epatch "${FILESDIR}"/ati-drivers-12.9-KCL_AGP_FindCapsRegisters-stub.patch

	# Compile fix, https://bugs.gentoo.org/show_bug.cgi?id=454870
	use pax_kernel && epatch "${FILESDIR}/const-notifier-block.patch"

	cd "${MODULE_DIR}"
	# bugged fglrx build system, this file should be copied by hand
	cp ${ARCH_DIR}/lib/modules/fglrx/build_mod/libfglrx_ip.a 2.6.x

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

	mkdir extra || die "mkdir extra failed"
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
