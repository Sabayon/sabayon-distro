# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
PYTHON_COMPAT=( python{2_7,3_4,3_5} )

inherit eutils distutils-r1

REAL_PN="${PN/python-}"

DESCRIPTION="A python module for system storage configuration"
HOMEPAGE="https://fedoraproject.org/wiki/Blivet"
SRC_URI="https://github.com/rhinstaller/${REAL_PN}/archive/${REAL_PN}-${PV}-1.tar.gz"
RESTRICT="mirror"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-util/pykickstart-1.99.22
	>=sys-apps/util-linux-2.15.1
	>=sys-block/parted-1.8.1
	sys-fs/cryptsetup
	>=dev-python/pyparted-2.5
	>=dev-python/pyudev-0.20
	sys-fs/mdadm
	sys-fs/dosfstools
	>=sys-fs/e2fsprogs-1.41.0
	sys-fs/btrfs-progs
	>=dev-python/pyblock-0.45
	=sys-fs/multipath-tools-0.5.0-r99
	<sys-libs/libblockdev-0.14
	sys-process/lsof
	"

DEPEND="${RDEPEND}
	sys-devel/gettext"

S="${WORKDIR}/${REAL_PN}-${REAL_PN}-${PV}-1"

src_prepare() {
	# Sabayon specific patches and bug fixes:
	epatch "${FILESDIR}/1.0/0001-Update-package-names-to-reflect-Gentoo-ones.patch"
	epatch "${FILESDIR}/1.0/0002-devices-enable-UUID-for-dm-based-devices-in-fstab.patch"
	epatch "${FILESDIR}/1.0/0003-Call-udev.settle-when-committing-to-disk.patch"
	epatch "${FILESDIR}/1.0/0004-Add-support-for-parsing-etc-sabayon-release.patch"

	distutils-r1_src_prepare
}
