# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/rhpl/rhpl-0.188.ebuild,v 1.1 2006/09/05 20:59:07 dberkholz Exp $

inherit eutils multilib python rpm toolchain-funcs

# Revision of the RPM. Shouldn't affect us, as we're just grabbing the source
# tarball out of it
RPMREV="2"

DESCRIPTION="Library of python code used by Red Hat Linux programs"
HOMEPAGE="http://fedora.redhat.com/projects/config-tools/"
SRC_URI="mirror://fedora/development/source/SRPMS/${P}-${RPMREV}.src.rpm"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc ~x86 ~amd64"
IUSE=""
RDEPEND="dev-lang/python
	dev-python/pyxf86config
	!<sys-libs/libkudzu-1.2"
DEPEND="${RDEPEND}
	!s390? ( >=net-wireless/wireless-tools-28 )
	sys-devel/gettext"

src_unpack() {
	rpm_src_unpack
	epatch "${FILESDIR}"/${PV}-use-raw-strings-for-gettext.diff

	sed -i \
		-e 's:gcc:$(CC):g' \
		"${S}"/src/Makefile
}

src_compile() {
	python_version
	emake \
		PYTHON=python${PYVER} \
		LIBDIR=$(get_libdir) \
		ARCH=${ARCH} \
		CC=$(tc-getCC) \
		|| die "emake failed"
}

src_install() {
	emake \
		DESTDIR="${D}" \
		PYTHON=python${PYVER} \
		LIBDIR=$(get_libdir) \
		install || die "emake install failed"
}
