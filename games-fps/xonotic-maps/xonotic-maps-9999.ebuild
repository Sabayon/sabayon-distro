# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit games check-reqs

MY_PN="${PN%-maps}"
DESCRIPTION="Xonotic maps"
HOMEPAGE="http://www.xonotic.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="unofficial"

RDEPEND="~games-fps/xonotic-data-9999"
DEPEND="
	app-arch/unzip
	net-misc/wget
"
S="${WORKDIR}"

pkg_setup() {
	games_pkg_setup

	ewarn "Downloaded pk3 files will be stored in \"xonotic-maps\" subdirectory of your DISTDIR"
	echo

	if use unofficial; then
		ewarn "You have enabled \"unofficial\" USE flag. Incomplete, unstable or broken maps may be installed."
		echo
	fi

	CHECKREQS_DISK_USR="350" \
	check_reqs
}

src_unpack() {
	# Used git.eclass,v 1.50 as example
	: ${MAPS_STORE_DIR:="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}/xonotic-maps"}
	# initial download, we have to create master maps storage directory and play
	# nicely with sandbox
	if [[ ! -d ${MAPS_STORE_DIR} ]] ; then
		addwrite /
		mkdir -p "${MAPS_STORE_DIR}" \
			|| die "can't mkdir ${MAPS_STORE_DIR}."
		export SANDBOX_WRITE="${SANDBOX_WRITE%%:/}"
	fi
	# allow writing into MAPS_STORE_DIR
	addwrite "${MAPS_STORE_DIR}"

	# FETCHCOMMAND from make.globals is example
	local WGET="/usr/bin/wget -t 3 -T 60"
	local base_url="http://beta.xonotic.org/autobuild-bsp/"

	$WGET -O \
		autobuild-bsp.list \
		"${base_url}" || die

	local OfficialMaps="$(
		$WGET -O- \
		'http://git.xonotic.org/?p=xonotic/xonotic-maps.pk3dir.git;a=tree;f=maps' |\
		grep -e '\.map</a>' |\
		sed -e 's,.*">\([^<]*\).map<\/a>.*,\1,'
	)"
	if [ "x${OfficialMaps}" = "x" ]; then
		die "List of official maps is empty"
	fi
	local Maps="${OfficialMaps}"

	if use unofficial; then
	# For maps not in master branch we need to download fullpk3,
	# but some old unofficial maps have only bspk3, exclude them.
		# AllMaps - OfficialMaps = UnofficialMaps
		echo "${OfficialMaps}" |\
		sed -e 's,\(.*\),^\1$,' \
			> OfficialMaps.grep || die
		local UnofficialMaps="$(
			grep autobuild-bsp.list \
				-e '<td class="mapname">' |\
			sed -e 's,.*="mapname">\([^<]*\)<.*,\1,' |\
			sort -u |\
			grep -v -e '^$' \
				-e '^arahia$' \
				-e '^darkzone$' \
				-e '^facility_114$' \
				-e '^valentine114$' \
				-f OfficialMaps.grep |\
			sed -e 's,$,-full,'
		)"
		if [ "x${UnofficialMaps}" = "x" ]; then
			die "List of unofficial maps is empty"
		fi
		Maps+=" ${UnofficialMaps}"
	fi

	MapFiles=""
	for i in ${Maps}; do
		local version="$(
			grep autobuild-bsp.list -m1 \
				-e "href=\"${i%-full}-.*.pk3\">bspk3<" |\
			sed -e "s,.*href=\"${i%-full}-\([^\"]*\).pk3\">bspk3<.*,\1,"
		)"
		local name="${i}-${version}.pk3"
		MapFiles+=" ${name}"
		local path="${MAPS_STORE_DIR}/${name}"
		local url="${base_url}${name}"

		if [[ ! -f "${path}" ]]; then
			rm -f "${path}" 2> /dev/null
			einfo "Downloading ${name}"
			$WGET "${url}" -O "${path}" || ewarn "downloading ${url} failed"
		fi
	done

	# Remove obsolete and broken files from MAPS_STORE_DIR
	# If map becomes official, it changes branch and git hashes in name => no need to check both fullpk3 and bsppk3
	for i in "${MAPS_STORE_DIR}"/*; do
		local name="$(
			echo "${i}" |\
			sed -e "s,${MAPS_STORE_DIR}/\([^/]*\)-.*-.*.pk3$,\1,"
		)"
		local version="$(
			echo "${i}" |\
			sed -e "s,${MAPS_STORE_DIR}/${name}-\([^/]*\).pk3$,\1,"
		)"
		# latest builds of maps are above
		local Cversion="$(
			grep autobuild-bsp.list -m1 \
				-e "href=\"${name%-full}-.*.pk3\">bspk3<" |\
			sed -e "s,.*href=\"${name%-full}-\([^\"]*\).pk3\">bspk3<.*,\1,"
		)"

		if [ "${version}" != "${Cversion}" ]; then
			einfo "${i} is obsolete, removing"
			rm -f "${i}"
		elif [ "x${version}" = "x" ]; then
			ewarn "${i} has incorrect name, removing"
			rm -f "${i}"
		elif [ "x${Cversion}" = "x" ]; then
			ewarn "${i} is not available in ${base_url}, removing"
			rm -f "${i}"
		elif unzip -t "${i}" > /dev/null; then
			true
		else
			ewarn "${i} is not valid pk3 file, removing"
			rm -f "${i}"
		fi
	done
}

src_install() {
	insinto "${GAMES_DATADIR}/${MY_PN}/data"
	for i in ${MapFiles}; do
		doins "${MAPS_STORE_DIR}/${i}" || ewarn "installing ${i} failed"
	done

	prepgamesdirs
}
