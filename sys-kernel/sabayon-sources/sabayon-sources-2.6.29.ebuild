# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_WANT_GENPATCHES=""
K_GENPATCHES_VER=""
inherit kernel-2
detect_version
detect_arch

DESCRIPTION="Official Sabayon Linux Standard kernel sources"
RESTRICT="nomirror"
IUSE=""
SRC_URI="${KERNEL_URI}"
UNIPATCH_STRICTORDER="yes"
KEYWORDS="~amd64 ~x86"
HOMEPAGE="http://www.sabayon.org"
SLOT="${PV}"

UNIPATCH_LIST="
        ${FILESDIR}/${PV}/patch-2.6.29.1.bz2
        ${FILESDIR}/${PV}/linux-sabayon-${PV}-aufs.patch.bz2
        ${FILESDIR}/${PV}/current-tuxonice-for-head.patch-20090313-v1.bz2
        ${FILESDIR}/${PV}/linux-sabayon-${PV}-acpi-issues-bug-13002.patch.bz2
"


# gentoo patches
for patch in `find ${FILESDIR}/${PV}/genpatches -iname "*.patch*" | sort -n`; do
        UNIPATCH_LIST="${UNIPATCH_LIST} ${patch}"
done

# mactel patches
for patch in `find ${FILESDIR}/${PV}/mactel -iname "*.patch*" | sort -n`; do
        UNIPATCH_LIST="${UNIPATCH_LIST} ${patch}"
done

src_install() {
	kernel-2_src_install
	local oldarch=${ARCH}
	cp ${FILESDIR}/linux-sabayon-${PV}-${ARCH}.config .config || die "cannot copy kernel config"
	unset ARCH
	make modules_prepare || die "failed to run modules_prepare"
	rm .config || die "unable to rm .config"
	ARCH=${oldarch}
}
