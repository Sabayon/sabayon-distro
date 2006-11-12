# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/portaudio/portaudio-18.1-r3.ebuild,v 1.3 2005/07/22 21:27:35 kito Exp $

DESCRIPTION="An open-source cross platform audio API."
HOMEPAGE="http://www.portaudio.com"
#http://www.portaudio.com/archives/pa_snapshot_v${PV:0:2}.tar.gz
SRC_URI="http://gentooexperimental.org/~genstef/dist/pa_snapshot_v${PV:0:2}-${PV:6:8}.tar.gz"

LICENSE="MIT"
SLOT="19"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc-macos ~ppc64 ~sh ~sparc ~x86"
IUSE="alsa oss jack"

RDEPEND="virtual/libc
	alsa? ( media-libs/alsa-lib )
	jack? ( >=media-sound/jack-audio-connection-kit-0.100.0 )"

S=${WORKDIR}/${PN}

src_compile() {
	econf \
		$(use_with alsa) \
		$(use_with oss) \
		$(use_with jack) \
		$(use_with userland_Darwin macapi) \
		--without-winapi \
		|| die "econf failed"
	emake || die "emake failed"

	cd bindings/cpp
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README.txt V19-devel-readme.txt docs/*.txt bindings/cpp/ChangeLog
	dohtml docs/*.html

	cd bindings/cpp
	emake DESTDIR="${D}" install || die "emake install failed"
}
