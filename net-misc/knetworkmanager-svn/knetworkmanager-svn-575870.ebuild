# Ebuild by cvill64 and rubengonc from Sabayon Linux #

# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
inherit eutils subversion kde

DESCRIPTION="A NetworkManager front-end for KDE"
HOMEPAGE="http://en.opensuse.org/Projects/KNetworkManager"
LICENSE="GPL-2"
GENTOO_MIRRORS=""
SRC_URI="http://aur.archlinux.org/packages/knetworkmanager-svn/knetworkmanager-svn/01-build-fix.patch
	 http://aur.archlinux.org/packages/knetworkmanager-svn/knetworkmanager-svn/02-kwallet-sync-fix.patch
	 http://aur.archlinux.org/packages/knetworkmanager-svn/knetworkmanager-svn/03-desktop-fix.patch
	 http://aur.archlinux.org/packages/knetworkmanager-svn/knetworkmanager-svn/04-policy-fix.patch
	 http://aur.archlinux.org/packages/knetworkmanager-svn/knetworkmanager-svn/05-visual-fix.patch"
KEYWORDS="~amd64 ~x86"
DEPEND="net-misc/networkmanager
        >=kde-base/kdelibs-3.2
	!net-misc/knetworkmanager
	"

src_unpack() {
	ESVN_UPDATE_CMD="svn update -N" 
	ESVN_FETCH_CMD="svn checkout -N export"
	ESVN_REPO_URI="svn://anonsvn.kde.org/home/kde/trunk/kdereview"
	subversion_svn_fetch

	ESVN_UPDATE_CMD="svn update" 
	ESVN_FETCH_CMD="svn checkout -r 575870"
	S=${WORKDIR}/${P}/knetworkmanager
	ESVN_REPO_URI="svn://anonsvn.kde.org/home/kde/trunk/kdereview/knetworkmanager"
	subversion_svn_fetch

	S=${WORKDIR}/${P}/admin
	ESVN_REPO_URI="svn://anonsvn.kde.org/home/kde/branches/KDE/3.5/kde-common/admin"
	subversion_svn_fetch

	S=${WORKDIR}/${P}/knetworkmanager
	cd ${S}

	EPATCH_SOURCE="${DISTDIR}" EPATCH_SUFFIX="patch" \
        EPATCH_FORCE="yes" epatch

	S=${WORKDIR}/${P}
	cd ${S}

}

src_compile() {

        emake -f Makefile.cvs
	emake clean
	econf || die "econf failed"
	emake || die "emake failed"
}



src_install() {
	emake DESTDIR="${D}" install || die "install failed"
}	
