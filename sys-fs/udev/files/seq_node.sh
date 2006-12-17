#!/bin/bash
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Author: Martin Schlemmer <azarah@gentoo.org>
# $Header: /var/cvsroot/gentoo-x86/sys-fs/udev/files/seq_node.sh,v 1.2 2006/07/05 09:06:06 azarah Exp $

# Stupid little script to emulate the depriciated '%e' directive of udev.
# I am not sure why its supposidly broken, so this might need fixing if it
# have the same issue as '%e'.
#
# Usage: seq_node.sh <root> <kernel name> <wanted node>
#
#  root        - root of udev (usuall /dev)
#  kernel name - kernel name for device
#  wanted node - needed free node
#
# Example: seq_node.sh %r %k cdrom
#
#  If called as above, it should return 'cdrom' if free, else 'cdrom1',
#  'cdrom2', etc.  It also checks if an existing node was already created for
#  the specific 'kernel name'.
#

root=$1
kname=$2
node=$3

count=0
new_node=${node}

if [[ -z ${root} || -z ${kname} || -z ${node} ]] ; then
	exit 1
fi

get_filename() {
	local symlink=$1
	local filename=

	if [[ ! -L ${root}/${symlink} ]] ; then
		echo "${symlink}"
		return 0
	fi

	if type -p readlink &>/dev/null ; then
		filename=$(readlink "${root}/${symlink}")
	else
		filename=$(perl -e "print readlink(\"${root}/${symlink}\")" 2>/dev/null)
	fi

	echo "${filename}"
}

while [[ -e "${root}/${new_node}" || -L "${root}/${new_node}" ]] ; do
	# Check if existing node is the same as the kname we are looking
	# for a new node, and return that instead
	if [[ $(get_filename "${new_node}") == "${kname}" ]] ; then
		break
	fi

	let "count += 1"
	new_node="${node}${count}"
done

echo "${new_node}"

exit 0

