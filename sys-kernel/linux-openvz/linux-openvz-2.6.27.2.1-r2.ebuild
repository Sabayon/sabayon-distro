# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/openvz-sources/openvz-sources-2.6.27.2.1-r2.ebuild,v 1.3 2009/07/22 05:54:03 pva Exp $

inherit versionator

# Upstream uses string to version their releases. To make portage version
# comparisment working we have to use numbers instead of strings, that is 4th
# component of our version. So we have aivazovsky - 1, briullov - 2 and so on.
# Keep this string on top since we have to modify it each new release.
OVZ_CODENAME="briullov"
OVZ_CODENAME_SUBRELEASE=$(get_version_component_range 5)

OVZ_KV="${OVZ_CODENAME}.${OVZ_CODENAME_SUBRELEASE}"

ETYPE="sources"

CKV=$(get_version_component_range 1-3)
OKV=${OKV:-${CKV}}
EXTRAVERSION=-${PN/-*}-${OVZ_KV}
KV_FULL=${CKV}${EXTRAVERSION}
if [[ ${PR} != r0 ]]; then
	KV_FULL+=-${PR}
	EXTRAVERSION+=-${PR}
fi

# ${KV_MAJOR}.${KV_MINOR}.${KV_PATCH} should succeed.
KV_MAJOR=$(get_version_component_range 1 ${OKV})
KV_MINOR=$(get_version_component_range 2 ${OKV})
KV_PATCH=$(get_version_component_range 3 ${OKV})

KERNEL_URI="mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/linux-${OKV}.tar.bz2"

inherit kernel-2 sabayon-artwork mount-boot linux-mod
detect_version
detect_arch

SLOT=${CKV}-${OVZ_KV}
if [[ ${PR} != r0 ]]; then
	SLOT+=-${PR}
fi

KEYWORDS="~amd64 ~x86"
IUSE="splash dmraid grub"

DESCRIPTION="Linux Kernel binaries with OpenVZ patchset"
HOMEPAGE="http://www.openvz.org"
SRC_URI="${KERNEL_URI} ${ARCH_URI}
	http://download.openvz.org/kernel/branches/${CKV}/${CKV}-${OVZ_KV}/patches/patch-${OVZ_KV}-combined.gz"

S_PN="openvz-sources"
UNIPATCH_STRICTORDER=1
UNIPATCH_LIST="${DISTDIR}/patch-${OVZ_KV}-combined.gz
${FILESDIR}/${S_PN}-2.6.27.2.1-ban-netns-creation.patch
${FILESDIR}/${S_PN}-2.6.27.2.1-bridge-process-skbs.patch
${FILESDIR}/${S_PN}-2.6.27.2.1-bridge-set_via_phys_dev_state.patch
${FILESDIR}/${S_PN}-2.6.27.2.1-avoid-double-free.patch
${FILESDIR}/${S_PN}-2.6.27.2.1-check-for-no-mmaps.patch
${FILESDIR}/${S_PN}-2.6.27.2.1-pi-futex-pid-check-fixup.patch
${FILESDIR}/${S_PN}-2.6.27.2.1-SLAB.patch"

K_EXTRAEINFO="For more information about this kernel take a look at:
http://wiki.openvz.org/Download/kernel/${CKV}/${CKV}-${OVZ_KV}"

############################################
# binary part

DEPEND="${DEPEND}
	<sys-kernel/genkernel-3.4.11
	splash? ( x11-themes/sabayon-artwork-core )"
RDEPEND="grub? ( sys-boot/grub sys-boot/grub-handler )"

KV_FULL=${KV_FULL/linux/openvz}
K_NOSETEXTRAVERSION="1"
EXTRAVERSION=${EXTRAVERSION/linux/openvz}
S="${WORKDIR}/linux-${KV_FULL}"


src_unpack() {

	kernel-2_src_unpack
	cd "${S}"

	# manually set extraversion
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile

}

