 
# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit flag-o-matic eutils kde

DESCRIPTION="This is a modified pager applet for kicker to make it work with
compiz."
HOMEPAGE="http://www.kde-apps.org/content/show.php?content=46021"
LICENSE="GPL-2"

SRC_URI="http://sabayonlinux.org/distfiles/kde-misc/${PN}-${PV}.tar.gz "

SLOT="2"
KEYWORDS="~x86 ~amd64"

IUSE="arts composite hiddenvisibility shadow java"
DEPENT="
	>=kdebase/kde-3.5.3
	"
DEPEND="${RDEPEND}"

src_compile() {
	if 
		use hiddenvisibility; 
		then HIDDEN="--enable-gcc-hidden-visibility";
	fi	

	econf	`use_with arts`	`use_with java` `use_with composite` $HIDDEN || die "Configure failed"
}

src_install() {

	emake || die "Make failed"
	emake DESTDIR=${D} install || die "Make Install failed"
	dodoc README NEWS TODO

}