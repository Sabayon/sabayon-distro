# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

EAPI=2

inherit eutils mono autotools

DESCRIPTION="glib integration for DBus-Sharp"
HOMEPAGE="https://github.com/mono/dbus-sharp"
SRC_URI="https://github.com/downloads/mono/dbus-sharp/dbus-sharp-glib-${PV}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-lang/mono-2.8.1
                 >=dev-dotnet/dbus-sharp-0.7"
DEPEND="${RDEPEND}
                >=dev-util/pkgconfig-0.19"

src_install() {
        make install DESTDIR="${D}"
        dodoc AUTHORS ChangeLog NEWS README
}
