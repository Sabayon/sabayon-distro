# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils distutils

DESCRIPTION="A GUI for Portage written in Python."
HOMEPAGE="http://portato.sourceforge.net/"
SRC_URI="mirror://sourceforge/portato/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="gtk qt4 userpriv etcproposals"

GTKDEPS=">=dev-python/pygtk-2.8.6
	>=x11-libs/vte-0.12.2
	>=gnome-base/libglade-2.5.1
	!userpriv? ( >=x11-libs/gksu-2.0.0 )
	>=dev-util/portatosourceview-2.16.0"

RDEPEND=">=sys-apps/portage-2.1.2
	gtk? ( ${GTKDEPS} )
	qt4? (
		>=dev-python/PyQt4-4.1.1
		!userpriv? ( >=kde-base/kdesu-3.5.5 )
	)
	!gtk? ( !qt4? ( ${GTKDEPS}	)	)
	etcproposals? ( >=app-portage/etcproposals-1.0 )"

S="${WORKDIR}/${PN}"
CONFIG_DIR="/etc/${PN}/"
DATA_DIR="/usr/share/${PN}/"
PLUGIN_DIR="${DATA_DIR}/plugins"
ICON_DIR="${DATA_DIR}/icons"

apply_sed() {
	cd "${S}"/${PN}

	frontends="["
	std=""

	if ( use gtk || ( ! use gtk && ! use qt4 ) ); then
		frontends="$frontends\"gtk\""
		std="gtk"
	fi

	if use qt4; then
		frontends="$frontends, \"qt\""

		if test -z $std; then
			std="qt"
		fi
	fi

	frontends="${frontends/\[, /[}]"

	einfo "Building frontends: $frontends"

	sed -i	-e "s;^\(VERSION\s*=\s*\).*;\1\"${PV}\";" \
			-e "s;^\(CONFIG_DIR\s*=\s*\).*;\1\"${CONFIG_DIR}\";" \
			-e "s;^\(DATA_DIR\s*=\s*\).*;\1\"${DATA_DIR}\";" \
			-e "s;^\(ICON_DIR\s*=\s*\).*;\1\"${ICON_DIR}\";" \
			-e "s;^\(PLUGIN_DIR\s*=\s*\).*;\1\"${PLUGIN_DIR}\";" \
			-e "s;^\(FRONTENDS\s*=\s*\).*;\1$frontends;" \
			-e "s;^\(STD_FRONTEND\s*=\s*\).*;\1\"$std\";" \
			constants.py

	cd ..
	if use userpriv; then
		for d in *.desktop; do
			sed -i -e "s/\(gk\|kde\)su.*\(portato.*\)/\2/" $d
		done
	fi
}

pkg_setup() {
	if ( use gtk || ( ! use gtk && ! use qt4 ) ) && ! built_with_use x11-libs/vte python; then
		echo
		eerror "x11-libs/vte has not been built with python support."
		eerror "Please re-emerge vte with the python use-flag enabled."
		die "missing python flag for x11-libs/vte"
	fi

	if ! use gtk && ! use qt4 ; then
		echo
		einfo "You have not chosen a frontend. Defaulting to gtk."
	fi
}

src_compile() {
	pushd "${S}/${PN}" > /dev/null
	apply_sed || die "Applying sed-commands failed."
	popd > /dev/null

	distutils_src_compile
}

src_install() {
	dodir ${DATA_DIR}
	distutils_src_install

	newbin portato.py portato
	dodoc doc/*

	# config
	insinto ${CONFIG_DIR}
	doins etc/*

	# plugins
	insinto ${PLUGIN_DIR}
	keepdir ${PLUGIN_DIR}

	use userpriv && doins "plugins/noroot.xml"
	use etcproposals && doins "plugins/etc_proposals.xml"

	# icon
	doicon icons/portato-icon.png

	# menus
	( use gtk || ( ! use gtk && ! use qt4 ) ) && domenu portato_gtk.desktop
	use qt4 && domenu portato_qt.desktop
}
