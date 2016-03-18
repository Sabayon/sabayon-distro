# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit systemd transmission-2.92

DESCRIPTION="A Fast, Easy and Free BitTorrent client - daemon"
KEYWORDS="~amd64 ~x86"
IUSE="systemd"

RDEPEND="systemd? ( >=sys-apps/systemd-209:= )"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/libsystemd.patch"
)

src_install() {
	dobin daemon/transmission-daemon
	dobin daemon/transmission-remote

	doman daemon/transmission-daemon.1
	doman daemon/transmission-remote.1

	newinitd "${FILESDIR}"/transmission-daemon.initd.10 transmission-daemon
	newconfd "${FILESDIR}"/transmission-daemon.confd.4 transmission-daemon
	systemd_dounit daemon/transmission-daemon.service
}
