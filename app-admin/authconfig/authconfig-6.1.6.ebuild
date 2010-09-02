# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils python

DESCRIPTION="Command line tool for setting up authentication from network services"
HOMEPAGE="https://fedorahosted.org/authconfig"
SRC_URI="https://fedorahosted.org/releases/a/u/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/glib
	sys-devel/gettext
	dev-util/intltool
	dev-util/desktop-file-utils
	dev-perl/XML-Parser"
RDEPEND="${DEPEND} dev-libs/newt"

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	# drop broken .desktop
	rm "${D}/usr/share/applications/authconfig.desktop" -f
}

MY_SYSTEM_AUTH="
auth            required        pam_env.so
auth            required        pam_unix.so try_first_pass likeauth nullok

account         required        pam_unix.so

password        required        pam_cracklib.so difok=2 minlen=8 dcredit=2 ocredit=2 retry=3
password        required        pam_unix.so try_first_pass use_authtok nullok md5 sha512 shadow

session         required        pam_limits.so
session         required        pam_env.so
session         required        pam_unix.so
session         optional        pam_permit.so
"

pkg_setup() {
	python_pkg_setup

	# Fix Sabayon 5.3 anaconda "bug" caused by the usage of authconfig
	# that broke Gentoo pambase file layout making /etc/pam.d/system-auth
	# a symlink of /etc/pam.d/system-auth-ac
	# Sabayon >5.3 dropped authconfig (so this ebuild will be removed)
	# and so the issue got solved.
	# The issue didn't happen inside our server chroots because authconfig
	# got triggered during installation (by anaconda, fixed in 0.9.9.3)
	if [ -e "/etc/pam.d/system-auth" ]; then
		local sa_link="$(readlink /etc/pam.d/system-auth)"
		if [ "${sa_link}" = "system-auth-ac" ]; then
			einfo "Fixing broken /etc/pam.d/system-auth with system-auth from pambase"
			rm /etc/pam.d/system-auth && echo "${MY_SYSTEM_AUTH}" > /etc/pam.d/system-auth
		fi
	fi
}
