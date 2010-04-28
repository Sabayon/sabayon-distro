EAPI="0"
inherit eutils linux-mod

DESCRIPTION="high performance network sniffer for packet inspection"
HOMEPAGE="http://code.google.com/p/netsniff-ng/"
SRC_URI="http://netsniff-ng.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

CONFIG_CHECK="PACKET_MMAP"
ERROR_PACKET_MMAP="${P} requires CONFIG_PACKET_MMAP support"

RESTRICT="mirror"
S="${WORKDIR}/${PN}_${PV}/src/"

pkg_setup() {
	linux-mod_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_compile() {
	emake || die
}

src_install() {
	dobin netsniff-ng
	doman doc/*.8 || die
	insinto /etc/netsniff-ng/rules/
	doins rules/* || die
}
