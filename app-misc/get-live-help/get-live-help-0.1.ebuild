# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion

DESCRIPTION="SabayonLinux Get Live Help package"
HOMEPAGE="http://www.sabayonlinux.org"
ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/${PN}/tags/${PV}"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 x86"
IUSE="kde"

DEPEND="
	net-irc/irssi
	kde? ( net-irc/konversation )
	"

src_unpack() {
        subversion_src_unpack
}

src_install() {

	cd ${S}

	# Install handler
	exeinto /usr/bin
	doexe handler/get-live-help

	# Install desktop file
	if use kde; then
		dodir /usr/share/get-live-help
		insinto /usr/share/get-live-help
		doins desktop/Get\ Live\ Help.desktop
		for dir in /home/*/Desktop; do
			insinto $dir
			doins desktop/Get\ Live\ Help.desktop
		done
	fi

}
