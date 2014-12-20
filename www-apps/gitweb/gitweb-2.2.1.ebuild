# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

GENTOO_DEPEND_ON_PERL=no

[[ ${PV} == *9999 ]] && SCM="git-2"
EGIT_REPO_URI="git://git.kernel.org/pub/scm/git/git.git"
EGIT_MASTER=pu

inherit toolchain-funcs eutils ${SCM}

MY_PV="${PV/_rc/.rc}"
MY_PV="${MY_PV/gitweb/git}"
MY_P="${PN}-${MY_PV}"
MY_P="${MY_P/gitweb/git}"

DESCRIPTION="A web interface to git"
HOMEPAGE="http://www.git-scm.com/"
if [[ "$PV" != *9999 ]]; then
	SRC_URI_SUFFIX="xz"
	SRC_URI_GOOG="http://git-core.googlecode.com/files"
	SRC_URI_KORG="mirror://kernel/software/scm/git"
	SRC_URI="${SRC_URI_GOOG}/${MY_P}.tar.${SRC_URI_SUFFIX}
			${SRC_URI_KORG}/${MY_P}.tar.${SRC_URI_SUFFIX}"
	KEYWORDS="~amd64 ~x86"
else
	SRC_URI=""
	KEYWORDS=""
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="highlight"

# Common to both DEPEND and RDEPEND
CDEPEND="
	~dev-vcs/git-${PV}
	sys-libs/zlib
	dev-lang/perl:=[-build(-)]
	dev-libs/libpcre
	dev-lang/tk"

RDEPEND="${CDEPEND}
	dev-vcs/git[-cgi]
	dev-perl/Error
	dev-perl/Net-SMTP-SSL
	dev-perl/Authen-SASL
	virtual/perl-CGI highlight? ( app-text/highlight )"

DEPEND="${CDEPEND}
	app-arch/cpio
	"

SITEFILE=50${PN}-gentoo.el
S="${WORKDIR}/${MY_P}"

src_unpack() {
	if [[ "${PV}" != *9999 ]]; then
		unpack ${MY_P}.tar.${SRC_URI_SUFFIX}
		cd "${S}"
	else
		git-2_src_unpack
		cd "${S}"
		#cp "${FILESDIR}"/GIT-VERSION-GEN .
	fi

}

src_prepare() {
	epatch_user

	sed -i \
		-e 's:^\(CFLAGS[[:space:]]*=\).*$:\1 $(OPTCFLAGS) -Wall:' \
		-e 's:^\(LDFLAGS[[:space:]]*=\).*$:\1 $(OPTLDFLAGS):' \
		-e 's:^\(CC[[:space:]]* =\).*$:\1$(OPTCC):' \
		-e 's:^\(AR[[:space:]]* =\).*$:\1$(OPTAR):' \
		-e "s:\(PYTHON_PATH[[:space:]]\+=[[:space:]]\+\)\(.*\)$:\1${EPREFIX}\2:" \
		-e "s:\(PERL_PATH[[:space:]]\+=[[:space:]]\+\)\(.*\)$:\1${EPREFIX}\2:" \
		Makefile || die "sed failed"

	# Never install the private copy of Error.pm (bug #296310)
	sed -i \
		-e '/private-Error.pm/s,^,#,' \
		perl/Makefile.PL
}

git_emake() {
	local MY_MAKEOPTS="INSTALLDIRS=vendor"
	emake ${MY_MAKEOPTS} \
		DESTDIR="${D}" \
		OPTCFLAGS="${CFLAGS}" \
		OPTLDFLAGS="${LDFLAGS}" \
		OPTCC="$(tc-getCC)" \
		OPTAR="$(tc-getAR)" \
		prefix="${EPREFIX}"/usr \
		htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		sysconfdir="${EPREFIX}"/etc \
		PERL_PATH="${EPREFIX}/usr/bin/env perl" \
		PERL_MM_OPT="" \
		GIT_TEST_OPTS="--no-color" \
		V=1 \
		"$@"
}

src_configure() {
	einfo "Nothing to configure."
}

src_compile() {
	git_emake perl/PM.stamp || die "emake perl/PM.stamp failed"
	git_emake perl/perl.mak || die "emake perl/perl.mak failed"

	git_emake \
		gitweb \
		|| die "emake gitweb failed"
}

src_install() {
	#if use perl && use cgi ; then
	# dosym /usr/share/gitweb /usr/share/${PN}/gitweb

	# INSTALL discusses configuration issues, not just installation
	docinto /
	newdoc "${S}"/gitweb/INSTALL INSTALL.gitweb
	newdoc "${S}"/gitweb/README README.gitweb

	find "${ED}"/usr/lib64/perl5/ \
		-name .packlist \
		-exec rm \{\} \;
	#else
	#	rm -rf "${ED}"/usr/share/gitweb
	#fi

	exeinto /usr/share/gitweb/
	doexe "${S}"/gitweb/gitweb.cgi

	insinto /usr/share/gitweb/static
	doins "${S}"/gitweb/static/*.png
	doins "${S}"/gitweb/static/*.css
	doins "${S}"/gitweb/static/*.js

	# Maybe not needed, but it's created when non-split ebuild is used too.
	dosym /usr/share/gitweb /usr/share/git/gitweb

	# perl_delete_localpod from perl-module: not needed
}

showpkgdeps() {
	local pkg=$1
	shift
	elog "  $(printf "%-17s:" ${pkg}) ${@}"
}

pkg_postinst() {
	elog "These additional scripts need some dependencies:"
	echo
	showpkgdeps git-quiltimport "dev-util/quilt"
	showpkgdeps git-instaweb \
		"|| ( www-servers/lighttpd www-servers/apache www-servers/nginx )"
	echo
}
