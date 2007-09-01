# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils distutils

DESCRIPTION="A GUI for Portage written in Python."
HOMEPAGE="http://portato.sourceforge.net/"
SRC_URI="mirror://sourceforge/portato/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc"
IUSE="kde libnotify nls userpriv"

RDEPEND=">=sys-apps/portage-2.1.2
		>=dev-python/lxml-1.3.2
		>=dev-python/pygtk-2.10.4
		>=x11-libs/vte-0.12.2
		>=gnome-base/libglade-2.5.1
		>=dev-util/portatosourceview-2.16.1
		!kde? ( !userpriv? ( >=x11-libs/gksu-2.0.0 ) )
		kde? ( !userpriv? ( || ( >=kde-base/kdesu-3.5.5 >=kde-base/kdebase-3.5.5
		) ) )
		nls? ( virtual/libintl )
		libnotify? ( >=dev-python/notify-python-0.1.1 )"

S="${WORKDIR}/${PN}"
CONFIG_DIR="/etc/${PN}/"
DATA_DIR="/usr/share/${PN}/"
LOCALE_DIR="/usr/share/locale/"
PLUGIN_DIR="${DATA_DIR}/plugins"
ICON_DIR="${DATA_DIR}/icons"

apply_sed ()
{
	cd "${S}"/${PN}

	# currently only gtk is supported
	local std="gtk"
	local frontends="[\"$std\"]"
	
	local su="\"gksu -D 'Portato'\""
	use kde && su="\"kdesu -t --nonewdcop -i %s -c\" % APP_ICON"

	sed -i 	-e "s;^\(VERSION\s*=\s*\).*;\1\"${PV}\";" \
			-e "s;^\(CONFIG_DIR\s*=\s*\).*;\1\"${CONFIG_DIR}\";" \
			-e "s;^\(DATA_DIR\s*=\s*\).*;\1\"${DATA_DIR}\";" \
			-e "s;^\(ICON_DIR\s*=\s*\).*;\1\"${ICON_DIR}\";" \
			-e "s;^\(PLUGIN_DIR\s*=\s*\).*;\1\"${PLUGIN_DIR}\";" \
			-e "s;^\(XSD_DIR\s*=\s*\).*;\1\"${DATA_DIR}\";" \
			-e "s;^\(LOCALE_DIR\s*=\s*\).*;\1\"${LOCALE_DIR}\";" \
			-e "s;^\(FRONTENDS\s*=\s*\).*;\1$frontends;" \
			-e "s;^\(STD_FRONTEND\s*=\s*\).*;\1\"$std\";" \
			-e "s;^\(SU_COMMAND\s*=\s*\).*;\1$su;" \
			constants.py

	cd ..
	
	# don't do this as "use userpriv && ..." as it makes the whole function
	# fail, if userpriv is not set
	if use userpriv; then
		sed -i -e "s/Exec=.*/Exec=portato --no-listener/" portato.desktop
	fi
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
	apply_sed || die "Applying sed-commands failed."

	cd ${S}
	use nls && ./pocompile.sh -emerge

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

	use libnotify && doins "plugins/notify.xml"

	# icon
	doicon icons/portato-icon.png

	# menus
	domenu portato.desktop

	# nls
	use nls && domo i18n/mo/*
}
