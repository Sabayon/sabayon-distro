# Copyright 2004-2010 Sabayon Project
# Distributed under the terms of the GNU General Public License v2
# $

# @ECLASS-VARIABLE: K_SABPATCHES_VER
# @DESCRIPTION:
# The version of the sabayon patches tarball(s) to apply.
# A value of "5" would apply 2.6.12-5 to my-sources-2.6.12.ebuild

# @ECLASS-VARIABLE: K_SABKERNEL_NAME
# @DESCRIPTION:
# The kernel name used by the ebuild, it should be the ending ${PN} part
# for example, of linux-sabayon it is "${PN/${PN/-*}-}" (sabayon)
K_SABKERNEL_NAME="${K_SABKERNEL_NAME:-${PN/${PN/-*}-}}"

# @ECLASS-VARIABLE: K_SABKERNEL_URI_CONFIG
# @DESCRIPTION:
# Set this either to "no" or "yes" depending on the location of the
# kernel config files.  If they are inside FILESDIR (old location)
# leave this option set to "no", otherwise set this to "yes"
K_SABKERNEL_URI_CONFIG="${K_SABKERNEL_URI_CONFIG:-no}"

# @ECLASS-VARIABLE: K_SABKERNEL_SELF_TARBALL_NAME
# @DESCRIPTION:
# If the main kernel sources tarball is generated in-house and available
# on the "sabayon" mirror, set this variable to the extension name (see example
# below). This will disable ALL the extra/local patches (since they have to
# be applied inside the tarball). Moreover, K_SABKERNEL_URI_CONFIG,
# K_SABPATCHES_VER, K_SABKERNEL_NAME, K_KERNEL_PATCH_VER will be ignored.
# Example:
#   K_SABKERNEL_SELF_TARBALL_NAME="sabayon"
#   This would generate:
#   SRC_URI="mirror://sabayon/sys-kernel/linux-${PV}+sabayon.tar.bz2"
K_SABKERNEL_SELF_TARBALL_NAME="${K_SABKERNEL_SELF_TARBALL_NAME:-}"

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
# patch corresponding to patch-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}.3.bz2
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

# @ECLASS-VARIABLE: K_GENKERNEL_ARGS
# @DESCRIPTION:
# Provide extra genkernel arguments using K_GENKERNEL_ARGS
K_GENKERNEL_ARGS="${K_GENKERNEL_ARGS-}"

KERN_INITRAMFS_SEARCH_NAME="${KERN_INITRAMFS_SEARCH_NAME:-initramfs-genkernel*${K_SABKERNEL_NAME}}"

# Disable deblobbing feature
K_DEBLOB_AVAILABLE=0

inherit eutils kernel-2 sabayon-artwork mount-boot linux-info

# from kernel-2 eclass
detect_version
detect_arch

DESCRIPTION="Sabayon Linux kernel functions and phases"


K_LONGTERM_URL_STR=""
if [ -n "${K_SABKERNEL_LONGTERM}" ]; then
	K_LONGTERM_URL_STR="/longterm/v${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}"
fi

## kernel-2 eclass settings
if [ -n "${K_SABKERNEL_SELF_TARBALL_NAME}" ]; then
	SRC_URI="mirror://sabayon/${CATEGORY}/linux-${PVR}+${K_SABKERNEL_SELF_TARBALL_NAME}.tar.bz2"
elif [ -n "${K_SABPATCHES_VER}" ]; then
	UNIPATCH_STRICTORDER="yes"
	K_SABPATCHES_PKG="${PV}-${K_SABPATCHES_VER}.tar.bz2"
	UNIPATCH_LIST="${DISTFILES}/${K_SABPATCHES_PKG}"
	SRC_URI="${KERNEL_URI}
		mirror://sabayon/${CATEGORY}/linux-sabayon-patches/${K_SABPATCHES_PKG}"
else
	SRC_URI="${KERNEL_URI}"
fi

if [ -z "${K_SABKERNEL_SELF_TARBALL_NAME}" ]; then
	if [ -n "${K_KERNEL_PATCH_VER}" ]; then
		K_PATCH_NAME="patch-${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}.${K_KERNEL_PATCH_VER}.bz2"
		SRC_URI="${SRC_URI}
			mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}${K_LONGTERM_URL_STR}/${K_PATCH_NAME}"
		UNIPATCH_LIST="${DISTDIR}/${K_PATCH_NAME}
			${UNIPATCH_LIST}"
	fi
fi
if [ -n "${K_KERNEL_PATCH_HOTFIXES}" ]; then
	UNIPATCH_LIST="${K_KERNEL_PATCH_HOTFIXES} ${UNIPATCH_LIST}"
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

# provide extra virtual pkg
if _is_kernel_binary; then
	PROVIDE="${PROVIDE} virtual/linux-binary"
fi

if [ -n "${K_SABKERNEL_SELF_TARBALL_NAME}" ]; then
	HOMEPAGE="http://gitweb.sabayon.org/?p=linux/kernel/sabayon.git;a=summary"
else
	HOMEPAGE="http://www.sabayon.org"
