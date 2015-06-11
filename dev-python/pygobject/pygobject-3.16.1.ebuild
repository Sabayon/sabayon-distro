# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
PYTHON_COMPAT=( python{2_7,3_3,3_4} )

inherit python-r1

DESCRIPTION="GLib's GObject library bindings for Python, meta package"
HOMEPAGE="https://wiki.gnome.org/Projects/PyGObject"

LICENSE="LGPL-2.1+"
SLOT="3"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="+cairo examples test +threads"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND="
	~dev-python/pygobject-base-${PV}[threads=,examples=,test=,${PYTHON_USEDEP}]
	cairo? ( ~dev-python/pygobject-cairo-${PV}[threads=,${PYTHON_USEDEP}] )
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"
