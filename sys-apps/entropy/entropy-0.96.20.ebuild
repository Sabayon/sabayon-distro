# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
EGIT_TREE="${PV}"
EGIT_REPO_URI="git://sabayon.org/projects/entropy.git"
inherit eutils python git

DESCRIPTION="Official Sabayon Linux Package Manager library"
HOMEPAGE="http://www.sabayonlinux.org"
REPO_CONFPATH="${ROOT}/etc/entropy/repositories.conf"
ENTROPY_CACHEDIR="${ROOT}/var/lib/entropy/caches"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	sys-apps/sandbox
	sys-devel/gettext
	sys-apps/diffutils
	|| ( dev-lang/python:2.5[sqlite] dev-lang/python:2.6[sqlite] )
	dev-db/sqlite[soundex]
	dev-util/intltool"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewgroup entropy || die "failed to create entropy group"
}

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" LIBDIR="usr/$(get_libdir)" entropy-install || die "make install failed"
	echo "${PV}" > revision
	insinto "/usr/$(get_libdir)/entropy/libraries"
	doins revision
}

pkg_preinst() {
	# backup user repositories.conf
	if [ -f "${REPO_CONFPATH}" ]; then
		cp -p "${REPO_CONFPATH}" "${REPO_CONFPATH}.backup"
	fi
}

pkg_postinst() {
	# Copy config file over
	if [ -f "${REPO_CONFPATH}.backup" ]; then
		cp ${REPO_CONFPATH}.backup ${REPO_CONFPATH} -p
	else
		if [ -f "${REPO_CONFPATH}.example" ] && [ ! -f "${REPO_CONFPATH}" ]; then
			cp ${REPO_CONFPATH}.example ${REPO_CONFPATH} -p
		fi
	fi
	if [ -d "${ENTROPY_CACHEDIR}" ]; then
		einfo "Purging current Entropy cache"
		rm -rf ${ENTROPY_CACHEDIR}/*
	fi
	python_mod_compile "/usr/$(get_libdir)/entropy/entropy"
}

pkg_postrm() {
	python_mod_cleanup "/usr/$(get_libdir)/entropy"
}
