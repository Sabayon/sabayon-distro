# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit eutils base autotools

DESCRIPTION="LXDE Display Manager"
HOMEPAGE="http://lxde.org/"
SRC_URI="mirror://sourceforge/lxde/${P}.tar.gz"
KEYWORDS="~amd64 ~arm ~ppc ~x86 ~x86-interix ~amd64-linux ~x86-linux"
SLOT="0"
IUSE="+X nls"
LICENSE="GPL-2 GPL-3 LGPL-2.1"

RDEPEND="x11-libs/gtk+:2
	 dev-libs/glib:2
	 sys-libs/pam
	 sys-auth/consolekit
	 X? ( x11-libs/libXmu
	      x11-libs/libX11 )"

DEPEND+="${RDEPEND}
	>=dev-util/intltool-0.40
	dev-util/pkgconfig
	nls? ( sys-devel/gettext )
	"

DOCS="AUTHORS README TODO"

src_configure() {
	econf $(use_with X x) \
		$(use nls || --disable-nls)
}

src_prepare() {
	# this will apply all patches in PATCHES array
	base_src_prepare

	# this replaces the bootstrap/autogen script in most packages
	eautoreconf

	# process LINGUAS
	if [[ -d "${S}/po" ]]; then
		einfo "Running intltoolize ..."
		intltoolize --force --copy --automake || die
		strip-linguas -i "${S}/po"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die

	# install all docs in DOCS variable
	if [[ -n "${DOCS}" ]]; then
		dodoc $DOCS || die
	fi

	newinitd "${FILESDIR}"/lxdm.init.d lxdm || \
		die "Cannot install /etc/init.d/lxdm"

	newconfd "${FILESDIR}"/lxdm.conf.d lxdm || \
		die "Cannot install /etc/conf.d/lxdm"
}

pkg_postinst() {
	ewarn ""
	ewarn "LXDM in the early stages of development!"
	ewarn "Today /etc/lxdm/xsession is not compatible with Gentoo's"
	ewarn "xdm init script."
	ewarn "It will need to be changed to start X Session correctly."
	ewarn ""
	ewarn "LXDM cannot currently be started using /etc/init.d/xdm."
	ewarn "Use /etc/init.d/lxdm as an alternative."
	ewarn ""
}
