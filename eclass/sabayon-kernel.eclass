# Copyright 2004-2010 Sabayon Project
# Distributed under the terms of the GNU General Public License v2
# $

# @ECLASS-VARIABLE: K_SABKERNEL_NAME
# @DESCRIPTION:
# The kernel name used by the ebuild, it should be the ending ${PN} part
# for example, of linux-sabayon it is "${PN/${PN/-*}-}" (sabayon)
K_SABKERNEL_NAME="${K_SABKERNEL_NAME:-${PN/${PN/-*}-}}"

# @ECLASS-VARIABLE: K_SABKERNEL_SELF_TARBALL_NAME
# @DESCRIPTION:
# If the main kernel sources tarball is generated in-house and available
# on the "sabayon" mirror, set this variable to the extension name (see example
# below). This will disable ALL the extra/local patches (since they have to
# be applied inside the tarball). Moreover, K_SABKERNEL_NAME,
# K_KERNEL_PATCH_VER will be ignored.
# Example:
#   K_SABKERNEL_SELF_TARBALL_NAME="sabayon"
#   This would generate:
#   SRC_URI="mirror://sabayon/sys-kernel/linux-${PV}+sabayon.tar.${K_TARBALL_EXT}"
K_SABKERNEL_SELF_TARBALL_NAME="${K_SABKERNEL_SELF_TARBALL_NAME:-}"

# @ECLASS-VARIABLE: K_SABKERNEL_PATCH_UPSTREAM_TARBALL
# @DESCRIPTION:
# If set to 1, the ebuild will fetch the upstream kernel tarball and
# apply the Sabayon patch against it. This strategy avoids the need of
# creating complete kernel source tarballs. The default value is 0.
K_SABKERNEL_PATCH_UPSTREAM_TARBALL="${K_SABKERNEL_PATCH_UPSTREAM_TARBALL:-0}"

# @ECLASS-VARIABLE: K_SABKERNEL_FORCE_SUBLEVEL
# @DESCRIPTION:
# Force the rewrite of SUBLEVEL in kernel sources Makefile
K_SABKERNEL_FORCE_SUBLEVEL="${K_SABKERNEL_FORCE_SUBLEVEL:-}"

# @ECLASS-VARIABLE: K_SABKERNEL_RESET_EXTRAVERSION
# @DESCRIPTION:
# Force the rewrite of EXTRAVERSION in kernel sources Makefile (setting it to "")
K_SABKERNEL_RESET_EXTRAVERSION="${K_SABKERNEL_RESET_EXTRAVERSION:-}"

# @ECLASS-VARIABLE: K_SABKERNEL_LONGTERM
# @DESCRIPTION:
# Consider Kernel stable patchset as longterm (changing URL)
K_SABKERNEL_LONGTERM="${K_SABKERNEL_LONGTERM:-}"

# @ECLASS-VARIABLE: K_KERNEL_SOURCES_PKG
# @DESCRIPTION:
# The kernel sources package used to build this kernel binary
K_KERNEL_SOURCES_PKG="${K_KERNEL_SOURCES_PKG:-${CATEGORY}/${PN/*-}-sources-${PVR}}"

# @ECLASS-VARIABLE: K_KERNEL_PATCH_VER
# @DESCRIPTION:
# If set to "3" for example, it applies the upstream kernel
# patch corresponding to patch-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}.3.${K_TARBALL_EXT}
# @TODO: deprecate and remove once 2.6.x kernels are retired
K_KERNEL_PATCH_VER="${K_KERNEL_PATCH_VER:-}"

# @ECLASS-VARIABLE: K_KERNEL_PATCH_HOTFIXES
# @DESCRIPTION:
# If there is the need to quickly apply patches to the kernel
# without bumping the kernel patch tarball (for eg. in case
# of just released security fixes), set this variable in your ebuild
# pointing to space separated list of patch paths.
K_KERNEL_PATCH_HOTFIXES="${K_KERNEL_PATCH_HOTFIXES:-}"

# @ECLASS-VARIABLE: K_KERNEL_DISABLE_PR_EXTRAVERSION
# @DESCRIPTION:
# Set this to "1" if you want to tell kernel-2 eclass to
# not use ${PR} in kernel EXTRAVERSION (K_NOUSEPR). Otherwise, set
# this to "0" to not set K_NOUSEPR at all.
K_KERNEL_DISABLE_PR_EXTRAVERSION="${K_KERNEL_DISABLE_PR_EXTRAVERSION:-1}"

# @ECLASS-VARIABLE: K_KERNEL_SLOT_USEPVR
# @DESCRIPTION:
# Set this to "1" if you want to use ${PVR} in SLOT variable, instead of ${PV}
# sys-kernel/linux-vserver (vserver-sources) require this. This won't work for
# firmware pkgs.
K_KERNEL_SLOT_USEPVR="${K_KERNEL_SLOT_USEPVR:-0}"

# @ECLASS-VARIABLE: K_KERNEL_NEW_VERSIONING
# @DESCRIPTION:
# Set this to "1" if your kernel ebuild uses the new Linux kernel upstream
# versioning and ${PV} contains the stable revision, like 3.7.1.
# In the example above, this makes the SLOT variable contain only "3.7".
# The sublevel version can be forced using K_SABKERNEL_FORCE_SUBLEVEL
K_KERNEL_NEW_VERSIONING="${K_KERNEL_NEW_VERSIONING:-0}"

