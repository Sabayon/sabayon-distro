# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="2"
EHG_REPO_URI="http://hg.fedoraproject.org/hg/system-config-date"
EHG_REVISION="${PN}-1_9_34"
inherit base mercurial

DESCRIPTION="The system-config-date tool lets you set the date and time of your machine."
HOMEPAGE="http://fedoraproject.org/wiki/SystemConfig/date"
SRC_URI=""

LICENSE="GPL-1"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""
S="${WORKDIR}/${PN}"

# FIXME: would also require a dependency against anaconda
DEPEND="app-text/docbook-xml-dtd
        app-text/docbook-sgml-dtd
        app-text/gnome-doc-utils
        app-text/rarian
        dev-libs/newt
        dev-util/desktop-file-utils
        dev-util/intltool
        sys-devel/gettext"

RDEPEND="net-misc/ntp
        dev-python/libgnomecanvas-python
        gnome-base/libglade
        dev-libs/newt
        dev-python/rhpl
        x11-themes/hicolor-icon-theme"
