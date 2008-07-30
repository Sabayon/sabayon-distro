# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

inherit git x-modular

EGIT_REPO_URI="git://anongit.freedesktop.org/git/xcb/util"

DESCRIPTION="X C-language Bindings sample implementations"
HOMEPAGE="http://xcb.freedesktop.org/"
SRC_URI=""

LICENSE="X11"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"

RDEPEND=">=x11-libs/libxcb-1"
DEPEND="${RDEPEND}
	>=dev-util/gperf-3
	x11-proto/xproto"