# @ECLASS-VARIABLE: K_KERNEL_IMAGE_NAME
# @DESCRIPTION:
# Set this to a custom kernel image make target if the default does not
# fit your needs. This value if set, is passed to genkernel through the
# --kernel-target= flag.
K_KERNEL_IMAGE_NAME="${K_KERNEL_IMAGE_NAME:-}"

# @ECLASS-VARIABLE: K_KERNEL_LTS
# @DESCRIPTION:
# Set this to 1 to mark the kernel as Long Term Stable. "virtual/linux-binary-lts"
# shall be appended to ${PROVIDE}.
K_KERNEL_LTS="${K_KERNEL_LTS:-}"

# @ECLASS-VARIABLE: K_KERNEL_IMAGE_PATH
# @DESCRIPTION:
# Set this to a custom relative kernel image path to override the default
# one. This value if set, is passed to genkernel through the
# --kernel-binary= flag.
K_KERNEL_IMAGE_PATH="${K_KERNEL_IMAGE_PATH:-}"

# @ECLASS-VARIABLE: K_SABKERNEL_FIRMWARE
# @DESCRIPTION:
# Set this to "1" if your ebuild is a kernel firmware package
K_FIRMWARE_PACKAGE="${K_FIRMWARE_PACKAGE:-}"

# @ECLASS-VARIABLE: K_ONLY_SOURCES
# @DESCRIPTION:
# For every kernel binary package, there is a kernel source package associated
# if your ebuild is one of them, set this to "1"
K_ONLY_SOURCES="${K_ONLY_SOURCES:-}"

# @ECLASS-VARIABLE: K_REQUIRED_LINUX_FIRMWARE_VER
# @DESCRIPTION:
# Minimum required version of sys-kernel/linux-formware package, if any
K_REQUIRED_LINUX_FIRMWARE_VER="${K_REQUIRED_LINUX_FIRMWARE_VER:-}"

# @ECLASS-VARIABLE: K_WORKAROUND_SOURCES_COLLISION
# @DESCRIPTION:
# For kernel binary packages, Workaround file collisions with kernel
# sources already providing certain files (like Makefile). Used
# by linux-openvz and linux-vserver
K_WORKAROUND_SOURCES_COLLISION="${K_WORKAROUND_SOURCES_COLLISION:-}"

# @ECLASS-VARIABLE: K_WORKAROUND_USE_REAL_EXTRAVERSION
# @DESCRIPTION:
# Some kernel sources are shipped with their own EXTRAVERSION and
# we're kindly asked to not touch it, if this is your case, set
# this variable and depmod will work correctly.
K_WORKAROUND_USE_REAL_EXTRAVERSION="${K_WORKAROUND_USE_REAL_EXTRAVERSION:-}"

# @ECLASS-VARIABLE: K_SABKERNEL_ZFS
# @DESCRIPTION:
# If set, this kernel features ZFS.
K_SABKERNEL_ZFS="${K_SABKERNEL_ZFS:-}"

# @ECLASS-VARIABLE: K_GENKERNEL_ARGS
# @DESCRIPTION:
# Provide extra genkernel arguments using K_GENKERNEL_ARGS
K_GENKERNEL_ARGS="${K_GENKERNEL_ARGS:-}"

# @ECLASS-VARIABLE: K_MKIMAGE_RAMDISK_ADDRESS
# @DESCRIPTION:
# [ARM ONLY] Provide the ramdisk load address to be used with mkimage
K_MKIMAGE_RAMDISK_ADDRESS="${K_MKIMAGE_RAMDISK_ADDRESS:-}"

# @ECLASS-VARIABLE: K_MKIMAGE_RAMDISK_ENTRYPOINT
# @DESCRIPTION:
# [ARM ONLY] Provide the ramdisk entry point address to be used with mkimage
K_MKIMAGE_RAMDISK_ENTRYPOINT="${K_MKIMAGE_RAMDISK_ENTRYPOINT:-}"

# @ECLASS-VARIABLE: K_MKIMAGE_WRAP_INITRAMFS
# @DESCRIPTION:
# [ARM ONLY] Execute mkimage against the generated initramfs Default is yes ("1").
K_MKIMAGE_WRAP_INITRAMFS="${K_MKIMAGE_WRAP_INITRAMFS:-1}"

# @ECLASS-VARIABLE: K_MKIMAGE_KERNEL_ADDRESS
# @DESCRIPTION:
# [ARM ONLY] Provide the kernel load address to be used with mkimage
K_MKIMAGE_KERNEL_ADDRESS="${K_MKIMAGE_KERNEL_ADDRESS:-}"

KERN_INITRAMFS_SEARCH_NAME="${KERN_INITRAMFS_SEARCH_NAME:-initramfs-genkernel*${K_SABKERNEL_NAME}}"

# Disable deblobbing feature
K_DEBLOB_AVAILABLE=0
ETYPE="sources"
K_TARBALL_EXT="${K_TARBALL_EXT:-xz}"

inherit versionator
if [ "${K_KERNEL_NEW_VERSIONING}" = "1" ]; then
	CKV="$(get_version_component_range 1-2)"
fi

