# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

SLREV=4
inherit gnome2-utils

DESCRIPTION="Elementary gnome icon theme"
HOMEPAGE="https://launchpad.net/elementaryicons"
SRC_URI="http://launchpad.net/elementaryicons/2.0/${PV}/+download/${P}.tar.gz
	branding? ( mirror://sabayon/x11-themes/fdo-icons-sabayon${SLREV}.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="monochrome branding"

DEPEND=""
RDEPEND=""
RESTRICT="binchecks strip"

src_install() {
	cd "${WORKDIR}/${PN}"
	dodoc elementary/{AUTHORS,CONTRIBUTORS} || die
	use monochrome && { newdoc elementary-mono-dark/AUTHORS AUTHORS.mono-dark || die; }
	rm elementary/{AUTHORS,CONTRIBUTORS,COPYING}
	rm elementary-mono-dark/{AUTHORS,COPYING}

	insinto /usr/share/icons
	doins -r elementary || die
	use monochrome && { doins -r elementary-mono-dark || die; }

	# this icon theme uses different layout
	# so let's do some blah here
	local base_dir icon_dir dest_icon_dir myfile

	cd "${WORKDIR}"
	# Sabayon nice stuff
	for base_dir in fdo-icons-sabayon/*; do
		[[ -d ${base_dir} ]] || \
			die "error, ${base_dir} doesn't exist or is not a directory"
		icon_dir=$(basename "${base_dir}") # example: 128x128
		dest_icon_dir=${icon_dir}
		[[ ${icon_dir} != scalable ]] && \
			dest_icon_dir=${icon_dir/x*} # leave number like "128"

		# under ${base_dir} we have emblems/ and places/
		[[ -d ${base_dir}/emblems ]] || \
			die "error, ${base_dir}/emblems doesn't exist or is not a directory"
		[[ -d ${base_dir}/places ]] || \
			die "error, ${base_dir}/places doesn't exist or is not a directory"

		# emblems
		for myfile in "${base_dir}"/emblems/*; do
			insinto /usr/share/icons/elementary/emblems/"${dest_icon_dir}"
			doins "${myfile}" || die "can't copy ${myfile}!"
			if use monochrome; then
				insinto /usr/share/icons/elementary-mono-dark/emblems/"${dest_icon_dir}"
				doins "${myfile}" || die "can't copy ${myfile}! (2)"
			fi
		done

		# places
		for myfile in "${base_dir}"/places/*; do
			insinto /usr/share/icons/elementary/places/"${dest_icon_dir}"
			doins "${myfile}" || die "can't copy ${myfile}!"
			dist_logo_symlink \
				"${myfile}" \
				"${ED}"usr/share/icons/elementary/places/"${dest_icon_dir}"
			if use monochrome; then
				insinto /usr/share/icons/elementary-mono-dark/places/"${dest_icon_dir}"
				doins "${myfile}" || die "can't copy ${myfile}! (2)"
				dist_logo_symlink \
					"${myfile}" \
					"${ED}"usr/share/icons/elementary-mono-dark/places/"${dest_icon_dir}"
			fi
		done
	done
}

# create symbolic link distributor-logo.{png,…} -> start-here.{png,…}
dist_logo_symlink() {
	local path=$1 # example: /path/start-here.png
	local dest_dir=$2
	local filename=${path##*/}
	[[ $filename = start-here.* ]] || return
	local ext=${filename##*.}
	[[ -z $ext ]] && return
	# remove files like elementary/places/48/distributor-logo.svg
	rm -f "${dest_dir}"/distributor-logo.*
	ln -s "start-here.${ext}" "${dest_dir}/distributor-logo.${ext}" \
		|| die "the command ln -s \"start-here.${ext}\" \"${dest_dir}/distributor-logo.${ext}\" failed!"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
