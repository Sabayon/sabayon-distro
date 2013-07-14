# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

# split ebuild providing only ->>> gitk, gitview, git-gui, git-citool

GENTOO_DEPEND_ON_PERL=no

# bug #329479: git-remote-testgit is not multiple-version aware
PYTHON_COMPAT=( python2_{5,6,7} )

inherit toolchain-funcs eutils python-single-r1
[ "$PV" == "9999" ] && inherit git

MY_PV="${PV/_rc/.rc}"
MY_PV="${MY_PV/-gui-tools}"
MY_P="${PN}-${MY_PV}"
MY_P="${MY_P/-gui-tools}"

DESCRIPTION="GUI tools derived from git: gitk, git-gui and gitview"
HOMEPAGE="http://www.git-scm.com/"
if [ "$PV" != "9999" ]; then
	SRC_URI_SUFFIX="gz"
	SRC_URI_GOOG="http://git-core.googlecode.com/files"
	SRC_URI_KORG="mirror://kernel/software/scm/git"
	SRC_URI="${SRC_URI_GOOG}/${MY_P}.tar.${SRC_URI_SUFFIX}
			${SRC_URI_KORG}/${MY_P}.tar.${SRC_URI_SUFFIX}"
	KEYWORDS="~amd64 ~x86"
else
	SRC_URI=""
	EGIT_BRANCH="master"
	EGIT_REPO_URI="git://git.kernel.org/pub/scm/git/git.git"
	# EGIT_REPO_URI="http://www.kernel.org/pub/scm/git/git.git"
	KEYWORDS=""
fi

SRC_URI+=" mirror://sabayon/dev-vcs/git/git-1.8.2-Gentoo-patches.tgz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

# Common to both DEPEND and RDEPEND
CDEPEND="
	sys-libs/zlib
	dev-lang/tk"

RDEPEND="${CDEPEND}
	~dev-vcs/git-${PV}
	dev-vcs/git[-gtk]
	dev-vcs/git[-tk]
	dev-vcs/git[python]
	>=dev-python/pygtk-2.8
	dev-python/pygtksourceview:2
	${PYTHON_DEPS}"

DEPEND="${CDEPEND}
	app-arch/cpio
	"

SITEFILE=50${PN}-gentoo.el
S="${WORKDIR}/${MY_P}"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
"

pkg_setup() {
	#if use python ; then
	python-single-r1_pkg_setup
	#fi
}

# This is needed because for some obscure reasons future calls to make don't
# pick up these exports if we export them in src_unpack()
exportmakeopts() {
	local myopts

	myopts="${myopts} NO_EXPAT=YesPlease"
	myopts="${myopts} NO_CURL=YesPlease"
	# broken assumptions, because of broken build system ...
	myopts="${myopts} NO_FINK=YesPlease NO_DARWIN_PORTS=YesPlease"
	myopts="${myopts} INSTALL=install TAR=tar"
	myopts="${myopts} SHELL_PATH=${EPREFIX}/bin/sh"
	myopts="${myopts} SANE_TOOL_PATH="
	myopts="${myopts} OLD_ICONV="
	myopts="${myopts} NO_EXTERNAL_GREP="

	# split ebuild: avoid collisions with dev-vcs/git's .mo files
	myopts="${myopts} NO_GETTEXT=YesPlease"

	# can't define this to null, since the entire makefile depends on it
	sed -i -e '/\/usr\/local/s/BASIC_/#BASIC_/' Makefile

	#use nls \
	#	|| myopts="${myopts} NO_GETTEXT=YesPlease"
	# use tk \
	#	|| myopts="${myopts} NO_TCLTK=YesPlease"
	#use perl \
	#	&& myopts="${myopts} INSTALLDIRS=vendor" \
	#	|| myopts="${myopts} NO_PERL=YesPlease"
	myopts="${myopts} NO_PERL=YesPlease"
	#use python \
	#	|| myopts="${myopts} NO_PYTHON=YesPlease"

	# Bug 290465:
	# builtin-fetch-pack.c:816: error: 'struct stat' has no member named 'st_mtim'
	[[ "${CHOST}" == *-uclibc* ]] && \
		myopts="${myopts} NO_NSEC=YesPlease"

	export MY_MAKEOPTS="${myopts}"
}

