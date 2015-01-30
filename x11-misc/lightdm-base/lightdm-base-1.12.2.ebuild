# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit autotools eutils pam readme.gentoo systemd versionator

TRUNK_VERSION="$(get_version_component_range 1-2)"
REAL_PN="${PN/-base}"
REAL_P="${P/-base}"
DESCRIPTION="A lightweight display manager, base libraries and programs"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/LightDM"
SRC_URI="http://launchpad.net/${REAL_PN}/${TRUNK_VERSION}/${PV}/+download/${REAL_P}.tar.xz
	mirror://gentoo/introspection-20110205.m4.tar.bz2"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~x86"
IUSE="+introspection"
S="${WORKDIR}/${REAL_P}"

COMMON_DEPEND=">=dev-libs/glib-2.32.3:2
	dev-libs/libxml2
	sys-apps/accountsservice
	virtual/pam
	x11-libs/libX11
	>=x11-libs/libxklavier-5
	introspection? ( >=dev-libs/gobject-introspection-1 )"

RDEPEND="${COMMON_DEPEND}
	>=sys-auth/pambase-20101024-r2"
DEPEND="${COMMON_DEPEND}
	dev-util/gtk-doc-am
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig"
PDEPEND="app-admin/eselect-lightdm"

DOCS=( NEWS )

src_prepare() {
	sed -i -e 's:getgroups:lightdm_&:' tests/src/libsystem.c || die #412369
	sed -i -e '/minimum-uid/s:500:1000:' data/users.conf || die

	einfo "Fixing the session-wrapper variable in lightdm.conf"
	sed -i -e \
		"/session-wrapper/s@^.*@session-wrapper=/etc/${PN}/Xsession@" \
		data/lightdm.conf || die "Failed to fix lightdm.conf"

	epatch_user

	# Remove bogus Makefile statement. This needs to go upstream
	sed -i /"@YELP_HELP_RULES@"/d help/Makefile.am || die
	if has_version dev-libs/gobject-introspection; then
		eautoreconf
	else
		AT_M4DIR=${WORKDIR} eautoreconf
	fi
}

src_configure() {
	# Set default values if global vars unset
	local _user
	_user=${LIGHTDM_USER:=root}
	# Let user know how lightdm is configured
	einfo "Sabayon configuration"
	einfo "Greeter user: ${_user}"

	# also disable tests because libsystem.c does not build. Tests are
	# restricted so it does not matter anyway.
	econf \
		--localstatedir=/var \
		--disable-static \
		--disable-tests \
		--disable-liblightdm-qt \
		--disable-liblightdm-qt5 \
		--with-greeter-user=${_user} \
		$(use_enable introspection) \
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF}/html
}

src_install() {
	default

	# Delete apparmor profiles because they only work with Ubuntu's
	# apparmor package. Bug #494426
	if [[ -d ${D}/etc/apparmor.d ]]; then
		rm -r "${D}/etc/apparmor.d" || die \
			"Failed to remove apparmor profiles"
	fi

	insinto /etc/${REAL_PN}
	doins data/{${REAL_PN},keys}.conf
	doins "${FILESDIR}"/Xsession
	fperms +x /etc/${REAL_PN}/Xsession
	# /var/lib/lightdm-data could be useful. Bug #522228
	dodir /var/lib/lightdm-data

	prune_libtool_files --all
	rm -rf "${ED}"/etc/init

	pamd_mimic system-local-login ${REAL_PN} auth account session #372229
	dopamd "${FILESDIR}"/${REAL_PN}-autologin #390863, #423163

	readme.gentoo_create_doc

	systemd_dounit "${FILESDIR}/${REAL_PN}.service"
}
