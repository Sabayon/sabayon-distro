#!/bin/bash

# Install all firefox-l10 packages.

#   Copyright 2014, 2015 Sławomir Nizio
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# The packages are expected to be in the same directory this script is in.
# It exports LINGUAS with all of the possible languages to make sure all
# of the language packages are installed properly (so that it does not matter
# what is set in make.conf). Note that it may not work with pkgcore!

# Options: --pkgcore - use pkgcore (but see note above),
#          -- PM_OPTS - pass options to the package manager (default: --ask).

e() {
	echo "$*" >&2
	exit 1
}

inst_cmd() {
	if [[ ${use_pkgcore} = yep ]]; then
		time pmerge "${pm_opts[@]}" "$@"
	else
		time emerge "${pm_opts[@]}" "$@"
	fi
}

determine_ver() {
	local pkgname=$1
	local ebuild
	for ebuild in "${pkgname}/${pkgname}"-*.ebuild; do
		ver=${ebuild#${pkgname}/${pkgname}-}
		ver=${ver%.ebuild}
		break
	done
}

dir=$(dirname "$0")

cd "${dir}" || e "cd $dir failed"
echo "working in ${PWD}"

packages=()
LINGUAS=""

ver=

use_pkgcore=no
pm_opts=( --ask )

while (( $# )); do
	if [[ $1 = --pkgcore ]]; then
		use_pkgcore=yep
		shift
	elif [[ $1 = -- ]]; then
		shift
		pm_opts=( "$@" )
		break
	else
		echo "I don't know what option '$1' means." >&2
		exit 1
	fi
done

for p in firefox-l10n-*; do
	if [[ ! -e ${p} ]]; then
		e "${p} does not exist - no packages in the current directory?"
	fi
	packages+=( ${p} )
	lang=${p#firefox-l10n-}
	lang=${lang//-/_}
	LINGUAS+=" ${lang}"

	# determine version from the first ebuild
	[[ -z ${ver} ]] && determine_ver "${p}"
done

export LINGUAS

inst_cmd "${packages[@]}"

echo "======="
# Version is "assumed" because it's determined using only one ebuild in the
# overlay (versions shouldn't differ, though)
echo "Listing Firefox language packages that are different than the assumed"
echo "version ${ver}. If any are found, condider uninstalling them!"
echo
qlist -ICv www-client/firefox | while read line; do
	[[ ${line} = *"-${ver}" ]] || echo "${line}"
done
echo
echo "Listing done."
echo "======="
