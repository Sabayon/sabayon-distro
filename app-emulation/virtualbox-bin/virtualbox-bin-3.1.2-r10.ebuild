# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/virtualbox-bin/virtualbox-bin-3.0.6.ebuild,v 1.1 2009/09/10 20:05:23 patrick Exp $

EAPI=2

inherit eutils fdo-mime pax-utils

MY_PV=${PV}-56127
MY_P=VirtualBox-${MY_PV}-Linux

DESCRIPTION="Family of powerful x86 virtualization products for enterprise as well as home use"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="amd64? ( http://download.virtualbox.org/virtualbox/${PV}/${MY_P}_amd64.run )
	x86? ( http://download.virtualbox.org/virtualbox/${PV}/${MY_P}_x86.run )
	sdk? ( http://download.virtualbox.org/virtualbox/${PV}/VirtualBoxSDK-${MY_PV}.zip )"

LICENSE="PUEL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+additions +chm headless sdk vboxwebsrv +system-qt4"
RESTRICT="mirror"

RDEPEND="!!app-emulation/virtualbox-ose
	!app-emulation/virtualbox-ose-additions
	~app-emulation/virtualbox-modules-${PV}
	!headless? (
		x11-libs/libXcursor
		media-libs/libsdl[X]
		x11-libs/libXrender
		x11-libs/libXfixes
		media-libs/libmng
		media-libs/jpeg
		media-libs/libpng
		x11-libs/libXi
		x11-libs/libXrandr
		x11-libs/libXinerama
		x11-libs/libXft
		media-libs/freetype
		media-libs/fontconfig
		x11-libs/libXext
		dev-libs/glib
		chm? ( dev-libs/expat )
	)
	x11-libs/libXt
	dev-libs/libxml2
	x11-libs/libXau
	x11-libs/libX11
	x11-libs/libSM
	x11-libs/libICE
	x11-libs/libXdmcp
	native-qt? ( x11-libs/qt-core x11-libs/qt-gui )
	x86? ( ~virtual/libstdc++-3.3 )"

S=${WORKDIR}

QA_TEXTRELS_amd64="opt/VirtualBox/VBoxVMM.so"
QA_TEXTRELS_x86="opt/VirtualBox/VBoxGuestPropSvc.so
	opt/VirtualBox/VBoxSDL.so
	opt/VirtualBox/VBoxPython2_4.so
	opt/VirtualBox/VBoxPython2_6.so
	opt/VirtualBox/VBoxDbg.so
	opt/VirtualBox/VBoxSharedFolders.so
	opt/VirtualBox/VBoxDD2.so
	opt/VirtualBox/VBoxOGLrenderspu.so
	opt/VirtualBox/VBoxPython.so
	opt/VirtualBox/VBoxPython2_3.so
	opt/VirtualBox/VBoxDD.so
	opt/VirtualBox/VBoxVRDP.so
	opt/VirtualBox/VBoxDDU.so
	opt/VirtualBox/VBoxREM64.so
	opt/VirtualBox/VBoxSharedClipboard.so
	opt/VirtualBox/VBoxHeadless.so
	opt/VirtualBox/VBoxRT.so
	opt/VirtualBox/VRDPAuth.so
	opt/VirtualBox/VBoxREM.so
	opt/VirtualBox/VBoxSettings.so
	opt/VirtualBox/VBoxKeyboard.so
	opt/VirtualBox/VBoxSharedCrOpenGL.so
	opt/VirtualBox/VBoxVMM.so
	opt/VirtualBox/VirtualBox.so
	opt/VirtualBox/VBoxOGLhosterrorspu.so
	opt/VirtualBox/components/VBoxC.so
	opt/VirtualBox/components/VBoxSVCM.so
	opt/VirtualBox/VBoxREM32.so
	opt/VirtualBox/VBoxPython2_5.so
	opt/VirtualBox/VBoxXPCOMC.so
	opt/VirtualBox/VBoxOGLhostcrutil.so
	opt/VirtualBox/VBoxNetDHCP.so"
QA_PRESTRIPPED="opt/VirtualBox/VBoxDD.so
	opt/VirtualBox/VBoxDD2.so
	opt/VirtualBox/VBoxDDU.so
	opt/VirtualBox/VBoxDbg.so
	opt/VirtualBox/VBoxGuestPropSvc.so
	opt/VirtualBox/VBoxHeadless
	opt/VirtualBox/VBoxHeadless.so
	opt/VirtualBox/VBoxKeyboard.so
	opt/VirtualBox/VBoxManage
	opt/VirtualBox/VBoxNetAdpCtl
	opt/VirtualBox/VBoxNetDHCP
	opt/VirtualBox/VBoxNetDHCP.so
	opt/VirtualBox/VBoxOGLhostcrutil.so
	opt/VirtualBox/VBoxOGLhosterrorspu.so
	opt/VirtualBox/VBoxOGLrenderspu.so
	opt/VirtualBox/VBoxPython.so
	opt/VirtualBox/VBoxPython2_3.so
	opt/VirtualBox/VBoxPython2_4.so
	opt/VirtualBox/VBoxPython2_5.so
	opt/VirtualBox/VBoxPython2_6.so
	opt/VirtualBox/VBoxREM.so
	opt/VirtualBox/VBoxREM32.so
	opt/VirtualBox/VBoxREM64.so
	opt/VirtualBox/VBoxRT.so
	opt/VirtualBox/VBoxSDL
	opt/VirtualBox/VBoxSDL.so
	opt/VirtualBox/VBoxSVC
	opt/VirtualBox/VBoxSettings.so
	opt/VirtualBox/VBoxSharedClipboard.so
	opt/VirtualBox/VBoxSharedCrOpenGL.so
	opt/VirtualBox/VBoxSharedFolders.so
	opt/VirtualBox/VBoxTestOGL
	opt/VirtualBox/VBoxTunctl
	opt/VirtualBox/VBoxVMM.so
	opt/VirtualBox/VBoxVRDP.so
	opt/VirtualBox/VBoxXPCOM.so
	opt/VirtualBox/VBoxXPCOMC.so
	opt/VirtualBox/VBoxXPCOMIPCD
	opt/VirtualBox/VRDPAuth.so
	opt/VirtualBox/VirtualBox
	opt/VirtualBox/VirtualBox.so
	opt/VirtualBox/accessible/libqtaccessiblewidgets.so
	opt/VirtualBox/components/VBoxC.so
	opt/VirtualBox/components/VBoxSVCM.so
	opt/VirtualBox/components/VBoxXPCOMIPCC.so
	opt/VirtualBox/kchmviewer
	opt/VirtualBox/libQtCoreVBox.so.4
	opt/VirtualBox/libQtGuiVBox.so.4
	opt/VirtualBox/libQtNetworkVBox.so.4
	opt/VirtualBox/vboxwebsrv"

pkg_setup() {
	# We cannot mirror VirtualBox PUEL licensed files see:
	# http://www.virtualbox.org/wiki/Licensing_FAQ
	check_license
}

src_unpack() {
	unpack_makeself ${MY_P}_${ARCH}.run
	unpack ./VirtualBox.tar.bz2

	if use sdk; then
		unpack VirtualBoxSDK-${MY_PV}.zip
	fi
}

src_install() {
	# create virtualbox configurations files
	insinto /etc/vbox
	newins "${FILESDIR}/${PN}-config" vbox.cfg

	if ! use headless ; then
		newicon VBox.png ${PN}.png
		newmenu "${FILESDIR}"/${PN}.desktop ${PN}.desktop
	fi

	insinto /opt/VirtualBox
	dodir /opt/bin

	doins UserManual.pdf

	if use sdk ; then
		doins -r sdk || die
	fi

	if use additions; then
		doins -r additions || die
	fi

	if use vboxwebsrv; then
		doins vboxwebsrv || die
		fowners root:vboxusers /opt/VirtualBox/vboxwebsrv
		fperms 0750 /opt/VirtualBox/vboxwebsrv
		dosym /opt/VirtualBox/VBox.sh /opt/bin/vboxwebsrv
		newinitd "${FILESDIR}"/vboxwebsrv-initd vboxwebsrv
		newconfd "${FILESDIR}"/vboxwebsrv-confd vboxwebsrv
	fi

	if ! use headless && use chm; then
		doins kchmviewer VirtualBox.chm || die
		fowners root:vboxusers /opt/VirtualBox/kchmviewer
		fperms 0750 /opt/VirtualBox/kchmviewer
	fi

	rm -rf src rdesktop* deffiles install* routines.sh runlevel.sh \
		vboxdrv.sh VBox.sh VBox.png vboxnet.sh additions VirtualBox.desktop \
		VirtualBox.tar.bz2 LICENSE VBoxSysInfo.sh rdesktop* vboxwebsrv \
		webtest kchmviewer VirtualBox.chm vbox-create-usb-node.sh \
		90-vbox-usb.fdi uninstall.sh vboxshell.py vboxdrv-pardus.py

	if use headless ; then
		rm -rf VBoxSDL VirtualBox VBoxKeyboard.so
	fi

	doins -r * || die

	# create symlinks for working around unsupported $ORIGIN/.. in VBoxC.so (setuid)
	dosym /opt/VirtualBox/VBoxVMM.so /opt/VirtualBox/components/VBoxVMM.so
	dosym /opt/VirtualBox/VBoxREM.so /opt/VirtualBox/components/VBoxREM.so
	dosym /opt/VirtualBox/VBoxRT.so /opt/VirtualBox/components/VBoxRT.so
	dosym /opt/VirtualBox/VBoxDDU.so /opt/VirtualBox/components/VBoxDDU.so
	dosym /opt/VirtualBox/VBoxXPCOM.so /opt/VirtualBox/components/VBoxXPCOM.so

	# Use Native Qt4, enables proper system Qt4 theme to be used.
	if use system-qt4 ; then
		for i in libQtCore libQtNetwork libQtGui libQtOpenGL ; do
			einfo "Using native ${i}"
			mv "${D}"/opt/VirtualBox/${i}VBox.so.4 "${D}"/opt/VirtualBox/${i}VBox.so.4.original
			dosym ${ROOT}/usr/lib/qt4/${i}.so.4 /opt/VirtualBox/${i}VBox.so.4
		done
	fi


	local each
	for each in VBox{Manage,SVC,XPCOMIPCD,Tunctl,NetAdpCtl,NetDHCP,TestOGL}; do
		fowners root:vboxusers /opt/VirtualBox/${each}
		fperms 0750 /opt/VirtualBox/${each}
		pax-mark -m "${D}"/opt/VirtualBox/${each}
	done
	# VBoxNetAdpCtl binary needs to be suid root in any case..
	fperms 4750 /opt/VirtualBox/VBoxNetAdpCtl

	if ! use headless ; then
		# Hardened build: Mark selected binaries set-user-ID-on-execution
		for each in VBox{SDL,Headless} VirtualBox; do
			fowners root:vboxusers /opt/VirtualBox/${each}
			fperms 4510 /opt/VirtualBox/${each}
			pax-mark -m "${D}"/opt/VirtualBox/${each}
		done

		dosym /opt/VirtualBox/VBox.sh /opt/bin/VirtualBox
		dosym /opt/VirtualBox/VBox.sh /opt/bin/VBoxSDL
	else
		# Hardened build: Mark selected binaries set-user-ID-on-execution
		fowners root:vboxusers /opt/VirtualBox/VBoxHeadless
		fperms 4510 /opt/VirtualBox/VBoxHeadless
		pax-mark -m "${D}"/opt/VirtualBox/VBoxHeadless
	fi

	exeinto /opt/VirtualBox
	newexe "${FILESDIR}/${PN}-2-wrapper" "VBox.sh" || die
	fowners root:vboxusers /opt/VirtualBox/VBox.sh
	fperms 0750 /opt/VirtualBox/VBox.sh

	dosym /opt/VirtualBox/VBox.sh /opt/bin/VBoxManage
	dosym /opt/VirtualBox/VBox.sh /opt/bin/VBoxVRDP
	dosym /opt/VirtualBox/VBox.sh /opt/bin/VBoxHeadless
	dosym /opt/VirtualBox/VBoxTunctl /opt/bin/VBoxTunctl
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	elog ""
	if ! use headless ; then
		elog "To launch VirtualBox just type: \"VirtualBox\""
		elog ""
	fi
	elog "You must be in the vboxusers group to use VirtualBox."
	elog ""
	elog "For advanced networking setups you should emerge:"
	elog "net-misc/bridge-utils and sys-apps/usermode-utilities"
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
