## Ebuild by cvill64 of SabayonLinux ##

# Distributed under the terms of the GNU General Public License v2
# $Header: $
inherit eutils

DESCRIPTION="A GUI for ODE simulation and solving"
SRC_URI="http://sabayonlinuxdev.com/distfiles/sci-biology/xppaut-5.96.tar.gz"
HOMEPAGE="http://www.math.pitt.edu/~bard/xpp/xpp.html"
GENTOO_MIRRORS="http://sabayonlinuxdev.com/distfiles/"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
RDEPEND="${DEPEND}
             "
S=/var/tmp/portage/xppaut-5.96/work
D=/usr/bin/xppaut

src_unpack() {
    unpack ${A}
    }

src_compile() {
       einfo "Nothing to compile"
    }

src_install() {
	
	cd ${S}
        emake || die "make failed"
	emake DESTDIR="${D}" install || die "install failed"
        dodoc README xpp_doc.pdf LICENSE install.pdf
}
