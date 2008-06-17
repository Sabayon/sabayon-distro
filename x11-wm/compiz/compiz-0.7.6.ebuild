# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/compiz/compiz-0.5.0.ebuild,v 1.1 2007/04/24 01:51:02 hanno Exp $

EAPI="1"

inherit autotools eutils gnome2-utils multilib

DESCRIPTION="3D composite- and windowmanager"
HOMEPAGE="http://www.compiz.org/"
SRC_URI="http://releases.compiz-fusion.org/${PV}/compiz/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1 MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="dbus fuse gnome gtk kde svg xcb"
RESTRICT="mirror"

DEPEND="
	>=media-libs/glitz-0.5.6
	media-libs/libpng
	>=media-libs/mesa-6.5.1-r1
	>=x11-base/xorg-server-1.1.1-r1
	>=x11-libs/gtk+-2.0
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/startup-notification
	x11-proto/damageproto
	dbus? ( >=sys-apps/dbus-1.0 )
	fuse? ( sys-fs/fuse )
	gnome? (
		>=gnome-base/gnome-control-center-2.16.1
		gnome-base/gconf
		>=x11-libs/libwnck-2.18.3
		)
	kde? (
		|| ( kde-base/kwin:3.5
			kde-base/kdebase:3.5 )
			dev-libs/dbus-qt3-old )
	svg? ( gnome-base/librsvg )
	xcb? ( x11-libs/libxcb )
"
RDEPEND="${DEPEND}
	x11-apps/mesa-progs
	x11-apps/xvinfo"

pkg_setup() {
	ewarn "If the build fails with an XGetXCBConnection error"
	ewarn "try this: eselect opengl set xorg-x11"
	ewarn "and/or read this: http://www.sabayonlinux.org/forum/viewtopic.php?f=53&t=12933"

	if use xcb && \
		! built_with_use x11-libs/libX11 xcb && \
		! built_with_use x11-libs/cairo xcb && \
		! built_with_use media-libs/mesa xcb
	then
		eerror "Compiz now requires libX11, cairo and mesa to be built with xcb."
		eerror "Please build libX11, cairo and mesa with USE=\"xcb\""
		ewarn "Be warned that building libX11 with xcb support might break Java."
		die "Build libX11, cairo and mesa with USE=\"xcb\""
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	use gnome || epatch "${FILESDIR}"/${PN}-no-gconf.patch
	use xcb || epatch "${FILESDIR}"/${PN}-drop-xcb.patch

	if use gnome || use xcb
	then
		# required to apply the above patches
		eautoreconf || die "eautoreconf failed"
		intltoolize --copy --force || die "intltoolize failed"
		glib-gettextize --copy --force || die "glib-gettextize failed"
	fi
}

src_compile() {
	econf \
		--with-default-plugins \
		$(use_enable dbus) \
		$(use_enable dbus dbus-glib) \
		$(use_enable fuse) \
		$(use_enable gnome) \
		$(use_enable gnome gconf) \
		$(use_enable gnome metacity) \
		$(use_enable gtk) \
		$(use_enable kde) \
		$(use_enable kde4) \
		$(use_enable svg librsvg) || die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# Install compiz-manager
	dobin "${FILESDIR}/compiz-manager" || die "dobin failed"

	# Add the full-path to lspci
	sed -i "s#lspci#/usr/sbin/lspci#" "${D}/usr/bin/compiz-manager"

	# Create gentoo's config file
	dodir /etc/xdg/compiz

	cat <<- EOF > "${D}/etc/xdg/compiz/compiz-manager"
	COMPIZ_BIN_PATH="/usr/bin/"
	PLUGIN_PATH="/usr/$(get_libdir)/compiz/"
	LIBGL_NVIDIA="/usr/$(get_libdir)/opengl/xorg-x11/libGL.so.1.2"
	LIBGL_FGLRX="/usr/$(get_libdir)/opengl/xorg-x11/libGL.so.1.2"
	KWIN="$(type -p kwin)"
	METACITY="$(type -p metacity)"
	SKIP_CHECKS="yes"
	EOF

	dodoc AUTHORS ChangeLog NEWS README TODO || die "dodoc failed"
}

pkg_postinst() {
	use gnome && gnome2_gconf_install
}

pkg_prerm() {
	use gnome && gnome2_gconf_uninstall
}

pkg_postinst() {
	ewarn "Dont forget to restore your opengl config if you set it to xorg-x11!"
}
