# Copyright 2004-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $

SUPPORTED_AVAHI_MODULES="base gtk gtk3 mono qt"

# @ECLASS-VARIABLE: AVAHI_MODULE
# @DESCRIPTION:
# Set this variable to the avahi module ebuild name, by default it's used
# the second part of PN, for example: for avahi-glib, it is "glib".
# Supported avahi modules:
# base gtk gtk3 mono qt
AVAHI_MODULE="${AVAHI_MODULE:-${PN/avahi-}}"

# @ECLASS-VARIABLE: AVAHI_PATCHES
# @DEFAULT-UNSET
# @DESCRIPTION:
# List of patches to apply
if [ -z "${AVAHI_PATCHES}" ]; then
	AVAHI_PATCHES=()
fi

# @ECLASS-VARIABLE: AVAHI_MODULE_DEPEND
# @DESCRIPTION:
# Avahi module built time dependencies list
AVAHI_MODULE_DEPEND="${AVAHI_MODULE_DEPEND:-}"

# @ECLASS-VARIABLE: AVAHI_MODULE_RDEPEND
# @DESCRIPTION:
# Avahi module run time dependencies list
AVAHI_MODULE_RDEPEND="${AVAHI_MODULE_RDEPEND:-}"

# @ECLASS-VARIABLE: AVAHI_MODULE_PDEPEND
# @DESCRIPTION:
# Avahi module post dependencies list
AVAHI_MODULE_PDEPEND="${AVAHI_MODULE_PDEPEND:-}"

_supported="0"
for mod in ${SUPPORTED_AVAHI_MODULES} ; do
    if [ "${mod}" = "${AVAHI_MODULE}" ]; then
        _supported="1"
        break
    fi
done
if [ "${_supported}" = "0" ]; then
    die "Unsupported avahi module: ${AVAHI_MODULE}"
fi

MY_P=${P/-${AVAHI_MODULE}}

inherit autotools eutils flag-o-matic

DESCRIPTION="avahi ${AVAHI_MODULE} module"
HOMEPAGE="http://avahi.org/"
SRC_URI="http://avahi.org/download/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

AVAHI_COMMON_DEPEND=">=dev-util/intltool-0.40.5
	>=dev-util/pkgconfig-0.9.0"
DEPEND="${AVAHI_MODULE_DEPEND} ${AVAHI_COMMON_DEPEND}"
RDEPEND="${AVAHI_MODULE_RDEPEND}"
PDEPEND="${AVAHI_MODULE_PDEPEND}"

avahi_src_prepare() {
	sed -i\
		-e "s:\\.\\./\\.\\./\\.\\./doc/avahi-docs/html/:../../../doc/${PF}/html/:" \
		doxygen_to_devhelp.xsl || die

	for i in ${!AVAHI_PATCHES[@]}; do
		epatch "${AVAHI_PATCHES[i]}"
	done

	eautoreconf
}

avahi_src_configure() {
	use sh && replace-flags -O? -O0
	# We need to unset DISPLAY, else the configure script might have problems detecting the pygtk module
	unset DISPLAY
	local myconf="
		--disable-static
		--localstatedir=/var
		--with-distro=gentoo
		--disable-xmltoman
		--disable-monodoc
		--enable-glib
		--enable-gobject
		--disable-qt3
		$@"
	econf ${myconf}
}

avahi_src_install-cleanup() {
	# Remove .la files
	find "${D}" -name '*.la' -exec rm -f {} + || die
}

EXPORT_FUNCTIONS src_prepare src_configure
