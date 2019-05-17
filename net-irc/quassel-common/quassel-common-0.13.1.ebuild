# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils gnome2-utils

MY_PN=${PN/-common}

DESCRIPTION="Qt/KDE IRC client supporting a remote daemon (common files)"
HOMEPAGE="https://quassel-irc.org/"
MY_P=${MY_PN}-${PV/_/-}
SRC_URI="https://quassel-irc.org/pub/${MY_P}.tar.bz2"
KEYWORDS="~amd64 ~x86"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-3"
SLOT="0"
IUSE="kde"

RDEPEND=""

DEPEND="${RDEPEND}
		!<net-irc/quassel-${PV}
		!<net-irc/quassel-client-${PV}"
		# -core(-bin) does not depend on it

S="${WORKDIR}/${MY_P}"

src_configure() {
	local mycmakeargs=(
		-DUSE_QT4=OFF
		-DUSE_QT5=ON
		-DEMBED_DATA=OFF
		-DWITH_BUNDLED_ICONS=ON
		-DWITH_OXYGEN_ICONS=OFF  # Just a choice.
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_make po
}

src_install() {
	# cmake-utils_src_install

	local mypath

	dodoc ChangeLog AUTHORS

	cmake-utils_src_install -C icons

	# /usr/share/quassel/stylesheets
	for mypath in data/stylesheets/*.qss; do
		if [ -f "${mypath}" ]; then
			insinto /usr/share/quassel/stylesheets
			doins "${mypath}"
		fi
	done

	# /usr/share/quassel/scripts
	for mypath in data/scripts/*; do
		if [ -f "${mypath}" ]; then
			insinto /usr/share/quassel/scripts
			doins "${mypath}"
		fi
	done

	# /usr/share/quassel/translations
	for mypath in "${CMAKE_BUILD_DIR}"/po/*.qm; do
		insinto /usr/share/quassel/translations
		doins "${mypath}"
	done

	insinto /usr/share/quassel
	doins data/networks.ini

	use kde && doins data/quassel.notifyrc
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
