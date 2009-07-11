# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

EAPI=2

inherit eutils fdo-mime pax-utils

MY_PV=${PV}-49928
MY_P=VirtualBox-${MY_PV}-Linux

DESCRIPTION="Family of powerful x86 virtualization products for enterprise as well as home use"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="amd64? ( http://download.virtualbox.org/virtualbox/${PV}/${MY_P}_amd64.run )
	x86? ( http://download.virtualbox.org/virtualbox/${PV}/${MY_P}_x86.run )
	sdk? ( http://download.virtualbox.org/virtualbox/${PV}/VirtualBoxSDK-${MY_PV}.zip )"

LICENSE="PUEL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+additions +chm headless sdk vboxwebsrv"
RESTRICT="strip"

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
	x86? ( sys-libs/libstdc++-v3 )"

S=${WORKDIR}

QA_TEXTRELS_amd64="opt/VirtualBox/VBoxVMM.so"

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
		90-vbox-usb.fdi uninstall.sh vboxshell.py

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

