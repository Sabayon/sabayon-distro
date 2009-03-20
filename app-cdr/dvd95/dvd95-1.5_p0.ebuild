#
# Copyright 1999-2008 Gentoo Foundation
#
# Distributed under the terms of the GNU General Public License v2
#
# $Header: /var/cvsroot/gentoo-x86/app-cdr/dvd95/dvd95-1.5_p0.ebuild,v 1.1 2009/03/08 13:00:00 drac Exp $
#
#
inherit eutils

DESCRIPTION="DVD95 is a Gnome application to convert DVD9 to DVD5."

HOMEPAGE="http://dvd95.sourceforge.net/"

SRC_URI="mirror://sourceforge/dvd95/${P/_}.tar.gz"

LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~x86"

IUSE_LINGUAS="linguas_de linguas_nl linguas_hu linguas_el linguas_cs

linguas_pt_BR linguas_et_EE linguas_es"

IUSE="${IUSE_LINGUAS} mmx 3dnow sse sse2 mpeg"

RDEPEND="gnome-base/libgnomeui
	media-libs/libdvdread
	mpeg? ( media-libs/libmpeg2 )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext"

S=${WORKDIR}/${P/_}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "s#prefix = /usr/local#prefix = /usr#" \
		po/Makefile.in.in || die "sed failed."

	epatch "${FILESDIR}"/${P}-desktop-entry.patch
}

src_compile() {
	#
	# Default language is French, but switch to English if no LINGUAS is set.
	#
	if [[ -z ${LINGUAS} ]]; then
		export LINGUAS="en"
	fi

	econf --disable-dependency-tracking \
		$(use_enable mmx) \
		$(use_enable 3dnow) \
		$(use_enable sse) \
		$(use_enable sse2) \
		$(use_enable mpeg libmpeg2)

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog TODO

	for lang in de nl hu el cs pt_BR es et_EE; do
		use linguas_${lang} || rm -rf "${D}"/usr/share/locale/${lang}
	done
}
