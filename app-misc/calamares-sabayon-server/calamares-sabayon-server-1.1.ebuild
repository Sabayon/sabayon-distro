# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="Sabayon Official Installer"
HOMEPAGE="http://www.sabayon.org/"
LICENSE="CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-misc/calamares-sabayon-server-base-modules
	app-misc/calamares-sabayon-server-branding"
RDEPEND="${DEPEND}
	sys-fs/dosfstools
	sys-fs/jfsutils
	sys-fs/reiserfsprogs
	sys-fs/xfsprogs
	sys-fs/xfsdump
	sys-fs/ntfs3g[ntfsprogs]
	sys-fs/btrfs-progs
	!!app-admin/anaconda
	!!app-misc/calamares-sabayon"

S=${FILESDIR}

src_install() {
	newbin "${S}/Installer.sh" "installer"
}
