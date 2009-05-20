#!/bin/sh

FROM_PV="3.0.1"
TO_PV="3.1.0"
for item in `find -name openoffice-l10n-*${FROM_PV}*.ebuild`; do

	echo $item
	newfile=${item/${FROM_PV}/${TO_PV}}
	cp ${item} ${newfile}

	if [ -z "`echo ${item} | grep meta`" ]; then
		echo "running sed on "${item}
		# edit
		sed -i 's/SRC_URI=".*"/SRC_URI="mirror:\/\/openoffice-extended\/\${PV}rc2\/OOo_\${PV}rc2_20090427_LinuxIntel_langpack_\${MY_LANG}.tar.gz"/' ${newfile}
	fi

	git add ${newfile}

	# do manifest
	ebuild ${newfile} manifest

done

