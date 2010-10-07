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
IUSE="+X nls +sabayon"
LICENSE="GPL-2 GPL-3 LGPL-2.1"

RDEPEND="x11-libs/gtk+:2
	 dev-libs/glib:2
	 sys-libs/pam
	 sys-auth/consolekit
	 X? ( x11-libs/libXmu
	      x11-libs/libX11 )
	 sabayon? ( x11-themes/sabayon-artwork-lxde )"

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

	epatch "${FILESDIR}/${P}-pam_console-disable.patch"

	if use sabayon; then
		epatch "${FILESDIR}/${P}-sabayon-theme.patch"
	fi

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

	# FIXME: deprecated, remove from FILESDIR
	# newinitd "${FILESDIR}"/lxdm.init.d lxdm || \
	#	die "Cannot install /etc/init.d/lxdm"
	# newconfd "${FILESDIR}"/lxdm.conf.d lxdm || \
	#	die "Cannot install /etc/conf.d/lxdm"

	exeinto /etc/lxdm
	doexe "${FILESDIR}"/xinitrc || \
		die "Cannot install /etc/lxdm/xinitrc"

	# Move the lxdm script to start-lxdm,
	# and symlink lxdm to lxdm-binary
	# mv ${D}/usr/sbin/lxdm ${D}/usr/sbin/start-lxdm || \
	#	die "Could not move /usr/sbin/lxdm..."
	# dosym /usr/sbin/lxdm-binary /usr/sbin/lxdm || \
	#	die "Could not symlink lxdm to lxdm-binary..."
}

pkg_postinst() {
	ewarn ""
	ewarn "LXDM in the early stages of development!"
	ewarn ""
	ewarn "Compatibility with Gentoo's xdm init script is in"
	ewarn "progresss."
	ewarn ""
	ewarn "Currently, if you want to start LXDM using xdm's"
	ewarn "init scripts, this can only be done with"
	ewarn "x11-apps/xinit-1.2.1 from the Sabayon overlay."
	ewarn "However, the changes are being coordinated with the"
	ewarn "Gentoo upstream, so this status is expected to change."
	ewarn ""
	ewarn "The /etc/init.d/lxdm init script can also be used"
	ewarn "as an alternative."
}
