# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/ati-drivers/ati-drivers-10.10.ebuild,v 1.1 2010/11/07 23:59:33 lu_zero Exp $

EAPI="2"

inherit eutils multilib linux-mod toolchain-funcs versionator

DESCRIPTION="Ati precompiled drivers for r600 (HD Series) and newer chipsets"
HOMEPAGE="http://www.ati.com"
# 8.ble will be used for beta releases.
if [[ $(get_major_version) -gt 8 ]]; then
	ATI_URL="https://a248.e.akamai.net/f/674/9206/0/www2.ati.com/drivers/linux/"
	SRC_URI="${ATI_URL}/ati-driver-installer-${PV/./-}-x86.x86_64.run"
	FOLDER_PREFIX="common/"
else
	SRC_URI="https://launchpad.net/ubuntu/maverick/+source/fglrx-installer/2:${PV}-0ubuntu1/+files/fglrx-installer_${PV}.orig.tar.gz"
	FOLDER_PREFIX=""
fi
# qt4 use is fake and is used to match upstream
IUSE="debug +modules multilib qt4"

LICENSE="AMD GPL-2 QPL-1.0 as-is"
KEYWORDS="~amd64 ~x86"
SLOT="1"

RDEPEND="
	<x11-base/xorg-server-1.9.99
	!x11-drivers/ati-drivers:0
	!x11-apps/ati-drivers-extra
	>=app-admin/eselect-opengl-1.0.7
	sys-power/acpid
	x11-apps/xauth
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
"

DEPEND="${RDEPEND}
	x11-proto/inputproto
	x11-proto/xf86miscproto
	x11-proto/xf86vidmodeproto
	x11-proto/xineramaproto
	x11-libs/libXtst
"

EMULTILIB_PKG="true"

S="${WORKDIR}"

# QA Silencing
QA_TEXTRELS="
	usr/lib*/opengl/ati/lib/libGL.so.1.2
	usr/lib*/libatiadlxx.so
	usr/lib*/xorg/modules/glesx.so
	usr/lib*/libaticaldd.so
	usr/lib*/dri/fglrx_dri.so
"

QA_EXECSTACK="
	opt/bin/atiode
	opt/bin/amdcccle
	usr/lib*/opengl/ati/lib/libGL.so.1.2
	usr/lib*/dri/fglrx_dri.so
"

QA_WX_LOAD="
	usr/lib*/opengl/ati/lib/libGL.so.1.2
	usr/lib*/dri/fglrx_dri.so
"

QA_PRESTRIPPED="
	usr/lib\(32\|64\)\?/libXvBAW.so.1.0
	usr/lib\(32\|64\)\?/opengl/ati/lib/libGL.so.1.2
	usr/lib\(32\|64\)\?/opengl/ati/extensions/libglx.so
	usr/lib\(32\|64\)\?/xorg/modules/glesx.so
	usr/lib\(32\|64\)\?/libAMDXvBA.so.1.0
	usr/lib\(32\|64\)\?/libaticaldd.so
	usr/lib\(32\|64\)\?/dri/fglrx_dri.so
"

QA_SONAME="
	usr/lib\(32\|64\)\?/libatiadlxx.so
	usr/lib\(32\|64\)\?/libaticalcl.so
	usr/lib\(32\|64\)\?/libaticaldd.so
	usr/lib\(32\|64\)\?/libaticalrt.so
"

QA_DT_HASH="
	opt/bin/amdcccle
	opt/bin/aticonfig
	opt/bin/atiodcli
	opt/bin/atiode
	opt/bin/fglrxinfo
	opt/sbin/atieventsd
	usr/lib\(32\|64\)\?/libaticalcl.so
	usr/lib\(32\|64\)\?/libaticalrt.so
	usr/lib\(32\|64\)\?/libatiuki.so.1.0
	usr/lib\(32\|64\)\?/libatiadlxx.so
	usr/lib\(32\|64\)\?/libfglrx_dm.so.1.0
	usr/lib\(32\|64\)\?/libXvBAW.so.1.0
	usr/lib\(32\|64\)\?/libAMDXvBA.so.1.0
	usr/lib\(32\|64\)\?/xorg/modules/amdxmm.so
	usr/lib\(32\|64\)\?/xorg/modules/glesx.so
	usr/lib\(32\|64\)\?/xorg/modules/linux/libfglrxdrm.so
	usr/lib\(32\|64\)\?/xorg/modules/drivers/fglrx_drv.so
	usr/lib\(32\|64\)\?/libaticaldd.so
	usr/lib\(32\|64\)\?/dri/fglrx_dri.so
	usr/lib\(32\|64\)\?/opengl/ati/extensions/libglx.so
	usr/lib\(32\|64\)\?/opengl/ati/lib/libGL.so.1.2
