# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2

BC_REVISION="1"
DESCRIPTION="Firmware for the Afatech 9005 DVB-T device"
HOMEPAGE="http://www.linuxtv.org/"
SRC_URI="mirror://sabayon/media-tv/af9005.fw"

LICENSE="AS-IS"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"

IUSE=""
DEPEND=">=sys-apps/hotplug-20040923"

src_unpack()
{
	cp ${DISTDIR}/af9005.fw ${WORKDIR}/
}

src_install() {
	cd ${WORKDIR}/
	insinto /lib/firmware
	doins *.fw
}