inherit eutils multilib kernel-2 sabayon-artwork mount-boot linux-info

# from kernel-2 eclass
detect_version
detect_arch

DESCRIPTION="Sabayon Linux kernel functions and phases"


K_LONGTERM_URL_STR=""
if [ -n "${K_SABKERNEL_LONGTERM}" ]; then
	K_LONGTERM_URL_STR="/longterm/v${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}"
fi

## kernel-2 eclass settings
if [ "${K_SABKERNEL_PATCH_UPSTREAM_TARBALL}" = "1" ]; then
	_patch_name="$(get_version_component_range 1-2)-${K_SABKERNEL_SELF_TARBALL_NAME}-${PVR}.patch.xz"
	SRC_URI="${KERNEL_URI}
		mirror://sabayon/${CATEGORY}/${_patch_name}
	"
	UNIPATCH_LIST="${UNIPATCH_LIST} ${DISTDIR}/${_patch_name}"
	unset _patch_name
elif [ -n "${K_SABKERNEL_SELF_TARBALL_NAME}" ]; then
	SRC_URI="mirror://sabayon/${CATEGORY}/linux-${PVR}+${K_SABKERNEL_SELF_TARBALL_NAME}.tar.${K_TARBALL_EXT}"
else
	SRC_URI="${KERNEL_URI}"
fi

if [ -z "${K_SABKERNEL_SELF_TARBALL_NAME}" ]; then
	if [ -n "${K_KERNEL_PATCH_VER}" ]; then
		K_PATCH_NAME="patch-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}.${K_KERNEL_PATCH_VER}.${K_TARBALL_EXT}"
		SRC_URI="${SRC_URI}
			mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}${K_LONGTERM_URL_STR}/${K_PATCH_NAME}"
		UNIPATCH_LIST="${DISTDIR}/${K_PATCH_NAME}
			${UNIPATCH_LIST}"
	fi
fi
if [ -n "${K_KERNEL_PATCH_HOTFIXES}" ]; then
	UNIPATCH_LIST="${UNIPATCH_LIST} ${K_KERNEL_PATCH_HOTFIXES}"
fi

_get_real_kv_full() {
	if [[ "${KV_MAJOR}${KV_MINOR}" -eq 26 ]]; then
		echo "${ORIGINAL_KV_FULL}"
	elif [[ "${OKV/.*}" = "3" ]]; then
		# Linux 3.x support, KV_FULL is set to: 3.0-sabayon
		# need to add another final .0 to the version part
		echo "${ORIGINAL_KV_FULL/-/.0-}"
	else
		echo "${ORIGINAL_KV_FULL}"
	fi
}

# replace "linux" with K_SABKERNEL_NAME, usually replaces
# "linux" with "sabayon" or "server" or "openvz"
KV_FULL="${KV_FULL/${PN/-*}/${K_SABKERNEL_NAME}}"
EXTRAVERSION="${EXTRAVERSION/${PN/-*}/${K_SABKERNEL_NAME}}"
# drop -rX if exists
if [[ -n "${PR//r0}" ]] && [[ "${K_KERNEL_DISABLE_PR_EXTRAVERSION}" = "1" ]] \
		&& [[ -z "${K_NOSETEXTRAVERSION}" ]]; then
	EXTRAVERSION="${EXTRAVERSION%-r*}"
	KV_FULL="${KV_FULL%-r*}"
	KV="${KV%-r*}"
fi
# rewrite it
ORIGINAL_KV_FULL="${KV_FULL}"
KV_FULL="$(_get_real_kv_full)"

# Starting from linux-3.0, we still have to install
# sources stuff into /usr/src/linux-3.0.0-sabayon (example)
# where the last part must always match uname -r
# otherwise kernel-switcher (and RELEASE_LEVEL file)
# will complain badly
KV_OUT_DIR="/usr/src/linux-${KV_FULL}"
S="${WORKDIR}/linux-${KV_FULL}"


if [ -n "${K_FIRMWARE_PACKAGE}" ]; then
	SLOT="0"
elif [ "${K_KERNEL_SLOT_USEPVR}" = "1" ]; then
	SLOT="${PVR}"
elif [ "${K_KERNEL_NEW_VERSIONING}" = "1" ]; then
	SLOT="$(get_version_component_range 1-2)"
else
	SLOT="${PV}"
fi

_is_kernel_binary() {
	if [ -z "${K_ONLY_SOURCES}" ] && [ -z "${K_FIRMWARE_PACKAGE}" ]; then
		# yes it is
		return 0
	else
		# no it isn't
		return 1
	fi
}

_is_kernel_lts() {
	local _ver="$(get_version_component_range 1-2)"
	[ "${_ver}" = "3.0" ] && return 0
	[ "${_ver}" = "3.2" ] && return 0
	[ "${_ver}" = "3.4" ] && return 0
	[ "${_ver}" = "3.10" ] && return 0
	[ "${_ver}" = "3.12" ] && return 0
	[ "${_ver}" = "3.14" ] && return 0
	return 1
}

# provide extra virtual pkg
if _is_kernel_binary; then
	PROVIDE="virtual/linux-binary"
# LTS support
	if [ "${K_KERNEL_LTS}" = "1" ] || _is_kernel_lts; then
		PROVIDE+=" virtual/linux-binary-lts"
	fi
