#!/bin/bash

# Generate avahi ebuilds to the provided directory.
# With -v, they will be moved to overlay's dirs.

# example: ./avahi-gen.sh [-f] [-v VERSION] .

#   Copyright 2019 Sławomir Nizio
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

set -e
set -o pipefail

if [[ $1 = -f ]]; then
	force=1
	shift
else
	force=0
fi

if [[ $1 = -v ]]; then
	version=$2
	if [[ -z $version ]]; then
		echo "no argument to -v" >&2
		exit 1
	fi
	shift 2
else
	version=
fi

output_dir=$1

if [[ -z $output_dir ]] || (( $# != 1 )); then
	echo "usage: $0 [-f] OUTPUT_DIR"
	exit 1
fi

dir=$(dirname "$0")

gen() {
	pkg=$1 \
	dir=$2 \
	python -c 'import os; import jinja2; print(jinja2.Environment(loader=jinja2.FileSystemLoader(os.environ["dir"]), trim_blocks=True).get_template("avahi.ebuild.jinja2").render(pkg=os.environ["pkg"]))' | sed '$d'
}

ebuild_file_name() {
	local pkg=$1
	if [[ -z $version ]]; then
		echo "$output_dir/avahi-${pkg:-upstream}.ebuild"
	elif [[ -z $pkg ]]; then
		echo "$output_dir/avahi-upstream.ebuild"
	else
		echo "$output_dir/avahi-$pkg/avahi-$pkg-$version.ebuild"
	fi
}

# "" is upstream by convention in this script
types=( "" base gtk gtk3 mono )

for t in "${types[@]}"; do
	output=$(ebuild_file_name "$t")
	if [[ -e $output ]]; then
		if [[ $force = 1 ]]; then
			echo "removing previous $output"
			rm -f -- "$output"
		else
			echo "$output exists, no -f, aborting." >&2
			exit 1
		fi
	fi
done

for t in "${types[@]}"; do
	output=$(ebuild_file_name "$t")
	echo "processing $output"
	gen "$t" "$dir" > "$output"
done

echo done
echo "note, avahi (meta package) is not covered"
