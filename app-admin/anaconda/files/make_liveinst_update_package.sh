#!/bin/sh

if [ -z "${1}" ]; then
	echo "syntax ${0} <ebuild>"
	exit 1
fi
eb="${1}"
eb_name=$(basename "${eb}")
tbz2_name="${eb_name/.ebuild/.tbz2}"
tar_file="py${eb_name/.ebuild}.tar.bz2"
current_dir="${PWD}"

ebuild "${eb}" clean package || exit 1
tmp_dir="$(mktemp -d)"

cp /usr/portage/packages/app-admin/"${tbz2_name}" "${tmp_dir}" || exit 1
cd "${tmp_dir}" || exit 1
tar xvf "${tbz2_name}" || exit 1

( cd usr/lib*/python*/site-packages && tar cjf \
	"${current_dir}/${tar_file}" pyanaconda ) || exit 1
( cd "${current_dir}" && md5sum "${tar_file}" > "${tar_file}.md5" ) || exit 1

echo "created ${tar_file} and ${tar_file}.md5 in this directory"
