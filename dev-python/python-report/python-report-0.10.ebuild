# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

EGIT_REPO_URI="git://git.fedorahosted.org/report.git"
EGIT_COMMIT="${PV}"
inherit base git autotools eutils

DESCRIPTION="Provides a single configurable problem/bug/issue reporting API."
HOMEPAGE="http://git.fedoraproject.org/git/?p=report.git;a=summary"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-arch/rpm
	net-misc/curl"
RDEPEND="dev-libs/openssl
	net-misc/curl
	dev-libs/libxml2"

src_prepare() {

	epatch "${FILESDIR}"/${P}-sabayon-defaults.patch

	eautoreconf || die "cannot run eautoreconf"
	autoreconf -i || die "wtf"
	eautomake || die "cannot run eautomake"
}

src_configure() {
	econf --prefix=/usr || die "configure failed"
}

src_compile() {
	# workaround crappy build system
	mkdir -p "${S}/python/report/templates/RHEL-template/bugzillaCopy"
	touch "${S}/python/report/templates/RHEL-template/bugzillaCopy/VERSION"

	emake || die "make failed"
}
