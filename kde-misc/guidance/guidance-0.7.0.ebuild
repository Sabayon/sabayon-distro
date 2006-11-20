# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit eutils distutils

DESCRIPTION="System tools for KDE"
HOMEPAGE="http://www.riverbankcomputing.co.uk/guidance/"
SRC_URI="http://www.simonzone.com/software/guidance/${P}.tar.bz2"

RESTRICT="nomirror"

LICENSE="GPL-2"
KEYWORDS="-*"
IUSE="debug"

RDEPEND="
	>=kde-misc/pykdeextensions-0.4.0"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-fix-setup.py.patch
}

src_compile() {
	KDEDIR="`kde-config --prefix`" python setup.py build
	KDEDIR="`kde-config --prefix`" python setup.py build_kcm
}

src_install() {

	# Get variables
	distutils_python_version

	cd ${S}
	KDEDIR="`kde-config --prefix`" python setup.py update_messages

	einfo Installing libraries

		insinto ${ROOT}/usr/$(get_libdir)/python${PYVER}/site-packages
		doins ${S}/build/lib.linux-*/*

	einfo Installing data

		insinto ${ROOT}/usr/share/icons/crystalsvg/16x16/apps
		doins ${S}/kde/*/pics/16x16/*.png
		
		dodir "${ROOT}/`kde-config --prefix`"/share/apps/guidance/pics
		insinto "${ROOT}/`kde-config --prefix`"/share/apps/guidance/pics
		doins ${S}/kde/*/pics/*.png

		dodir "${ROOT}/`kde-config --prefix`"/share/apps/guidance/pics/displayconfig/dualhead		
		insinto "${ROOT}/`kde-config --prefix`"/share/apps/guidance/pics/displayconfig/dualhead
		doins ${S}/kde/displayconfig/pics/dualhead/*.png

		dodir "${ROOT}/`kde-config --prefix`"/share/apps/guidance/pics/displayconfig/monitor_resizable
		insinto "${ROOT}/`kde-config --prefix`"/share/apps/guidance/pics/displayconfig/monitor_resizable
		doins ${S}/kde/displayconfig/pics/monitor_resizable/*.png

		dodir "${ROOT}/`kde-config --prefix`"/share/apps/guidance/pics/displayconfig/gammapics
		insinto "${ROOT}/`kde-config --prefix`"/share/apps/guidance/pics/displayconfig/gammapics
		doins ${S}/kde/displayconfig/pics/gammapics/*.png

		dodir "${ROOT}/`kde-config --prefix`"/share/applications/kde
		insinto "${ROOT}/`kde-config --prefix`"/share/applications/kde
		# disabled for now - since it needs integration
		#doins ${S}/serviceconfig/*.desktop
		doins ${S}/userconfig/*.desktop
		doins ${S}/mountconfig/*.desktop
		doins ${S}/displayconfig/*.desktop
		doins ${S}/wineconfig/*.desktop

	einfo Installing scripts
		
		insinto "${ROOT}/`kde-config --prefix`"/share/apps/guidance
		doins ${S}/serviceconfig/*.py
		doins ${S}/userconfig/*.py

		doins ${S}/mountconfig/*.py
		doins ${S}/mountconfig/*.ui

		doins ${S}/displayconfig/*.py
		doins ${S}/displayconfig/*modes
		doins ${S}/displayconfig/ldetect-lst/*

		doins ${S}/wineconfig/*.py
		doins ${S}/powermanager/*.py
		doins ${S}/powermanager/*.ui

	einfo Compiling *.ui files

		pyuic -o ${D}/`kde-config --prefix`/share/apps/guidance/fuser_ui.py.bak ${D}`kde-config --prefix`/share/apps/guidance/fuser_ui.ui
		pyuic -o ${D}/`kde-config --prefix`/share/apps/guidance/guidance_power_manager_ui.py.bak ${D}`kde-config --prefix`/share/apps/guidance/guidance_power_manager_ui.ui
		pyuic -o ${D}/`kde-config --prefix`/share/apps/guidance/powermanager_ui.py.bak ${D}`kde-config --prefix`/share/apps/guidance/powermanager_ui.ui

	einfo Installing HTML files

		dodir "${ROOT}`kde-config --prefix`"/share/doc/HTML/en/guidance
		insinto "${ROOT}`kde-config --prefix`"/share/doc/HTML/en/guidance
		doins -r ${S}/doc/en/*

	einfo Installing kcm modules

		# copy kcm_*.la
		dodir "${ROOT}`kde-config --prefix`"/lib/kde3/
		exeinto "${ROOT}`kde-config --prefix`"/lib/kde3/
		doexe  ${S}/build/*.la

		libtool --mode=install /usr/bin/install -c build/kcm_serviceconfig.la "${D}`kde-config --prefix`"/lib/kde3/kcm_serviceconfig.la
		libtool --mode=install /usr/bin/install -c build/kcm_userconfig.la "${D}`kde-config --prefix`"/lib/kde3/kcm_userconfig.la
		libtool --mode=install /usr/bin/install -c build/kcm_mountconfig.la "${D}`kde-config --prefix`"/lib/kde3/kcm_mountconfig.la
		libtool --mode=install /usr/bin/install -c build/kcm_displayconfig.la "${D}`kde-config --prefix`"/lib/kde3/kcm_displayconfig.la
		libtool --mode=install /usr/bin/install -c build/kcm_wineconfig.la "${D}`kde-config --prefix`"/lib/kde3/kcm_wineconfig.la


}
