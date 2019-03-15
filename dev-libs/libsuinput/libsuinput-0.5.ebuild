EAPI="3"

DESCRIPTION="Helper functions to simplify Uinput usage."
HOMEPAGE="http://codegrove.org/projects/libsuinput"
SRC_URI="http://edge.launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"


src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}



