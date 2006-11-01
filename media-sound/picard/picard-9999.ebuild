# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils distutils subversion

DESCRIPTION="The PicardTagger is the next generation MusicBrainzTagger."
HOMEPAGE="http://wiki.musicbrainz.org/PicardTagger"
ESVN_REPO_URI="http://svn.musicbrainz.org/picard/trunk/"

LICENSE="|| ( GPL-2 RPSL RCSL-1.0 )"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND=">=dev-lang/python-2.4
	>=dev-python/wxpython-2.6.1
	=media-libs/tunepimp-9999
	=dev-python/python-musicbrainz2-9999
	>=dev-python/ctypes-0.9"

DEPEND="${RDEPEND}"
DOCS="AUTHORS README TODO ChangeLog"
S="${WORKDIR}/trunk"

pkg_setup() {
	if ! built_with_use dev-python/wxpython unicode; then
		eerror "Dependency dev-python/wxpython must be intalled with USE=\"unicode\""
		die "Broken depencency"
	fi
	if ! built_with_use media-libs/tunepimp python; then
		eerror "Dependency media-libs/tunepimp must be installed with USE=\"python\""
		die "Broken dependency"
	fi
}

src_compile() {
	# This needs to remain empty to override distutils_src_compile since
	# upstream's 'setup.py build' is broken.
	#echo
	${python} setup.py build_locales || die "setup.py build_locales failed"
}

src_install() {
	distutils_src_install
	# Symlinks for the deprecated executables the old ebuild used to
	# have
	dosym picard /usr/bin/tagger.py
	dosym picard /usr/bin/picard-tagger.py
}

pkg_postinst() {
	einfo "You should set the environment variable BROWSER to something like"
	einfo "\"firefox '%s' &\" to let python know which browser to use."
	einfo
	ewarn "The /usr/bin/tagger.py and /usr/bin/picard-tagger.py executables"
	ewarn "are now deprecated and have been removed in favor of upstream\'s"
	ewarn "/usr/bin/picard."
}

