# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

K_PREPATCHED="yes"
UNIPATCH_STRICTORDER="yes"

ETYPE="sources"
inherit kernel-2 eutils fetch-tools reiser4-patch patcher
detect_version
#get_realtime_patch_url
K_NOSETEXTRAVERSION="don't_set_it"

#FBSPLASH="fbcondecor-0.9.4_for_2.6.26-rt.patch"
RT_PATCH="patch-${KV}.bz2"

RESTRICT="mirror"
DESCRIPTION="Realtime Preemption patched low latency Linux kernel"
SRC_URI="${KERNEL_URI}
http://www.kernel.org/pub/linux/kernel/projects/rt/${RT_PATCH}
http://www.kernel.org/pub/linux/kernel/projects/rt/older/${RT_PATCH}"
#fbcondecor? ( http://proaudio.tuxfamily.org/patches/${FBSPLASH} )"
#http://download.tuxfamily.org/proaudio/realtime-patches/${RT_PATCH}

KEYWORDS="~amd64 ~x86"
IUSE=""
#"fbcondecor"

#pkg_setup(){
#	einfo "Additional patches for $PN can be enabled with following USE-flags:"
#	echo
#	einfo "fbcondecor - Add support for fbcondecor framebuffer splash"
#	echo
#	sleep 3
#}

src_unpack(){
	kernel-2_src_unpack

	epatch "${DISTDIR}/${RT_PATCH}"

	# fix sandbox_problems
	epatch "${FILESDIR}/build-id-sandbox-violation.patch"

	# Spock's stuff
#	use fbcondecor && epatch "${DISTDIR}/${FBSPLASH}"
	
	# hotfix http://article.gmane.org/gmane.linux.audio.users/52475
#	epatch "${FILESDIR}/${PN}-2.6.26_fix_midi.patch"

}

K_EXTRAEINFO="This kernel is not supported by Gentoo If you have any issues, try
a matching vanilla-sources ebuild -- if the problem persists there, please file
a bug at http://bugme.osdl.org. If the problem only occurs with rt-sources then
please contact the -rt mailing list: http://www.mail-archive.com/linux-rt-users@vger.kernel.org/ .
Recommended other packages: sys-process/rtirq and sys-apps/das_watchdog"
