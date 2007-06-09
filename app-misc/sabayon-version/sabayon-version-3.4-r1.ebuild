# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="SabayonLinux Release version file"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="x86_release x86_64_release x86_mini_release x86_64_mini_release x86_be_release x86_64_be_release"
SABAYON_VER="${PV}"
SABAYON_HEADER="Sabayon Linux"
SABAYON_RELEASE="sabayon-release"

src_unpack () {

        cd ${WORKDIR}

	if use x86_release; then
		echo ${SABAYON_HEADER}" x86 "${SABAYON_VER} > ${SABAYON_RELEASE}
	elif use x86_64_release; then
		echo ${SABAYON_HEADER}" x86-64 "${SABAYON_VER} > ${SABAYON_RELEASE}
	elif use x86_mini_release; then
		echo ${SABAYON_HEADER}" x86.miniEdition "${SABAYON_VER} > ${SABAYON_RELEASE}
	elif use x86_64_mini_release; then
		echo ${SABAYON_HEADER}" x86-64.miniEdition "${SABAYON_VER} > ${SABAYON_RELEASE}
	elif use x86_be_release; then
		echo ${SABAYON_HEADER}" x86.BusinessEdition "${SABAYON_VER} > ${SABAYON_RELEASE}
	elif use x86_64_be_release; then
		echo ${SABAYON_HEADER}" x86-64.BusinessEdition "${SABAYON_VER} > ${SABAYON_RELEASE}
	else
		die "No release type selected using USE flags"
	fi
}

src_install () {

	cd ${WORKDIR}
	insinto /etc/
	doins sabayon-release

}