"

_check_kernel_config() {
	local failed=0
	local error=""
	if ! kernel_is 2 6; then
		eerror "You need a 2.6 linux kernel to compile against!"
		die "No 2.6 Kernel found"
	fi

	if kernel_is ge 2 6 25 && linux_chkconfig_present PREEMPT_RCU; then
		eerror "${P} is incompatible with RCU preemption (bug #223281)."
		eerror "Please disable it:"
		eerror "    CONFIG_PREEMT_RCU=n"
		eerror "in /usr/src/linux/.config or"
		eerror "    Processor type and features  --->"
		eerror "        [ ] Preemptible RCU"
		eerror "in the 'menuconfig'"
		error="${error} CONFIG_PREEMT_RCU enabled"
		failed=1
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
		error="${error} CONFIG_ACPI disabled"
		failed=1
	fi

	if ! linux_chkconfig_present MAGIC_SYSRQ; then
		eerror "${P} requires the magic SysRq keys in the kernel."
		eerror "Please enable it:"
		eerror "    CONFIG_MAGIC_SYSRQ=y"
		eerror "in /usr/src/linux/.config or"
		eerror "    Kernel hacking  --->"
		eerror "        [*] Magic SysRq key"
		eerror "in the 'menuconfig'"
		error="${error} CONFIG_MAGIC_SYSRQ disabled"
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
		error="${error} CONFIG_PCI_MSI disabled"
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
		error="${error} LOCKDEP enabled"
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
		error="${error} COMPAT disabled"
		failed=1
	fi

	[ "x${failed}" != "x0" ] && die "${error}"
}

pkg_setup() {
	# Define module dir.
	MODULE_DIR="${S}/${FOLDER_PREFIX}/lib/modules/fglrx/build_mod"
	# get the xorg-server version and set BASE_DIR for that
	local ver_str=$(qatom `best_version x11-base/xorg-server` | cut -d ' ' -f 3)
	case ${ver_str} in
		1\.9*) BASE_DIR="${S}/x760" ;;
		9999*) BASE_DIR="${S}/x760"
			ewarn "Experimental xorg-server-${ver_str}"
			ewarn "Picking the last implementation" ;;
		1\.8*|1\.7*) BASE_DIR="${S}/x750" ;;
		*) die "xorg-server-${ver_str} not supported" ;;
	esac

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

	if use modules; then
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
		_check_kernel_config
	fi

	elog
	elog "Please note that this driver supports only graphic cards based on"
	elog "r600 chipset and newer."
	elog "This represent the ATI Radeon HD series at this moment."
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
	# All kernel options for prepare are ment to be in here
	if use modules; then
		# version patches
		# epatch "${FILESDIR}"/kernel/${PV}-*.patch
		if use debug; then
			sed -i '/^#define DRM_DEBUG_CODE/s/0/1/' \
				"${MODULE_DIR}/firegl_public.c" \
				|| die "Failed to enable debug output."
		fi
	fi

	# Fix a known compilation error
	epatch "${FILESDIR}"/ati-drivers-fix_compilation-bug-297322.patch
	# Patch for 3.6.36 kernel
	if kernel_is eq 2 6 36 ; then
		epatch "${FILESDIR}"/ati-drivers-2.6.36.patch || \
			die "epatch ati-drivers-2.6.36.patch failed"
	fi

	if kernel_is ge 2 6 37; then
			epatch "${FILESDIR}"/${PN}-2.6.37-sema_init.patch
	fi


	# These are the userspace utilities that we also have source for.
	# We rebuild these later.
	rm \
		"${ARCH_DIR}"/usr/X11R6/bin/{fgl_glxgears,fglrx_xgamma} \
		"${ARCH_DIR}"/usr/X11R6/${PKG_LIBDIR}/libfglrx_gamma* \
		|| die "bin rm failed"

	# amdcccle is shipped separately
	rm "${ARCH_DIR}"/usr/X11R6/bin/amdcccle || die "cannot rm amdcccle"

	# ACPI fixups
	sed -i \
		-e "s:/var/lib/xdm/authdir/authfiles/:/var/run/xauth/:" \
		-e "s:/var/lib/gdm/:/var/gdm/:" \
		"${S}/${FOLDER_PREFIX}etc/ati/authatieventsd.sh" \
		|| die "sed failed."

	# Since "who" is in coreutils, we're using that one instead of "finger".
	sed -i -e 's:finger:who:' \
		"${S}/${FOLDER_PREFIX}usr/share/doc/fglrx/examples/etc/acpi/ati-powermode.sh" \
		|| die "Replacing 'finger' with 'who' failed."
	# Adjust paths in the script from /usr/X11R6/bin/ to /opt/bin/ and
	# add function to detect default state.
	epatch "${FILESDIR}"/ati-powermode-opt-path-2.patch || die "Failed to epatch powermode-opt-path-2.patch"

	cd "${MODULE_DIR}"
	ln -s "${ARCH_DIR}"/lib/modules/fglrx/build_mod/libfglrx_ip.a.GCC$(gcc-major-version) \
		|| die "symlinking precompiled core failed"

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
	sed -i -e 's:include/extensions/extutil.h:X11/extensions/extutil.h:' \
		lib/fglrx_gamma/fglrx_gamma.c || die "include fixup failed"
	# Add a category.
	mv programs/fglrx_gamma/fglrx_xgamma.{man,1} || die "man mv failed"
}

