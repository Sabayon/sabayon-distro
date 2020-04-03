# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
DESCRIPTION="Migrate lib* as per default/linux/amd64/17.1/desktop"
HOMEPAGE="https://www.sabayon.org/"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="app-portage/unsymlink-lib"
S="${WORKDIR}"

# Note: package made from this has to be merged before anything else.

_inform_and_exec() {
	ewarn "!!!! calling $*"
	"$@"
	local st=$?

	if [[ ${st} -ne 0 ]]; then
		# Going to be tested well but inform the used just in case...
		eerror "The program failed."
		eerror "It is possible that at least 32 bit binaries will not work,"
		eerror "and the system will not boot."
		eerror "Read this for help:"
		eerror "- https://www.gentoo.org/support/news-items/2019-06-05-amd64-17-1-profiles-are-now-stable.html"
		eerror "- https://github.com/mgorny/unsymlink-lib"
		eerror "and if unsure, reach for help in Sabayon's help channels."
		eerror ""
		eerror "AT THE VERY LEAST, CHECK THAT THERE ARE DIRECTORES WITH CONTENT:"
		eerror "/lib /usr/lib /lib64 /usr/lib64"
		eerror "Sorry, and please report it. :("
		# Apparently there is no effective way to stop Entropy. Doing this instead.
		# Note: I have not tested effectiveness of ctrl-c in pkg_postinst, but
		# there is also glibc and sabayon-lib-migration-check that do it also
		# in pkg_setup (tested scenario).
		eerror ""
		eerror "! The process has been stopped. Press Control+C once or twice"
		eerror "! and make sure the package manager does not continue, and see the error above."
		command sleep 200d
		die "FAILED, SEE THE MESSAGE ABOVE"
	fi
}

_already_done() {
	{ [[ ! -L /lib ]] && [[ ! -L /usr/lib ]]; } && return 0
	return 1
}

pkg_postinst() {
	ls -ld /lib* /usr/lib* || true
	if _already_done; then
		elog "Migration seems to have been done already; skipping."
		return 0
	fi

	ewarn "*******************"  # bad practice to put this but I'd really want this to be noticed
	ewarn ""
	ewarn "migration of lib* will be performed"
	ewarn "do not interrupt this process"
	ewarn ""
	ewarn "*******************"
	_inform_and_exec unsymlink-lib --analyze
	_inform_and_exec unsymlink-lib --migrate
	_inform_and_exec unsymlink-lib --finish
	ewarn "*******************"
	ewarn "Done, everyting went well."
}
