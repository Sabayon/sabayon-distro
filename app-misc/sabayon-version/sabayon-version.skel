# Copyright 2004-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit multilib

DESCRIPTION="Sabayon system release virtual package"
HOMEPAGE="http://www.sabayon.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

IUSE=""
DEPEND=""
GCC_VER="4.7"
PYTHON_VER="2.7"
# Listing default packages for the current release
RDEPEND="app-admin/eselect-python
	dev-lang/python:${PYTHON_VER}
	sys-apps/systemd
	sys-devel/base-gcc:${GCC_VER}
	sys-devel/gcc-config"

src_unpack () {
	echo "Sabayon Linux ${ARCH} ${PV}" > "${T}/sabayon-release"
	mkdir -p "${S}" || die
}

src_install () {
	insinto /etc
	doins "${T}"/sabayon-release
	dosym /etc/sabayon-release /etc/system-release
	# Bug 3459 - reduce the risk of fork bombs
	insinto /etc/security/limits.d
	doins "${FILESDIR}/00-sabayon-anti-fork-bomb.conf"
}

pkg_postinst() {
	# Setup Python ${PYTHON_VER}
	eselect python set python${PYTHON_VER}

	# Setup GCC profile
	local find_target="${CHOST}-${GCC_VER}*"
	elog "Trying to find: ${find_target} in /etc/env.d/gcc"
	local gcc_profile=$( find "${ROOT}/etc/env.d/gcc" -name "${find_target}-vanilla" -print )
	[[ -z "${gcc_profile}" ]] && \
		gcc_profile=$( find "${ROOT}/etc/env.d/gcc" -name "${find_target}" -print )

	if [[ -n "${gcc_profile}" ]]; then
		gcc_profile=$(basename ${gcc_profile})
		echo "Found GCC profile: ${gcc_profile}, switching"
		gcc-config "${gcc_profile}"
	else
		eerror "GCC profile for ${GCC_VER} not found"
	fi

	# Improve systemd support
	if [[ ! -L /etc/mtab ]] && [[ -e /proc/self/mounts ]]; then
		rm -f /etc/mtab
		einfo "Migrating /etc/mtab to a /proc/self/mounts symlink"
		ln -sf /proc/self/mounts /etc/mtab
	fi
}
