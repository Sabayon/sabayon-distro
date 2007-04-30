# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit gnome2

DESCRIPTION="Compiz extra third party plugins"
HOMEPAGE="http://www.go-compiz.org/index.php?title=Download"
SRC_URI="http://www.anykeysoftware.co.uk/compiz/plugins/extra-plugins-${PV}.2.tar.gz"

S=${WORKDIR}/extra-plugins-${PV}

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=x11-wm/compiz-0.5.0"

src_compile() {
	cd ${S}
	for dir in ${S}/*; do
		if [ -d "${dir}" ]; then
			cd ${dir}
			if [ -f Makefile ]; then
				make
			fi
		fi
	done
}

src_install() {
	cd ${S}
	for dir in ${S}/*; do
		if [ -d "${dir}" ]; then
			cd ${dir}
			if [ -f Makefile ]; then
				make DESTDIR=${D}/usr/lib/compiz install
			fi
		fi
	done


	addwrite /etc/gconf
	export GCONF_CONFIG_SOURCE=$(gconftool-2 --get-default-source)

	# Install schemas
	cd ${S}
	for file in `find -name *.schema`; do gconftool-2 --makefile-install-rule $file; done

	# Configure default plugins
	gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults --type list --list-type=string  --set /apps/compiz/general/allscreens/options/active_plugins [gconf,svg,png,decoration,wobbly,animation,fade,minimize,cube,rotate,zoom,scale,move,resize,place,switcher,trailfocus,water,bs,state,widget,neg,jpeg,3d,thumbnail]

	# Respawn gconftool-2
	${ROOT}/usr/bin/gconftool-2 --shutdown

}

