# Copyright 1999-2006 Sabayon Linux - Fabio Erculiani
# Distributed under the terms of the GNU General Public License v2

inherit eutils linux-mod

DESCRIPTION="qemu emulator and abi wrapper meta ebuild"
HOMEPAGE="http://kvm.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="no_kernel_module"

RESTRICT="nomirror"

RDEPEND="${DEPEND}"

# FIXME: add kernel dependency
DEPEND=">=media-libs/alsa-lib-1.0.11
	>=media-libs/libsdl-1.2.10
	sys-fs/e2fsprogs
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXdmcp
	media-libs/libcaca
	>=sys-libs/ncurses-5.5
	>=sys-fs/udev-100
	"

pkg_setup() {
	if ! use no_kernel_module; then
		MODULE_NAMES="kvm(extra:${S}/kernel) kvm-amd(extra:${S}/kernel) kvm-intel(extra:${S}/kernel)"
		linux-mod_pkg_setup
	fi
}

src_unpack() {
	unpack ${A}

	# GCC4 support
	cd ${S}/qemu
	epatch ${FILESDIR}/qemu-0.7.0-gcc4-dot-syms.patch
	epatch ${FILESDIR}/qemu-0.8.0-gcc4-hacks.patch
	epatch ${FILESDIR}/qemu-0.8.3-gcc4.patch

	einfo "Setting up proper install path"
	cd ${S}
	sed -i 's/prefix=\/usr\/local/prefix=\/usr/' configure
	sed -i '/datadir=/ s/qemu/kvm/' qemu/configure
	sed -i '/docdir=/ s/qemu/kvm/' qemu/configure
	
}

src_compile() {

	OLD_ARCH=$ARCH
	unset ARCH
	
	cd ${S}
	BUILDOPTS="--disable-gcc-check --qemu-cc=/usr/bin/gcc"
	BUILDOPTS="${BUILDOPTS} --kerneldir=${KV_DIR}"
	if use no_kernel_module; then
		BUILDOPTS="${BUILDOPTS} --with-patched-kernel"
	fi

	./configure ${BUILDOPTS} || die "configure failed"
	make || die "make failed"

	ARCH=$OLD_ARCH
	
}

src_install() {
	if ! use no_kernel_module; then
		linux-mod_src_install
	fi
	cd ${S}/qemu
        make DESTDIR="${D}" install || die "make install failed"
	dosym /usr/bin/qemu /usr/bin/kvm
}
