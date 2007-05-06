# Copyright 2006-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

WANT_AUTOMAKE="1.9"
inherit gnome2 eutils autotools

DESCRIPTION="Liboobs is a lightweight library that provides a GObject based interface to system-tools-backends"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND="
	app-admin/system-tools-backends
	"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog NEWS README"
