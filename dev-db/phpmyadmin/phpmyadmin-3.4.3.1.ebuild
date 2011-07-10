# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/phpmyadmin/phpmyadmin-3.4.3.1.ebuild,v 1.5 2011/07/09 16:52:28 armin76 Exp $

EAPI="2"

inherit eutils webapp depend.php

MY_PV=${PV/_/-}
MY_P="phpMyAdmin-${MY_PV}-all-languages"

DESCRIPTION="Web-based administration for MySQL database in PHP"
HOMEPAGE="http://www.phpmyadmin.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="alpha amd64 ~hppa ~ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="+setup"

RDEPEND="
	dev-lang/php[crypt,ctype,filter,json,session,unicode]
	|| (
		<dev-lang/php-5.3[spl,pcre]
		>=dev-lang/php-5.3
	)
	|| (
		dev-lang/php[mysqli]
		dev-lang/php[mysql]
	)
"

need_httpd_cgi
need_php_httpd

S="${WORKDIR}"/${MY_P}

pkg_setup() {
	webapp_pkg_setup
}

src_install() {
	webapp_src_preinst

	dodoc CREDITS Documentation.txt INSTALL README RELEASE-DATE-${MY_PV} TODO ChangeLog || die
	rm -f LICENSE CREDITS INSTALL README* RELEASE-DATE-${MY_PV} TODO

	if ! use setup; then
		rm -rf setup || die "Cannot remove setup utility"
		elog "The phpmyadmin setup utility has been removed."
	else
		elog "You should consider disabling the setup USE flag"
		elog "to exclude the setup utility if you don't use it."
		elog "It regularly is the target of various exploits."
	fi

	insinto "${MY_HTDOCSDIR}"
	doins -r .

	webapp_configfile "${MY_HTDOCSDIR}"/libraries/config.default.php
	webapp_serverowned "${MY_HTDOCSDIR}"/libraries/config.default.php

	webapp_postinst_txt en "${FILESDIR}"/postinstall-en-3.1.txt
	webapp_src_install
}
