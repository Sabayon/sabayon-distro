# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/ntfsprogs/ntfsprogs-2.0.0-r2.ebuild,v 1.1 2010/07/24 06:29:22 vapier Exp $
EAPI="3"

inherit eutils

DESCRIPTION="User tools for NTFS filesystems"
HOMEPAGE="http://www.linux-ntfs.org/"
SRC_URI="mirror://sourceforge/linux-ntfs/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~mips ~ppc ~ppc64 ~sparc ~x86"
IUSE="crypt debug fuse gnome minimal"

RDEPEND="dev-libs/libconfig
	fuse? ( >=sys-fs/fuse-2.7.0 )
	crypt? ( >=dev-libs/libgcrypt-1.2.0 >=net-libs/gnutls-1.2.8 )
	gnome? (
		>=dev-libs/glib-2.0
		>=gnome-base/gnome-vfs-2.0
	)"
DEPEND="${RDEPEND}
	!=sys-fs/ntfs3g-0.1_beta20070714
	dev-util/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/ntfsclone_progress_bar.diff
	epatch "${FILESDIR}"/${P}-extras.patch #218601
	epatch "${FILESDIR}"/${P}-gnutls-2.8.patch
	epatch "${FILESDIR}"/${P}-erange.patch #329445
	use minimal || sed -i 's:^EXTRA_PROGRAMS =:bin_PROGRAMS +=:' ntfsprogs/Makefile.in #218601
	sed -i \
		-e '/CFLAGS/s:-ggdb3\>::' \
		-e '/CFLAGS/s:-O0\>::' \
		configure || die
}

src_configure() {
	econf \
		$(use_enable crypt crypto) \
		$(use_enable debug) \
		$(use_enable fuse ntfsmount) \
		$(use_enable gnome gnome-vfs) \
		|| die "Configure failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	mv "${D}"/sbin/mkfs.ntfs "${D}"/usr/sbin/ || die
	if ! use minimal ; then
		mv "${D}"/usr/bin/ntfsck "${D}"/sbin/ || die
		dosym ntfsck /sbin/fsck.ntfs
	fi
	if use fuse ; then
		mv "${D}"/sbin/mount.{fuse.ntfs,ntfs-fuse} "${D}"/usr/bin/ || die
	fi

	dodoc AUTHORS CREDITS ChangeLog NEWS README TODO.* \
		doc/attribute_definitions doc/*.txt doc/tunable_settings
}
