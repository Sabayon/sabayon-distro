# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mono eutils 

DESCRIPTION="Hipo is an application that allows you to manage the data of your iPod"
HOMEPAGE="http://www.gnome.org/~pvillavi/hipo/"
SRC_URI="http://ftp.gnome.org/pub/GNOME/sources/hipo/0.6/hipo-${PV}.tar.bz2"
LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND=">=dev-lang/mono-1.1.10
	>=dev-dotnet/gtk-sharp-2.10
	>=dev-dotnet/gnome-sharp-2.10
	>=dev-dotnet/glade-sharp-2.10
	>=dev-dotnet/ipod-sharp-0.6.2
	"

DEPEND="${RDEPEND}
	"

DOCS="AUTHORS ChangeLog MAINTAINERS NEWS README"

src_unpack() {
	unpack ${A}

}

src_compile() {
	econf $(use_enable doc docs) || die "configure failed"
	emake -j1 || die "make failed"
}

src_install() 
{
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
