# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
DESCRIPTION="Verify lib* as per default/linux/amd64/17.1/desktop"
HOMEPAGE="https://www.sabayon.org/"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

# to make them install first
DEPEND="sys-apps/sabayon-lib-migration"
RDEPEND="sys-apps/sabayon-lib-migration"
S="${WORKDIR}"

_already_done() {
	{ [[ ! -L /lib ]] && [[ ! -L /usr/lib ]]; } && return 0
	return 1
}

pkg_setup() {
	if _already_done; then
		elog "Migration seems to have been done already; skipping."
		return 0
	fi

	# Abort the install or upgrade phase or e.g. glibc will install 32 bit
	# libc.so.6 (binary from the new profile) to /lib that is still to
	# be 64 bit (/lib -> /lib64) and it will break the whole system.
	eerror "Profile migration was supposed to have been done by sys-apps/sabayon-lib-migration"
	eerror "but it is not the case."
	eerror ""
	eerror "If it didn't get installed, install it now as THE FIRST AND ONLY PACKAGE."
	eerror "If it tried to install but failed, refer to information printed by that package."
	eerror ""
	eerror "Stopping now. DO NOT CONTINUE THE UPGRADE UNLESS sys-apps/sabayon-lib-migration IS INSTALLED WITHOUT ERROR."
	eerror "OTHERWISE YOUR SYSTEM WILL BE BROKEN."
	# Apparently there is no effective way to stop Entropy. Doing this instead.
	eerror ""
	eerror "! The process has been stopped. Press Control+C once or twice"
	eerror "! and make sure the package manager does not continue, and see the error above."
	command sleep 200d
	die "/lib* and /usr/lib* not migrated; cannot continue. Refer to the message above."
}
