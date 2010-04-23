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
	epatch "${FILESDIR}"/${P}-disable-rpm.patch
	epatch "${FILESDIR}"/${P}-fix-version-detection.patch

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

src_install() {
	base_src_install

	# remove Red Hat stuff
	rm "${D}"/etc/report.d/RHEL.ini
	rm "${D}"/etc/report.d/dropbox.redhat.com.ini
	rm "${D}"/etc/report.d/bugzilla.redhat.com.ini

	# XXX: {not yet implemented} install Sabayon configuration
	# cp "${FILESDIR}"/bugs.sabayon.org.ini "${D}/etc/report.d/"
	find "${D}"/ -name "bugzilla-template" -type d | xargs rm -rf
	find "${D}"/ -name "RHEL-template" -type d | xargs rm -rf
	find "${D}"/ -name "strata-template" -type d | xargs rm -rf

}
