# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# split ebuild providing only ->>> gitk, gitview, git-gui, git-citool

GENTOO_DEPEND_ON_PERL=no

# bug #329479: git-remote-testgit is not multiple-version aware
PYTHON_COMPAT=( python2_7 )
if [[ ${PV} == *9999 ]]; then
	SCM="git-r3"
	EGIT_REPO_URI="git://git.kernel.org/pub/scm/git/git.git"
	# Please ensure that all _four_ 9999 ebuilds get updated; they track the 4 upstream branches.
	# See https://git-scm.com/docs/gitworkflows#_graduation
	# In order of stability:
	# 9999-r0: maint
	# 9999-r1: master
	# 9999-r2: next
	# 9999-r3: pu
	case "${PVR}" in
		9999) EGIT_BRANCH=maint ;;
		9999-r1) EGIT_BRANCH=master ;;
		9999-r2) EGIT_BRANCH=next;;
		9999-r3) EGIT_BRANCH=pu ;;
	esac
fi

inherit toolchain-funcs eutils python-single-r1 ${SCM}

MY_PV="${PV/_rc/.rc}"
MY_PV="${MY_PV/-gui-tools}"
MY_P="${PN}-${MY_PV}"
MY_P="${MY_P/-gui-tools}"

DESCRIPTION="GUI tools derived from git: gitk, git-gui and gitview"
HOMEPAGE="http://www.git-scm.com/"
if [[ ${PV} != *9999 ]]; then
	SRC_URI_SUFFIX="xz"
	SRC_URI_KORG="mirror://kernel/software/scm/git"
	[[ "${PV/rc}" != "${PV}" ]] && SRC_URI_KORG+='/testing'
	SRC_URI="${SRC_URI_KORG}/${MY_P}.tar.${SRC_URI_SUFFIX}"
	[[ "${PV}" = *_rc* ]] || \
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE=""

# Common to both DEPEND and RDEPEND
CDEPEND="
	sys-libs/zlib
	dev-lang/tk:0="

RDEPEND="${CDEPEND}
	~dev-vcs/git-${PV}
	dev-vcs/git[-tk]
	dev-vcs/git[python]
	${PYTHON_DEPS}"

DEPEND="${CDEPEND}"

SITEFILE=50${PN}-gentoo.el
S="${WORKDIR}/${MY_P}"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
"

PATCHES=(
	# bug #350330 - automagic CVS when we don't want it is bad.
	"${FILESDIR}"/git-2.12.0-optional-cvs.patch

	# install mediawiki perl modules also in vendor_dir
	# hack, needs better upstream solution
	"${FILESDIR}"/git-1.8.5-mw-vendor.patch

	"${FILESDIR}"/git-2.2.0-svn-fe-linking.patch

	# Bug #493306, where FreeBSD 10.x merged libiconv into its libc.
	"${FILESDIR}"/git-2.5.1-freebsd-10.x-no-iconv.patch
)

pkg_setup() {
	#if use python ; then
	python-single-r1_pkg_setup
	#fi
}

# This is needed because for some obscure reasons future calls to make don't
# pick up these exports if we export them in src_unpack()
exportmakeopts() {
	local myopts

	myopts+=" NO_EXPAT=YesPlease"
	myopts+=" NO_CURL=YesPlease"
	# broken assumptions, because of static build system ...
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

	myopts+=" NO_PERL=YesPlease"
	grep -q getdelim "${ROOT}"/usr/include/stdio.h && \
		myopts+=" HAVE_GETDELIM=1"

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
	else
		git-r3_src_unpack
		cd "${S}"
		#cp "${FILESDIR}"/GIT-VERSION-GEN .
	fi
}

src_prepare() {
	default

	sed -i \
		-e 's:^\(CFLAGS[[:space:]]*=\).*$:\1 $(OPTCFLAGS) -Wall:' \
		-e 's:^\(LDFLAGS[[:space:]]*=\).*$:\1 $(OPTLDFLAGS):' \
		-e 's:^\(CC[[:space:]]* =\).*$:\1$(OPTCC):' \
		-e 's:^\(AR[[:space:]]* =\).*$:\1$(OPTAR):' \
		-e "s:\(PYTHON_PATH[[:space:]]\+=[[:space:]]\+\)\(.*\)$:\1${EPREFIX}\2:" \
		-e "s:\(PERL_PATH[[:space:]]\+=[[:space:]]\+\)\(.*\)$:\1${EPREFIX}\2:" \
		Makefile contrib/svn-fe/Makefile || die "sed failed"

	# Never install the private copy of Error.pm (bug #296310)
	sed -i \
		-e '/private-Error.pm/s,^,#,' \
		perl/Makefile.PL
}

git_emake() {
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

	#find "${ED}"/usr/lib64/perl5/ \
	#	-name .packlist \
	#	-exec rm \{\} \;

	rm -r "${ED}"usr/share/git-core || die
	rm -r "${ED}"usr/libexec/git-core/mergetools || die

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
