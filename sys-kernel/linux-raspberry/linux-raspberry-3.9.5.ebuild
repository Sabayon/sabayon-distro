# Copyright 2004-2013 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=5

K_SABKERNEL_SELF_TARBALL_NAME="raspberry"
K_REQUIRED_LINUX_FIRMWARE_VER="20130421"
K_SABKERNEL_FORCE_SUBLEVEL="0"
K_KERNEL_NEW_VERSIONING="1"

K_KERNEL_IMAGE_NAME="Image"
K_KERNEL_IMAGE_PATH="arch/arm/boot/Image"
K_MKIMAGE_WRAP_INITRAMFS="0"

inherit sabayon-kernel

KEYWORDS="~arm"
DESCRIPTION="Linux Kernel binaries for the Raspberry Pi"
RESTRICT="mirror"

src_install() {
	sabayon-kernel_src_install || die

	# Run upstream imagetool-uncompressed.py, which is a kinda
	# brain-dead broken script, but we don't want to touch it in any way.
	cd "${S}" || die
	cp "${FILESDIR}"/*.{txt,py} "${S}"/ || die
	chmod +x "${S}"/imagetool-uncompressed.py || die

	local kernel_file="kernel-genkernel-arm-${KV_FULL}"
	"${S}"/imagetool-uncompressed.py "${D}/boot/${kernel_file}" || die
	# Now replace the already installed kernel file with this one.
	mv kernel.img "${D}/boot/${kernel_file}" || die "cannot copy kernel.img to destination"
}