src_unpack() {
	if [ "${PV}" != "9999" ]; then
		unpack ${MY_P}.tar.${SRC_URI_SUFFIX}
		cd "${S}"
	else
		git_src_unpack
		cd "${S}"
		#cp "${FILESDIR}"/GIT-VERSION-GEN .
	fi

	cd "${WORKDIR}" && unpack git-1.8.2-Gentoo-patches.tgz
}

src_prepare() {
	# bug #350330 - automagic CVS when we don't want it is bad.
	epatch "${WORKDIR}"/1.8.2-patches/git-1.8.2-optional-cvs.patch

	sed -i \
		-e 's:^\(CFLAGS =\).*$:\1 $(OPTCFLAGS) -Wall:' \
		-e 's:^\(LDFLAGS =\).*$:\1 $(OPTLDFLAGS):' \
		-e 's:^\(CC = \).*$:\1$(OPTCC):' \
		-e 's:^\(AR = \).*$:\1$(OPTAR):' \
		-e "s:\(PYTHON_PATH = \)\(.*\)$:\1${EPREFIX}\2:" \
		-e "s:\(PERL_PATH = \)\(.*\)$:\1${EPREFIX}\2:" \
		Makefile contrib/svn-fe/Makefile || die "sed failed"

	# Never install the private copy of Error.pm (bug #296310)
	sed -i \
		-e '/private-Error.pm/s,^,#,' \
		perl/Makefile.PL
}

git_emake() {
	PYTHON_PATH="$(python_get_PYTHON)"
	emake ${MY_MAKEOPTS} \
		DESTDIR="${D}" \
		OPTCFLAGS="${CFLAGS}" \
		OPTLDFLAGS="${LDFLAGS}" \
		OPTCC="$(tc-getCC)" \
		OPTAR="$(tc-getAR)" \
		prefix="${EPREFIX}"/usr \
		htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		sysconfdir="${EPREFIX}"/etc \
		PYTHON_PATH="${PYTHON_PATH}" \
		PERL_PATH="${EPREFIX}/usr/bin/env perl" \
		PERL_MM_OPT="" \
		GIT_TEST_OPTS="--no-color" \
		V=1 \
		"$@"
}

src_configure() {
	exportmakeopts
}

src_compile() {
	git_emake || die "emake failed"
}

src_install() {
	git_emake \
		install || \
		die "make install failed"

	#if use python && use gtk ; then
	python_doscript "${S}"/contrib/gitview/gitview
	dodoc "${S}"/contrib/gitview/gitview.txt
	#fi

	#find "${ED}"/usr/lib64/perl5/ \
	#	-name .packlist \
	#	-exec rm \{\} \;

	rm -rf "${ED}"usr/share/gitweb
	rm -rf "${ED}"usr/share/git/contrib
	rm -rf "${ED}"usr/share/git-core
	rm -rf "${ED}"usr/share/man/
	rm -rf "${ED}"usr/lib{,64}/perl5/
	rm -rf "${ED}"usr/lib{,64}/python*
	rm -rf "${ED}"usr/libexec/git-core/mergetools

	local myfile
	for myfile in "${ED}"usr/bin/*; do
		case "$myfile" in
			*/gitview*|*/gitk*)
				true ;;
			*)
				rm -f "$myfile" ;;
		esac
	done

	for myfile in "${ED}"usr/libexec/git-core/*; do
		case "$myfile" in
		*/git-gui|*/git-gui--askpass|*/git-citool)
			true ;;
		*)
			rm -f "$myfile" ;;
		esac
	done
}