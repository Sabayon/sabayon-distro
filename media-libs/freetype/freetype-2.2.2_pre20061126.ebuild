# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freetype/freetype-2.2.1.ebuild,v 1.4 2006/10/01 13:43:20 flameeyes Exp $

inherit eutils flag-o-matic

DESCRIPTION="A high-quality and portable font engine"
HOMEPAGE="http://www.freetype.org/"
SRC_URI="http://manta.univ.gda.pl/~rbonieck/${P}.tar.gz"

LICENSE="FTL GPL-2"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="zlib bindist doc demos"

# The RDEPEND below makes sure that if there is a version of moz/ff/tb
# installed, then it will have the freetype-2.1.8+ binary compatibility patch.
# Otherwise updating freetype will cause moz/ff/tb crashes.	 #59849
# 20 Nov 2004 agriffis
DEPEND="zlib? ( sys-libs/zlib )"

RDEPEND="${DEPEND}
	!<www-client/mozilla-1.7.3-r3
	!<www-client/mozilla-firefox-1.0-r3
	!<mail-client/mozilla-thunderbird-0.9-r3
	!<media-libs/libwmf-0.2.8.2"

S="${WORKDIR}/freetype2"

src_unpack() {

	unpack ${A}

	# we should disable BCI and new method of subpixel rendering when distributing binaries
	# (patent issues)
	# newspr patches should be merged into bindist. but I left them in separate use flag
	# for experimentation purposes
	use bindist || 
	( 
		cd ${S} && 
			epatch "${FILESDIR}"/${PN}-2-enable_bci.patch 
	)

	cd ${S}/src/autofit &&
		epatch "${FILESDIR}"/${PN}-2-quantization_fix.patch
	cd ${S}/include/freetype/config &&
		epatch "${FILESDIR}"/${PN}-2-enable_new_subpixel_rendering.patch

	epunt_cxx
	
}

src_compile() {

	# https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=118021
	append-flags "-fno-strict-aliasing"
	type -p gmake &> /dev/null && export GNUMAKE=gmake
	sh autogen.sh
	
	econf $(use_with zlib) || die
	
	emake || die
	
	use demos &&
	(
		cd ${WORKDIR}/ft2demos
		emake || die
	)
	
}

src_install() {

	make DESTDIR="${D}" install || die

	dodoc ChangeLog README
	dodoc docs/{CHANGES,CUSTOMIZE,DEBUG,*.txt,PATENTS,TODO}

	cd "${S}"
	use doc && dohtml -r docs/*

	use demos &&
	(
		cd ${WORKDIR}/ft2demos/bin/.libs &&
		    for i in "*"
		    do
			dobin $i
		    done
	)

}
pkg_postinst() {

ewarn "Freetype 2.2 will break packages depending on its internals."
ewarn "Read more here: http://www.freetype.org/freetype2/patches/rogue-patches.html " 
einfo "See http://forums.gentoo.org/viewtopic-t-511382.html for support topic on Gentoo forums."

}
