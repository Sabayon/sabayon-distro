# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $

MY_P="cedega-000133"
DESCRIPTION="Cedega replaces WineX, a distribution of Wine with enhanced DirectX for gaming"
HOMEPAGE="http://www.transgaming.com/"
SRC_URI="${MY_P}.tgz"

LICENSE="cedega"
SLOT="3"
KEYWORDS="-* amd64 x86"
IUSE="cups dbus opengl"
RESTRICT="fetch strip"

RDEPEND="x11-libs/libX11
	opengl? ( virtual/opengl )
	dbus? ( dev-python/dbus-python )
	>=sys-libs/ncurses-5.2
	cups? ( net-print/cups )
	>=media-libs/freetype-2.0.0
	>=dev-lang/python-2.4
	>=dev-python/pygtk-2.6
	>=dev-util/glade-2.6
	!app-emulation/point2play
	amd64? ( app-emulation/emul-linux-x86-xlibs
	         app-emulation/emul-linux-x86-soundlibs )"

pkg_nofetch() {
	einfo "Please download the appropriate Cedega archive (${MY_P}.tgz)"
	einfo "from ${HOMEPAGE} (requires a Transgaming subscription)"
	einfo
	einfo "Then put the file in ${DISTDIR}"
}

src_install() {
	#rm -r "${WORKDIR}"/usr/share/gnome
	#rmdir "${WORKDIR}"/usr/share/* >& /dev/null
	mv "${WORKDIR}"/usr "${D}"/ || die "mv usr"
}

pkg_postinst() {
	einfo "Run /usr/bin/cedega to start cedega as any non-root user."
	einfo "This is a wrapper-script which will take care of creating"
	einfo "an initial environment and do everything else."
	einfo ""
	einfo "Optionally, if you have binfmt_misc compiled into your kernel,"
	einfo "you can add the following to /etc/sysctl.conf to allow direct"
	einfo "execution of Windows binaries through the cedega wrapper:"
	einfo ""
	einfo "  fs.binfmt_misc.register = :WINEXE:M::MZ::/usr/bin/cedega:"
	einfo ""
	einfo "You will also need to mount the /proc/sys/fs/binfmt_misc"
	einfo "file system in order for this to work.  You can add the following"
	einfo "line into your /etc/fstab file:"
	einfo ""
	einfo "  none  /proc/sys/fs/binfmt_misc  binfmt_misc  defaults 0 0"
	einfo ""
	einfo "Note: Binaries will still need executable permissions to run."
	einfo "Note: If binfmt_misc is compiled as a module, make sure you"
	einfo "have it loaded on startup by adding it to"
	einfo "/etc/modules.autoload.d/<your kernel version>"
}
