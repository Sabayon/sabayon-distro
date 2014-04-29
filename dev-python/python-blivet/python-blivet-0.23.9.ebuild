# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
SUPPORT_PYTHON_ABIS="1"

inherit eutils distutils

REAL_PN="${PN/python-}"

DESCRIPTION="python module for examining and modifying storage configuration."
HOMEPAGE="https://fedoraproject.org/wiki/Blivet"
SRC_URI="https://github.com/Sabayon/${REAL_PN}/archive/${REAL_PN}-${PV}-1.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-util/pykickstart-1.99.22
	>=sys-apps/util-linux-2.15.1
	>=sys-block/parted-1.8.1
	sys-fs/cryptsetup
	>=dev-python/python-cryptsetup-0.1.1
	sys-fs/mdadm
	sys-fs/dosfstools
	>=sys-fs/e2fsprogs-1.41.0
	sys-fs/btrfs-progs
	>=dev-python/pyblock-0.45
	sys-fs/multipath-tools
	sys-process/lsof
	"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${REAL_PN}-${REAL_PN}-${PV}-1"

src_prepare() {
	# libudev in Gentoo is in /usr/lib64 if systemd
	epatch "${FILESDIR}/${PN}-udev-path.patch"

	distutils_src_prepare
}
