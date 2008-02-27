# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/kdm/kdm-3.5.9.ebuild,v 1.1 2008/02/20 22:57:42 philantrop Exp $

KMNAME=kdebase
EAPI="1"
inherit kde-meta eutils

SRC_URI="${SRC_URI}
	mirror://gentoo/kdebase-3.5-patchset-04.tar.bz2"

DESCRIPTION="KDE login manager, similar to xdm and gdm"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="elibc_glibc kdehiddenvisibility pam"

KMEXTRA="kdmlib/"
KMEXTRACTONLY="libkonq/konq_defaults.h"
KMCOMPILEONLY="kcontrol/background"

DEPEND="pam? ( kde-base/kdebase-pam )
	>=kde-base/kcontrol-${PV}:${SLOT}"
	# Requires the desktop background settings and kdm kcontrol modules
RDEPEND="${DEPEND}
	>=kde-base/kdepasswd-${PV}:${SLOT}
	x11-apps/xinit
	x11-apps/xmessage"
PDEPEND=">=kde-base/kdesktop-${PV}:${SLOT}"

PATCHES="${FILESDIR}/${PN}-3.5.7-bsd-shutdown.patch
	${FILESDIR}/${P}-respect-cflags.patch
	${FILESDIR}/${PN}-keyboard-repeat-fix.patch
	${FILESDIR}/${PN}-dbus-session-support.patch
	"

src_compile() {
	local myconf="--with-x-binaries-dir=/usr/bin $(use_with pam)"

	if ! use pam && use elibc_glibc; then
		myconf="${myconf} --with-shadow"
	fi

	export USER_LDFLAGS="${LDFLAGS}"

	kde-meta_src_compile myconf configure
	kde_remove_flag kdm/kfrontend -fomit-frame-pointer
	kde-meta_src_compile make
}

src_install() {
	kde-meta_src_install
	cd "${S}/kdm" && make DESTDIR="${D}" GENKDMCONF_FLAGS="--no-old --no-backup --no-in-notice" install

	# Customize the kdmrc configuration
	sed -i -e "s:#SessionsDirs=:SessionsDirs=/usr/share/xsessions\n#SessionsDirs=:" \
		"${D}/${KDEDIR}/share/config/kdm/kdmrc" || die

	# to avoid issues with the missing directory
	dodir /var/run/console

}

pkg_postinst() {
	kde_pkg_postinst

	# set the default kdm face icon if it's not already set by the system admin
	# because this is user-overrideable in that way, it's not in src_install
	if [ ! -e "${ROOT}${KDEDIR}/share/apps/kdm/faces/.default.face.icon" ];	then
		mkdir -p "${ROOT}${KDEDIR}/share/apps/kdm/faces"
		cp "${ROOT}${KDEDIR}/share/apps/kdm/pics/users/default1.png" \
			"${ROOT}${KDEDIR}/share/apps/kdm/faces/.default.face.icon"
	fi
	if [ ! -e "${ROOT}${KDEDIR}/share/apps/kdm/faces/root.face.icon" ]; then
		mkdir -p "${ROOT}${KDEDIR}/share/apps/kdm/faces"
		cp "${ROOT}${KDEDIR}/share/apps/kdm/pics/users/root1.png" \
			"${ROOT}${KDEDIR}/share/apps/kdm/faces/root.face.icon"
	fi
}
