# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

PYTHON_DPEEND="2:2.4"

inherit eutils python games

MY_PN="Frets on Fire"
MY_PN_URI="FretsOnFire"
DESCRIPTION="A game of musical skill and fast fingers"
HOMEPAGE="http://fretsonfire.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_PN_URI}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc guitarhero psyco"

# NOTES :
# pyopengl-2.0.0.44 (stable) makes the game crash with some configs
DEPEND=""
RDEPEND="dev-python/pygame
	>=dev-python/pyopengl-2.0.1.09-r1
	dev-python/imaging
	dev-python/numpy
	media-libs/sdl-mixer[vorbis]
	doc? ( >=dev-python/epydoc-3.0.1 )
	psyco? ( dev-python/psyco )
	guitarhero? ( media-sound/vorbis-tools )"

S=${WORKDIR}/${MY_PN}-${PV}

DOCS="readme.txt todo.txt PKG-INFO MANIFEST"

src_prepare() {
	# change main game executable path
	sed -i -e "s:\(FretsOnFire.py\):$(games_get_libdir)/${PN}/\1:" \
		src/FretsOnFire.py || die "patching src/FretsOnFire.py failed"

	# change data path
	sed -i -e \
		"s:os.path.join(\"..\", \"\(data\)\"):\"${GAMES_DATADIR}/${PN}/\1\":" \
		src/Version.py || die "patching src/Version.py failed"
}

src_compile() {
	# NOTE : there is a Makefile but it has not te be run

	if use doc; then
		epydoc --html -o "doc/html" -n "Frets on Fire" src/*.py src/midi/*.py \
			|| die "documentation generation failed"
	fi
}

src_install() {
	insinto "$(games_get_libdir)/${PN}"
	# we have to ignore .pyc files
	doins src/*.py src/*.pot || die "installation failed"

	insinto "$(games_get_libdir)/${PN}/midi"
	# we have to ignore .pyc files
	doins src/midi/*.py || die "installation failed"

	insinto "${GAMES_DATADIR}/${PN}"
	# removes useless files
	rm -fr data/win32
	# removes useless file that is throwing a QA notice
	rm -f data/PyOpenGL__init__.pyc
	doins -r data || die "data installation failed"

	games_make_wrapper \
		${PN} "python FretsOnFire.py" "$(games_get_libdir)/${PN}" \
		|| die "games wrapper installation failed"

	if use doc; then
		dohtml -r doc/html/* || die "documentation installation failed"
	fi

	dodoc ${DOCS} || die "documentation installation failed"

	newicon data/icon.png ${PN}.png
	make_desktop_entry ${PN} "Frets on Fire"

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst
	python_mod_optimize "$(games_get_libdir)/${PN}"
}

pkg_postrm() {
	python_mod_cleanup "$(games_get_libdir)/${PN}"
}
