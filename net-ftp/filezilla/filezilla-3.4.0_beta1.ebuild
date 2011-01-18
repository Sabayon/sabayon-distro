# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-ftp/filezilla/filezilla-3.3.5.1.ebuild,v 1.1 2010/11/21 21:47:13 voyageur Exp $

EAPI=2

WX_GTK_VER="2.8"

inherit eutils multilib wxwidgets

MY_PV=${PV/_/-}
MY_P="FileZilla_${MY_PV}"

DESCRIPTION="FTP client with lots of useful features and an intuitive interface"
HOMEPAGE="http://filezilla-project.org/"
SRC_URI="mirror://sourceforge/${PN}/FileZilla_Client_Unstable/${MY_PV}/${MY_P}_src.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~sparc ~x86"
IUSE="dbus nls test"

RDEPEND=">=app-admin/eselect-wxwidgets-0.7-r1
	net-dns/libidn
	>=net-libs/gnutls-2.8.3
	>=x11-libs/wxGTK-2.8.9:2.8[X]
	dbus? ( sys-apps/dbus )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=sys-devel/libtool-1.4
	nls? ( >=sys-devel/gettext-0.11 )
	test? ( dev-util/cppunit )"

S="${WORKDIR}"/${PN}-${MY_PV}

src_configure() {
	econf $(use_with dbus) $(use_enable nls locales) \
		--with-tinyxml=builtin \
		--disable-autoupdatecheck || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	doicon src/interface/resources/48x48/${PN}.png || die "doicon failed"

	dodoc AUTHORS ChangeLog NEWS
}
