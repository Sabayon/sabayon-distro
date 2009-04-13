# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=1
inherit eutils multilib

EGIT_TREE="${PV}"
EGIT_REPO_URI="git://sabayon.org/projects/entropy.git"
inherit git

DESCRIPTION="Official Sabayon Linux Package Manager library"
HOMEPAGE="http://www.sabayonlinux.org"
REPO_CONFPATH="/etc/entropy/repositories.conf"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
	sys-apps/sandbox
	sys-devel/gettext
	sys-apps/diffutils
	>=dev-lang/python-2.5[sqlite]
	dev-db/sqlite[soundex]
	dev-util/intltool"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewgroup entropy || die "failed to create entropy group"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR=usr/$(get_libdir) entropy-install || die "make install failed"
	echo "${PV}" > revision
	insinto /usr/$(get_libdir)/entropy/libraries
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
}
