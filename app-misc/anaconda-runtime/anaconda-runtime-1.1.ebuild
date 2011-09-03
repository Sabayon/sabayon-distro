# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="2"

DESCRIPTION="Anaconda Installer runtime meta-package (containing all the runtime dependencies)"
SRC_URI=""

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"

DEPEND=""
RDEPEND="app-admin/system-config-date
	app-admin/system-config-users
	>=app-misc/sabayonlive-tools-2.1.1
	>=app-misc/sabayon-version-5-r1
	app-text/xmlto
	dev-libs/elfutils
	dev-libs/libnl
	dev-libs/libxml2[python]
	dev-python/pyblock
	dev-python/python-cryptsetup
	dev-python/python-meh
	dev-python/python-nss
	dev-python/python-report
	dev-python/urlgrabber
	dev-util/pykickstart
	net-misc/curl
	net-misc/dhcp
	net-misc/fcoe-utils
	>=net-misc/networkmanager-0.7.2
	sys-apps/dmidecode
	sys-apps/language-configuration-helpers
	>=sys-boot/grub-1.98
	sys-boot/makebootfat
	sys-fs/btrfs-progs
	sys-fs/cryptsetup
	sys-fs/dosfstools
	sys-fs/e2fsprogs
	sys-fs/jfsutils
	sys-fs/mdadm
	sys-fs/multipath-tools
	|| ( sys-fs/ntfsprogs sys-fs/ntfs3g[ntfsprogs] )
	sys-fs/reiserfsprogs
	sys-fs/squashfs-tools
	sys-fs/xfsprogs
	sys-libs/cracklib
	sys-libs/libuser
	sys-libs/slang"
