# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/ipw3945d/ipw3945d-1.7.22-r4.ebuild,v 1.7 2007/02/13 16:42:21 wolf31o2 Exp $

inherit eutils

DESCRIPTION="Regulatory daemon for the Intel PRO/Wireless 3945ABG miniPCI express adapter"
HOMEPAGE="http://www.bughost.org/ipw3945/"
SRC_URI="http://www.bughost.org/ipw3945/daemon/${P}.tgz"

LICENSE="ipw3945"
SLOT="0"
KEYWORDS="amd64 x86"

# The daemon is binary only, is setXid, dyn linked,
# and using lazy bindings
RESTRICT="stricter"

IUSE=""
DEPEND=""

pkg_setup() {
	# Create a user for the ipw3945d daemon
	enewuser ipw3945d -1
}

src_install() {
	into /
	use x86 && dosbin x86/ipw3945d
	use amd64 && dosbin x86_64/ipw3945d

	# Give the ipw3945d access to the binary
	fowners ipw3945d:root /sbin/ipw3945d
	fperms 04450 /sbin/ipw3945d

	keepdir /var/run/ipw3945d
	fowners ipw3945d:root /var/run/ipw3945d

	newconfd "${FILESDIR}/${PN}-conf.d" ${PN}
	newinitd "${FILESDIR}/${PN}-init.d" ${PN}

	insinto /etc/modules.d
	newins "${FILESDIR}/${P}-modprobe.conf" ${PN}

	dodoc README.${PN}
}

pkg_postinst() {
	# Update the modules.d cache
	if [ -f "${ROOT}/etc/modules.d/${PN}" ] ; then
		ebegin "Executing /sbin/modules-update"
		"${ROOT}"sbin/modules-update --force
		eend $?
	fi

	echo

	# These nasty live-filesystem fixes are needed, because if the files are
	# already there, the permissions applied in src_install() won't get
	# merged to the live filesystem. Once portage is fixed with regard to
	# this, these hacks can go away.

	# Fix the permissions of /sbin/ipw3945d
	ebegin "Fixing permissions of ${ROOT}sbin/ipw3945d"
	chown ipw3945d:root "${ROOT}sbin/ipw3945d"
	chmod 04450 "${ROOT}sbin/ipw3945d"
	eend $?

	# Fixing ownership of /var/run/ipw3945d
	ebegin "Fixing ownership of ${ROOT}var/run/ipw3945d"
	chown ipw3945d:root "${ROOT}var/run/ipw3945d"
	eend $?

	echo

	einfo "The ipw3945 daemon is now started by udev. The daemon should be"
	einfo "brought up automatically once you reboot. Also make sure when you"
	einfo "update from a previous version, you need to reboot in order to"
	einfo "replace an existing version of this daemon!"
}
