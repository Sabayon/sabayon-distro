# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="3"
inherit base eutils

DESCRIPTION="The libuser library implements a standardized interface for manipulating and administering user and group accounts."
HOMEPAGE="https://fedorahosted.org/libuser"
SRC_URI="https://fedorahosted.org/releases/l/i/${PN}/${P}.tar.xz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="ldap +popt sasl selinux"
COMMON_DEPEND="dev-libs/glib:2
	ldap? ( net-nds/openldap )
	popt? ( dev-libs/popt )
	sasl? ( dev-libs/cyrus-sasl )
	selinux? ( sys-libs/libselinux )"
DEPEND="app-text/linuxdoc-tools
	sys-devel/bison
	sys-devel/gettext
	${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

src_configure() {
	cd "${S}"
	econf $(use_with ldap) $(use_with popt) $(use_with sasl) \
		$(use_with selinux) --with-python
}
