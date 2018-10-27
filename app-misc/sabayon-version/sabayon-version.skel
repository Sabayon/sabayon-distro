# Copyright 2004-2017 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit multilib

DESCRIPTION="Sabayon system release virtual package"
HOMEPAGE="http://www.sabayon.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86 ~arm64"

IUSE=""
DEPEND=""
GCC_VER="6.4.0"
PYTHON_VER="3.6"
# Listing default packages for the current release
RDEPEND="!app-admin/eselect-init
	!<sys-apps/sysvinit-1000
	!sys-apps/hal
	!sys-auth/consolekit
	app-eselect/eselect-python
	dev-lang/python:${PYTHON_VER}
	sys-apps/systemd
	sys-kernel/sabayon-dracut
	virtual/man
	sys-devel/base-gcc:${GCC_VER}
	sys-devel/gcc-config"

src_unpack () {
	echo "Sabayon Linux ${ARCH} ${PV}" > "${T}/sabayon-release"

	# Anaconda expects a "release" somewhere in the string
	# and no trailing \n
	echo -n "Sabayon ${ARCH} release ${PV}" > "${T}/system-release"
	mkdir -p "${S}" || die
}

src_install () {
	insinto /etc
	doins "${T}"/sabayon-release
	doins "${T}"/system-release

	# Bug 3459 - reduce the risk of fork bombs
	insinto /etc/security/limits.d
	doins "${FILESDIR}/00-sabayon-anti-fork-bomb.conf"

	# Create this directory here. It is normally provided by
	# sys-apps/baselayout, but in a way (installed in pkg_preinst when
	# USE=build) that it is not recorded as belonging to that package.
	keepdir /var/empty
}

pkg_postinst() {
	# Setup Python ${PYTHON_VER}
	# not critical, can be removed (with the file) after some time
	local py3file="${ROOT}/etc/sabayon-py3-was-set"
	if [[ ! -e ${py3file} ]]; then
		ewarn "Switching to Python 3 (${PYTHON_VER}) as default."
		ewarn "This is a one time action. Override using eselect if preferred."
		eselect python set python${PYTHON_VER} \
			&& touch "${py3file}"
	fi

	# No need to set the GCC profile here, since it's done in base-gcc

	# Improve systemd support
	if [[ ! -L /etc/mtab ]] && [[ -e /proc/self/mounts ]]; then
		rm -f /etc/mtab
		einfo "Migrating /etc/mtab to a /proc/self/mounts symlink"
		ln -sf /proc/self/mounts /etc/mtab
	fi

	# force kdm back to the default runlevel if added to boot
	# this is in preparation for the logind migration
	local xdm_conf="${ROOT}/etc/conf.d/xdm"
	local xdm_boot_runlevel="${ROOT}/etc/runlevels/boot/xdm"
	local xdm_default_runlevel="${ROOT}/etc/runlevels/default/xdm"
	if [ -e "${xdm_conf}" ] && [ -e "${xdm_boot_runlevel}" ]; then
		DISPLAYMANAGER=""
		. "${xdm_conf}"
		if [ "${DISPLAYMANAGER}" = "kdm" ]; then
			elog "Moving xdm (kdm) from boot runlevel to default"
			elog "or logind will not work as expected"
			mv -f "${xdm_boot_runlevel}" "${xdm_default_runlevel}"
		fi
	fi

	# remove old hal udev rules.d file, if found. sys-apps/hal is long gone.
	rm -f "${ROOT}/lib/udev/rules.d/90-hal.rules"
}
