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
IUSE="kde userpriv etcproposals"

RDEPEND=">=sys-apps/portage-2.1.2
		>=dev-python/lxml-1.3.2
		>=dev-python/pygtk-2.10.4
		>=x11-libs/vte-0.12.2
		>=gnome-base/libglade-2.5.1
		>=dev-util/portatosourceview-2.16.1
		!kde? ( !userpriv? ( >=x11-libs/gksu-2.0.0 ) )
		kde? ( !userpriv? ( >=kde-base/kdesu-3.5.5 ) )
		etcproposals? ( >=app-portage/etcproposals-1.0 )"

S="${WORKDIR}/${PN}"
CONFIG_DIR="/etc/${PN}/"
DATA_DIR="/usr/share/${PN}/"
PLUGIN_DIR="${DATA_DIR}/plugins"
ICON_DIR="${DATA_DIR}/icons"

apply_sed ()
{
	cd "${S}"/${PN}

	# currently only gtk is supported
	local std="gtk"
	local frontends="[\"$std\"]"

	sed -i 	-e "s;^\(VERSION\s*=\s*\).*;\1\"${PV}\";" \
			-e "s;^\(CONFIG_DIR\s*=\s*\).*;\1\"${CONFIG_DIR}\";" \
			-e "s;^\(DATA_DIR\s*=\s*\).*;\1\"${DATA_DIR}\";" \
			-e "s;^\(ICON_DIR\s*=\s*\).*;\1\"${ICON_DIR}\";" \
			-e "s;^\(PLUGIN_DIR\s*=\s*\).*;\1\"${PLUGIN_DIR}\";" \
			-e "s;^\(XSD_DIR\s*=\s*\).*;\1\"${DATA_DIR}\";" \
			-e "s;^\(FRONTENDS\s*=\s*\).*;\1$frontends;" \
			-e "s;^\(STD_FRONTEND\s*=\s*\).*;\1\"$std\";" \
			constants.py

	cd ..
	local su="gksu -D \"Portato\" -u root portato gtk"
	use kde && su="kdesu -t --nonewdcop -c portato gtk"
	use userpriv && su="portato gtk"

	sed -i -e "s/Exec=.*/Exec=${su}/" portato.desktop
}

pkg_setup ()
{
	if ! built_with_use x11-libs/vte python; then
		echo
		eerror "x11-libs/vte has not been built with python support."
		eerror "Please re-emerge vte with the python use-flag enabled."
		die "missing python flag for x11-libs/vte"
	fi
}

src_compile ()
{
	pushd "${S}/${PN}" > /dev/null
	apply_sed || die "Applying sed-commands failed."
	popd > /dev/null

	distutils_src_compile
}

src_install ()
{
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
	domenu portato.desktop
}
