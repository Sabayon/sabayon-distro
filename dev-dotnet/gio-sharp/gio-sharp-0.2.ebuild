# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $


EAPI=3

inherit eutils mono autotools

DESCRIPTION="A branch of the official gtk-sharp/gio to get gio-sharp building on gtk-sharp 2.12"
HOMEPAGE="http://github.com/mono/gio-sharp"
SRC_URI="https://github.com/mono/gio-sharp/zipball/${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND=">=dev-lang/mono-2
	dev-dotnet/glib-sharp
	dev-dotnet/gtk-sharp-gapi
	>=dev-libs/glib-2.22:2"
DEPEND="${RDEPEND}"

src_prepare () {
	cd ${WORKDIR}/${PN}-${PV}/
	./autogen-2.22.sh
	#eautoreconf 
}

src_configure () {
	./configure --prefix=/usr
}

src_compile() {
	make 
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README
	mono_multilib_comply
}
