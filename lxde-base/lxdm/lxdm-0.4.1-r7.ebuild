# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils autotools systemd

DESCRIPTION="LXDE Display Manager"
HOMEPAGE="http://lxde.org"
SRC_URI="mirror://sourceforge/lxde/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~arm ~amd64 ~x86"

IUSE="consolekit debug gtk3 nls pam"

RDEPEND="consolekit? ( sys-auth/consolekit )
	x11-libs/libxcb
	>=x11-themes/sabayon-artwork-lxde-8-r1
	gtk3? ( x11-libs/gtk+:3 )
	!gtk3? ( x11-libs/gtk+:2 )
	nls? ( sys-devel/gettext )
	pam? ( virtual/pam )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	dev-util/pkgconfig"

src_prepare() {
	# Upstream bug, tarball contains pre-made lxdm.conf
	rm "${S}"/data/lxdm.conf || die

	# There is consolekit
	epatch "${FILESDIR}/${P}-pam_console-disable.patch"
	# Backported, drop it when 0.4.2
	epatch "${FILESDIR}/${P}-git-fix-null-pointer-deref.patch"
	# Sabayon specific theme patch
	epatch "${FILESDIR}/${P}-sabayon-8-theme.patch"
	# Fix sessions with arguments, see:
	# http://lists.sabayon.org/pipermail/devel/2012-January/007582.html
	epatch "${FILESDIR}/${P}-fix-session-args.patch"

	epatch "${FILESDIR}"/${P}-configure-add-pam.patch

	# 403999
	epatch "${FILESDIR}"/${P}-missing-pam-defines.patch

	epatch "${FILESDIR}"/${P}-fix-event-check-bug.patch

	# Also see #422495
	epatch "${FILESDIR}"/${P}-pam-use-system-local-login.patch

	# See https://bugs.launchpad.net/ubuntu/+source/lxdm/+bug/922363
	epatch "${FILESDIR}/${P}-fix-pam-100-cpu.patch"

	# Make consolekit optional
	epatch "${FILESDIR}/${P}-optional-consolekit.patch"

	# this replaces the bootstrap/autogen script in most packages
	eautoreconf

	# process LINGUAS
	if use nls; then
		einfo "Running intltoolize ..."
		intltoolize --force --copy --automake || die
		strip-linguas -i "${S}/po" || die
	fi
}
src_configure() {
	econf	--enable-password \
		--with-x \
		--with-xconn=xcb \
		$(use_enable consolekit) \
		$(use_enable gtk3) \
		$(use_enable nls) \
		$(use_enable debug) \
		$(use_with pam)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS README TODO || die

	systemd_dounit "${FILESDIR}/lxdm.service"
}

pkg_postinst() {
	echo
	elog "LXDM in the early stages of development!"
	echo
}
