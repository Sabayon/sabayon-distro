# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/portage/portage-2.1.3.4.ebuild,v 1.1 2007/08/10 22:14:39 zmedico Exp $

inherit toolchain-funcs eutils flag-o-matic multilib

DESCRIPTION="The Portage Package Management System. The primary package management and distribution system for Gentoo."
HOMEPAGE="http://www.gentoo.org/proj/en/portage/index.xml"
LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
PROVIDE="virtual/portage"
SLOT="0"
# USE_EXPAND_HIDDEN hides ELIBC and USERLAND expansions from emerge output (see make.conf.5).
IUSE_ELIBC="elibc_glibc elibc_uclibc elibc_FreeBSD"
IUSE="build doc epydoc selinux linguas_pl userland_GNU ${IUSE_ELIBC}"
DEPEND=">=dev-lang/python-2.4
	!build? ( >=sys-apps/sed-4.0.5 )
	doc? ( app-text/xmlto ~app-text/docbook-xml-dtd-4.4 )
	epydoc? ( >=dev-python/epydoc-2.0 )"
RDEPEND=">=dev-lang/python-2.4
	!build? ( >=sys-apps/sed-4.0.5
		dev-python/python-fchksum
		>=app-shells/bash-3.0 )
	elibc_FreeBSD? ( dev-python/py-freebsd )
	elibc_glibc? ( >=sys-apps/sandbox-1.2.17 )
	elibc_uclibc? ( >=sys-apps/sandbox-1.2.17 )
	>=app-misc/pax-utils-0.1.13
	userland_GNU? ( >=sys-apps/coreutils-6.4 )
	selinux? ( >=dev-python/python-selinux-2.16 )
	doc? ( || ( app-portage/eclass-manpages app-portage/portage-manpages ) )
	>=dev-python/pycrypto-2.0.1-r5
	>=net-misc/rsync-2.6.4"
# coreutils-6.4 rdep is for date format in emerge-webrsync #164532
# rsync-2.6.4 rdep is for the --filter option #167668
SRC_ARCHIVES="http://dev.gentoo.org/~zmedico/portage/archives"

PV_PL="2.1.2"
PATCHVER_PL=""
TARBALL_PV="${PV%.*}"
SRC_URI="mirror://gentoo/${PN}-${TARBALL_PV}.tar.bz2
	${SRC_ARCHIVES}/${PN}-${TARBALL_PV}.tar.bz2
	linguas_pl? ( mirror://gentoo/${PN}-man-pl-${PV_PL}.tar.bz2
	${SRC_ARCHIVES}/${PN}-man-pl-${PV_PL}.tar.bz2 )"

#PATCHVER="${PVR}"
#if [ -n "${PATCHVER}" ]; then
#	SRC_URI="${SRC_URI} mirror://gentoo/${PN}-${PATCHVER}.patch.bz2
#	${SRC_ARCHIVES}/${PN}-${PATCHVER}.patch.bz2"
#fi

if [ -n "${PATCHVER_PL}" ]; then
	SRC_URI="${SRC_URI} linguas_pl? ( mirror://gentoo/${PN}-man-pl-${PV_PL}${PATCHVER_PL}.patch.bz2
	${SRC_ARCHIVES}/${PN}-man-pl-${PV_PL}${PATCHVER_PL}.patch.bz2 )"
fi

S="${WORKDIR}"/${PN}-${TARBALL_PV}
S_PL="${WORKDIR}"/${PN}-${PV_PL}

portage_docs() {
	elog ""
	elog "For help with using portage please consult the Gentoo Handbook"
	elog "at http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=3"
	elog ""
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fix Portage slowness, thanks drobbins and ezmedico
	epatch "${FILESDIR}"/setcpv_wildcards.patch

	if [ -n "${PATCHVER}" ]; then
		cd "${S}"
		epatch "${WORKDIR}/${PN}-${PATCHVER}.patch"
	fi
	einfo "Setting portage.VERSION to ${PVR} ..."
	sed -i "s/^VERSION=.*/VERSION=\"${PVR}\"/" pym/portage.py || \
		die "Failed to patch portage.VERSION"
	eend 0
	if [ -n "${PATCHVER_PL}" ]; then
		use linguas_pl && \
			epatch "${WORKDIR}/${PN}-man-pl-${PV_PL}${PATCHVER_PL}.patch"
	fi
}

src_compile() {
	append-lfs-flags

	cd "${S}"/src
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} -o tbz2tool tbz2tool.c || \
		die "Failed to build tbz2tool"

	if use doc; then
		cd "${S}"/doc
		touch fragment/date
		sed -i "s/svn-trunk/${PVR}/" fragment/version
		make xhtml-nochunks || die "failed to make docs"
	fi

	if use epydoc; then
		einfo "Generating api docs"
		mkdir "${WORKDIR}"/api
		local my_modules
		my_modules="$(find "${S}/pym" -name "*.py" \
			| sed -e 's:/__init__.py$::' -e 's:\.py$::' -e "s:^${S}/pym/::" \
			 -e 's:/:.:g')" || die "error listing modules"
		PYTHONPATH="${S}/pym:${PYTHONPATH}" epydoc -o "${WORKDIR}"/api \
			-qqqqq --ignore-param-mismatch --no-frames --show-imports \
			--name "${PN}" --url "${HOMEPAGE}" \
			${my_modules} || die "epydoc failed"
	fi
}

