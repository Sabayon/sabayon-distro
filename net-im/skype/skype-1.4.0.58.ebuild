# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/skype/skype-1.3.0.53-r1.ebuild,v 1.5 2007/03/17 12:31:56 beandog Exp $

inherit eutils qt3


#If you want to know when this package will be marked stable please see the Changelog
RESTRICT="nomirror nostrip"
AVATARV="1.0"
DESCRIPTION="${PN} is a P2P-VoiceIP client."
MY_PN=${PN}-alpha
S=${WORKDIR}/${PN}-${PV}_alpha
HOMEPAGE="http://www.skype.com/"
SRC_URI="http://dev.gentoo.org/~humpback/skype-avatars-${AVATARV}.tgz
		!static? ( http://download.skype.com/linux/${MY_PN}-${PV}-generic.tar.bz2 )
		static? (
		http://download.skype.com/linux/${MY_PN}_staticQT-${PV}-generic.tar.bz2 )"

LICENSE="skype-eula"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="static cjk"
DEPEND="
	amd64? ( >=app-emulation/emul-linux-x86-xlibs-1.2
		>=app-emulation/emul-linux-x86-baselibs-2.1.1
		>=app-emulation/emul-linux-x86-soundlibs-2.4
		app-emulation/emul-linux-x86-compat
		!static? ( >=app-emulation/emul-linux-x86-qtlibs-1.1 ) )
	x86? ( >=sys-libs/glibc-2.3.2
		>=media-libs/alsa-lib-1.0.11
		virtual/libstdc++
		!static? ( $(qt_min_version 3.2) ) )"
RDEPEND="${DEPEND}
	>=sys-apps/dbus-0.23.4"

QA_EXECSTACK_x86="opt/skype/skype"
QA_EXECSTACK_amd64="opt/skype/skype"

src_unpack() {
	if use static;
	then
		unpack ${MY_PN}_staticQT-${PV}-generic.tar.bz2
	else
		if use cjk;
		then
			ewarn "If you use scim to have Multi-byte character's in QT"
			ewarn "applications you will not be able to input cjk. This is a"
			ewarn "know upstream issue"
			sleep 5
		fi
		unpack ${MY_PN}-${PV}-generic.tar.bz2
	fi
	cd ${S}
	unpack skype-avatars-${AVATARV}.tgz

}

src_install() {

	# remove mprotect() restrictions for PaX usage - see Bug 100507
	[[ -x /sbin/chpax ]] && /sbin/chpax -m skype

	dodir /opt/${PN}
	exeopts -m0755
	exeinto /opt/${PN}
	doexe skype
	doexe ${FILESDIR}/skype.sh
	dosym /opt/skype/skype.sh /usr/bin/skype

	insinto /opt/${PN}/sounds
	doins sounds/*.wav

	insinto /etc/dbus-1/system.d
	newins ${FILESDIR}/skype.debus.config skype.conf

	insinto /opt/${PN}/avatars
	doins avatars/*.jpg

	insinto /opt/${PN}
	insinto /usr/share/pixmaps
	doins ${FILESDIR}/${PN}.png

	fowners root:audio /opt/skype/skype

	insinto /usr/share/applications/
	doins ${FILESDIR}/skype.desktop

	dodir /usr/bin/

	# TODO: Optional configuration of callto:// in KDE, Mozilla and friends
}

pkg_postinst() {
	einfo "If you have sound problems please visit: "
	einfo "http://forum.skype.com/bb/viewtopic.php?t=4489"
	einfo "These kernel options are reported to help"
	einfo "Processor type and features --->"
	einfo "-- Preemption Model (Preemptible Kernel (Low-Latency Desktop))"
	einfo "-- Timer frequency (250 HZ)"
	ewarn ""
	ewarn "This release no longer uses the old wrapper because skype now uses
	ALSA"
	ewarn ""

}
