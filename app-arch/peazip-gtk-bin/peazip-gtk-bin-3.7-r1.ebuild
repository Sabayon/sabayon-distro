# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
inherit eutils multilib

DESCRIPTION="Open Source file and archive manager: flexible, portable, secure, and free as in freedom"
HOMEPAGE="http://www.peazip.org"
MY_PN="peazip"
MY_P="${MY_PN}-${PV}"
[[ ${PN} = *-gtk-bin ]] && SRC_URI="http://peazip.googlecode.com/files/${MY_P}.LINUX.GTK2.tgz" || \
	SRC_URI="http://peazip.googlecode.com/files/${MY_P}.LINUX.Qt.tgz"

LICENSE="LGPL-3 GPL-2 unRAR LGPL-2.1 GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="kde gnome"
RESTRICT="mirror strip"
S="${WORKDIR}"

# Split Gtk+ and Qt version as separate ebuilds.

MY_GTK_RDEPEND="!${CATEGORY}/${MY_PN}-qt4-bin
	amd64? ( app-emulation/emul-linux-x86-gtklibs )
	x86? ( x11-libs/cairo
		x11-libs/gdk-pixbuf
		x11-libs/gtk+:2 )"

MY_QT4_RDEPEND="!${CATEGORY}/${MY_PN}-gtk-bin
	amd64? ( app-emulation/emul-linux-x86-qtlibs )
	x86? ( x11-libs/qt-core
		x11-libs/qt-gui )"

[[ ${PN} = *-gtk-bin ]] && MY_RDEPEND=${MY_GTK_RDEPEND} || \
	MY_RDEPEND=${MY_QT4_RDEPEND}

RDEPEND="${MY_RDEPEND}
		amd64? (
			app-emulation/emul-linux-x86-baselibs
			app-emulation/emul-linux-x86-xlibs
			app-emulation/emul-linux-x86-opengl  )
		x86? ( dev-libs/atk
			dev-libs/expat
			media-libs/fontconfig
			media-libs/freetype
			media-libs/libpng
			media-libs/mesa )"
DEPEND=${RDEPEND}

QA_TEXTRELS="opt/PeaZip/res/7z/Codecs/Rar29.so
	opt/PeaZip/res/7z/7z.so"

QA_EXECSTACK="opt/PeaZip/res/paq/paq8o
	opt/PeaZip/res/paq/paq8l
	opt/PeaZip/res/paq/paq8f
	opt/PeaZip/res/paq/paq8jd
	opt/PeaZip/res/pea
	opt/PeaZip/res/pealauncher
	opt/PeaZip/peazip"

src_unpack()
{
	if [[ ${PN} = *-gtk-bin ]]; then
		unpack ${MY_P}.LINUX.GTK2.tgz
	else
		unpack ${MY_P}.LINUX.Qt.tgz
	fi
}

src_install() {
	cd "${ED}"
	if use kde; then
		mkdir -p usr/share/kde4
		cp -Rf "${S}"/usr/share/kde4/* usr/share/kde4
	fi
	if use !gnome; then
		rm -Rf "${S}"/usr/local/share/PeaZip/FreeDesktop_integration/nautilus-scripts
	fi

	rm -Rf "${S}"/usr/local/share/PeaZip/FreeDesktop_integration/kde3-konqueror
	rm -Rf "${S}"/usr/local/share/PeaZip/FreeDesktop_integration/kde4-dolphin
	rm -Rf "${S}"/usr/share

	mkdir -p usr/share/icons/hicolor/256x256/apps usr/share/pixmaps
	mv "${S}"/usr/local/share/icons/peazip.png usr/share/icons/hicolor/256x256/apps
	ln usr/share/icons/hicolor/256x256/apps/peazip.png usr/share/pixmaps/
	rm -Rf "${S}"usr/local/share/icons

	mkdir -p usr/share/applications
	mv "${S}"/usr/local/share/applications/peazip.desktop usr/share/applications/
	rm -Rf "${S}"usr/local/share/applications

	mkdir -p opt
	cp -Rf "${S}"/usr/local/share/* opt

	find usr/share -type f -exec chmod a-x {} \;

	mkdir -p usr/bin
	ln -sf ../../opt/PeaZip/res/pea usr/bin/pea
	ln -sf ../../opt/PeaZip/res/pealauncher usr/bin/pealauncher
	ln -sf ../../opt/PeaZip/peazip usr/bin/peazip

	if [[ ${PN} = *-qt4-bin ]]; then
		# /opt/PeaZip/libQt4Pas.so.5
		# unfortunately this app's helpers does not work
		# if we make a wrapper with LD_LIBRARY_PATH
		mkdir -p usr/"$(get_libdir)"
		ln -s ../../opt/PeaZip/libQt4Pas.so usr/"$(get_libdir)"/libQt4Pas.so.5
	fi
}

pkg_postinst() {
	if use gnome; then
		einfo ""
		einfo "If you want Nautilus scripts, simply copy files from"
		einfo "${EROOT}opt/PeaZip/FreeDesktop_integration/nautilus-scripts"
		einfo "into ~/.gnome2/nautilus-scripts"
		einfo ""
	fi
}
