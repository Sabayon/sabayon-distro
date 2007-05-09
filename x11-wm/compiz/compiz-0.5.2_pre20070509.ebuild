# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/compiz/compiz-0.5.0.ebuild,v 1.1 2007/04/24 01:51:02 hanno Exp $

inherit eutils

DESCRIPTION="3D composite- and windowmanager"
HOMEPAGE="http://www.compiz.org/"
PRE_PV="0.5.0"
SRC_URI="http://xorg.freedesktop.org/archive/individual/app/${PN}-${PRE_PV}.tar.bz2"
LICENSE="GPL-2 LGPL-2.1 MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="dbus gnome kde svg"
S=${WORKDIR}/${PN}-${PRE_PV}

DEPEND=">=media-libs/mesa-6.5.1-r1
	>=media-libs/glitz-0.5.6
	>=x11-base/xorg-server-1.1.1-r1
	x11-libs/libXdamage
	x11-libs/libXrandr
	x11-libs/libXcomposite
	x11-libs/libXinerama
	media-libs/libpng
	>=x11-libs/gtk+-2.0
	x11-libs/startup-notification
	gnome-base/gconf
	gnome? ( >=x11-libs/libwnck-2.16.1
		>=gnome-base/control-center-2.16.1 )
	svg? ( gnome-base/librsvg )
	dbus? ( >=sys-apps/dbus-1.0 )
	kde? (
		|| ( kde-base/kwin kde-base/kdebase )
		dev-libs/dbus-qt3-old )"

RDEPEND="${DEPEND}
	x11-apps/mesa-progs"

PDEPEND="~x11-plugins/compiz-extra-${PV}"

src_unpack() {
	unpack ${A}
	cd ${WORKDIR}
	tar xjf ${FILESDIR}/compiz-settings-${PRE_PV}.tar.bz2

	cd ${S}
	epatch ${FILESDIR}/${P}.patch
	epatch ${FILESDIR}/${PN}-sabayonlinux-logo.patch
}

src_compile() {
	econf --with-default-plugins \
		--enable-gtk \
		--enable-gconf \
		`use_enable gnome` \
		`use_enable gnome metacity` \
		`use_enable kde` \
		`use_enable svg librsvg` \
		`use_enable dbus` \
		`use_enable dbus dbus-glib` || die

	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dobin "${FILESDIR}/compiz-start" || die
	dodoc AUTHORS ChangeLog NEWS README TODO || die

	# Install Settings
	if [ -d "/etc/skel" ]; then
		dodir /etc/skel/.compiz
		insinto /etc/skel/.compiz
		doins -r ${WORKDIR}/compiz-settings/*
	fi

	# hackish thing...
	addwrite /home
	for user in /home/*; do
		if [ ! -e "$user/.compiz" ]; then
			username=$(echo $user | cut -d/ -f3)
			if [ -n "`cat /etc/passwd | grep ^$username`" ]; then
				cp ${WORKDIR}/compiz-settings/* $user/.compiz/ -R
				mkdir $user/.compiz
				chown $username $user/.compiz -R
			fi
		fi
	done

}
