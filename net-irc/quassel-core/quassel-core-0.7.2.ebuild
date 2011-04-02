# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

EGIT_REPO_URI="git://git.quassel-irc.org/quassel.git"
EGIT_BRANCH="master"
[[ "${PV}" == "9999" ]] && GIT_ECLASS="git"

QT_MINIMAL="4.6.0"
KDE_MINIMAL="4.4"

inherit cmake-utils eutils ${GIT_ECLASS}

DESCRIPTION="Qt4/KDE4 IRC client. This provides the \"core\" (server) component."
HOMEPAGE="http://quassel-irc.org/"
MY_P=${P/-core}
MY_PN=${PN/-core}
[[ "${PV}" == "9999" ]] || SRC_URI="http://quassel-irc.org/pub/${MY_P/_/-}.tar.bz2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="crypt dbus +ssl postgres"

SERVER_RDEPEND="
	crypt? (
		app-crypt/qca:2
		app-crypt/qca-ossl
	)
	!postgres? ( >=x11-libs/qt-sql-${QT_MINIMAL}:4[sqlite] dev-db/sqlite[threadsafe,-secure-delete] )
	postgres? ( >=x11-libs/qt-sql-${QT_MINIMAL}:4[postgres] )
	>=x11-libs/qt-script-${QT_MINIMAL}:4
"

RDEPEND="
	>=x11-libs/qt-core-${QT_MINIMAL}:4[ssl?]
	${SERVER_RDEPEND}
	"
DEPEND="
	${RDEPEND}
	!net-irc/quassel-core-bin
	"

DOCS="AUTHORS ChangeLog README"

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
		"-DWITH_LIBINDICATE=OFF"
		"-DWANT_CORE=ON"
		"-DWANT_QTCLIENT=OFF"
		"-DWANT_MONO=OFF"
		"-DWITH_WEBKIT=OFF"
		"-DWITH_PHONON=OFF"
		"-DWITH_KDE=OFF"
		$(cmake-utils_use_with dbus)
		$(cmake-utils_use_with ssl OPENSSL)
		"-DWITH_OXYGEN=OFF"
		$(cmake-utils_use_with crypt)
		"-DEMBED_DATA=OFF"
	)

	# -DSTATIC=ON
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rm -rf "${ED}"usr/share/apps/quassel/
	rm -f "${ED}"usr/share/pixmaps/quassel.png
	rm -f "${ED}"usr/share/icons/hicolor/48x48/apps/quassel.png

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
