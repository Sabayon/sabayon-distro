# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# clutter.eclass
#
# Sets SRC_URI, SLOT, and a few deps
#
# Authors:
# Nirbheek Chauhan <nirbheek@gentoo.org>
#

inherit versionator

HOMEPAGE="http://www.clutter-project.org/"

RV=($(get_version_components))
SRC_URI="http://www.clutter-project.org/sources/${PN}/${RV[0]}.${RV[1]}/${P}.tar.bz2"
LICENSE="LGPL-2"

DEPEND="dev-util/pkgconfig"

DOCS="${DOCS:-AUTHORS ChangeLog NEWS README TODO}"

clutter_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ${DOCS} || die "dodoc failed"

	# examples
	if hasq examples ${IUSE} && use examples; then
		insinto /usr/share/doc/${PF}/examples

		# We use eval to be able to use globs
		for example in $(eval echo ${EXAMPLES}); do
			# If directory
			if [[ ${example: -1} = "/" ]]; then
				doins -r ${example}
			else
				doins ${example}
			fi
		done
	fi
}

EXPORT_FUNCTIONS src_install
