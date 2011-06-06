# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-boot/grub/grub-1.98.ebuild,v 1.1 2010/03/10 19:47:34 vapier Exp $

inherit mount-boot eutils flag-o-matic toolchain-funcs

if [[ ${PV} == "9999" ]] ; then
	EBZR_REPO_URI="http://bzr.savannah.gnu.org/r/grub/trunk/grub"
	inherit autotools bzr
	SRC_URI=""
else
	SRC_URI="ftp://alpha.gnu.org/gnu/${PN}/${P}.tar.gz
		mirror://gentoo/${P}.tar.gz"
fi

DESCRIPTION="GNU GRUB 2 boot loader"
HOMEPAGE="http://www.gnu.org/software/grub/"

LICENSE="GPL-3"
use multislot && SLOT="2" || SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="custom-cflags debug truetype multislot static"

RDEPEND=">=sys-libs/ncurses-5.2-r5
	dev-libs/lzo
	truetype? (
		media-libs/freetype
		media-fonts/unifont
	)"
DEPEND="${RDEPEND}
	dev-lang/ruby"
PDEPEND="${PDEPEND}
	sys-boot/os-prober"
PROVIDE="virtual/bootloader"

export STRIP_MASK="*/grub/*/*.mod"
QA_EXECSTACK="sbin/grub-probe sbin/grub-setup sbin/grub-mkdevicemap"

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		bzr_src_unpack
	else
		unpack ${A}
	fi
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.98-genkernel.patch
	epatch "${FILESDIR}"/${PN}-1.97-vga-deprecated.patch
	epatch "${FILESDIR}"/${PN}-1.98-wallpaper-settings-support.patch
	# see Gentoo #302634
	epatch "${FILESDIR}"/${PN}-1.98-add-legacy-rootfs-detection.patch

	# Ubuntu and upstream patches
	epatch "${FILESDIR}"/ubuntu-upstream-${PV}/*.diff

	epatch_user

	# see Gentoo #321569
	epatch "${FILESDIR}"/${PN}-1.98-follow-dev-mapper-symlinks.patch

	# Genkernel doesn't support "single" for rescue mode
	# but rather init_opts=single
	epatch "${FILESDIR}"/${PN}-1.98-genkernel-initramfs-single.patch

	# autogen.sh does more than just run autotools
	# need to eautomake due to weirdness #296013
	if [[ ${PV} == "9999" ]] ; then
		sed -i \
			-e '/^\(auto\|ac\)/s:^:e:' \
			-e "s:^eautomake:`which automake`:" \
			autogen.sh
		(. ./autogen.sh) || die
	fi
}

src_compile() {
	use custom-cflags || unset CFLAGS CPPFLAGS LDFLAGS
	use static && append-ldflags -static

	econf \
		--disable-werror \
		--sbindir=/sbin \
		--bindir=/bin \
		--libdir=/$(get_libdir) \
		--disable-efiemu \
		$(use_enable truetype grub-mkfont) \
		$(use_enable debug mm-debug) \
		$(use_enable debug grub-emu) \
		$(use_enable debug grub-emu-usb) \
		$(use_enable debug grub-fstest)
	emake -j1 || die "making regular stuff"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
	if use multislot ; then
		sed -i "s:grub-install:grub2-install:" "${D}"/sbin/grub-install || die
		mv "${D}"/sbin/grub{,2}-install || die
		mv "${D}"/sbin/grub{,2}-set-default || die
		mv "${D}"/usr/share/info/grub{,2}.info || die
	fi

	# install /etc/default/grub
	cp "${FILESDIR}/grub2-default" grub
	dodir /etc/default
	insinto /etc/default
	doins grub

	# Install fonts setup hook
	exeinto /etc/grub.d
	doexe "${FILESDIR}/00_fonts"
	doexe "${FILESDIR}/05_distro_theme"

	dodir /boot/grub
	insinto /boot/grub
	newins "${FILESDIR}/default-splash-6.png" default-splash.png
	# keep backward compat
	dodir /usr/share/grub
	insinto /usr/share/grub
	newins "${FILESDIR}/default-splash-6.png" default-splash.png

}

setup_boot_dir() {
	local boot_dir=$1
	local dir=${boot_dir}/grub

	if [[ ! -e ${dir}/grub.cfg ]] ; then
		einfo "Running: grub-mkconfig -o '${dir}/grub.cfg'"
		grub-mkconfig -o "${dir}/grub.cfg"
	fi

	#local install=grub-install
	#use multislot && install="grub2-install --grub-setup=/bin/true"
	#einfo "Running: ${install} "
	#${install}
}

pkg_postinst() {
	if use multislot ; then
		elog "You have installed grub2 with USE=multislot, so to coexist"
		elog "with grub1, the grub2 install binary is named grub2-install."
	fi
	setup_boot_dir "${ROOT}"boot
}
