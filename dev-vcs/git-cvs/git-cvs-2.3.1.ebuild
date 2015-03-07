# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

GENTOO_DEPEND_ON_PERL=no

PYTHON_COMPAT=( python2_{6,7} )
[[ ${PV} == *9999 ]] && SCM="git-2"
EGIT_REPO_URI="git://git.kernel.org/pub/scm/git/git.git"
EGIT_MASTER=pu

SAB_PATCHES_SRC=( "mirror://sabayon/dev-vcs/git/git-2.2.2-Gentoo-patches.tar.gz" )
inherit sab-patches toolchain-funcs eutils multilib python-single-r1 ${SCM}

MY_PV="${PV/_rc/.rc}"
MY_PN="${PN/-cvs}"
MY_P="${MY_PN}-${MY_PV}"

DOC_VER=${MY_PV}

DESCRIPTION="CVS module for GIT, the stupid content tracker"
HOMEPAGE="http://www.git-scm.com/"
if [[ ${PV} != *9999 ]]; then
	SRC_URI_SUFFIX="xz"
	SRC_URI_GOOG="http://git-core.googlecode.com/files"
	SRC_URI_KORG="mirror://kernel/software/scm/git"
	SRC_URI+=" ${SRC_URI_GOOG}/${MY_P}.tar.${SRC_URI_SUFFIX}
			${SRC_URI_KORG}/${MY_P}.tar.${SRC_URI_SUFFIX}
			${SRC_URI_GOOG}/${MY_PN}-manpages-${DOC_VER}.tar.${SRC_URI_SUFFIX}
			${SRC_URI_KORG}/${MY_PN}-manpages-${DOC_VER}.tar.${SRC_URI_SUFFIX}
			doc? (
			${SRC_URI_KORG}/${MY_PN}-htmldocs-${DOC_VER}.tar.${SRC_URI_SUFFIX}
			${SRC_URI_GOOG}/${MY_PN}-htmldocs-${DOC_VER}.tar.${SRC_URI_SUFFIX}
			)"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="doc"

RDEPEND="~dev-vcs/git-${PV}[-cvs,perl]
	dev-perl/Error
	dev-perl/Net-SMTP-SSL
	dev-perl/Authen-SASL
	>=dev-vcs/cvsps-2.1:0 dev-perl/DBI dev-perl/DBD-SQLite
	${PYTHON_DEPS}"
DEPEND="app-arch/cpio
	dev-lang/perl:=[-build(-)]
	doc? (
		app-text/asciidoc
		app-text/docbook2X
		sys-apps/texinfo
		app-text/xmlto
	)"

# Live ebuild builds man pages and HTML docs, additionally
if [[ ${PV} == *9999 ]]; then
	DEPEND="${DEPEND}
		app-text/asciidoc"
fi

S="${WORKDIR}/${MY_P}"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
"

# This is needed because for some obscure reasons future calls to make don't
# pick up these exports if we export them in src_unpack()
exportmakeopts() {
	local myopts

	# broken assumptions, because of broken build system ...
	myopts+=" NO_FINK=YesPlease NO_DARWIN_PORTS=YesPlease"
	myopts+=" INSTALL=install TAR=tar"
	myopts+=" SHELL_PATH=${EPREFIX}/bin/sh"
	myopts+=" SANE_TOOL_PATH="
	myopts+=" OLD_ICONV="
	myopts+=" NO_EXTERNAL_GREP="

	# split ebuild: avoid collisions with dev-vcs/git's .mo files
	myopts+=" NO_GETTEXT=YesPlease"

	# can't define this to null, since the entire makefile depends on it
	sed -i -e '/\/usr\/local/s/BASIC_/#BASIC_/' Makefile

	myopts+=" INSTALLDIRS=vendor"
	myopts+=" NO_SVN_TESTS=YesPlease"

	has_version '>=app-text/asciidoc-8.0' \
		&& myopts+=" ASCIIDOC8=YesPlease"
	myopts+=" ASCIIDOC_NO_ROFF=YesPlease"

	# Bug 290465:
	# builtin-fetch-pack.c:816: error: 'struct stat' has no member named 'st_mtim'
	[[ "${CHOST}" == *-uclibc* ]] && \
		myopts+=" NO_NSEC=YesPlease"

	export MY_MAKEOPTS="${myopts}"
}