fi

if [ -n "${K_SABKERNEL_SELF_TARBALL_NAME}" ]; then
	HOMEPAGE="https://github.com/Sabayon/kernel"
else
	HOMEPAGE="http://www.sabayon.org"
fi

# Returns success if _set_config_file_vars was called.
_is_config_file_set() {
	[[ ${_config_file_set} = 1 ]]
}

# Returns the arm kernel config file extension for the current subarch
_get_arm_subarch() {
	local target="${CTARGET:-${CHOST}}"
	local arm_arch=${target%%-*}
	if [[ ${arm_arch} == armv7? ]]; then
		echo "armv7"
	elif [[ ${arm_arch} == armv6? ]]; then
		echo "armv6"
	elif [[ ${arm_arch} == armv5? ]]; then
		echo "armv5"
	fi
}

_get_arch() {
	if use arm; then
		_get_arm_subarch
	elif use amd64; then
		echo "amd64"
	elif use x86; then
		echo "x86"
	fi
}

_set_config_file_vars() {
	# Setup kernel configuration file name
	local pvr="${PVR}"
	local pv="${PV}"
	if [ "${K_KERNEL_NEW_VERSIONING}" = "1" ]; then
		pvr="$(get_version_component_range 1-2)"
		pv="${pvr}"
		if [ "${PR}" != "r0" ]; then
			pvr+="-${PR}"
		fi
	fi

	K_SABKERNEL_CONFIG_FILES=()
	K_SABKERNEL_CONFIG_FILES+=( "${K_SABKERNEL_NAME}-${pvr}-$(_get_arch).config" )
	K_SABKERNEL_CONFIG_FILES+=( "${K_SABKERNEL_NAME}-${pv}-$(_get_arch).config" )
	K_SABKERNEL_CONFIG_FILES+=( "${K_SABKERNEL_NAME}-$(_get_arch).config" )

	_config_file_set=1
}

if [ -n "${K_ONLY_SOURCES}" ] || [ -n "${K_FIRMWARE_PACKAGE}" ]; then
	IUSE="${IUSE}"
	DEPEND="sys-apps/sed"
	RDEPEND="${RDEPEND}"
else
	IUSE="dmraid dracut iscsi luks lvm mdadm plymouth splash"
	if [ -n "${K_SABKERNEL_ZFS}" ]; then
		IUSE="${IUSE} zfs"
	fi
	DEPEND="app-arch/xz-utils
		sys-apps/sed
		sys-devel/autoconf
		sys-devel/make
		|| ( >=sys-kernel/genkernel-next-5 >=sys-kernel/genkernel-3.4.45-r2 )
		arm? ( dev-embedded/u-boot-tools )
		amd64? ( sys-apps/v86d )
		x86? ( sys-apps/v86d )
		splash? ( x11-themes/sabayon-artwork-core )
		lvm? ( sys-fs/lvm2 sys-block/thin-provisioning-tools )
		plymouth? (
			|| ( >=sys-kernel/genkernel-next-5 >=sys-kernel/genkernel-5 )
			sys-boot/plymouth
		)
		dracut? ( sys-apps/v86d sys-kernel/dracut )"
	RDEPEND="sys-apps/sed
		sys-kernel/linux-firmware"
	if [ -n "${K_REQUIRED_LINUX_FIRMWARE_VER}" ]; then
		RDEPEND+=" >=sys-kernel/linux-firmware-${K_REQUIRED_LINUX_FIRMWARE_VER}"
	fi
fi

# internal function
#
# FUNCTION: _update_depmod
# @USAGE: _update_depmod <-r depmod>
# DESCRIPTION:
# It updates the modules.dep file for the current kernel.
# This is more or less the same of linux-mod update_depmod, with the
# exception of accepting parameter which is passed to depmod -r switch
_update_depmod() {

        # if we haven't determined the version yet, we need too.
        get_version;

	ebegin "Updating module dependencies for ${KV_FULL}"
	if [ -r "${KV_OUT_DIR}"/System.map ]; then
		depmod -ae -F "${KV_OUT_DIR}"/System.map -b "${ROOT}" -r "${1}"
		eend $?
	else
		ewarn
		ewarn "${KV_OUT_DIR}/System.map not found."
		ewarn "You must manually update the kernel module dependencies using depmod."
		eend 1
		ewarn
	fi
}

sabayon-kernel_pkg_setup() {
	if [ -n "${K_FIRMWARE_PACKAGE}" ]; then
		einfo "Preparing kernel firmwares"
	else
		einfo "Preparing kernel and its modules"
	fi
}

