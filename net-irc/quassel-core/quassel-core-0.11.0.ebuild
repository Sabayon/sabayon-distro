# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils eutils pax-utils systemd user versionator

EGIT_REPO_URI="git://git.quassel-irc.org/quassel"
[[ "${PV}" == "9999" ]] && inherit git-r3

DESCRIPTION="Qt/KDE IRC client - the \"core\" (server) component"
HOMEPAGE="http://quassel-irc.org/"
MY_P=${P/-core}
MY_PN=${PN/-core}
[[ "${PV}" == "9999" ]] || SRC_URI="http://quassel-irc.org/pub/${MY_P/_/-}.tar.bz2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="crypt postgres qt5 +ssl syslog"

SERVER_RDEPEND="
	qt5? (
		dev-qt/qtscript:5
		postgres? ( dev-qt/qtsql:5[postgres] )
		!postgres? ( dev-qt/qtsql:5[sqlite] dev-db/sqlite:3[threadsafe(+),-secure-delete] )
	)
	!qt5? (
		dev-qt/qtscript:4
		crypt? (
			app-crypt/qca:2[qt4(+)]
			|| ( app-crypt/qca-ossl:2 app-crypt/qca:2[openssl] )
		)
		postgres? ( dev-qt/qtsql:4[postgres] )
		!postgres? ( dev-qt/qtsql:4[sqlite] dev-db/sqlite:3[threadsafe(+),-secure-delete] )
	)
	syslog? ( virtual/logger )
"

RDEPEND="
	sys-libs/zlib
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtnetwork:5[ssl?]
	)
	!qt5? ( dev-qt/qtcore:4[ssl?] )
	${SERVER_RDEPEND}
"
DEPEND="
	${RDEPEND}
	!net-irc/quassel-core-bin
	"

DOCS=( AUTHORS ChangeLog README )

S="${WORKDIR}/${MY_P/_/-}"

pkg_setup() {
	QUASSEL_DIR=/var/lib/${MY_PN}
	QUASSEL_USER=${MY_PN}
	# create quassel:quassel user
	enewgroup "${QUASSEL_USER}"
	enewuser "${QUASSEL_USER}" -1 -1 "${QUASSEL_DIR}" "${QUASSEL_USER}"
}

src_configure() {
	local mycmakeargs=(
		"CMAKE_DISABLE_FIND_PACKAGE_IndicateQt=ON"
		$(cmake-utils_use_find_package crypt QCA2)
		# $(cmake-utils_use_find_package dbus dbusmenu-qt)
		# $(cmake-utils_use_find_package dbus dbusmenu-qt5)
		"-DWITH_KDE=OFF"
		"-DWITH_OXYGEN=OFF"
		"-DWANT_MONO=OFF"

		"CMAKE_DISABLE_FIND_PACKAGE_phonon=ON"
		"CMAKE_DISABLE_FIND_PACKAGE_Phonon=ON"
		"CMAKE_DISABLE_FIND_PACKAGE_PHONON=ON"

		"CMAKE_DISABLE_FIND_PACKAGE_Phonon4Qt5=ON"
		$(cmake-utils_use_use qt5)
		"-DWANT_CORE=ON"
		"-DWITH_WEBKIT=OFF"
		"-DWANT_QTCLIENT=OFF"
		"-DEMBED_DATA=OFF"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rm -rf "${ED}"usr/share/apps/quassel/ || die
	rm -f "${ED}"usr/share/pixmaps/quassel.png || die
	rm -f "${ED}"usr/share/icons/hicolor/48x48/apps/quassel.png || die

	# server stuff

	# needs PAX marking wrt bug#346255
	pax-mark m "${ED}/usr/bin/quasselcore"

	# prepare folders in /var/
	keepdir "${QUASSEL_DIR}"
	fowners "${QUASSEL_USER}":"${QUASSEL_USER}" "${QUASSEL_DIR}"

	# init scripts & systemd unit
	newinitd "${FILESDIR}"/quasselcore.init quasselcore
	newconfd "${FILESDIR}"/quasselcore.conf quasselcore
	systemd_dounit "${FILESDIR}"/quasselcore.service

	# logrotate
	insinto /etc/logrotate.d
	newins "${FILESDIR}/quassel.logrotate" quassel
}

pkg_postinst() {
	einfo "If you want to generate SSL certificate remember to run:"
	einfo "	emerge --config =${CATEGORY}/${PF}"

	# server || monolithic
	einfo "Quassel can use net-misc/oidentd package if installed on your system."
	einfo "Consider installing it if you want to run quassel within identd daemon."

	# temporary info mesage
	if [[ $(get_version_component_range 2 ${REPLACING_VERSIONS}) -lt 7 ]]; then
		echo
		ewarn "Please note that all configuration moved from"
		ewarn "/home/\${QUASSEL_USER}/.config/quassel-irc.org/"
		ewarn "to: ${QUASSEL_DIR}."
		echo
		ewarn "For migration, stop the core, move quasselcore files (pretty much"
		ewarn "everything apart from quasselclient.conf and settings.qss) into"
		ewarn "new location and then start server again."
	fi
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
