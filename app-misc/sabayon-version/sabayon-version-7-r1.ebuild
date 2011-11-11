# Copyright 2004-2011 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Sabayon System Release virtual package"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""
DEPEND=""
# Listing default packages for the current release
RDEPEND="app-admin/eselect-python
	dev-lang/python:2.7
	sys-devel/base-gcc:4.6
	sys-devel/gcc-config"

SABAYON_VER="${PV}"
SABAYON_HEADER="Sabayon Linux"
SABAYON_RELEASE="sabayon-release"

src_unpack () {
	if use x86; then
		echo "${SABAYON_HEADER} x86 ${SABAYON_VER}" > "${SABAYON_RELEASE}"
	else
		echo "${SABAYON_HEADER} amd64 ${SABAYON_VER}" > "${SABAYON_RELEASE}"
	fi
}

src_install () {
	insinto /etc
	doins sabayon-release
	dosym /etc/sabayon-release /etc/system-release
}

pkg_postinst() {
	# Setup Python 2.7
	eselect python update --ignore 3.0 --ignore 3.1 --ignore 3.2 --ignore 3.3 --ignore 3.4

	# Setup GCC 4.5 (it's also in packages.db.post_upgrade.sh
	c_profile=$(gcc-config -l | grep "\-4.5" | cut -d"[" -f 2 | cut -d"]" -f 1)
	[[ "${?}" != "0" ]] && ewarn "gcc-config script error" && exit 1
	if [[ ${c_profile} =~ ^[0-9]+$ ]]; then
		gcc-config ${c_profile}
		env-update
	else
		ewarn "gcc-config unable to set new profile:" ${c_profile}
	fi
}
