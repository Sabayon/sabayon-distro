# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_WANT_GENPATCHES=""
K_GENPATCHES_VER=""
inherit kernel-2 sabayon-artwork mount-boot
detect_version
detect_arch

DESCRIPTION="Official Sabayon Linux Standard kernel image and source"
RESTRICT="nomirror"
IUSE="splash dmraid grub"
UNIPATCH_STRICTORDER="yes"
KEYWORDS="amd64 x86"
HOMEPAGE="http://www.sabayonlinux.org"

DEPEND="<sys-kernel/genkernel-3.4.11
	splash? ( x11-themes/sabayon-artwork-core )"

RDEPEND="grub? ( sys-boot/grub sys-boot/grub-handler )"

KV_FULL=${KV_FULL/linux/sabayon}
K_NOSETEXTRAVERSION="1"
EXTRAVERSION=${EXTRAVERSION/linux/sabayon}
SLOT="${PV}"
S="${WORKDIR}/linux-${KV_FULL}"

## INIT: Exported data

UNIPATCH_LIST="
	"${FILESDIR}"/${PV}/patch-2.6.29.4.bz2
 	"${FILESDIR}"/${PV}/${P}-aufs.patch.bz2
	"${FILESDIR}"/${PV}/current-tuxonice-for-head.patch-20090313-v1.bz2
	"${FILESDIR}"/${PV}/genpatches/1916_ext4-automatically-allocate-delay-allocated-blocks-on-close.patch
	"${FILESDIR}"/${PV}/genpatches/1917_ext4-add-EXT4_IOC_ALLOC_DA_BLKS-ioctl.patch
	"${FILESDIR}"/${PV}/genpatches/4100_dm-bbr.patch
	"${FILESDIR}"/${PV}/genpatches/1915_ext4-automatically-allocate-delay-allocated-blocks-on-rename.patch
	"${FILESDIR}"/${PV}/genpatches/4200_fbcondecor-0.9.4.patch
	"${FILESDIR}"/${PV}/genpatches/4400_alpha-sysctl-uac.patch
	"${FILESDIR}"/${PV}/mactel/1-bcm5974-headers.patch
	"${FILESDIR}"/${PV}/mactel/2-bcm5974-quad-finger-tapping.patch
	"${FILESDIR}"/${PV}/mactel/3-bcm5974-macbook5-support.patch
"


SRC_URI="${KERNEL_URI} ${SL_PATCHES_URI} ${SUSPEND2_URI} ${SUSPEND2_URI}"

## END: Exported data

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

	kernel-2_src_install || die "sources install failed"

	cd ${D}/usr/src/linux-${KV_FULL} || die "cannot cd into sources directory"
	cp Module.symvers Module.symvers.backup -p || die "cannot copy Module.symvers"
	cp System.map System.map.backup -p || die "cannot copy System.map"
	OLDARCH=${ARCH}
	unset ARCH
	make distclean || die "cannot run make distclean"
	cp ${FILESDIR}/${PF/-r0/}-${OLDARCH}.config ${D}/usr/src/linux-${KV_FULL}/.config || die "cannot copy kernel configuration"

	make prepare modules_prepare || die "cannot run make prepare modules_prepare"
	ARCH=${OLDARCH}
	cp Module.symvers.backup Module.symvers -p || die "cannot copy back Module.symvers"
	cp System.map.backup System.map -p || die "cannot copy System.map"


	insinto /boot
	doins ${WORKDIR}/boot/*
	cp -Rp ${WORKDIR}/lib/* ${D}/
	rm ${D}/lib/modules/${KV_FULL}/source
	rm ${D}/lib/modules/${KV_FULL}/build
	ln -s /usr/src/linux-${KV_FULL} ${D}/lib/modules/${KV_FULL}/source
	ln -s /usr/src/linux-${KV_FULL} ${D}/lib/modules/${KV_FULL}/build

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
	einfo "Please report kernel bugs at:"
	einfo "http://bugs.sabayonlinux.org"
}

pkg_postrm() {

	# Add kernel to grub.conf
	if use grub; then
		if use amd64; then
			local kern_arch="x86_64"
		else
			local kern_arch="x86"
		fi
		/usr/sbin/grub-handler remove \
			"/boot/kernel-genkernel-${kern_arch}-${KV_FULL}" \
			"/boot/initramfs-genkernel-${kern_arch}-${KV_FULL}"
	fi

}
