# Copyright 2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils autotools

DESCRIPTION="Unionfs 1.x/2.x userspace tools"
HOMEPAGE="http://www.am-utils.org/project-unionfs.html"
SRC_URI="ftp://ftp.fsl.cs.sunysb.edu/pub/unionfs/${PN}-0.x/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE=""
RESTRICT="nomirror"

S=${WORKDIR}/${PN}

src_compile() {
	cd ${S}

	./bootstrap || die "bootstrap failed"

	econf --mandir="${D}/usr/share/man" \
	      --prefix="${D}" || die "Autoreconf failed"

        emake || die "make failed"

}

src_install() {
	# docs
	dodoc INSTALL NEWS README ChangeLog

	# man
	doman man/unionctl.8 man/uniondbg.8 man/unionimap.8

	# exes
	exeinto /sbin
	doexe unionctl uniondbg unionimap
}
