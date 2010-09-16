# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit eutils

DESCRIPTION="Gnarwl is a serverside email autoresponder, which is backed by an LDAP database."
SRC_URI="http://www.onyxbits.de/sites/default/files/${P}.tgz"
HOMEPAGE="http://www.onyxbits.de/gnarwl"
LICENSE="GPL-2"
SLOT="0"
#IUSE="targrey"
DEPEND=""
RDEPEND=">=sys-devel/gcc-2.95.3
	>=sys-libs/gdbm-1.8.0
	>=net-nds/openldap-2.0.23
	mail-mta/postfix
	sys-devel/make
	sys-apps/groff
	app-arch/gzip"

KEYWORDS="~amd64 ~x86"

pkg_setup() {
	GNARWL_HOME=${GNARWL_HOME:-/var/lib/gnarwl}
	GNARWL_USER=${GNARWL_USER:-gnarwl}
	GNARWL_GROUP=${GNARWL_GROUP:-gnarwl}
	enewgroup ${GNARWL_GROUP} || die "enewgroup failed"
	enewuser ${GNARWL_USER} -1 -1 ${GNARWL_HOME} ${GNARWL_USER} -c "gnarwl autoreply agent" || die "enewuser failed"
}

src_compile() {
	econf --with-homedir=${GNARWL_HOME} || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	dobin src/gnarwl
	dosbin src/damnit

	insinto ${GNARWL_HOME}
	doins data/{header,footer}.txt
	dodir ${GNARWL_HOME}/{block,bin}
	echo "|/usr/bin/gnarwl" > .forward
	doins .forward
	./src/damnit -a badheaders.db < data/badheaders.txt
	./src/damnit -a blacklist.db < data/blacklist.txt
	doins badheaders.db
	doins blacklist.db

	insinto /etc
	doins data/gnarwl.cfg

	doman doc/{damnit,gnarwl}.8
	dodoc doc/{FAQ,HISTORY,README,README.upgrade,*.ldif,*.schema}

	fowners -R ${GNARWL_USER}:${GNARWL_GROUP} ${GNARWL_HOME}
	fowners ${GNARWL_USER}:${GNARWL_GROUP} /etc/gnarwl.cfg
}
