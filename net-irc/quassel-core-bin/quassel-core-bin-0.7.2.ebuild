# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

DESCRIPTION="Qt4/KDE4 IRC client. This provides the \"core\" (server) component (static build, no Qt dependency)."
HOMEPAGE="http://quassel-irc.org/"

MY_FETCH_NAME="quasselcore-static-${PV}"
[[ "${PV}" = "0.7.2" ]] && MY_FETCH_NAME="quasselcore-static-0.7.1"

SRC_URI="http://quassel-irc.org/pub/${MY_FETCH_NAME}.bz2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="!net-irc/quassel-core"

# MY_P=${P/-core-bin}
MY_PN=${PN/-core-bin}

pkg_setup() {
	QUASSEL_DIR=/var/lib/${MY_PN}
	QUASSEL_USER=${MY_PN}
	# create quassel:quassel user
	enewgroup "${QUASSEL_USER}"
	enewuser "${QUASSEL_USER}" -1 -1 "${QUASSEL_DIR}" "${QUASSEL_USER}"
}

src_install() {
	newbin "${MY_FETCH_NAME}" "${MY_FETCH_NAME%%-*}"

	# server stuff
	# prepare folders in /var/
	keepdir "${QUASSEL_DIR}"
	fowners "${QUASSEL_USER}":"${QUASSEL_USER}" "${QUASSEL_DIR}"

	# init scripts
	newinitd "${FILESDIR}"/quasselcore.init quasselcore || die "newinitd failed"
	newconfd "${FILESDIR}"/quasselcore.conf quasselcore || die "newconfd failed"

	# logrotate
	insinto /etc/logrotate.d
	newins "${FILESDIR}/quassel.logrotate" quassel || die "newins failed"
}

pkg_postinst() {
	einfo "If you want to generate SSL certificate remember to run:"
	einfo "	emerge --config =${CATEGORY}/${PF}"

	# temporary info mesage
	echo
	ewarn "Please note that all configuration moved from"
	ewarn "/home/\${QUASSEL_USER}/.config/quassel-irc.org/"
	ewarn "to: ${QUASSEL_DIR}."
	echo
	ewarn "For migration, stop the core, move quasselcore files (pretty much"
	ewarn "everything apart from quasselclient.conf and settings.qss) into"
	ewarn "new location and then start server again."
}

pkg_config() {
	if use ssl; then
		# generate the pem file only when it does not already exist
		if [ ! -f "${QUASSEL_DIR}/quasselCert.pem" ]; then
			einfo "Generating QUASSEL SSL certificate to: \"${QUASSEL_DIR}/quasselCert.pem\""
			openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
				-keyout "${QUASSEL_DIR}/quasselCert.pem" \
				-out "${QUASSEL_DIR}/quasselCert.pem"
			# permissions for the key
			chown ${QUASSEL_USER}:${QUASSEL_USER} "${QUASSEL_DIR}/quasselCert.pem"
			chmod 400 "${QUASSEL_DIR}/quasselCert.pem"
		else
			einfo "Certificate \"${QUASSEL_DIR}/quasselCert.pem\" already exists."
			einfo "Remove it if you want to create new one."
		fi
	fi
}
