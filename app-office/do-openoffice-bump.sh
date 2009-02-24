#!/bin/sh

FROM_PV="3.0.0"
TO_PV="3.0.1"
for item in `find -name openoffice-l10n-*${FROM_PV}*.ebuild`; do

	echo $item
	newfile=${item/${FROM_PV}/${TO_PV}}
	svn cp ${item} ${newfile}

	if [ -z "`echo ${item} | grep meta`" ]; then
		echo "running sed on "${item}
		# edit
		sed -i 's/SRC_URI=".*"/SRC_URI="mirror:\/\/openoffice-extended\/\${PV}rc2\/OOo_\${PV}rc2_20090112_LinuxIntel_langpack_\${MY_LANG}.tar.gz"/' ${newfile}
	fi

	# do manifest
	ebuild ${newfile} manifest

done

