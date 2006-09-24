# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:
# Ebuild grabbed from http://bugs.gentoo.org/show_bug.cgi?id=129216

inherit linux-mod

DESCRIPTION="Drivers for the realtek 8168 gigabit ethernet chip"
HOMEPAGE="http://www.realtek.com.tw/downloads/downloads1-3.aspx?keyword=8168"
#SRC_URI="http://www.spillkescht.lu/david/linux-${PN}-${PV}.zip"
RESTRICT="mirror"
SRC_URI="ftp://202.65.194.18/cn/nic/${PN}_v${PV}.tgz"
#The 2 other mirrors:
#ftp://152.104.238.194/cn/nic/rtl8111brtl8168b/
#ftp://210.51.181.211/cn/nic/rtl8111brtl8168b/

LICENSE="GPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE=""
# why there isn't any virtual depend atom like virtual/kernel-sources ?!?!
# everyone with other sources has to use --nodeps or rewrite the ebuild 
# with a static DEPEND on sources... so disable this DEPEND ;)
# who uses this ebuild knows, that his sources should be <=2.6.16 ;)
#DEPEND="<=sys-kernel/gentoo-sources-2.6.16-r12"
DEPEND=""
RDEPEND="sys-apps/module-init-tools" # ;)

BUILD_TARGETS="modules"

S=${WORKDIR}/${PN}_v${PV}/
MODULE_NAMES="r1000(kernel/net:${S}:${S}/src)"

pkg_setup() {
	linux-mod_pkg_setup

	BUILD_PARAMS="KSRC=${KV_DIR}"
}

src_unpack() {
	unpack ${A}

	convert_to_m ${S}/src/Makefile
	# FIX compilation bug when using 2.6.17 or newer kernel(sources)
	#the MODULE_PARM function(2.4 kernels) is no longer supported
	if [ ${KV_MINOR} -gt 5 ]; then
		einfo "Change the sources to use module_param_array instead of MODULE_PARM(obsolete from 2.4)"
		# unfortunately dosed is only usable in ${D}, not ${S}
		local _tmp=${S}/src/r1000_n.c
		mv ${_tmp} ${_tmp}.orig
		sed -e 's:MODULE_PARM:module_param_array:' \
			-e 's:"1-" __MODULE_STRING(MAX_UNITS) "i":int, NULL, 0444:' \
			${_tmp}.orig > ${_tmp}
		rm ${_tmp}.orig
	fi
}

src_install() {
	linux-mod_src_install
	dodoc README
}

pkg_postinst() {
	einfo "The in-kernel r8169 driver will support the hardware"
	einfo "supported by r1000 very soon, so watch out when new kernel"
	einfo "sources are released."
}

