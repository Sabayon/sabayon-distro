# Copyright 1999-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

MY_PV="1.01"

DESCRIPTION="CUPS filters and drivers for Xerox Phaser 6000B and 6010"
HOMEPAGE="http://www.support.xerox.com/support/phaser-6000"
SRC_URI="http://download.support.xerox.com/pub/drivers/6000/drivers/linux/en_GB/6000_6010_rpm_${MY_PV}_${PV}.zip"
LICENSE="as-is"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="app-arch/unzip app-arch/rpm2targz sys-apps/findutils"
RDEPEND="amd64? ( app-emulation/emul-linux-x86-baselibs )
	net-print/cups"

S="${WORKDIR}/rpm_${MY_PV}_${PV}"
RESTRICT="strip"

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	mkdir -p "${S}/out"

	local fs=( *.rpm )
	local f=
	for f in "${fs[@]}"; do
		rpm2tar -O "${f}" | tar -x -v -C "${S}/out" -f - || die
	done
}

src_install() {
	find "${S}/out" -name "*.ppd.gz" -delete || die
	cp -d -p --recursive "${S}/out/"* "${ED}/" || die

	insinto /usr/share/cups/model
	doins "${S}"/*.ppd.gz || die "missing ppd files"
}
