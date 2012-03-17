EAPI="3"
SUPPORT_PYTHON_ABIS="1"

DESCRIPTION="Additional theme icons for Gnome15"
HOMEPAGE="http://www.gnome15.org/"
SRC_URI="http://www.gnome15.org/downloads/Gnome15/Optional/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND="app-misc/gnome15-core"
DEPEND="${RDEPEND}"


src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}


