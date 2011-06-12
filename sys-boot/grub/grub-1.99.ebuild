# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

if [[ ${PV} == "9999" ]] ; then
	EBZR_REPO_URI="http://bzr.savannah.gnu.org/r/grub/trunk/grub/"
	LIVE_ECLASS="autotools bzr"
	SRC_URI=""
else
	MY_P=${P/_/\~}
	SRC_URI="mirror://gnu/${PN}/${MY_P}.tar.xz
		mirror://gentoo/${MY_P}.tar.xz"
	S=${WORKDIR}/${MY_P}
fi

inherit mount-boot eutils flag-o-matic toolchain-funcs autotools ${LIVE_ECLASS}
unset LIVE_ECLASS

DESCRIPTION="GNU GRUB boot loader"
HOMEPAGE="http://www.gnu.org/software/grub/"

LICENSE="GPL-3"
use multislot && SLOT="2" || SLOT="0"
[[ ${PV} != "9999" ]] && KEYWORDS="~amd64 ~x86 ~mips ~ppc ~ppc64"
IUSE="custom-cflags debug +device-mapper multislot nls static sdl +truetype"

GRUB_PLATFORMS="coreboot efi-32 efi-64 emu ieee1275 multiboot pc yeeloong"
# everywhere:
#     emu
# mips only:
#     qemu-mips, yeelong
# amd64, x86, ppc, ppc64
#     ieee1275
# amd64, x86
#     coreboot, multiboot, efi-32, pc, qemu
# amd64
#     efi-64
for i in ${GRUB_PLATFORMS}; do
	IUSE+=" grub_platforms_${i}"
done
unset i

# os-prober: Used on runtime to detect other OSes
# xorriso (dev-libs/libisoburn): Used on runtime for mkrescue
RDEPEND="
	dev-libs/libisoburn
	dev-libs/lzo
	sys-boot/os-prober
	>=sys-libs/ncurses-5.2-r5
	debug? (
		sdl? ( media-libs/libsdl )
	)
	device-mapper? ( >=sys-fs/lvm2-2.02.45 )
	truetype? ( media-libs/freetype >=media-fonts/unifont-5 )"
DEPEND="${RDEPEND}
	>=dev-lang/python-2.5.2
"
if [[ ${PV} == "9999" ]]; then
	DEPEND+=" >=sys-devel/autogen-5.10 sys-apps/help2man"
else
	DEPEND+=" >=sys-devel/autogen-5.10 app-arch/xz-utils"
fi

export STRIP_MASK="*/grub/*/*.mod"
QA_EXECSTACK="
	sbin/grub-probe
	sbin/grub-setup
	sbin/grub-mkdevicemap
	bin/grub-script-check
	bin/grub-fstest
"

grub_run_phase() {
	local phase=$1
	local platform=$2
	[[ -z ${phase} ]] && die "${FUNCNAME}: Phase is undefined"
	[[ -z ${platform} ]] && die "${FUNCNAME}: Platform is undefined"

	[[ -d "${WORKDIR}/build-${platform}" ]] || \
		{ mkdir "${WORKDIR}/build-${platform}" || die ; }
	pushd "${WORKDIR}/build-${platform}" > /dev/null || die

	echo ">>> Running ${phase} for platform \"${platform}\""
	echo ">>> Working in: \"${WORKDIR}/build-${platform}\""

	grub_${phase} ${platform}

	popd > /dev/null || die
}

