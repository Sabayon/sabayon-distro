# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="SabayonLinux Release version file"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="x86 amd64 x86-mini amd64-mini"

src_unpack () {

        cd ${WORKDIR}
	if use x86-mini; then
		cp ${FILESDIR}/${PV}/sabayon-release-x86 sabayon-release -p
	elif use x86_64-mini; then
		cp ${FILESDIR}/${PV}/sabayon-release-x86_64 sabayon-release -p
	elif use x86; then
		cp ${FILESDIR}/${PV}/sabayon-release-x86mini sabayon-release -p
	elif use amd64; then
		cp ${FILESDIR}/${PV}/sabayon-release-x86_64mini sabayon-release -p
	fi

}

src_install () {

	cd ${WORKDIR}
	insinto /etc/
	doins sabayon-release

}
