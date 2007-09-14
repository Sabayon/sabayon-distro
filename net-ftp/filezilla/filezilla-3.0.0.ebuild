# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils multilib autotools

MY_P="FileZilla_${PV}"

DESCRIPTION="FTP client with lots of useful features and an intuitive interface"
HOMEPAGE="http://filezilla-project.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}_src.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND=">=x11-libs/wxGTK-2.8.0
	>=net-libs/gnutls-1.6.1
	net-dns/libidn
	>=sys-devel/libtool-1.4"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.11"

src_compile() {
	econf \
		--with-wx-config=/usr/$(get_libdir)/wx/config/gtk2-unicode-release-2.8 \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	doicon src/interface/resources/${PN}.xpm || die "doicon failed"
	make_desktop_entry ${PN} "FileZilla" ${PN}.xpm

	dodoc AUTHORS ChangeLog NEWS
}
