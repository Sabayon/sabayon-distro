# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-pda/libopensync-plugin-irmc/libopensync-plugin-irmc-0.36.ebuild,v 1.2 2008/12/04 14:09:03 flameeyes Exp $

inherit eutils cmake-utils

DESCRIPTION="OpenSync IrMC plugin"
HOMEPAGE="http://www.opensync.org/"
SRC_URI="http://www.opensync.org/download/releases/${PV}/${P}.tar.bz2"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="GPL-2"
IUSE="bluetooth irda"

DEPEND="=app-pda/libopensync-${PV}*
	>=dev-libs/openobex-1.0
	bluetooth? ( || ( net-wireless/bluez net-wireless/bluez-libs ) )"

RDEPEND="${DEPEND}"

pkg_setup() {
	if ! use irda && ! use bluetooth; then
		eerror "${CATEGORY}/${P} without support for bluetooth nor irda is unusable."
		eerror "Please enable \"bluetooth\" or/and \"irda\" USE flags."
		die "Please enable \"bluetooth\" or/and \"irda\" USE flags."
	fi

	if use bluetooth && ! built_with_use dev-libs/openobex bluetooth; then
		eerror "You are trying to build ${CATEGORY}/${P} with the \"bluetooth\""
		eerror "USE flag, but dev-libs/openobex was built without"
		eerror "the \"bluetooth\" USE flag."
		eerror "Please rebuild dev-libs/openobex with \"bluetooth\" USE flag."
		die "Please rebuild dev-libs/openobex with \"bluetooth\" USE flag."
	fi

	if use irda && ! built_with_use dev-libs/openobex irda; then
		eerror "You are trying to build ${CATEGORY}/${P} with the \"irda\""
		eerror "USE flag, but dev-libs/openobex was built without"
		eerror "the \"irda\" USE flag."
		eerror "Please rebuild dev-libs/openobex with \"irda\" USE flag."
		die "Please rebuild dev-libs/openobex with \"irda\" USE flag."
	fi
}

src_compile() {
	local mycmakeargs="
		$(cmake-utils_use_enable bluetooth BLUETOOTH)
		$(cmake-utils_use_enable irda IRDA)"

	cmake-utils_src_compile
}
