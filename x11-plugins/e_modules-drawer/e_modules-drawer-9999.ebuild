# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

ESVN_SUB_PROJECT="E-MODULES-EXTRA"
ESVN_URI_APPEND="${PN#e_modules-}"
inherit enlightenment

DESCRIPTION="A drawer module to present different types of information"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND=">=media-libs/edje-0.5.0
	>=media-libs/ethumb-9999[dbus]
	>=x11-wm/enlightenment-0.16.999"
RDEPEND=${DEPEND}
