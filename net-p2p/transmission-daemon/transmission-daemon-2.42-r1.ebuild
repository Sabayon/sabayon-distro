# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit transmission-2.42

DESCRIPTION="A Fast, Easy and Free BitTorrent client - daemon"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext
		>=dev-util/intltool-0.40 )"

src_install() {
	dobin daemon/transmission-daemon
	dobin daemon/transmission-remote

	doman daemon/transmission-daemon.1
	doman daemon/transmission-remote.1

	# change reported in Gentoo bug 403443
	newinitd "${FILESDIR}"/${MY_PN}-daemon.initd.8-r1 ${MY_PN}-daemon
	newconfd "${FILESDIR}"/${MY_PN}-daemon.confd.3 ${MY_PN}-daemon
}
