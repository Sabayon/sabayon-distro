# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils eutils versionator

MY_P="Democracy-${PV}"
DESCRIPTION="Democracy is a free and open internet TV platform."
HOMEPAGE="http://www.getdemocracy.com/"
SRC_URI="ftp://ftp.osuosl.org/pub/pculture.org/democracy/src/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND="dev-python/pyrex
	>virtual/python-2.4
	media-libs/xine-lib
	dev-libs/boost
	>=dev-python/pygtk-2.0
	dev-python/gnome-python-extras
	www-client/mozilla-firefox
	x11-libs/libX11"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

DOCS="README"

S=${WORKDIR}/${MY_P}/platform/gtk-x11

pkg_setup() {
	if ! built_with_use python berkdb; then
		eerror "You must build python with berkdb support"
		die "Please re-emerge python with berkdb USE flag ON"
	fi

	if ! grep -q compiler.find /usr/lib/python2.4/distutils/unixccompiler.py; then
		eerror "You need to apply a patch to make distutils use the correct RPATH."
		eerror "To do this execute the following command:"
		eerror "wget -q 'http://sourceforge.net/tracker/download.php?group_id=5470&atid=305470&file_id=144928&aid=1254718' -O -|patch -p1 -d /usr/lib/python2.4"
		die "python version not patched"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/democracy-as-needed-libX11.patch
}

pkg_postinst(){
	if ! built_with_use xine-lib aac mad asf flac sdl win32codecs; then
		ewarn "The Democracy team recommends you to emerge xine-lib as follows:"
		ewarn ""
		ewarn "# echo \"media-libs/xine-lib aac ffmpeg mad asf flac sdl win32codecs\" \ "
		ewarn ">> /etc/portage/package.use && emerge xine-lib"
		ewarn ""
		ewarn "This way you will have support enabled for the most popular"
		ewarn "video and audio formats. You may also want to add support"
		ewarn "for theora and vorbis"
	fi
}
