# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

DESCRIPTION="GLib's GObject library bindings for Python, meta package"
HOMEPAGE="http://www.pygtk.org"

LICENSE="LGPL-2.1"
SLOT="3"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="+cairo examples test +threads" # doc

COMMON_DEPEND="
	~dev-python/pygobject-base-${PV}[threads=,examples=,test=]
	cairo? ( ~dev-python/pygobject-cairo-${PV}[threads=] )"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"
