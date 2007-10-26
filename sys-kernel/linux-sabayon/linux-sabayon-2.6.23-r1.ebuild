# Copyright 2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_WANT_GENPATCHES=""
K_GENPATCHES_VER=""
inherit kernel-2
detect_version
detect_arch

UNIPATCH_STRICTORDER="yes"
KEYWORDS="~amd64 ~x86"
HOMEPAGE="http://www.sabayonlinux.org"
DEPEND="
	>=sys-kernel/genkernel-3.4.9_pre3
	splash? ( x11-themes/sabayonlinux-artwork )
	"
RDEPEND="grub? ( sys-boot/grub )"
IUSE="splash dmraid grub no_sources"

DESCRIPTION="Official Sabayon Linux kernel images"
MY_P="${PV}/sabayon-sources-${PV}"
KV_FULL=${KV_FULL/linux/sabayon}
K_NOSETEXTRAVERSION="1"
EXTRAVERSION=${EXTRAVERSION/linux/sabayon}
SLOT="${PV}"

## INIT: Exported data
SL_PATCHES_URI="
		http://dev.gentoo.org/~spock/projects/fbcondecor/archive/fbcondecor-0.9.4-${PV}-rc7.patch
		http://download.filesystems.org/unionfs/unionfs-2.1/unionfs-2.1.6_for_2.6.23-rc8.diff.gz
"

SUSPEND2_VERSION="2.2.10.4"
SUSPEND2_TARGET="2.6.23-rc9"
SUSPEND2_SRC="tuxonice-${SUSPEND2_VERSION}-for-${SUSPEND2_TARGET}"
SUSPEND2_URI="http://www.tuxonice.net/downloads/all/${SUSPEND2_SRC}.patch.bz2"

UNIPATCH_LIST="
		${DISTDIR}/fbcondecor-0.9.4-${PV}-rc7.patch
		${FILESDIR}/${MY_P}-squashfs-3.2.patch 
		${FILESDIR}/${MY_P}-squashfs-update.patch
		${DISTDIR}/${SUSPEND2_SRC}.patch.bz2
		${FILESDIR}/${MY_P}-ipw3945-1.2.0-2.6.22.patch 
		${FILESDIR}/${MY_P}-from-ext4dev-to-ext4.patch
		${DISTDIR}/unionfs-2.1.6_for_2.6.23-rc8.diff.gz
		${FILESDIR}/${MY_P}-mac80211-drivers.patch
		${FILESDIR}/${MY_P}-acx-old.patch

		${FILESDIR}/${MY_P}-mactel-appleir.patch
		${FILESDIR}/${PV}/acer-acpi-2.6.23.patch
		${FILESDIR}/${PV}/linux-phc-0.3.0-pre1-2.6.23.patch
		${FILESDIR}/${PV}/hrtimers-2.6.23.patch
		${FILESDIR}/${PV}/powertop-2.6.23.patch
		${FILESDIR}/${PV}/pm_qos-2.6.23.patch
		${FILESDIR}/${PV}/thinkpad-2.6.23.patch
		${FILESDIR}/${PV}/mactel-patches-2.6.23.patch
		${FILESDIR}/${MY_P}-sandbox-violation.patch
		${FILESDIR}/${PV}/linux-2.6.23.1.patch
		${FILESDIR}/${PV}/acpi-release-20070126-2.6.23.patch
		${FILESDIR}/${PV}/rt2x00-latest-2.6.23.patch

		"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI} ${SUSPEND2_URI} ${SL_PATCHES_URI}"
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

	# creating workdirs
	mkdir -p ${WORKDIR}/boot/grub
	mkdir ${WORKDIR}/lib
	mkdir ${WORKDIR}/cache
	mkdir ${S}/temp

	einfo "Starting to compile kernel..."
	cp ${FILESDIR}/${P}-${ARCH}.config ${WORKDIR}/config

	if use grub; then
		if [ -e "/boot/grub/grub.conf" ]; then
			cp /boot/grub/grub.conf ${WORKDIR}/boot/grub -p
		fi
	fi

	OLDARCH=${ARCH}
	unset ARCH
	cd ${S}
	GK_ARGS=""
	use splash && GKARGS="${GKARGS} --gensplash=sabayon"
	use dmraid && GKARGS="${GKARGS} --dmraid"
	use grub && GKARGS="${GKARGS} --bootloader=grub"
	genkernel ${GKARGS} \
		--kerneldir=${S} \
		--kernel-config=${WORKDIR}/config \
		--cachedir=${WORKDIR}/cache \
		--makeopts=-j3 \
		--tempdir=${S}/temp \
		--debugfile=${WORKDIR}/genkernel.log \
		--bootdir=${WORKDIR}/boot \
		--mountboot \
		--lvm \
		--luks \
		--module-prefix=${WORKDIR}/lib \
		all || die "genkernel failed"
	ARCH=${OLDARCH}
}

src_install() {

	if ! use no_sources; then
		kernel-2_src_install || die "sources install failed"
		cp ${FILESDIR}/${P}-${ARCH}.config ${D}/usr/src/linux-${KV_FULL}/.config || die "cannot copy kernel configuration"
		cd ${D}/usr/src/linux-${KV_FULL} || die "cannot cd into sources directory"
		OLDARCH=${ARCH}
		unset ARCH
		make prepare modules_prepare || die "cannot run make prepare modules_prepare"
		ARCH=${OLDARCH}
	fi

	insinto /boot
	doins ${WORKDIR}/boot/*
	cp -Rp ${WORKDIR}/lib/* ${D}/
	rm ${D}/lib/modules/${KV_FULL}/source
	rm ${D}/lib/modules/${KV_FULL}/build
	ln -s /usr/src/linux-${KV_FULL} ${D}/lib/modules/${KV_FULL}/source
	ln -s /usr/src/linux-${KV_FULL} ${D}/lib/modules/${KV_FULL}/build
	if use grub; then
		if [ -e "${WORKDIR}/boot/grub.conf" ]; then
			insinto /boot/grub/
			doins ${WORKDIR}/boot/grub.conf
		fi
	fi
}

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "Please report kernel bugs at:"
	einfo "http://bugs.sabayonlinux.org"
}