sabayon-kernel_src_unpack() {
	local okv="${OKV}"
	if [ -n "${K_SABKERNEL_SELF_TARBALL_NAME}" ] && [ "${K_SABKERNEL_PATCH_UPSTREAM_TARBALL}" != "1" ]; then
		OKV="${PVR}+${K_SABKERNEL_SELF_TARBALL_NAME}"
	fi
	if [ "${K_KERNEL_NEW_VERSIONING}" = "1" ]; then
		# workaround for kernel-2's universal_unpack assumptions
		UNIPATCH_LIST_DEFAULT= KV_MAJOR=0 kernel-2_src_unpack
	else
		kernel-2_src_unpack
	fi
	if [ -n "${K_SABKERNEL_FORCE_SUBLEVEL}" ]; then
		# patch out Makefile with proper sublevel
		sed -i "s:^SUBLEVEL = .*:SUBLEVEL = ${K_SABKERNEL_FORCE_SUBLEVEL}:" \
			"${S}/Makefile" || die
	fi
	if [ -n "${K_SABKERNEL_RESET_EXTRAVERSION}" ]; then
		sed -i "s:^EXTRAVERSION =.*:EXTRAVERSION = :" "${S}/Makefile" || die
		# some sources could have multiple append-based EXTRAVERSIONs
		sed -i "s/^EXTRAVERSION :=.*//" "${S}/Makefile" || die
	fi
	OKV="${okv}"

	# Let's handle EAPIs 0 and 1...
	case ${EAPI:-0} in
		0|1) sabayon-kernel_src_prepare ;;
	esac
}

sabayon-kernel_src_prepare() {
	_set_config_file_vars
}

sabayon-kernel_src_compile() {
	if [ -n "${K_FIRMWARE_PACKAGE}" ]; then
		_firmwares_src_compile
	elif [ -n "${K_ONLY_SOURCES}" ]; then
		kernel-2_src_compile
	else
		_kernel_src_compile
	fi
}

_firmwares_src_compile() {
	einfo "Starting to compile firmwares..."
	_kernel_copy_config "${S}/.config"
	cd "${S}" || die "cannot find source dir"

	export LDFLAGS=""
	OLDARCH="${ARCH}"
	unset ARCH
	emake firmware || die "cannot compile firmwares"
	ARCH="${OLDARCH}"
}

_kernel_copy_config() {
	_is_config_file_set \
		|| die "Kernel configuration file not set. Was sabayon-kernel_src_prepare() called?"

	local base_path="${DISTDIR}"
	if [ -n "${K_SABKERNEL_SELF_TARBALL_NAME}" ]; then
		base_path="${S}/sabayon/config"
	fi

	local found= cfg=
	for cfg in "${K_SABKERNEL_CONFIG_FILES[@]}"; do
		cfg="${base_path}/${cfg}"
		if [ -f "${cfg}" ]; then
			cp "${cfg}" "${1}" || die "cannot copy kernel config ${cfg} -> ${1}"
			elog "Using kernel config: ${cfg}"
			found=1
			break
		fi
	done
	[[ -z "${found}" ]] && die "cannot find kernel configs among: ${K_SABKERNEL_CONFIG_FILES[*]}"
}

_kernel_src_compile() {
	# disable sandbox
	export SANDBOX_ON=0

	# needed anyway, even if grub use flag is not used here
	if use amd64 || use x86; then
		mkdir -p "${WORKDIR}"/boot/grub
	else
		mkdir -p "${WORKDIR}"/boot
	fi

	einfo "Starting to compile kernel..."
	_kernel_copy_config "${WORKDIR}"/config

	# do some cleanup
	rm -rf "${WORKDIR}"/lib
	rm -rf "${WORKDIR}"/cache
	rm -rf "${S}"/temp

	# creating workdirs
	# some kernels fail with make 3.82 if firmware dir is not created
	mkdir "${WORKDIR}"/lib/lib/firmware -p
	mkdir "${WORKDIR}"/cache
	mkdir "${S}"/temp

	cd "${S}" || die
	local GKARGS=()
	GKARGS+=( "--no-save-config" "--e2fsprogs" "--udev" )
	use splash && GKARGS+=( "--splash=sabayon" )
	use plymouth && GKARGS+=( "--plymouth" "--plymouth-theme=${PLYMOUTH_THEME}" )
	use dmraid && GKARGS+=( "--dmraid" )
	use iscsi && GKARGS+=( "--iscsi" )
	use mdadm && GKARGS+=( "--mdadm" )
	use luks && GKARGS+=( "--luks" )
	use lvm && GKARGS+=( "--lvm" )
	if [ -n "${K_SABKERNEL_ZFS}" ]; then
		use zfs && GKARGS+=( "--zfs" )
	fi

	export DEFAULT_KERNEL_SOURCE="${S}"
	export CMD_KERNEL_DIR="${S}"
	for opt in ${MAKEOPTS}; do
		if [ "${opt:0:2}" = "-j" ]; then
			mkopts="${opt}"
			break
		fi
	done
	[ -z "${mkopts}" ] && mkopts="-j3"

	if [ -n "${K_KERNEL_IMAGE_NAME}" ]; then
		GKARGS+=( "--kernel-target=${K_KERNEL_IMAGE_NAME}" )
	elif use arm; then
		# backward compat + provide sane defaults.
		GKARGS+=( "--kernel-target=uImage" )
	fi
	if [ -n "${K_KERNEL_IMAGE_PATH}" ]; then
		GKARGS+=( "--kernel-binary=${K_KERNEL_IMAGE_PATH}" )
	elif use arm; then
		# backward compat + provide sane defaults.
		GKARGS+=( "--kernel-binary=arch/arm/boot/uImage" )
	fi

	# Workaround bug in splash_geninitramfs corrupting the initramfs
	# if xz compression is used (newer genkernel >3.4.24)
	local support_comp=$(genkernel --help | grep compress-initramfs-type)
	if [ -n "${support_comp}" ]; then
		GKARGS+=( "--compress-initramfs-type=gzip" )
	fi

	# Use --disklabel if genkernel supports it
	local support_disklabel=$(genkernel --help | grep -- --disklabel)
	if [ -n "${support_disklabel}" ]; then
		GKARGS+=( "--disklabel" )
	fi

	if [ -n "${K_MKIMAGE_KERNEL_ADDRESS}" ]; then
		export LOADADDR="${K_MKIMAGE_KERNEL_ADDRESS}"
	fi
	OLDARCH="${ARCH}"
	unset ARCH
	unset LDFLAGS
	DEFAULT_KERNEL_SOURCE="${S}" CMD_KERNEL_DIR="${S}" genkernel "${GKARGS[@]}" ${K_GENKERNEL_ARGS} \
		--kerneldir="${S}" \
		--kernel-config="${WORKDIR}"/config \
		--cachedir="${WORKDIR}"/cache \
		--makeopts="${mkopts}" \
		--tempdir="${S}"/temp \
		--logfile="${WORKDIR}"/genkernel.log \
		--bootdir="${WORKDIR}"/boot \
		--mountboot \
		--module-prefix="${WORKDIR}"/lib \
		all || die "genkernel failed"

	if [ -n "${K_MKIMAGE_KERNEL_ADDRESS}" ]; then
		unset LOADADDR
	fi

	ARCH=${OLDARCH}
}

