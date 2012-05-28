# Copyright 2004-2012 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $

AT_M4DIR="config"
AUTOTOOLS_AUTORECONF="1"
AUTOTOOLS_IN_SOURCE_BUILD="1"

inherit eutils flag-o-matic git-2 linux-mod autotools-utils

# export all the available functions here
EXPORT_FUNCTIONS pkg_setup src_prepare src_configure src_install src_test pkg_preinst pkg_postinst pkg_postrm

EGIT_REPO_URI="git://github.com/ryao/spl.git"
EGIT_BRANCH="gentoo"
SRC_URI=""

# @ECLASS-VARIABLE: SPL_TARGET
# @DESCRIPTION:
# Identifies either the userspace tools (="userspace")
# or the kernel module (="kernel")
SPL_TARGET="${SPL_TARGET:-}"

if [ "${SPL_TARGET}" = "userspace" ]; then
	DESCRIPTION="The Solaris Porting Layer userspace utilities"
else
	DESCRIPTION="The Solaris Porting Layer Linux kernel module"
fi

HOMEPAGE="http://zfsonlinux.org/"

LICENSE="|| ( GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="custom-cflags debug"

RDEPEND="!sys-devel/spl"
if [ "${SPL_TARGET}" = "kernel" ]; then
	RDEPEND+=" ~sys-kernel/spl-userspace-${PV}"
fi

spl-snapshot_pkg_setup() {
	if [ "${SPL_TARGET}" = "kernel" ]; then
		CONFIG_CHECK="
			!DEBUG_LOCK_ALLOC
			MODULES
			KALLSYMS
			ZLIB_DEFLATE
			ZLIB_INFLATE
		"
		kernel_is ge 2 6 26 || die "Linux 2.6.26 or newer required"
		check_extra_config
	fi
}

spl-snapshot_src_prepare() {
	# Workaround for hard coded path
	sed -i "s|/sbin/lsmod|/bin/lsmod|" scripts/check.sh || die
	autotools-utils_src_prepare
}

spl-snapshot_src_configure() {
	use custom-cflags || strip-flags
	local what_config
	if [ "${SPL_TARGET}" = "kernel" ]; then
		what_config="kernel"
		set_arch_to_kernel
	else
		what_config="user"
	fi
	local myeconfargs=(
		--bindir="${EPREFIX}/bin"
		--sbindir="${EPREFIX}/sbin"
		--with-config=all
		--with-linux="${KV_DIR}"
		--with-linux-obj="${KV_OUT_DIR}"
		$(use_enable debug)
		--with-config="${what_config}"
	)
	autotools-utils_src_configure
}

spl-snapshot_src_install() {
	autotools-utils_src_install
	if [ "${SPL_TARGET}" = "kernel" ]; then
		rm -rf "${ED}/usr" # make sure
	fi
}

spl-snapshot_src_test() {
	if [[ ! -e /proc/modules ]]
	then
		die  "Missing /proc/modules"
	elif [[ $UID -ne 0 ]]
	then
		ewarn "Cannot run make check tests with FEATURES=userpriv."
		ewarn "Skipping make check tests."
	elif grep -q '^spl ' /proc/modules
	then
		ewarn "Cannot run make check tests with module spl loaded."
		ewarn "Skipping make check tests."
	else
		autotools-utils_src_test
	fi
}

spl-snapshot_pkg_preinst() {
	[[ "${SPL_TARGET}" = "kernel" ]] && \
		linux-mod_pkg_preinst
}

spl-snapshot_pkg_postinst() {
	[[ "${SPL_TARGET}" = "kernel" ]] && \
		linux-mod_pkg_postinst
}

spl-snapshot_pkg_postrm() {
	[[ "${SPL_TARGET}" = "kernel" ]] && \
		linux-mod_pkg_postrm
}
