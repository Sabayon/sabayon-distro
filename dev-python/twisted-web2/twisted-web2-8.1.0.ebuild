# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-web/twisted-web-8.1.0.ebuild,v 1.6 2008/08/13 08:46:47 coldwind Exp $

MY_PACKAGE=Web2

inherit twisted eutils versionator

DESCRIPTION="Twisted web server, programmable in Python"

KEYWORDS="alpha amd64 ~arm hppa ia64 ~mips ~ppc ppc64 ~s390 ~sh sparc x86 ~x86-fbsd"

DEPEND="=dev-python/twisted-$(get_version_component_range 1-2)*"

src_unpack() {
	unpack ${A}
	cd "${S}"
}