src_test() {
	./tests/runTests || \
		die "test(s) failed"
}

src_install() {
	local libdir=$(get_libdir)
	local portage_base="/usr/${libdir}/portage"
	cd "${S}"/cnf
	insinto /etc
	doins etc-update.conf dispatch-conf.conf make.globals
	if [ -f "make.conf.${ARCH}".diff ]; then
		patch make.conf "make.conf.${ARCH}".diff || \
			die "Failed to patch make.conf.example"
		newins make.conf make.conf.example
	else
		eerror ""
		eerror "Portage does not have an arch-specific configuration for this arch."
		eerror "Please notify the arch maintainer about this issue. Using generic."
		eerror ""
		newins make.conf make.conf.example
	fi

	insinto /etc/logrotate.d
	doins "${S}"/cnf/logrotate.d/elog-save-summary

	dodir ${portage_base}/bin
	exeinto ${portage_base}/bin
	# BSD and OSX need a sed wrapper so that find/xargs work properly
	if use userland_GNU; then
		rm "${S}"/bin/sed || die "Failed to remove sed wrapper"
	fi
	cd "${S}"/bin
	doexe *
	doexe "${S}"/src/tbz2tool
	dosym newins ${portage_base}/bin/donewins

	for mydir in pym pym/cache pym/elog_modules; do
		dodir ${portage_base}/${mydir}
		insinto ${portage_base}/${mydir}
		cd "${S}"/${mydir}
		doins *.py
	done

	doman "${S}"/man/*.[0-9]
	if use linguas_pl; then
		doman -i18n=pl "${S_PL}"/man/pl/*.[0-9]
		doman -i18n=pl_PL.UTF-8 "${S_PL}"/man/pl_PL.UTF-8/*.[0-9]
	fi
	dodoc "${S}"/ChangeLog
	dodoc "${S}"/NEWS
	dodoc "${S}"/RELEASE-NOTES
	use doc && dohtml "${S}"/doc/*.html
	use epydoc && dohtml -r "${WORKDIR}"/api

	dodir /usr/bin
	for x in ebuild emerge portageq repoman tbz2tool xpak; do
		dosym ../${libdir}/portage/bin/${x} /usr/bin/${x}
	done

	dodir /usr/sbin
	local my_syms="archive-conf
		dispatch-conf
		emaint
		emerge-webrsync
		env-update
		etc-update
		fixpackages
		quickpkg
		regenworld"
	local x
	for x in ${my_syms}; do
		dosym ../${libdir}/portage/bin/${x} /usr/sbin/${x}
	done
	dosym env-update /usr/sbin/update-env
	dosym etc-update /usr/sbin/update-etc

	dodir /etc/portage
	keepdir /etc/portage

	echo PYTHONPATH=\"${portage_base}/pym\" > "${WORKDIR}"/05portage.envd
	doenvd "${WORKDIR}"/05portage.envd
}

pkg_preinst() {
	local portage_base="/usr/$(get_libdir)/portage"
	if has livecvsportage ${FEATURES} && [ "${ROOT}" = "/" ]; then
		rm -rf "${D}"/${portage_base}/pym/*
		mv "${D}"/${portage_base}/bin/tbz2tool "${T}"
		rm -rf "${D}"/${portage_base}/bin/*
		mv "${T}"/tbz2tool "${D}"/${portage_base}/bin/
	fi
	remove_python_bytecodes
}

pkg_postinst() {
	local x

	if [ ! -f "${ROOT}/var/lib/portage/world" ] &&
	   [ -f "${ROOT}"/var/cache/edb/world ] &&
	   [ ! -h "${ROOT}"/var/cache/edb/world ]; then
		mv "${ROOT}"/var/cache/edb/world "${ROOT}"/var/lib/portage/world
		ln -s ../../lib/portage/world /var/cache/edb/world
	fi

	for x in "${ROOT}"/etc/._cfg????_make.globals; do
		# Overwrite the globals file automatically.
		[ -e "${x}" ] && mv -f "${x}" "${ROOT}etc/make.globals"
	done

	elog
	elog "FEATURES=\"userfetch\" is now enabled by default. Depending on your \${DISTDIR}"
	elog "permissions, this may result in Permission Denied errors. If you would like"
	elog "to fetch with superuser privileges, add FEATURES=\"-userfetch\" to make.conf."
	elog
	elog "The world file now supports slot atoms such as 'sys-devel/gcc:3.4'. In some"
	elog "cases, emerge --depclean may remove slots that it would not have removed"
	elog "in the past. The emerge --noreplace command can be used to add an atom to"
	elog "the world file and prevent matching packages from being removed.  A slot"
	elog "atom will be recorded in the world file for any atom that is precise enough"
	elog "to identify a specific slot."

	portage_docs
}

pkg_postrm() {
	remove_python_bytecodes
}

remove_python_bytecodes() {
	local d="${ROOT}/usr/$(get_libdir)/portage/pym"
	[ -d "${d}" ] || return
	find "${d}" -type d -print0 | \
	while read -d $'\0' d ; do
		cd "${d}"
		rm -f *.pyc *.pyo
	done
}
