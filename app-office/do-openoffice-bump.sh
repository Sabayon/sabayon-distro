#!/bin/sh

FROM_PV="2.4.1_rc2"
TO_PV="2.4.1"
for item in `find -name openoffice-l10n-*.ebuild`; do

	echo $item
	newfile=${item/${FROM_PV}/${TO_PV}}
	svn cp ${item} ${newfile}

	if [ -z "`echo ${item} | grep meta`" ]; then
		echo "running sed on "${item}
		# edit
		sed -i 's/SRC_URI=".*"/SRC_URI="mirror:\/\/openoffice-extended\/\${PV}rc2\/OOo_\${PV}rc2_20080529_LinuxIntel_langpack_\${MY_LANG}.tar.gz"/' ${newfile}
	fi

	# do manifest
	ebuild ${newfile} manifest

done