grub_src_configure() {
	local platform=$1
	local target

	[[ -z ${platform} ]] && die "${FUNCNAME}: Platform is undefined"

	# if we have no platform then --with-platform=guessed does not work
	[[ ${platform} == "guessed" ]] && platform=""

	# check if we have to specify the target (EFI)
	# or just append correct --with-platform
	if [[ -n ${platform} ]]; then
		if [[ ${platform/-*} == ${platform} ]]; then
			platform=" --with-platform=${platform}"
		else
			# EFI platform hack
			[[ ${platform/*-} == 32 ]] && target=i386
			[[ ${platform/*-} == 64 ]] && target=x86_64
			# program-prefix is required empty because otherwise it is equal to
			# target variable, which we do not want at all
			platform="
				--with-platform=${platform/-*}
				--target=${target}
				--program-prefix=
			"
		fi
	fi

	ECONF_SOURCE="${WORKDIR}/${P}/" \
	econf \
		--disable-werror \
		--sbindir=/sbin \
		--bindir=/bin \
		--libdir=/$(get_libdir) \
		--disable-efiemu \
		$(use_enable device-mapper) \
		$(use_enable truetype grub-mkfont) \
		$(use_enable nls) \
		$(use_enable debug mm-debug) \
		$(use sdl && use_enable debug grub-emu-sdl) \
		$(use_enable debug grub-emu-usb) \
		${platform}
}

grub_src_compile() {
	default_src_compile
}

grub_src_install() {
	default_src_install
}

src_prepare() {
	local i j archs

	epatch "${FILESDIR}"/${PN}-1.99-genkernel.patch #256335
	epatch "${FILESDIR}"/${PN}-1.99-vga-deprecated.patch
	epatch "${FILESDIR}"/${PN}-1.99-wallpaper-settings-support.patch
	# This happens with md raid metadata 0.90. Due to limitations of the format
	epatch "${FILESDIR}"/${PN}-1.99-workaround-raid-bios-bug.patch
	# vga= not yet deprecated for us
	epatch "${FILESDIR}"/${PN}-1.99-vga-deprecated-not-yet.patch
	epatch "${FILESDIR}"/${PN}-1.99-disable-floppies.patch
	epatch_user
	# Genkernel doesn't support "single" for rescue mode
	# but rather init_opts=single
	epatch "${FILESDIR}"/${PN}-1.98-genkernel-initramfs-single.patch

	sed -i -e '/^autoreconf/ d' autogen.sh || die
	(. ./autogen.sh) || die
	eautoreconf

	# get enabled platforms
	GRUB_ENABLED_PLATFORMS=""
	for i in ${GRUB_PLATFORMS}; do
		use grub_platforms_${i} && GRUB_ENABLED_PLATFORMS+=" ${i}"
	done
	[[ -z ${GRUB_ENABLED_PLATFORMS} ]] && GRUB_ENABLED_PLATFORMS="guessed"
	einfo "Going to build following platforms: ${GRUB_ENABLED_PLATFORMS}"
}

src_configure() {
	local i

	use custom-cflags || unset CFLAGS CPPFLAGS LDFLAGS
	use static && append-ldflags -static

	for i in ${GRUB_ENABLED_PLATFORMS}; do
		grub_run_phase ${FUNCNAME} ${i}
	done
}

src_compile() {
	local i

	for i in ${GRUB_ENABLED_PLATFORMS}; do
		grub_run_phase ${FUNCNAME} ${i}
	done
}

src_install() {
	local i

	for i in ${GRUB_ENABLED_PLATFORMS}; do
		grub_run_phase ${FUNCNAME} ${i}
	done
	if use multislot ; then
		sed -i "s:grub-install:grub2-install:" "${D}"/sbin/grub-install || die
		mv "${D}"/sbin/grub{,2}-install || die
		mv "${D}"/sbin/grub{,2}-set-default || die
		mv "${D}"/usr/share/info/grub{,2}.info || die
	fi

	# can't be in docs array as we use defualt_src_install in different builddir
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
	insinto /etc/default
	newins "${FILESDIR}"/grub2-default-1.99 grub
	cat <<-EOF >> "${D}"/lib*/grub/grub-mkconfig_lib
	GRUB_DISTRIBUTOR="Sabayon"
EOF

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

	dodir /etc/env.d
	echo 'CONFIG_PROTECT_MASK="/etc/grub.d"' > "${D}/etc/env.d/10grub2"

}

setup_boot_dir() {
	local dir=$1

	if [[ ! -e ${dir}/grub.cfg ]]; then
		# display the link to guide if user didn't set up anything yet.
		elog "For informations how to configure grub-2 please reffer to guide:"
		# FIXME: we don't have any guide yet!
		# Lets just use archlinux wiki until we have some.
		elog "    https://wiki.archlinux.org/index.php/GRUB2"
	fi

	if [[ ! -e ${dir}/grub.cfg && -e ${dir}/menu.lst ]] ; then
		# This is first grub2 install and we have old configuraton for
		# grub1 around. Lets try to generate grub.cfg from it so user
		# does not loose any stuff when rebooting.
		# NOTE: in long term he still NEEDS to migrate to grub.d stuff.
		einfo "Running: grub-menulst2cfg '${dir}/menu.lst' '${dir}/grub.cfg'"
		grub-menulst2cfg "${dir}/menu.lst" "${dir}/grub.cfg" || \
			ewarn "Running grub-menulst2cfg failed!"

		einfo "Even if we just created configuration for your grub-2 using old"
		einfo "grub-1 configuration file you should migrate to use new style"
		einfo "configuration in '${ROOT}/etc/grub.d'."
		einfo
		elog "Remember to run grub-install to install your grub!"
	else
		# we need to refresh the grub.cfg everytime just to play it safe
		einfo "Running: grub-mkconfig -o '${dir}/grub.cfg'"
		grub-mkconfig -o "${dir}/grub.cfg" || \
			ewarn "Running grub-mkconfig failed! Check your configuration files!"
	fi

	elog "Remember to run \"grub-mkconfig -o '${dir}/grub.cfg'\" every time"
	elog "you update the configuration files."
}

pkg_postinst() {
	if use multislot ; then
		elog "You have installed grub2 with USE=multislot, so to coexist"
		elog "with grub1, the grub2 install binary is named grub2-install."
	fi
	mount-boot_mount_boot_partition

	setup_boot_dir "${ROOT}"boot/grub

	# needs to be called after we call setup_boot_dir
	mount-boot_pkg_postinst
}
