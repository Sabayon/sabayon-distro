# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils eutils

EGIT_REPO_URI="git://git.quassel-irc.org/quassel"
[[ "${PV}" == "9999" ]] && inherit git-r3

DESCRIPTION="Qt/KDE IRC client supporting a remote daemon for 24/7 connectivity (common files)"
HOMEPAGE="http://quassel-irc.org/"
MY_P=${P/-common}
[[ "${PV}" == "9999" ]] || SRC_URI="http://quassel-irc.org/pub/${MY_P/_/-}.tar.bz2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="kde"

RDEPEND="kde? (
	|| ( kde-apps/oxygen-icons kde-base/oxygen-icons:4 ) )"
DEPEND="${RDEPEND}
		!<net-irc/quassel-${PV}
		!<net-irc/quassel-client-${PV}"
		# -core(-bin) does not depend on it

S="${WORKDIR}/${MY_P/_/-}"

src_configure() {
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_make po
}

src_install() {
	# cmake-utils_src_install

	local mypath

	dodoc ChangeLog AUTHORS

	# /usr/share/icons/hicolor
	for mypath in icons/hicolor/*/*/quassel*.png; do
		if [ -f "${mypath}" ]; then
			insinto "/usr/share/${mypath%/*}"
			doins "${mypath}" || die "doins for icon failed"
		fi
	done

	# /usr/share/apps/quassel/icons/oxygen
	if ! use kde; then
		dodoc icons/README.Oxygen
		local mydest
		for mydest in COPYING AUTHORS CONTRIBUTING; do
			newdoc "icons/oxygen/${mydest}" "${mydest}.Oxygen"
		done

		for mypath in icons/oxygen{,_kde}/*/*/*.{svgz,png}; do
			if [ -f "${mypath}" ]; then
				mydest=${mypath/oxygen_kde/oxygen}
				insinto "/usr/share/apps/quassel/${mydest%/*}"
				doins "${mypath}" || die "doins for Oxygen icon failed"
			fi
		done
	fi

	doicon icons/oxygen_kde/48x48/apps/quassel.png

	# /usr/share/apps/quassel/stylesheets
	for mypath in data/stylesheets/*.qss; do
		if [ -f "${mypath}" ]; then
			insinto /usr/share/apps/quassel/stylesheets
			doins "${mypath}" || die "doins for .qss file failed"
		fi
	done

	# /usr/share/apps/quassel/scripts
	for mypath in data/scripts/*; do
		if [ -f "${mypath}" ]; then
			insinto /usr/share/apps/quassel/scripts
			doins "${mypath/$CMAKE_BUILD_DIR}" || die "doins for script failed"
		fi
	done

	# /usr/share/apps/quassel/translations
	for mypath in "${CMAKE_BUILD_DIR}"/po/*.qm; do
		insinto /usr/share/apps/quassel/translations
		doins "${mypath}" || die "doins for .qm file failed"
	done

	insinto /usr/share/apps/quassel
	doins data/networks.ini

	use kde && doins data/quassel.notifyrc
}
