#!/bin/bash
# Author: geaaru@sabayonlinux.org
# Description: Remove old ebuild for a specific slot.

prefix=${prefix:-sabayon-sources}
slot=${slot:-4.4}
n_left=3

versions=($(ls -1 | grep --color=none ${prefix}-${slot} | cut -d'-' -f 3 | sed  -e 's/.ebuild//g'))

for ((i=0; i<$((${#versions[@]}-${n_left})); i++)) ; do rm ${prefix}-${versions[$i]}.ebuild -v ; done

ebuild ${prefix}-${versions[$((${#versions[@]}-1))]}.ebuild digest

