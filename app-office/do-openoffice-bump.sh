#!/bin/sh

FROM_PV="3.1.1"
TO_PV="3.2.0"
FAILED_LANGS=""
DONE_LANGS=""
for item in `find -name openoffice-l10n-*${FROM_PV}*.ebuild`; do

	echo $item
	newfile=${item/${FROM_PV}/${TO_PV}}
	cp ${item} ${newfile}

	if [ -z "`echo ${item} | grep meta`" ]; then
		echo "running sed on "${item}
		# edit
		sed -i 's/SRC_URI=".*"/SRC_URI="mirror:\/\/openoffice-extended\/\${PV}rc5\/OOo_\${PV}rc5_20100203_LinuxIntel_langpack_\${MY_LANG}.tar.gz"/' ${newfile}
	fi

	# do manifest
	ebuild "${newfile}" manifest
	if [ "$?" != "0" ]; then
		FAILED_LANGS="${FAILED_LANGS} ${newfile}"
		rm "${newfile}"
	else
		DONE_LANGS="${DONE_LANGS} ${newfile}"
		git add "${newfile}"
	fi

done

echo "FAILED => ${FAILED_LANGS}"
echo "DONE => ${DONE_LANGS}"
