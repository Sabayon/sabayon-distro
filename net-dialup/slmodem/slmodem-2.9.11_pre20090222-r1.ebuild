# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dialup/slmodem/slmodem-2.9.11_pre20090222-r1.ebuild,v 1.1 2009/06/20 20:48:10 mrness Exp $

EAPI="2"

inherit eutils linux-mod multilib

UNGRAB_PV="20080126"

DESCRIPTION="Driver for Smart Link modem"
HOMEPAGE="http://linmodems.technion.ac.il/packages/smartlink/"
SRC_URI="http://linmodems.technion.ac.il/packages/smartlink/${P/_pre/-}.tar.gz
	http://linmodems.technion.ac.il/packages/smartlink/ungrab-winmodem-${UNGRAB_PV}.tar.gz"

LICENSE="Smart-Link"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="alsa usb"

DEPEND="alsa? ( media-libs/alsa-lib )
	amd64? ( app-emulation/emul-linux-x86-soundlibs )"

RDEPEND="${DEPEND}
	virtual/logger"

QA_EXECSTACK="usr/sbin/slmodem_test usr/sbin/slmodemd"

S="${WORKDIR}"/${P/_pre/-}

pkg_setup() {
	use amd64 && multilib_toolchain_setup x86

	MODULE_NAMES="ungrab-winmodem(:${WORKDIR}/ungrab-winmodem-${UNGRAB_PV})"
	CONFIG_CHECK=""
	MY_SLMODULES=""
	if kernel_is ge 2 6 25; then
	    if use usb; then
		ewarn "slusb module will not be installed because is not compatible with kernels >=2.6.25"
	    fi
	elif use usb; then
		MODULE_NAMES="${MODULE_NAMES} slusb(net:${S}/drivers)"
		CONFIG_CHECK="${CONFIG_CHECK} USB"
		MY_SLMODULES="${MY_SLMODULES} slusb.o"
	fi
	BUILD_TARGETS="all"
	if kernel_is ge 2 6 24; then
		CONFIG_CHECK="${CONFIG_CHECK} PCI_LEGACY"
	fi
	linux-mod_pkg_setup
	BUILD_PARAMS="KERNEL_DIR=${KV_OUT_DIR}"
}

src_prepare() {
	cd "${WORKDIR}"
	sed -i "s:SUBDIRS=\$(shell pwd):SUBDIRS=${WORKDIR}/ungrab-winmodem-${UNGRAB_PV}:" \
		ungrab-winmodem-${UNGRAB_PV}/Makefile
	convert_to_m ungrab-winmodem-${UNGRAB_PV}/Makefile

	cd "${WORKDIR}/ungrab-winmodem-${UNGRAB_PV}"
	epatch "${FILESDIR}"/${PN}-ungrab-winmodem-hp500.patch

	cd "${S}"
	epatch "${FILESDIR}/${P%%_*}-makefile-r1.patch"

	cd "${S}"/drivers
	sed -i -e "s:SUBDIRS=\$(shell pwd):SUBDIRS=${S}/drivers:" \
	    -e "s|^obj-m:=.*$|obj-m:=${MY_SLMODULES}|" \
	    Makefile
	convert_to_m Makefile
	sed -i "s:.*=[ \t]*THIS_MODULE.*::" st7554.c amrmo_init.c old_st7554.c
	sed -i 's:MODULE_PARM(\([^,]*\),"i");:module_param(\1, int, 0);:' st7554.c \
		amrmo_init.c old_st7554.c
}

src_compile() {
	local MAKE_PARAMS=""
	if use alsa; then
		MAKE_PARAMS="SUPPORT_ALSA=1"
	fi
	emake ${MAKE_PARAMS} modem || die "failed to build modem"

	use amd64 && multilib_toolchain_setup amd64
	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install

	cd "${S}"
	newsbin modem/modem_test slmodem_test
	dosbin modem/slmodemd
	dodir /var/lib/slmodem
	fowners root:dialout /var/lib/slmodem
	keepdir /var/lib/slmodem

	newconfd "${FILESDIR}/slmodem-confd" ${PN}
	newinitd "${FILESDIR}/slmodem-initd" ${PN}

	# configure for alsa - or not for alsa
	if use alsa; then
		sed -i -e "s/# MODULE=alsa/MODULE=alsa/" \
			-e "s/# HW_SLOT=modem:1/HW_SLOT=modem:1/" "${D}/etc/conf.d/slmodem"
	elif use usb; then
		sed -i "s/# MODULE=slusb/MODULE=slusb/" "${D}/etc/conf.d/slmodem"
	else
		sed -i "s/# MODULE=slamr/MODULE=slamr/" "${D}/etc/conf.d/slmodem"
	fi

	# Add module aliases
	insinto /etc/modprobe.d/
	newins "${FILESDIR}/slmodem-modprobe" ${PN}.conf

	# Add configuration for udev
	dodir /etc/udev/rules.d/
	echo 'KERNEL=="slamr", NAME="slamr0" GROUP="dialout"' > \
		 "${D}/etc/udev/rules.d/55-${PN}.rules"
	if use usb; then
		exeinto /$(get_libdir)/udev
		newexe "${FILESDIR}/slusb-udev.script" slmodem_usb.sh
		echo 'KERNEL=="slusb", NAME="slusb0" GROUP="dialout" RUN+="slmodem_usb.sh"' >> \
			 "${D}/etc/udev/rules.d/55-${PN}.rules"
	fi

	dodoc Changes README
	newdoc "${WORKDIR}"/ungrab-winmodem-${UNGRAB_PV}/Readme.txt README-ungrab-winmodem.txt
}

pkg_postinst() {
	linux-mod_pkg_postinst

	# Make some devices if we aren't using devfs or udev
	if [ -e "${ROOT}/dev/.udev" ]; then
		ebegin "Reloading udev rules..."
			udevadm control --reload-rules
		eend $?
	else
		cd "${S}/drivers"
		make DESTDIR="${ROOT}" install-devices
	fi

	elog "You must edit /etc/conf.d/${PN} for your configuration"
	elog "To add slmodem to your startup - type : rc-update add slmodem default"
	elog

	if use alsa; then
		elog "I hope you have already added alsa to your startup: "
		elog "otherwise type: rc-update add alsasound boot"
		elog
		elog "If you need to use snd-intel8x0m from the kernel"
		elog "compile it as a module and edit /etc/modules.d/alsa"
		elog 'to: "alias snd-card-(number) snd-intel8x0m"'
		elog
	fi

	elog "You need to be in the uucp AND dialout group to make calls as a user."
	elog
	elog "If you see the following in dmesg:"
	elog "    slamr: device 10b9:5457 is grabbed by driver serial"
	elog "you need to modprobe ungrab-winmodem before slamr"
}