fi


# Setup kernel configuration file name
if [ -z "${K_SABKERNEL_SELF_TARBALL_NAME}" ]; then
	if [ "${K_SABKERNEL_URI_CONFIG}" = "yes" ]; then
		K_SABKERNEL_CONFIG_FILE="${K_SABKERNEL_CONFIG_FILE:-${K_SABKERNEL_NAME}-${PVR}-__ARCH__.config}"
		SRC_URI="${SRC_URI}
			amd64? ( mirror://sabayon/${CATEGORY}/linux-sabayon-patches/config/${K_SABKERNEL_CONFIG_FILE/__ARCH__/amd64} )
			x86? ( mirror://sabayon/${CATEGORY}/linux-sabayon-patches/config/${K_SABKERNEL_CONFIG_FILE/__ARCH__/x86} )"
		use amd64 && K_SABKERNEL_CONFIG_FILE=${K_SABKERNEL_CONFIG_FILE/__ARCH__/amd64}
		use x86 && K_SABKERNEL_CONFIG_FILE=${K_SABKERNEL_CONFIG_FILE/__ARCH__/x86}
	else
		use amd64 && K_SABKERNEL_CONFIG_FILE="${K_SABKERNEL_CONFIG_FILE:-${K_SABKERNEL_NAME}-${PVR}-amd64.config}"
		use x86 && K_SABKERNEL_CONFIG_FILE="${K_SABKERNEL_CONFIG_FILE:-${K_SABKERNEL_NAME}-${PVR}-x86.config}"
	fi
else
	K_SABKERNEL_CONFIG_FILE="${K_SABKERNEL_CONFIG_FILE:-${K_SABKERNEL_NAME}-${PVR}-__ARCH__.config}"
	use amd64 && K_SABKERNEL_CONFIG_FILE=${K_SABKERNEL_CONFIG_FILE/__ARCH__/amd64}
	use x86 && K_SABKERNEL_CONFIG_FILE=${K_SABKERNEL_CONFIG_FILE/__ARCH__/x86}
fi

if [ -n "${K_ONLY_SOURCES}" ] || [ -n "${K_FIRMWARE_PACKAGE}" ]; then
	IUSE="${IUSE}"
	DEPEND="sys-apps/sed"
	RDEPEND="${RDEPEND}"
else
	IUSE="dmraid dracut grub splash"
	DEPEND="app-arch/xz-utils
		sys-apps/sed
		sys-devel/make
		>=sys-kernel/genkernel-3.4.16-r1
		splash? ( x11-themes/sabayon-artwork-core )
		dracut? ( sys-kernel/dracut )"
	# FIXME: when grub-legacy will be removed, remove sys-boot/grub-handler
	RDEPEND="grub? ( || ( >=sys-boot/grub-1.98 ( <sys-boot/grub-1 sys-boot/grub-handler ) ) )
		sys-apps/sed
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
	if [ -n "${K_SABKERNEL_SELF_TARBALL_NAME}" ]; then
		OKV="${PVR}+${K_SABKERNEL_SELF_TARBALL_NAME}"
	fi
	kernel-2_src_unpack
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
	if [ -n "${K_SABKERNEL_SELF_TARBALL_NAME}" ]; then
		cp "${S}/sabayon/config/${K_SABKERNEL_CONFIG_FILE}" "${1}" || die "cannot copy kernel config"
	else
		if [ "${K_SABKERNEL_URI_CONFIG}" = "no" ]; then
			cp "${FILESDIR}/${PF/-r0/}-${ARCH}.config" "${1}" || die "cannot copy kernel config"
		else
			cp "${DISTDIR}/${K_SABKERNEL_CONFIG_FILE}" "${1}" || die "cannot copy kernel config"
		fi
	fi
}

_kernel_src_compile() {
	# disable sandbox
	export SANDBOX_ON=0
	export LDFLAGS=""

	# creating workdirs
	# some kernels fail with make 3.82 if firmware dir is not created
	mkdir "${WORKDIR}"/lib/lib/firmware -p
	mkdir "${WORKDIR}"/cache
	mkdir "${S}"/temp
	# needed anyway, even if grub use flag is not used here
	mkdir -p "${WORKDIR}"/boot/grub

	einfo "Starting to compile kernel..."
	_kernel_copy_config "${WORKDIR}"/config

	# do some cleanup
	rm -rf "${WORKDIR}"/lib
	rm -rf "${WORKDIR}"/cache
	rm -rf "${S}"/temp
	OLDARCH="${ARCH}"
	unset ARCH
	cd "${S}" || die
	GKARGS="--no-save-config --disklabel"
	use dracut && GKARGS="${GKARGS} --dracut"
	use splash && GKARGS="${GKARGS} --splash=sabayon"
	use dmraid && GKARGS="${GKARGS} --dmraid"
	export DEFAULT_KERNEL_SOURCE="${S}"
	export CMD_KERNEL_DIR="${S}"
	for opt in ${MAKEOPTS}; do
		if [ "${opt:0:2}" = "-j" ]; then
			mkopts="${opt}"
			break
		fi
	done
	[ -z "${mkopts}" ] && mkopts="-j3"

	DEFAULT_KERNEL_SOURCE="${S}" CMD_KERNEL_DIR="${S}" genkernel ${GKARGS} ${K_GENKERNEL_ARGS} \
		--kerneldir="${S}" \
		--kernel-config="${WORKDIR}"/config \
		--cachedir="${WORKDIR}"/cache \
		--makeopts="${mkopts}" \
		--tempdir="${S}"/temp \
		--logfile="${WORKDIR}"/genkernel.log \
		--bootdir="${WORKDIR}"/boot \
		--mountboot \
		--lvm \
		--luks \
		--iscsi \
		--mdadm \
		--module-prefix="${WORKDIR}"/lib \
		all || die "genkernel failed"
	ARCH=${OLDARCH}
}

sabayon-kernel_src_install() {
	if [ -n "${K_FIRMWARE_PACKAGE}" ]; then
		_firmwares_src_install
	elif [ -n "${K_ONLY_SOURCES}" ]; then
		_kernel_sources_src_install
	else
		_kernel_src_install
	fi
}

_firmwares_src_install() {
	dodir /lib/firmware
	keepdir /lib/firmware
	cd "${S}" || die
	emake INSTALL_FW_PATH="${D}/lib/firmware" firmware_install || die "cannot install firmwares"
}

_kernel_sources_src_install() {
	local version_h_name="${KV_OUT_DIR/\//}/include/linux"
	local version_h="${ROOT}${version_h_name}"
	if [ -f "${version_h}" ]; then
		einfo "Discarding previously installed version.h to avoid collisions"
		addwrite "/${version_h_name}"
		rm -f "${version_h}"
	fi

	_kernel_copy_config ".config"
	kernel-2_src_install
	cd "${D}${KV_OUT_DIR}" || die
	local oldarch="${ARCH}"
	unset ARCH
	if ! use sources_standalone; then
		make modules_prepare || die "failed to run modules_prepare"
		rm .config || die "cannot remove .config"
		rm Makefile || die "cannot remove Makefile"
		rm include/linux/version.h || die "cannot remove include/linux/version.h"
	fi
	ARCH="${oldarch}"
}

_kernel_src_install() {
	dodir "${KV_OUT_DIR}"
	insinto "${KV_OUT_DIR}"

	_kernel_copy_config ".config"
	doins ".config" || die "cannot copy kernel config"
	doins Makefile || die "cannot copy Makefile"
	doins Module.symvers || die "cannot copy Module.symvers"
	doins System.map || die "cannot copy System.map"

	# NOTE: this is a workaround caused by linux-info.eclass not
	# being ported to EAPI=2 yet
	local version_h_name="${KV_OUT_DIR/\//}/include/linux"
	local version_h="${ROOT}${version_h_name}/version.h"
	if [ -f "${version_h}" ]; then
		einfo "Discarding previously installed version.h to avoid collisions"
		addwrite "${version_h}"
		rm -f "${version_h}"
	fi

	# Include include/linux/version.h to make Portage happy
	dodir "${KV_OUT_DIR}/include/linux"
	insinto "${KV_OUT_DIR}/include/linux"
	doins "${S}/include/linux/version.h" || die "cannot copy version.h"

	insinto "/boot"
	doins "${WORKDIR}"/boot/*
	cp -Rp "${WORKDIR}"/lib/* "${D}/"

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
	if _is_kernel_binary; then
		# release level is enough for now
		base_dir="/etc/kernels/${P}"
		dodir "${base_dir}"
		insinto "${base_dir}"
		echo "${KV_FULL}" > "RELEASE_LEVEL"
		doins "RELEASE_LEVEL"
		einfo "Installing ${base_dir}/RELEASE_LEVEL file: ${KV_FULL}"
	fi
}

sabayon-kernel_pkg_preinst() {
	if _is_kernel_binary; then
		mount-boot_pkg_preinst
	fi
}
sabayon-kernel_grub2_mkconfig() {
	if [ -x "${ROOT}sbin/grub-mkconfig" ]; then
		"${ROOT}sbin/grub-mkdevicemap" --device-map="${ROOT}boot/grub/device.map"
		"${ROOT}sbin/grub-mkconfig" -o "${ROOT}boot/grub/grub.cfg"
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

sabayon-kernel_pkg_postinst() {
	if _is_kernel_binary; then
		fstab_file="${ROOT}etc/fstab"
		einfo "Removing extents option for ext4 drives from ${fstab_file}"
		# Remove "extents" from /etc/fstab
		if [ -f "${fstab_file}" ]; then
			sed -i '/ext4/ s/extents//g' "${fstab_file}"
		fi

		# Update kernel initramfs to match user customizations
		update_sabayon_kernel_initramfs_splash

		# Add kernel to grub.conf
		if use grub; then
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
		if use grub; then
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
	fi
}

# export all the available functions here
EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_install pkg_preinst pkg_postinst pkg_prerm pkg_postrm