_setup_mkimage_ramdisk() {
	local initramfs=$(ls "${WORKDIR}"/boot/${KERN_INITRAMFS_SEARCH_NAME}* 2> /dev/null)
	if [ ! -e "${initramfs}" ] || [ ! -f "${initramfs}" ]; then
		ewarn "No initramfs at ${initramfs}, cannot run mkimage on it!"
	elif [ "${K_MKIMAGE_WRAP_INITRAMFS}" = "1" ]; then
		einfo "Setting up u-boot initramfs for: ${initramfs}"
		mkimage -A arm -O linux -T ramdisk -C none -a \
			"${K_MKIMAGE_RAMDISK_ADDRESS}" \
			-e "${K_MKIMAGE_RAMDISK_ENTRYPOINT}" -d "${initramfs}" \
			"${initramfs}.u-boot" || return 1
		mv "${initramfs}.u-boot" "${initramfs}" || return 1
	else
		einfo "mkimage won't be called for: ${initramfs}"
	fi
	return 0
}

sabayon-kernel_src_install() {
	if [ -n "${K_FIRMWARE_PACKAGE}" ]; then
		_firmwares_src_install
	elif [ -n "${K_ONLY_SOURCES}" ]; then
		_kernel_sources_src_install
	else
		_kernel_src_install
	fi
	# File collisions between slots, debug stuff
	# not really needed for a kernel
	rm -rf "${D}/usr/lib/debug"
}

_firmwares_src_install() {
	dodir /lib/firmware
	keepdir /lib/firmware
	cd "${S}" || die
	emake INSTALL_FW_PATH="${D}/lib/firmware" firmware_install || die "cannot install firmwares"
}

_kernel_sources_src_install() {
	_kernel_copy_config ".config"
	kernel-2_src_install
	cd "${D}${KV_OUT_DIR}" || die
	local oldarch="${ARCH}"
	unset ARCH
	if ! use sources_standalone; then
		make modules_prepare || die "failed to run modules_prepare"
		rm .config || die "cannot remove .config"
		rm Makefile || die "cannot remove Makefile"
		rm -f include/linux/version.h
		rm -f include/generated/uapi/linux/version.h
	fi
	ARCH="${oldarch}"
}

