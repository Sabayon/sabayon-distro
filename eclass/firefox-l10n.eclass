# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

[[ ${EAPI} != 4 ]] && die "only EAPI 4 is supported"

# note: no Gentoo patches are applied, but that's unlikely they
# would touch the locale files

MOZ_ESR=${MOZ_ESR:-}

MOZ_LANGS=( ${PN#firefox-l10n-} )

# Convert the ebuild version to the upstream mozilla version, used by mozlinguas
# (copied from a Firefox ebuild)
MOZ_PV="${PV/_alpha/a}" # Handle alpha for SRC_URI
MOZ_PV="${MOZ_PV/_beta/b}" # Handle beta for SRC_URI
MOZ_PV="${MOZ_PV/_rc/rc}" # Handle rc for SRC_URI

if [[ ${MOZ_ESR} == 1 ]]; then
	# ESR releases have slightly version numbers
	MOZ_PV="${MOZ_PV}esr"
fi

MOZ_PN="firefox"

MOZ_FTP_URI="ftp://ftp.mozilla.org/pub/${MOZ_PN}/releases/"

inherit toolchain-funcs mozlinguas
# for mozextension.eclass, hopefully temporary
inherit versionator

DESCRIPTION="Firefox language pack (${MOZ_LANGS[0]})"
HOMEPAGE="http://www.mozilla.com/firefox"

LICENSE="MPL-2.0 GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="!<www-client/firefox-${PV}"

S=${WORKDIR}

src_install() {
	local MOZILLA_FIVE_HOME
	MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${MOZ_PN}"
	# we need to fake PN: see mozversion_extension_location
	# in mozextension.eclass
	PN=${MOZ_PN} mozlinguas_src_install
}
