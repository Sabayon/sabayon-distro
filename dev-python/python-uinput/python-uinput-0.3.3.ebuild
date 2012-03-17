EAPI="3"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Python API to the Linux uinput-system."
HOMEPAGE="http://codegrove.org/projects/python-uinput/"
SRC_URI="http://pypi.python.org/packages/source/p/python-uinput/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND="dev-libs/libsuinput"
DEPEND="${RDEPEND}"

RESTRICT_PYTHON_ABIS="3.*"
