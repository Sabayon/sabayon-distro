# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

VERSION_BUSYBOX="1.20.2"
BB_HOME="http://www.busybox.net/downloads"
COMMON_URI="${BB_HOME}/busybox-${VERSION_BUSYBOX}.tar.bz2"

EGIT_REPO_URI="git://github.com/Sabayon/genkernel-next.git"
EGIT_COMMIT="v${PV}"
inherit git-2 bash-completion-r1 eutils

S="${WORKDIR}/${PN}"
SRC_URI="${COMMON_URI}"
KEYWORDS="~amd64 ~arm ~x86"

DESCRIPTION="Gentoo automatic kernel building scripts ('next' branch)"
HOMEPAGE="http://www.gentoo.org"

LICENSE="GPL-2"
SLOT="0"
RESTRICT=""
IUSE="crypt cryptsetup dmraid gpg ibm iscsi plymouth selinux"  # Keep 'crypt' in to keep 'use crypt' below working!

DEPEND="app-text/asciidoc
	sys-fs/e2fsprogs
	selinux? ( sys-libs/libselinux )"
RDEPEND="${DEPEND}
		cryptsetup? ( sys-fs/cryptsetup )
		dmraid? ( sys-fs/dmraid )
		gpg? ( app-crypt/gnupg )
		iscsi? ( sys-block/open-iscsi )
		plymouth? ( sys-boot/plymouth )
		app-portage/portage-utils
		app-arch/cpio
		>=app-misc/pax-utils-0.2.1
		!<sys-apps/openrc-0.9.9
		sys-fs/dmraid
		sys-fs/lvm2"

src_prepare() {
	use selinux && sed -i 's/###//g' "${S}"/gen_compile.sh

	# Update software.sh
	sed -i \
		-e "s:VERSION_BUSYBOX:$VERSION_BUSYBOX:" \
		"${S}"/defaults/software.sh \
		|| die "Could not adjust versions"

	sed -i "/^GK_V=/ s:GK_V=.*:GK_V=${PV}:g" "${S}/genkernel" || \
		die "Could not setup release"
}

src_install() {
	insinto /etc
	doins "${S}"/genkernel.conf || die "doins genkernel.conf"

	doman genkernel.8 || die "doman"
	dodoc AUTHORS README TODO || die "dodoc"

	dobin genkernel || die "dobin genkernel"

	rm -f genkernel genkernel.8 AUTHORS ChangeLog README TODO genkernel.conf

	insinto /usr/share/genkernel
	doins -r "${S}"/* || die "doins"
	use ibm && cp "${S}"/ppc64/kernel-2.6-pSeries "${S}"/ppc64/kernel-2.6 || \
		cp "${S}"/arch/ppc64/kernel-2.6.g5 "${S}"/arch/ppc64/kernel-2.6

	# Copy files to /var/cache/genkernel/src
	elog "Copying files to /var/cache/genkernel/src..."
	mkdir -p "${D}"/var/cache/genkernel/src
	cp -f \
		"${DISTDIR}"/busybox-${VERSION_BUSYBOX}.tar.bz2 \
		"${D}"/var/cache/genkernel/src || die "Copying distfiles..."

	newbashcomp "${FILESDIR}"/genkernel.bash "${PN}"
	insinto /etc
	doins "${FILESDIR}"/initramfs.mounts
}

pkg_postinst() {
	elog 'You are using an EXPERIMENTAL version of genkernel called genkernel-next'
	elog 'Actually, it is supposed to be more polished and reliable'
	echo
	ewarn "The LUKS support has changed from versions prior to 3.4.4.  Now,"
	ewarn "you use crypt_root=/dev/blah instead of real_root=luks:/dev/blah."
	echo
	if use crypt && ! use cryptsetup ; then
		ewarn "Local use flag 'crypt' has been renamed to 'cryptsetup' (bug #414523)."
		ewarn "Please set flag 'cryptsetup' for this very package if you would like"
		ewarn "to have genkernel create an initramfs with LUKS support."
		echo
	fi
}
