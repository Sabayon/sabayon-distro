<<<<<<<
# Copyright 1999-2015 Gentoo Foundation
=======
# Copyright 1999-2019 Gentoo Authors
>>>>>>>
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit toolchain-funcs

<<<<<<<
DESCRIPTION="utility to manage compilers"
HOMEPAGE="https://gitweb.gentoo.org/proj/gcc-config.git/"
SRC_URI="mirror://gentoo/${P}.tar.xz
	http://dev.gentoo.org/~vapier/dist/${P}.tar.xz"
=======
if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://anongit.gentoo.org/git/proj/gcc-config.git"
	inherit git-r3
else
	SRC_URI="mirror://gentoo/${P}.tar.xz
		https://dev.gentoo.org/~slyfox/distfiles/${P}.tar.xz"
	KEYWORDS="alpha amd64 arm arm64 hppa ia64 m68k ~mips ppc ppc64 ~riscv s390 sh sparc x86 ~amd64-fbsd ~x86-fbsd"
fi
>>>>>>>

DESCRIPTION="Utility to manage compilers"
HOMEPAGE="https://gitweb.gentoo.org/proj/gcc-config.git/"
LICENSE="GPL-2"
SLOT="0"
<<<<<<<
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
=======
>>>>>>>
IUSE=""

<<<<<<<
src_prepare() {
	epatch "${FILESDIR}/${PN}-sabayon-base-gcc-support-2.patch"
	epatch "${FILESDIR}/${PN}-1.8-dont_source_functions_sh_from_etc_initd.patch" # 504118
}

=======
>>>>>>>
src_compile() {
	emake CC="$(tc-getCC)" \
		PV="${PV}" \
		SUBLIBDIR="$(get_libdir)"
}

src_install() {
	emake \
		DESTDIR="${D}" \
		PV="${PV}" \
		SUBLIBDIR="$(get_libdir)" \
		install
}

pkg_postinst() {
	# Scrub eselect-compiler remains
	rm -f "${ROOT}"/etc/env.d/05compiler &

	# Make sure old versions dont exist #79062
	rm -f "${ROOT}"/usr/sbin/gcc-config &

	# We not longer use the /usr/include/g++-v3 hacks, as
	# it is not needed ...
	rm -f "${ROOT}"/usr/include/g++{,-v3} &

	# Do we have a valid multi ver setup ?
	local x
	for x in $(gcc-config -C -l 2>/dev/null | awk '$NF == "*" { print $2 }') ; do
		gcc-config ${x}
	done

	wait
}