src_compile() {
	use modules && linux-mod_src_compile

	ebegin "Building fgl_glxgears"
	cd "${S}"/extra/fgl_glxgears
	# These extra libs/utils either have an Imakefile that does not
	# work very well without tweaking or a Makefile ignoring CFLAGS
	# and the like. We bypass those.

	# The -DUSE_GLU is needed to compile using nvidia headers
	# according to a comment in ati-drivers-extra-8.33.6.ebuild.
	"$(tc-getCC)" -o fgl_glxgears ${CFLAGS} ${LDFLAGS} -DUSE_GLU \
		-I"${S}"/${FOLDER_PREFIX}usr/include fgl_glxgears.c \
		-lGL -lGLU -lX11 -lm || die "fgl_glxgears build failed"
	eend $?

	ebegin "Building fglrx_gamma lib"
	cd "${S}"/extra/lib/fglrx_gamma
	"$(tc-getCC)" -shared -fpic -o libfglrx_gamma.so.1.0 ${CFLAGS} ${LDFLAGS} \
		-DXF86MISC -Wl,-soname,libfglrx_gamma.so.1.0 fglrx_gamma.c \
		-lXext || die "fglrx_gamma lib build failed"
	ln -s libfglrx_gamma.so.1.0 libfglrx_gamma.so || die "ln failed"
	ln -s libfglrx_gamma.so.1.0 libfglrx_gamma.so.1 || die "ln failed"
	eend $?

	ebegin "Building fglrx_gamma util"
	cd "${S}"/extra/programs/fglrx_gamma
	"$(tc-getCC)" -o fglrx_xgamma ${CFLAGS} ${LDFLAGS} \
		-I../../../${FOLDER_PREFIX}usr/X11R6/include -L../../lib/fglrx_gamma \
		fglrx_xgamma.c -lm -lfglrx_gamma -lX11 \
		|| die "fglrx_gamma util build failed"
	eend $?

}

