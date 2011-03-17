# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

ESVN_SUB_PROJECT="E-MODULES-EXTRA"
ESVN_URI_APPEND="${PN#e_modules-}"
inherit enlightenment

DESCRIPTION="A module that allows a user to navigate the filemanager module"

KEYWORDS="~amd64 ~x86"

DEPEND=">=x11-wm/enlightenment-9999
	>=media-libs/edje-0.5.0"