_kernel_src_install() {
	if use arm; then
		_setup_mkimage_ramdisk || die "cannot setup mkimage"
	fi

	dodir "${KV_OUT_DIR}"
	insinto "${KV_OUT_DIR}"

	_kernel_copy_config ".config"
	doins ".config" || die "cannot copy kernel config"
	doins Makefile || die "cannot copy Makefile"
	doins Module.symvers || die "cannot copy Module.symvers"
	doins System.map || die "cannot copy System.map"

	# NOTE: this is a workaround caused by linux-info.eclass not
	# being ported to EAPI=2 yet
	local version_h_dir="include/linux"
	local version_h_dir2="include/generated/uapi/linux"
	local version_h=
	local version_h_src=
	for ver_dir in "${version_h_dir}" "${version_h_dir2}"; do
		version_h="${ROOT}${KV_OUT_DIR/\//}/${ver_dir}/version.h"
		if [ -f "${version_h}" ]; then
			einfo "Discarding previously installed version.h to avoid collisions"
			addwrite "${version_h}"
			rm -f "${version_h}"
		fi

		# Include include/linux/version.h to make Portage happy
		version_h_src="${S}/${ver_dir}/version.h"
		if [ -f "${version_h_src}" ]; then
			dodir "${KV_OUT_DIR}/${ver_dir}"
			insinto "${KV_OUT_DIR}/${ver_dir}"
			doins "${version_h_src}" || die "cannot copy version.h"
		fi
	done

	insinto "/boot"
	doins "${WORKDIR}"/boot/* || die "cannot copy /boot over"
	cp -Rp "${WORKDIR}"/lib/* "${D}/" || die "cannot copy /lib over"

	# Install dtbs if found
	if use arm; then
		local dtb_dir="/lib/dts/${KV_FULL}"
		elog "Installing .dtbs (if any) into ${dtb_dir}"
		insinto "${dtb_dir}"
		local dtb=
		for dtb in "${S}/arch/arm/boot/dts"/*.dtb; do
			if [ -f "${dtb}" ]; then
				elog "Installing dtb: ${dtb}"
				doins "${dtb}"
			fi
		done
	fi

	# This doesn't always work because KV_FULL (when K_NOSETEXTRAVERSION=1) doesn't
	# reflect the real value used in Makefile
	#dosym "../../..${KV_OUT_DIR}" "/lib/modules/${KV_FULL}/source" || die "cannot install source symlink"
	#dosym "../../..${KV_OUT_DIR}" "/lib/modules/${KV_FULL}/build" || die "cannot install build symlink"
	cd "${D}"/lib/modules/* || die "cannot enter /lib/modules directory, more than one element?"
	# cleanup previous
	rm -f build source || die
	# create sane symlinks
	ln -sf "../../..${KV_OUT_DIR}" source || die "cannot create source symlink"
	ln -sf "../../..${KV_OUT_DIR}" build || die "cannot create build symlink"
	cd "${S}" || die

	# drop ${D}/lib/firmware, virtual/linux-firmwares provides it
	rm -rf "${D}/lib/firmware"

	if [ -n "${K_WORKAROUND_SOURCES_COLLISION}" ]; then
		# Fixing up Makefile collision if already installed by
		# openvz-sources
		einfo "Workarounding source package collisions"
		make_file="${KV_OUT_DIR/\//}/Makefile"
		einfo "Makefile: ${make_file}"
		if [ -f "${ROOT}/${make_file}" ]; then
			elog "Removing ${D}/${make_file}"
			rm -f "${D}/${make_file}"
		fi
	fi

	# Install kernel configuration information
	# useful for Entropy kernel-switcher
	# release level is enough for now
	base_dir="/etc/kernels/${P}"
	dodir "${base_dir}"
	insinto "${base_dir}"
	echo "${KV_FULL}" > "RELEASE_LEVEL"
	doins "RELEASE_LEVEL"
	einfo "Installing ${base_dir}/RELEASE_LEVEL file: ${KV_FULL}"

	use dracut && \
		_dracut_initramfs_create "${KV_FULL}"
}

sabayon-kernel_pkg_preinst() {
	if _is_kernel_binary; then
		mount-boot_pkg_preinst
	fi
}
sabayon-kernel_grub2_mkconfig() {
	if [ -x "${ROOT}usr/sbin/grub2-mkconfig" ]; then
		# Grub 2.00
		"${ROOT}usr/sbin/grub2-mkconfig" -o "${ROOT}boot/grub/grub.cfg"
	elif [ -x "${ROOT}sbin/grub-mkconfig" ]; then
		# Grub 1.99
		"${ROOT}sbin/grub-mkdevicemap" --device-map="${ROOT}boot/grub/device.map"
		"${ROOT}sbin/grub-mkconfig" -o "${ROOT}boot/grub/grub.cfg"
	else
		echo
		ewarn "Attention, Grub2 is not installed !!!"
		ewarn "Grub2 bootloader configuration won't be updated"
		echo
	fi
}

_get_real_extraversion() {
	make_file="${ROOT}${KV_OUT_DIR}/Makefile"
	local extraver=$(grep -r "^EXTRAVERSION =" "${make_file}" | cut -d "=" -f 2 | head -n 1)
	local trimmed=${extraver%% }
	echo ${trimmed## }
}

_get_release_level() {
	if [[ -n "${K_WORKAROUND_USE_REAL_EXTRAVERSION}" ]]; then
		echo "${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}$(_get_real_extraversion)"
	elif [[ "${KV_MAJOR}${KV_MINOR}" -eq 26 ]]; then
		echo "${KV_FULL}"
	elif [[ "${OKV/.*}" = "3" ]] && [[ "${KV_PATCH}" = "0" ]]; then
		# Linux 3.x support, KV_FULL is set to: 3.0-sabayon
		# need to add another final .0 to the version part
		echo "${KV_FULL/-/.0-}"
	else
		echo "${KV_FULL}"
	fi
}

sabayon-kernel_uimage_config() {
	# Two cases here:
	# 1. /boot/uImage symlink is broken (pkg_postrm)
	# 2. /boot/uImage symlink doesn't exist (pkg_postinst)

	if ! has_version app-admin/eselect-uimage; then
		ewarn "app-admin/eselect-uimage not installed"
		ewarn "If you are using this tool, please install it"
		return 0
	fi

	local uimage_file=$(eselect uimage show --quiet 2> /dev/null)
	if [ -z "${uimage_file}" ]; then
		# pick the first listed, sorry!
		local eselect_list=$(eselect uimage list --quiet 2> /dev/null)
		if [ -n "${eselect_list}" ]; then
			eselect uimage set 1
		else
			echo
			ewarn "No more kernels available, you won't be able to boot"
			echo
		fi
	else
		echo
		elog "If you use eselect-bzimage, you are currently booting with kernel:"
		elog "${uimage_file}"
		elog
		elog "Use 'eselect uimage' in order to switch between the available ones"
		echo
	fi
}

sabayon-kernel_bzimage_config() {
	# Two cases here:
	# 1. /boot/bzImage symlink is broken (pkg_postrm)
	# 2. /boot/bzImage symlink doesn't exist (pkg_postinst)
	local kern_arch
	use x86 && kern_arch="x86"
	use amd64 && kern_arch="x86_64"

	if ! has_version app-admin/eselect-bzimage; then
		ewarn "app-admin/eselect-bzimage not installed"
		ewarn "If you are using this tool, please install it"
		return 0
	fi

	local bzimage_file=$(eselect bzimage show --quiet 2> /dev/null)
	if [ -z "${bzimage_file}" ]; then
		# try to pic what's being installed
		local eselect_list=$(eselect bzimage list --quiet 2> /dev/null)
		if [ -n "${eselect_list}" ]; then
			eselect bzimage set "kernel-genkernel-${kern_arch}-${KV_FULL}"
			if [ "${?}" != "0" ]; then
				# pick the first available, sorry!
				echo
				eselect bzimage set 1
				ewarn "Unable to select the right kernel, falling back"
				ewarn "to the first available entry. You have been warned"
				echo
			fi
		else
			echo
			ewarn "No more kernels available, you might not be able to boot"
			echo
		fi
	else
		echo
		ewarn "You are currently booting with kernel:"
		ewarn "${bzimage_file}"
		ewarn
		ewarn "Use 'eselect bzimage' in order to switch between the available ones"
		echo
	fi
}

_dracut_initramfs_create() {
	local kver="${1}"

	elog "Creating dracut initramfs for ${kver}"
	addpredict /etc/ld.so.cache~
	dracut -q -N -f --kver="${kver}" "${D}/boot/initramfs-dracut-${kver}"
}

sabayon-kernel_pkg_postinst() {
	if _is_kernel_binary; then
		fstab_file="${ROOT}etc/fstab"
		einfo "Removing extents option for ext4 drives from ${fstab_file}"
		# Remove "extents" from /etc/fstab
		if [ -f "${fstab_file}" ]; then
			sed -i '/ext4/ s/extents//g' "${fstab_file}"
		fi

		# Update kernel initramfs to match user customizations
		use splash && update_sabayon_kernel_initramfs_splash

		# Add kernel to grub.conf
		if use amd64 || use x86; then
			if use amd64; then
				local kern_arch="x86_64"
			else
				local kern_arch="x86"
			fi
			# grub-legacy
			if [ -x "${ROOT}usr/sbin/grub-handler" ]; then
				"${ROOT}usr/sbin/grub-handler" add \
					"/boot/kernel-genkernel-${kern_arch}-${KV_FULL}" \
					"/boot/initramfs-genkernel-${kern_arch}-${KV_FULL}"
			fi

			sabayon-kernel_grub2_mkconfig
		fi

		# Setup newly installed kernel on ARM
		if use arm; then
			sabayon-kernel_uimage_config
		fi
		# Setup newly installed kernel on x86/amd64
		# This is quite handy for static grub1/grub2
		# configurations (like on Amazon EC2)
		if use x86 || use amd64; then
			sabayon-kernel_bzimage_config
		fi

		kernel-2_pkg_postinst
		local depmod_r=$(_get_release_level)
		_update_depmod "${depmod_r}"

		elog "Please report kernel bugs at:"
		elog "http://bugs.sabayon.org"

		elog "The source code of this kernel is located at"
		elog "=${K_KERNEL_SOURCES_PKG}."
		elog "Sabayon Linux recommends that portage users install"
		elog "${K_KERNEL_SOURCES_PKG} if you want"
		elog "to build any packages that install kernel modules"
		elog "(such as ati-drivers, nvidia-drivers, virtualbox, etc...)."
	else
		kernel-2_pkg_postinst
	fi
}

sabayon-kernel_pkg_prerm() {
	if _is_kernel_binary; then
		mount-boot_pkg_prerm
	fi
}

sabayon-kernel_pkg_postrm() {
	if _is_kernel_binary; then
		# Remove kernel from grub.conf
		if use amd64 || use x86; then
			if use amd64; then
				local kern_arch="x86_64"
			else
				local kern_arch="x86"
			fi
			if [ -x "${ROOT}usr/sbin/grub-handler" ]; then
				"${ROOT}usr/sbin/grub-handler" remove \
					"/boot/kernel-genkernel-${kern_arch}-${KV_FULL}" \
					"/boot/initramfs-genkernel-${kern_arch}-${KV_FULL}"
			fi

			sabayon-kernel_grub2_mkconfig
		fi

		# Setup newly installed kernel on ARM
		if use arm; then
			sabayon-kernel_uimage_config
		fi
		# Setup newly installed kernel on x86/amd64
		# This is quite handy for static grub1/grub2
		# configurations (like on Amazon EC2)
		if use x86 || use amd64; then
			sabayon-kernel_bzimage_config
		fi
	fi
}

# export all the available functions here
case ${EAPI:-0} in
	0|1) extra_export_funcs= ;;
	*) extra_export_funcs=src_prepare ;;
esac

EXPORT_FUNCTIONS pkg_setup src_unpack ${extra_export_funcs} \
	src_compile src_install pkg_preinst pkg_postinst pkg_prerm pkg_postrm
