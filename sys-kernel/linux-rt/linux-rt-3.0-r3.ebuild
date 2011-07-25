# Copyright 1999-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

K_PREPATCHED="yes"
UNIPATCH_STRICTORDER="yes"

ETYPE="sources"
K_KERNEL_SOURCES_PKG="sys-kernel/rt-sources-${PVR}"
K_NOSETEXTRAVERSION="don't_set_it"
inherit sabayon-kernel

RT_PATCH="patch-3.0-rt3.patch.bz2"

RESTRICT="mirror"
DESCRIPTION="Realtime Preemption patched low latency Linux kernel binaries"
SRC_URI="${KERNEL_URI}
http://www.kernel.org/pub/linux/kernel/projects/rt/${RT_PATCH}
http://www.kernel.org/pub/linux/kernel/projects/rt/older/${RT_PATCH}"

KEYWORDS="~amd64 ~x86"
IUSE=""

src_unpack(){
	kernel-2_src_unpack

	epatch "${DISTDIR}/${RT_PATCH}"

}

K_EXTRAEINFO="This kernel is not supported by Gentoo If you have any issues, try
a matching vanilla-sources ebuild -- if the problem persists there, please file
a bug at http://bugme.osdl.org. If the problem only occurs with rt-sources then
please contact the -rt mailing list: http://www.mail-archive.com/linux-rt-users@vger.kernel.org/ .
Recommended other packages: sys-process/rtirq and sys-apps/das_watchdog"
