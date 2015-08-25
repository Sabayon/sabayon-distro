# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
AUTOTOOLS_AUTO_DEPEND=yes

inherit autotools-utils bash-completion-r1 eutils flag-o-matic multibuild pax-utils toolchain-funcs

if [[ ${PV} != 9999 ]]; then
	MY_P=${P/_/\~}
	if [[ ${PV} == *_alpha* || ${PV} == *_beta* || ${PV} == *_rc* ]]; then
		SRC_URI="mirror://gnu-alpha/${PN}/${MY_P}.tar.xz"
	else
		SRC_URI="mirror://gnu/${PN}/${MY_P}.tar.xz
			mirror://gentoo/${MY_P}.tar.xz"
	fi
	KEYWORDS="~amd64 ~x86"
	S=${WORKDIR}/${MY_P}
	PATCHES=(
		"${FILESDIR}"/${PN}-1.99-vga-deprecated.patch
		# vga= not yet deprecated for us
		"${FILESDIR}"/${PN}-2.00-vga-deprecated-not-yet.patch
		"${FILESDIR}"/${PN}-1.99-disable-floppies.patch
		# Genkernel doesn't support "single" for rescue mode
		# but rather init_opts=single
		"${FILESDIR}"/${PN}-2.00-genkernel-initramfs-single.patch
		# Down with SecureBoot
		"${FILESDIR}"/${PN}-2.00-secureboot-user-sign-2.patch

		"${FILESDIR}/${P}-parallel-make.patch" #424231
		"${FILESDIR}/${P}-no-gets.patch" #424703
		"${FILESDIR}/${P}-config-quoting.patch" #426364
		"${FILESDIR}/${P}-tftp-endian.patch" # 438612
		"${FILESDIR}/${P}-hardcoded-awk.patch" #424137
		"${FILESDIR}/${P}-freebsd.patch" #442050
		"${FILESDIR}/${P}-compression.patch" #424527
		"${FILESDIR}/${P}-zfs-feature-flag-support-r1.patch" #455358
		"${FILESDIR}/${P}-20_linux_xen.patch" #463992
		"${FILESDIR}/${P}-dmraid.patch" #430748
		"${FILESDIR}/${P}-texinfo.patch"
		"${FILESDIR}/${P}-os-prober-efi-system.patch" #477314
		"${FILESDIR}/${P}-fix-locale-en.mo.gz-not-found-error-message.patch" #408599
		"${FILESDIR}/101-freetype2_fix_mkfont.patch"
	)
else
	inherit bzr
	EBZR_REPO_URI="http://bzr.savannah.gnu.org/r/grub/trunk/grub/"
fi

DESCRIPTION="GNU GRUB boot loader"
HOMEPAGE="http://www.gnu.org/software/grub/"

LICENSE="GPL-3"
SLOT="2"
IUSE="custom-cflags debug device-mapper doc efiemu mount +multislot nls static sdl test truetype libzfs"

GRUB_ALL_PLATFORMS=(
	# everywhere:
	emu
	# mips only:
	qemu-mips yeeloong
	# amd64, x86, ppc, ppc64:
	ieee1275
	# amd64, x86:
	coreboot multiboot efi-32 pc qemu
	# amd64, ia64:
	efi-64
)
IUSE+=" ${GRUB_ALL_PLATFORMS[@]/#/grub_platforms_}"

REQUIRED_USE="grub_platforms_qemu? ( truetype )
	grub_platforms_yeeloong? ( truetype )"

# os-prober: Used on runtime to detect other OSes
# xorriso (dev-libs/libisoburn): Used on runtime for mkrescue
# sbsigntool is Sabayon specific
RDEPEND="
	app-crypt/sbsigntool
	app-arch/xz-utils
	>=sys-libs/ncurses-5.2-r5
	debug? (
		sdl? ( media-libs/libsdl )
	)
	device-mapper? ( >=sys-fs/lvm2-2.02.45 )
	libzfs? ( sys-fs/zfs )
	mount? ( sys-fs/fuse )
	truetype? (
		media-libs/freetype
		media-fonts/dejavu
		>=media-fonts/unifont-5
	)
	ppc? ( sys-apps/ibm-powerpc-utils sys-apps/powerpc-utils )
	ppc64? ( sys-apps/ibm-powerpc-utils sys-apps/powerpc-utils )
"
DEPEND="${RDEPEND}
	app-misc/pax-utils
	>=dev-lang/python-2.5.2
	sys-devel/flex
	sys-devel/bison
	sys-apps/help2man
	sys-apps/texinfo
	>=sys-devel/autogen-5.10
	static? (
		truetype? (
			app-arch/bzip2[static-libs(+)]
			media-libs/freetype[static-libs(+)]
			sys-libs/zlib[static-libs(+)]
		)
	)
	test? (
		dev-libs/libisoburn
		app-emulation/qemu
	)
"
RDEPEND+="
	kernel_linux? (
		grub_platforms_efi-32? ( sys-boot/efibootmgr )
		grub_platforms_efi-64? ( sys-boot/efibootmgr )
	)
	!multislot? ( !sys-boot/grub:0 )
"

STRIP_MASK="*/grub/*/*.{mod,img}"
RESTRICT="test"

