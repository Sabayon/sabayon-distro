#!/bin/bash

# Generate avahi ebuilds to the provided directory.
# example: ./avahi-gen.sh [-f] .

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

types=( "" base gtk gtk3 mono )

for t in "${types[@]}"; do
	output=$output_dir/avahi-${t:-upstream}.ebuild
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
	output=$output_dir/avahi-${t:-upstream}.ebuild
	echo "processing $output"
	gen "$t" "$dir" > "$output"
done

echo done
echo "note, avahi (meta package) is not covered"
