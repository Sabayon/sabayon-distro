# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils autotools

DESCRIPTION="LXDE Display Manager"
HOMEPAGE="http://lxde.org"
SRC_URI="mirror://sourceforge/lxde/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="debug gtk3 nls"

RDEPEND="sys-libs/pam
	sys-auth/consolekit
	x11-libs/libxcb
	>=x11-themes/sabayon-artwork-lxde-6_beta2
	gtk3? ( x11-libs/gtk+:3 )
	!gtk3? ( x11-libs/gtk+:2 )
	nls? ( sys-devel/gettext )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	dev-util/pkgconfig"

src_configure() {
	econf	--enable-password \
		--with-pam \
		--with-x \
		--with-xconn=xcb \
		$(use_enable gtk3) \
		$(use_enable nls) \
		$(use_enable debug) \
		|| die "econf failed"
}

src_prepare() {
	# There is consolekit
	epatch "${FILESDIR}/${P}-pam_console-disable.patch"
	# Sabayon specific theme patch
	epatch "${FILESDIR}/${P}-sabayon-6-theme.patch"

	# this replaces the bootstrap/autogen script in most packages
	eautoreconf

	# process LINGUAS
	if use nls; then
		einfo "Running intltoolize ..."
		intltoolize --force --copy --automake || die
		strip-linguas -i "${S}/po" || die
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS README TODO || die
	exeinto /etc/lxdm
	doexe "${FILESDIR}"/xinitrc || die
}

pkg_postinst() {
	echo
	elog "LXDM in the early stages of development!"
	echo
}
