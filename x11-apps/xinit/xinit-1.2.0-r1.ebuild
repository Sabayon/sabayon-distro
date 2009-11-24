# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xinit/xinit-1.2.0-r1.ebuild,v 1.1 2009/11/17 08:45:48 remi Exp $

EAPI="2"

inherit x-modular pam

DESCRIPTION="X Window System initializer"

LICENSE="${LICENSE} GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="+minimal pam"

RDEPEND="
	x11-apps/xauth
	x11-libs/libX11
"
DEPEND="${RDEPEND}"
PDEPEND="x11-apps/xrdb
	!minimal? (
		x11-apps/xclock
		x11-apps/xsm
		x11-terms/xterm
		x11-wm/twm
	)
"

PATCHES=(
	"${FILESDIR}/0001-Gentoo-specific-customizations.patch"
)

pkg_setup() {
	CONFIGURE_OPTIONS="--with-xinitdir=/etc/X11/xinit"
}

src_install() {
	x-modular_src_install
	exeinto /etc/X11
	doexe "${FILESDIR}"/chooser.sh "${FILESDIR}"/startDM.sh || die
	exeinto /etc/X11/Sessions
	doexe "${FILESDIR}"/Xsession || die
	exeinto /etc/X11/xinit
	doexe "${FILESDIR}"/xserverrc || die
	newinitd "${FILESDIR}"/xdm.initd-4 xdm || die
	newinitd "${FILESDIR}"/xdm-setup.initd-1 xdm-setup || die
	newconfd "${FILESDIR}"/xdm.confd-2 xdm || die
	newpamd "${FILESDIR}"/xserver.pamd xserver
	dodir /etc/X11/xinit/xinitrc.d
	exeinto /etc/X11/xinit/xinitrc.d/
	doexe "${FILESDIR}/00-xhost"
}

pkg_preinst() {
        # backup user /etc/conf.d/xdm
        if [ -f "${CONFD_XDM}" ]; then
                cp -p "${CONFD_XDM}" "${CONFD_XDM}.backup"
        fi
}

pkg_postinst() {

        # Copy config file over
        if [ -f "${CONFD_XDM}.backup" ]; then
                cp ${CONFD_XDM}.backup ${CONFD_XDM} -p
        else
                if [ -f "${CONFD_XDM}.example" ] && [ ! -f "${CONFD_XDM}" ]; then
                        cp ${CONFD_XDM}.example ${CONFD_XDM} -p
                fi
        fi

	x-modular_pkg_postinst
	ewarn "If you use startx to start X instead of a login manager like gdm/kdm,"
	ewarn "you can set the XSESSION variable to anything in /etc/X11/Sessions/ or"
	ewarn "any executable. When you run startx, it will run this as the login session."
	ewarn "You can set this in a file in /etc/env.d/ for the entire system,"
	ewarn "or set it per-user in ~/.bash_profile (or similar for other shells)."
	ewarn "Here's an example of setting it for the whole system:"
	ewarn "    echo XSESSION=\"Gnome\" > /etc/env.d/90xsession"
	ewarn "    env-update && source /etc/profile"
	ewarn
	ewarn "If you use the nox boot option to prevent x from starting on boot,"
	ewarn "you should now use gentoo=nox."
	ewarn
	ewarn "/etc/conf.d/xdm is no longer provided, /etc/conf.d/xdm.example is"
	ewarn "Your current /etc/conf.d/xdm has been used as new default"
	ewarn
}
