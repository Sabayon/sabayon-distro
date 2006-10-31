# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="SabayonLinux NTFS HAL Policy files"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND=">=sys-apps/hal-0.5.7.1-r1"


src_unpack () {

        cd ${WORKDIR}
        cp ${FILESDIR}/99-ntfs-policy.fdi . -p
	cp /usr/share/hal/scripts/hal-system-storage-mount . -p

}

src_install () {

	cd ${WORKDIR}
	insinto /usr/share/hal/fdi/policy/10osvendor/
	doins 99-ntfs-policy.fdi

	# Patching hal-system-storage-mount
	if [ -z "`cat hal-system-storage-mount | grep '$MOUNTOPTIONS,$HAL_PROP_VOLUME_MOUNT_OPTION'`" ]; then
	   einfo "Patching hal-system-storage-mount"
	   sed -i '/# echo "options =/ s/#/MOUNTOPTIONS="$MOUNTOPTIONS,$HAL_PROP_VOLUME_MOUNT_OPTION"\n\n#/' hal-system-storage-mount
	fi

	exeinto /usr/share/hal/scripts/
	doexe hal-system-storage-mount

}