src_unpack() {
	if [[ ${PV} != *9999 ]]; then
		unpack ${MY_P}.tar.${SRC_URI_SUFFIX}
		cd "${S}"
		unpack ${MY_PN}-manpages-${DOC_VER}.tar.${SRC_URI_SUFFIX}
		use doc && \
			cd "${S}"/Documentation && \
			unpack ${MY_PN}-htmldocs-${DOC_VER}.tar.${SRC_URI_SUFFIX}
		cd "${S}"
	else
		git-2_src_unpack
	fi

	sab-patches_unpack
}

src_prepare() {
	# see the git ebuild for the list of patches
	sab-patches_apply_all

	epatch_user

	sed -i \
		-e 's:^\(CFLAGS[[:space:]]*=\).*$:\1 $(OPTCFLAGS) -Wall:' \
		-e 's:^\(LDFLAGS[[:space:]]*=\).*$:\1 $(OPTLDFLAGS):' \
		-e 's:^\(CC[[:space:]]* =\).*$:\1$(OPTCC):' \
		-e 's:^\(AR[[:space:]]* =\).*$:\1$(OPTAR):' \
		-e "s:\(PYTHON_PATH[[:space:]]\+=[[:space:]]\+\)\(.*\)$:\1${EPREFIX}\2:" \
		-e "s:\(PERL_PATH[[:space:]]\+=[[:space:]]\+\)\(.*\)$:\1${EPREFIX}\2:" \
		Makefile contrib/svn-fe/Makefile || die "sed failed"

	# Fix docbook2texi command
	sed -r -i 's/DOCBOOK2X_TEXI[[:space:]]*=[[:space:]]*docbook2x-texi/DOCBOOK2X_TEXI = docbook2texi.pl/' \
		Documentation/Makefile || die "sed failed"

	# Never install the private copy of Error.pm (bug #296310)
	sed -i \
		-e '/private-Error.pm/s,^,#,' \
		perl/Makefile.PL
}

git_emake() {
	# bug #326625: PERL_PATH, PERL_MM_OPT
	# bug #320647: PYTHON_PATH
	PYTHON_PATH="${PYTHON}"
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
		PERL_MM_OPT="" \
		GIT_TEST_OPTS="--no-color" \
		V=1 \
		"$@"
	# This is the fix for bug #326625, but it also causes breakage, see bug
	# #352693.
	# PERL_PATH="${EPREFIX}/usr/bin/env perl" \
}

src_configure() {
	exportmakeopts
}

src_compile() {
	#if use perl ; then
	git_emake perl/PM.stamp || die "emake perl/PM.stamp failed"
	git_emake perl/perl.mak || die "emake perl/perl.mak failed"
	#fi
	git_emake || die "emake failed"

	cd "${S}"/Documentation
	if [[ ${PV} == *9999 ]] ; then
		git_emake man \
			|| die "emake man failed"
		if use doc ; then
			git_emake info html \
				|| die "emake info html failed"
		fi
	else
		if use doc ; then
			git_emake info \
				|| die "emake info html failed"
		fi
	fi
}

src_install() {
	git_emake install || die "make install failed"

	rm -rf "${ED}"usr/share/gitweb || die
	rm -rf "${ED}"usr/share/git-core/templates || die
	rm -rf "${ED}"usr/share/git-gui || die
	rm -rf "${ED}"usr/share/gitk || die

	local myrelfile=""
	for myfile in "${ED}"usr/libexec/git-core/* "${ED}"usr/$(get_libdir)/* "${ED}"usr/share/man/*/* "${ED}"usr/bin/* ; do
		# image dir contains the keyword "cvs"
		myrelfile="${myfile/${ED}}"
		case "${myrelfile}" in
			*cvs*)
				true ;;
			*)
				rm -rf "${myfile}" || die ;;
		esac
	done

	local libdir="${ED}"usr/$(get_libdir)
	if [ -d "${libdir}" ]; then
		# must be empty
		rmdir "${libdir}" || die
	fi

	doman man*/*cvs* || die
	if use doc; then
		docinto /
		dodoc Documentation/*cvs*.txt
		dohtml -p / Documentation/*cvs*.html
	fi

	# kill empty dirs from ${ED}
	find "${ED}" -type d -empty -delete || die
}
