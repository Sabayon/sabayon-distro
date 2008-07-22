# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $ 

inherit eutils

HOMEPAGE="http://micans.org/apparix/"
DESCRIPTION="Fast file system navigation by bookmarking directories and jumping
to a bookmark directly"

MY_PV="${PV//./-}"
SRC_URI="http://micans.org/${PN}/src/${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc ~x86"
IUSE=""
DEPEND=""

S="${WORKDIR}/${PN}-${MY_PV}"


src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS COPYING INSTALL LICENSE README THANKS TODO ChangeLog

	dodoc doc/apparix.{ps,azm}
	dohtml doc/apparix.html
	
	insinto /usr/share/apparix
	doins ${FILESDIR}/*.{csh,sh} \
		|| die "failed to install contrib scripts"
}

pkg_postinst() {
	echo
	einfo "Add the following line to your ~/.bashrc to enable apparix helper"
	einfo "functions/aliases in your environment:"
	einfo "[ -f /usr/share/apparix/bash.sh ] && \\ "
	einfo "		source /usr/share/apparix/bash.sh"
	einfo
	einfo "Users of cshell will find csh.csh there with a reduced"
	einfo "feature set."
	einfo
	einfo "You may also find GOTO extremely useful which you can download from"
	einfo "http://sitaramc.googlepages.com/goto-considered-useful.html"
	echo
}
