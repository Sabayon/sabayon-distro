#!/bin/bash

ver="${1}"

if [ -z "${ver}" ]; then
    echo "${0} <ver>" >&2
    exit 1
fi

for libre in libreoffice-l10n-*; do
    pushd "${libre}" || exit 1
    git rm "${libre}"-${ver}.ebuild
    ebuild "$(ls -1 *.ebuild | head -n 1)" manifest
    popd
done
