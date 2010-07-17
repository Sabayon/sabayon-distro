# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit eutils python multilib

DESCRIPTION="Official Sabayon Linux Package Manager library"
HOMEPAGE="http://www.sabayon.org"
REPO_CONFPATH="${ROOT}/etc/entropy/repositories.conf"
ENTROPY_CACHEDIR="${ROOT}/var/lib/entropy/caches"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/${P}.tar.bz2"
RESTRICT="mirror"

DEPEND="sys-apps/sandbox
	sys-devel/gettext
	sys-apps/diffutils
	|| ( dev-lang/python:2.6[sqlite] )
	dev-db/sqlite[soundex]
	dev-util/intltool"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewgroup entropy || die "failed to create entropy group"
}

src_compile() {
	# TODO: move to separate package
	cd "${S}"/misc/po
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="usr/$(get_libdir)" entropy-install || die "make install failed"

	# TODO: move to separate package
	cd "${S}"/misc/po
	emake DESTDIR="${D}" LIBDIR="usr/$(get_libdir)" install || die "make install failed"
}

pkg_preinst() {
	# backup user repositories.conf
	if [ -f "${REPO_CONFPATH}" ]; then
		cp -p "${REPO_CONFPATH}" "${REPO_CONFPATH}.backup"
	fi
}

pkg_postinst() {

	# make sure than old entropy pyc files don't interfere (this is a workaround)
	find /usr/$(get_libdir)/entropy -name "*.pyc" | xargs rm &> /dev/null

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

	python_mod_optimize "/usr/$(get_libdir)/entropy/libraries/entropy"

	# force python 2.6 at least
	eselect python update --ignore 3.0 --ignore 3.1 --ignore 3.2 --ignore 3.3 --ignore 2.7

}

pkg_postrm() {
	python_mod_cleanup "/usr/$(get_libdir)/entropy/libraries/entropy"
}