src_compile() {
	# disable sandbox
	export SANDBOX_ON=0
	export LDFLAGS=""

	# creating workdirs
	mkdir ${WORKDIR}/lib
	mkdir ${WORKDIR}/cache
	mkdir ${S}/temp
	# needed anyway, even if grub use flag is not used here
	mkdir -p ${WORKDIR}/boot/grub

	einfo "Starting to compile kernel..."
	cp ${FILESDIR}/${PF/-r0/}-${ARCH}.config ${WORKDIR}/config || die "cannot copy kernel config"

	# do some cleanup
	rm -rf "${WORKDIR}"/lib
	rm -rf "${WORKDIR}"/cache
	rm -rf "${S}"/temp
	OLDARCH=${ARCH}
	unset ARCH
	cd ${S}
	GK_ARGS="--disklabel"
	use splash && GKARGS="${GKARGS} --splash=sabayon"
	use dmraid && GKARGS="${GKARGS} --dmraid"
	export DEFAULT_KERNEL_SOURCE="${S}"
	export CMD_KERNEL_DIR="${S}"
	DEFAULT_KERNEL_SOURCE="${S}" CMD_KERNEL_DIR="${S}" genkernel ${GKARGS} \
		--kerneldir=${S} \
		--kernel-config=${WORKDIR}/config \
		--cachedir=${WORKDIR}/cache \
		--makeopts=-j3 \
		--tempdir=${S}/temp \
		--logfile=${WORKDIR}/genkernel.log \
		--bootdir=${WORKDIR}/boot \
		--mountboot \
		--lvm \
		--luks \
		--disklabel \
		--module-prefix=${WORKDIR}/lib \
		all || die "genkernel failed"
	ARCH=${OLDARCH}
}

src_install() {
	dodir "/usr/src/linux-${KV_FULL}"
	insinto "/usr/src/linux-${KV_FULL}"

	cp "${FILESDIR}/${PF/-r0/}-${OLDARCH}.config" .config
	doins ".config" || die "cannot copy kernel config"
	doins Module.symvers || die "cannot copy Module.symvers"
	doins System.map || die "cannot copy System.map"

	insinto "/boot"
	doins "${WORKDIR}"/boot/*
	cp -Rp "${WORKDIR}"/lib/* "${D}/"
	rm "${D}/lib/modules/${KV_FULL}/source"
	rm "${D}/lib/modules/${KV_FULL}/build"

	dosym "../../../usr/src/linux-${KV_FULL}" "/lib/modules/${KV_FULL}/source" || die "cannot install source symlink"
	dosym "../../../usr/src/linux-${KV_FULL}" "/lib/modules/${KV_FULL}/build" || die "cannot install build symlink"

	addwrite "/lib/firmware"
	# Workaround kernel issue with colliding
	# firmwares across different kernel versions
	for fwfile in `find "${D}/lib/firmware" -type f`; do

		sysfile="${ROOT}/${fwfile/${D}}"
		if [ -f "${sysfile}" ]; then
			ewarn "Removing duplicated: ${sysfile}"
			rm ${sysfile} || die "failed to remove ${sysfile}"
		fi

	done
}

pkg_setup() {
	# do not run linux-mod-pkg_setup
	einfo "Preparing to build the kernel and its modules"
}

pkg_preinst() {
	mount-boot_mount_boot_partition
	linux-mod_pkg_preinst
	UPDATE_MODULEDB=false
}

pkg_postinst() {
	fstab_file="${ROOT}/etc/fstab"
	einfo "Removing extents option for ext4 drives from ${fstab_file}"
	# Remove "extents" from /etc/fstab
	if [ -f "${fstab_file}" ]; then
		sed -i '/ext4/ s/extents//g' ${fstab_file}
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
		/usr/sbin/grub-handler add \
			"/boot/kernel-genkernel-${kern_arch}-${KV_FULL}" \
			"/boot/initramfs-genkernel-${kern_arch}-${KV_FULL}"
	fi

	kernel-2_pkg_postinst
	linux-mod_pkg_postinst

	einfo "Please report kernel bugs at:"
	einfo "http://bugs.sabayonlinux.org"

	elog "The OpenVZ Linux kernel source code is located at"
	elog "=sys-kernel/openvz-sources-${PVR}."
	elog "Sabayon Linux recommends that portage users install"
	elog "sys-kernel/openvz-sources-${PVR} if you want"
	elog "to build any packages that install kernel modules"
	elog "(such as ati-drivers, nvidia-drivers, virtualbox, etc...)."
}

pkg_postrm() {
	# Add kernel to grub.conf
	if use grub; then
		local kern_arch="x86"
		if use amd64; then
			kern_arch="x86_64"
		fi
		/usr/sbin/grub-handler remove \
			"/boot/kernel-genkernel-${kern_arch}-${KV_FULL}" \
			"/boot/initramfs-genkernel-${kern_arch}-${KV_FULL}"
	fi

	linux-mod_pkg_postrm
}