src_install() {
	use modules && linux-mod_src_install

	# We can do two things here, and neither of them is very nice.

	# For direct rendering libGL has to be able to load one or more
	# dri modules (files ending in _dri.so, like fglrx_dri.so).
	# Gentoo's mesa looks for these files in the location specified by
	# LIBGL_DRIVERS_PATH or LIBGL_DRIVERS_DIR, then in the hardcoded
	# location /usr/$(get_libdir)/dri. Ati's libGL does the same
	# thing, but the hardcoded location is /usr/X11R6/lib/modules/dri
	# on x86 and amd64 32bit, /usr/X11R6/lib64/modules/dri on amd64
	# 64bit. So we can either put the .so files in that (unusual,
	# compared to "normal" mesa libGL) location or set
	# LIBGL_DRIVERS_PATH. We currently do the latter. See also bug
	# 101539.

	# The problem with this approach is that LIBGL_DRIVERS_PATH
	# *overrides* the default hardcoded location, it does not extend
	# it. So if ati-drivers is merged but a non-ati libGL is selected
	# and its hardcoded path does not match our LIBGL_DRIVERS_PATH
	# (because it changed in a newer mesa or because it was compiled
	# for a different set of multilib abis than we are) stuff breaks.

	# We create one file per ABI to work with "native" multilib, see
	# below.

	echo "COLON_SEPARATED=LIBGL_DRIVERS_PATH" > "${T}/03ati-colon-sep"
	doenvd "${T}/03ati-colon-sep" || die

	# All libraries that we have a 32 bit and 64 bit version of on
	# amd64 are installed in src_install-libs. Everything else
	# (including libraries only available in native 64bit on amd64)
	# goes in here.

	# There used to be some code here that tried to detect running
	# under a "native multilib" portage ((precursor of)
	# http://dev.gentoo.org/~kanaka/auto-multilib/). I removed that, it
	# should just work (only doing some duplicate work). --marienz
	if has_multilib_profile; then
		local OABI=${ABI}
		for ABI in $(get_install_abis); do
			src_install-libs
		done
		ABI=${OABI}
		unset OABI
	else
		src_install-libs
	fi

	# remove the damn watermark
	fgl_drv="${MY_BASE_DIR}"/usr/X11R6/${PKG_LIBDIR}/modules/drivers/fglrx_drv.so
	for x in $(objdump -d "${fgl_drv}" |awk '/call/&&/EnableLogo/{print "\\x"$2"\\x"$3"\\x"$4"\\x"$5"\\x"$6}'); do
		sed -i "s/$x/\x90\x90\x90\x90\x90/g" "${fgl_drv}"
	done

	# This is sorted by the order the files occur in the source tree.

	# X modules.
	exeinto /usr/$(get_libdir)/xorg/modules/drivers
	doexe "${MY_BASE_DIR}"/usr/X11R6/${PKG_LIBDIR}/modules/drivers/fglrx_drv.so || die
	exeinto /usr/$(get_libdir)/xorg/modules/linux
	doexe "${MY_BASE_DIR}"/usr/X11R6/${PKG_LIBDIR}/modules/linux/libfglrxdrm.so || die
	exeinto /usr/$(get_libdir)/xorg/modules
	doexe "${MY_BASE_DIR}"/usr/X11R6/${PKG_LIBDIR}/modules/{glesx.so,amdxmm.so} || die

	# Arch-specific files.
	# (s)bin.
	into /opt
	dosbin "${ARCH_DIR}"/usr/sbin/atieventsd || die
	# We cleaned out the compilable stuff in src_unpack
	dobin "${ARCH_DIR}"/usr/X11R6/bin/* || die

	# lib.
	exeinto /usr/$(get_libdir)
	# Everything except for the libGL.so installed in src_install-libs.
	doexe $(find "${ARCH_DIR}"/usr/X11R6/${PKG_LIBDIR} \
		-maxdepth 1 -type f -name '*.so*' -not -name 'libGL.so*')
	insinto /usr/$(get_libdir)
	doins $(find "${ARCH_DIR}"/usr/X11R6/${PKG_LIBDIR} \
		-maxdepth 1 -type f -not -name '*.so*')

	# Common files.
	# etc.
	insinto /etc/ati
	# Everything except for the authatieventsd.sh script.
	doins ${FOLDER_PREFIX}etc/ati/{logo*,control,atiogl.xml,signature,amdpcsdb.default}
	insopts -m0755
	doins ${FOLDER_PREFIX}etc/ati/authatieventsd.sh || die

	# include.
	insinto /usr
	doins -r ${FOLDER_PREFIX}usr/include || die
	insinto /usr/include/X11/extensions
	doins ${FOLDER_PREFIX}usr/X11R6/include/X11/extensions/fglrx_gamma.h || die

	# Just the atigetsysteminfo.sh script.
	into /usr
	dosbin ${FOLDER_PREFIX}usr/sbin/* || die

	# doc.
	dohtml -r ${FOLDER_PREFIX}usr/share/doc/fglrx || die

	doman ${FOLDER_PREFIX}usr/share/man/man8/atieventsd.8 || die

	pushd ${FOLDER_PREFIX}usr/share/doc/fglrx/examples/etc/acpi > /dev/null

	exeinto /etc/acpi
	doexe ati-powermode.sh || die
	insinto /etc/acpi/events
	doins events/* || die

	popd > /dev/null

	# Done with the "source" tree. Install tools we rebuilt:
	dobin extra/fgl_glxgears/fgl_glxgears || die
	newdoc extra/fgl_glxgears/README README.fgl_glxgears || die

	dolib extra/lib/fglrx_gamma/*so* || die
	newdoc extra/lib/fglrx_gamma/README README.libfglrx_gamma || die

	dobin extra/programs/fglrx_gamma/fglrx_xgamma || die
	doman extra/programs/fglrx_gamma/fglrx_xgamma.1 || die
	newdoc extra/programs/fglrx_gamma/README README.fglrx_gamma || die

	# Gentoo-specific stuff:
	newinitd "${FILESDIR}"/atieventsd.init atieventsd \
		|| die "Failed to install atieventsd.init.d"
	echo 'ATIEVENTSDOPTS=""' > "${T}"/atieventsd.conf
	insopts -m0644
	newconfd "${T}"/atieventsd.conf atieventsd || die
}

src_install-libs() {
	if [[ "${ABI}" == "amd64" ]]; then
		local EX_BASE_DIR="${BASE_DIR}_64a"
		local pkglibdir=lib64
		local MY_ARCH_DIR="${S}/arch/x86_64"
	else
		local EX_BASE_DIR="${BASE_DIR}"
		local pkglibdir=lib
		local MY_ARCH_DIR="${S}/arch/x86"
	fi
	einfo "ati tree '${pkglibdir}' -> '$(get_libdir)' on system"

	local ATI_ROOT=/usr/$(get_libdir)/opengl/ati
	# To make sure we do not miss a spot when these change.
	local libmajor=1 libminor=2
	local libver=${libmajor}.${libminor}

	# The GLX libraries
	# (yes, this really is "lib" even on amd64/multilib --marienz)
	exeinto ${ATI_ROOT}/lib
	doexe "${MY_ARCH_DIR}"/usr/X11R6/${pkglibdir}/libGL.so.${libver} || die
	dosym libGL.so.${libver} ${ATI_ROOT}/lib/libGL.so.${libmajor} || die
	dosym libGL.so.${libver} ${ATI_ROOT}/lib/libGL.so || die

	exeinto ${ATI_ROOT}/extensions
	doexe "${EX_BASE_DIR}"/usr/X11R6/${pkglibdir}/modules/extensions/* || die

	# DRI modules, installed into the path used by recent versions of mesa.
	exeinto /usr/$(get_libdir)/dri
	doexe "${MY_ARCH_DIR}"/usr/X11R6/${pkglibdir}/modules/dri/fglrx_dri.so || die

	# AMD Cal libraries
	exeinto /usr/$(get_libdir)
	doexe "${MY_ARCH_DIR}"/usr/${pkglibdir}/libati*.so* || die

	local envname="${T}"/04ati-dri-path
	if [[ -n ${ABI} ]]; then
		envname="${envname}-${ABI}"
	fi
	echo "LIBGL_DRIVERS_PATH=/usr/$(get_libdir)/dri" > "${envname}"
	doenvd "${envname}" || die
}

pkg_postinst() {
	elog "To switch to ATI OpenGL, run \"eselect opengl set ati\""
	elog "To change your xorg.conf you can use the bundled \"aticonfig\""
	elog
	elog "If you experience unexplained segmentation faults and kernel crashes"
	elog "with this driver and multi-threaded applications such as wine,"
	elog "set UseFastTLS in xorg.conf to either 0 or 1, but not 2."
	elog
	elog "You will have to source /etc/profile (or logout and back in) for dri"
	elog "to work, unless you previously had ati-drivers installed."

	use modules && linux-mod_pkg_postinst
	"${ROOT}"/usr/bin/eselect opengl set --use-old ati
}

pkg_preinst() {
	use modules && linux-mod_pkg_preinst
}

pkg_prerm() {
	"${ROOT}"/usr/bin/eselect opengl set --use-old xorg-x11
}

pkg_postrm() {
	use modules && linux-mod_pkg_postrm
	"${ROOT}"/usr/bin/eselect opengl set --use-old xorg-x11
}
