# Copyright 2004-2015 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit versionator

K_SABKERNEL_SELF_TARBALL_NAME="sabayon"
K_REQUIRED_LINUX_FIRMWARE_VER="20150320"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_SABKERNEL_PATCH_UPSTREAM_TARBALL="1"
K_KERNEL_NEW_VERSIONING="1"

K_MKIMAGE_RAMDISK_ADDRESS="0x81000000"
K_MKIMAGE_RAMDISK_ENTRYPOINT="0x00000000"
K_MKIMAGE_KERNEL_ADDRESS="0x80008000"
K_KERNEL_IMAGE_NAME="uImage dtbs"

inherit sabayon-kernel

KEYWORDS="~arm"
DESCRIPTION="Official Sabayon Linux Standard kernel image for beaglebone"
RESTRICT="mirror"
SRC_URI="
	${SRC_URI}
	https://github.com/beagleboard/linux/raw/4.1/firmware/am335x-pm-firmware.bin
	https://github.com/beagleboard/linux/raw/4.1/firmware/am335x-bone-scale-data.bin
	https://github.com/beagleboard/linux/raw/4.1/firmware/am335x-evm-scale-data.bin
	https://github.com/beagleboard/linux/raw/4.1/firmware/am335x-pm-firmware.elf
	https://github.com/beagleboard/linux/raw/4.1/firmware/am43x-evm-scale-data.bin
	"

src_prepare() {
	sabayon-kernel_src_prepare
	cp -r "${FILESDIR}"/"kernel.config" "${S}"/sabayon/config/"beaglebone-$(_get_arch).config"
	mv "${DISTDIR}"/am335x-pm-firmware.bin "${DISTDIR}"/am335x-bone-scale-data.bin "${DISTDIR}"/am335x-evm-scale-data.bin "${DISTDIR}"/am335x-pm-firmware.elf "${DISTDIR}"/am43x-evm-scale-data.bin "${S}"/firmware
}
