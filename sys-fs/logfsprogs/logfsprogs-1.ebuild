# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="Tools to manage LogFS partitions"
HOMEPAGE="http://logfs.org/"
SRC_URI="http://lazybastard.org/~joern/progs/mklogfs"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""

src_unpack() {
	mkdir -p "${S}"
	cd "${S}"
	cp "${DISTDIR}"/mklogfs .
}

src_compile() {
	einfo "nothing to compile"
}

src_install() {

	exeinto /sbin
	doexe mklogfs
	dosym /sbin/mklogfs /sbin/mkfs.logfs

}
