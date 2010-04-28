# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs

DESCRIPTION="powerful open-source, cross platform IDE for the C/C++"
HOMEPAGE="http://www.codelite.org/"
SRC_URI="mirror://sourceforge/codelite/codelite-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND=""

#more deps to find
#svn not needed should be use flag
#ssh-askpass for SVN
DEPEND="${RDEPEND}
	>=x11-libs/wxGTK-2.8.0
	net-misc/x11-ssh-askpass
	dev-util/subversion
	"

src_compile() {
	cd "${S}"
	
	#system uses non-standard configure (ie autoconf)
	#make sure you have done eselect wxwidgets
	#as the configure uses wx-config for the path
	./configure --prefix=/usr || die "configure failed"
	#the build contains a version of ctags and SQlite inside
	#probably would be better to use the system version
	emake || die "make failed"
}

src_install() {
	#QA complains about a world write bit, but still works
	einstall DESTDIR="${D}" install || die "install failed"
}
