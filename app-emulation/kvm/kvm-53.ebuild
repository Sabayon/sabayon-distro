# Copyright 1999-2006 Sabayon Linux - Fabio Erculiani
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="KVM (for Kernel-based Virtual Machine) is a full virtualization solution for Linux on x86 hardware containing virtualization extensions (Intel VT or AMD-V)"
HOMEPAGE="http://kvm.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="nomirror"

# FIXME: add kernel dependency
RDEPEND=">=media-libs/alsa-lib-1.0.11
	>=media-libs/libsdl-1.2.10
	sys-fs/e2fsprogs
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXdmcp
	media-libs/libcaca
	>=sys-libs/ncurses-5.5
	>=sys-fs/udev-100
	"

DEPEND="${RDEPEND}
	>=sys-kernel/linux-headers-2.6.22"

src_unpack() {
	unpack ${A}
	einfo "Setting up proper install path"
	cd ${S}
	epatch ${FILESDIR}/${P}-disable-headers-installation.patch
	sed -i 's/prefix=\/usr\/local/prefix=\/usr/' configure
	sed -i '/datadir=/ s/qemu/kvm/' qemu/configure
	sed -i '/docdir=/ s/qemu/kvm/' qemu/configure
}

src_compile() {
	cd ${S}
	BUILDOPTS="--disable-gcc-check --qemu-cc=/usr/bin/gcc --enable-alsa --with-patched-kernel"
	./configure ${BUILDOPTS} || die "configure failed"
	make || die "make kvm failed"
}

src_install() {
	cd ${S}
        make DESTDIR="${D}" install || die "make kvm install failed"
	if use amd64; then
		dosym /usr/bin/qemu-system-x86_64 /usr/bin/kvm
	elif use x86; then
		dosym /usr/bin/qemu /usr/bin/kvm
	fi
	# Install previously removed headers
	insinto /usr/include/linux
	doins ${S}/kernel/include/linux/kvm.h
	doins ${S}/kernel/include/linux/kvm_para.h
}