QA_EXECSTACK="
	usr/bin/grub*
	usr/sbin/grub*
	usr/lib*/grub/*/*.mod
	usr/lib*/grub/*/*.module
	usr/lib*/grub/*/kernel.exec
	usr/lib*/grub/*/kernel.img
"

QA_WX_LOAD="
	usr/lib*/grub/*/kernel.exec
	usr/lib*/grub/*/kernel.img
	usr/lib*/grub/*/*.image
"

QA_PRESTRIPPED="
	usr/lib.*/grub/.*/kernel.img
"

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		# Bug 439082
		if $(tc-getLD) --version | grep -q "GNU gold"; then
			eerror "GRUB does not function correctly when built with the gold linker."
			eerror "Please select the bfd linker with binutils-config."
			die "GNU gold detected"
		fi
	fi
}

src_prepare() {
	[[ ${PATCHES} ]] && epatch "${PATCHES[@]}"
	sed -i -e /autoreconf/d autogen.sh || die
	if use multislot; then
		# fix texinfo file name, bug 416035
		sed -i -e 's/^\* GRUB:/* GRUB2:/' -e 's/(grub)/(grub2)/' docs/grub.texi || die
	fi
	epatch_user
	bash autogen.sh || die
	autopoint() { return 0; }
	eautoreconf
}

grub_configure() {
	local platform

	case ${MULTIBUILD_VARIANT} in
		efi-32)
			platform=efi
			if [[ ${CTARGET:-${CHOST}} == x86_64* ]]; then
				local CTARGET=${CTARGET:-i386}
			fi ;;
		efi-64)
			platform=efi
			if [[ ${CTARGET:-${CHOST}} == i?86* ]]; then
				local CTARGET=${CTARGET:-x86_64}
				local TARGET_CFLAGS="-Os -march=x86-64 ${TARGET_CFLAGS}"
				local TARGET_CPPFLAGS="-march=x86-64 ${TARGET_CPPFLAGS}"
				export TARGET_CFLAGS TARGET_CPPFLAGS
			fi ;;
		guessed) ;;
		*)	platform=${MULTIBUILD_VARIANT} ;;
	esac

	# Sabayon: backward compatibility, do not change --with-grubdir
	local myeconfargs=(
		--disable-werror
		--program-prefix=
		--program-transform-name="s,grub,grub2,"
		--libdir="${EPREFIX}"/usr/lib
		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html
		$(use_enable debug mm-debug)
		$(use_enable debug grub-emu-usb)
		$(use_enable mount grub-mount)
		$(use_enable nls)
		$(use_enable truetype grub-mkfont)
		$(use_enable libzfs)
		$(use sdl && use_enable debug grub-emu-sdl)
		${platform:+--with-platform=}${platform}

		# Let configure detect this where supported
		$(usex efiemu '' --disable-efiemu)
	)

	# Sabayon: keep --with-grubdir=grub to grub for backward compatibility
	if use multislot; then
		myeconfargs+=(
			--program-transform-name="s,grub,grub2,"
			--with-grubdir=grub
		)
	fi

	autotools-utils_src_configure
}

src_configure() {
	use custom-cflags || unset CCASFLAGS CFLAGS CPPFLAGS LDFLAGS
	use static && append-ldflags -static

	tc-export CC NM OBJCOPY STRIP
	export TARGET_CC=${TARGET_CC:-${CC}}

	# Portage will take care of cleaning up GRUB_PLATFORMS
	MULTIBUILD_VARIANTS=( ${GRUB_PLATFORMS:-guessed} )
	multibuild_parallel_foreach_variant grub_configure
}

src_compile() {
	# Sandbox bug 404013.
	use libzfs && addpredict /etc/dfs:/dev/zfs

	multibuild_foreach_variant autotools-utils_src_compile

	use doc && multibuild_for_best_variant \
		autotools-utils_src_compile -C docs html
}

src_test() {
	# The qemu dependency is a bit complex.
	# You will need to adjust QEMU_SOFTMMU_TARGETS to match the cpu/platform.
	multibuild_foreach_variant autotools-utils_src_test
}

src_install() {
	multibuild_foreach_variant autotools-utils_src_install \
		bashcompletiondir="$(get_bashcompdir)"

	use doc && multibuild_for_best_variant run_in_build_dir \
		emake -C docs DESTDIR="${D}" install-html

	# Install fonts setup hook
	exeinto /etc/grub.d
	doexe "${FILESDIR}/00_fonts"

	if use multislot; then
		mv "${ED%/}"/usr/share/info/grub{,2}.info || die
	fi

	insinto /etc/default
	newins "${FILESDIR}"/grub.default-2 grub

	# Backward compatibility with Grub 1.99 executables
	dosym /usr/sbin/grub2-mkconfig /sbin/grub-mkconfig
	dosym /usr/sbin/grub2-install /sbin/grub2-install

	cd "${ED}" || die
	pax-mark mpes $(scanelf -BF %F usr/{bin,sbin})
}

pkg_postinst() {
	elog "For information on how to configure grub-2 please refer to the guide:"
	elog "    http://wiki.gentoo.org/wiki/GRUB2_Quick_Start"
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		if ! has_version sys-boot/os-prober; then
			elog "Install sys-boot/os-prober to enable detection of other operating systems using grub2-mkconfig."
		fi
		if ! has_version dev-libs/libisoburn; then
			elog "Install dev-libs/libisoburn to enable creation of rescue media using grub2-mkrescue."
		fi
	fi
}
