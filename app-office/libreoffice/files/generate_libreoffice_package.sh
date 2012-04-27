#!/bin/bash

die() {
	echo "${1}"
	exit 1
}

VERSION="3.4.5.2"

# first the default subset of useflags
IUSES_BASE="bash-completion binfilter branding dbus graphite gstreamer gtk python templates webdav odk"

# now for the options
IUSES_J="java"
IUSES_NJ="-java"
IUSES_G="gnome eds"
IUSES_NG="-gnome -eds"
IUSES_K="kde"
IUSES_NK="-kde"

mkdir -p /etc/portage/package.use/

# compile the flavor
echo "Base"
echo "app-office/libreoffice ${IUSES_BASE} ${IUSES_NJ} ${IUSES_NG} ${IUSES_NK}" > /etc/portage/package.use/libreo
emerge -v =libreoffice-${VERSION} || die "emerge failed"
quickpkg libreoffice --include-config=y
cp /usr/portage/packages/app-office/libreoffice-${VERSION}.tbz2 ./libreoffice-base-${VERSION}.tbz2  || die "Copying package failed"

echo "Base - java"
echo "app-office/libreoffice ${IUSES_BASE} ${IUSES_J} ${IUSES_NG} ${IUSES_NK}" > /etc/portage/package.use/libreo
emerge -v =libreoffice-${VERSION} || die "emerge failed"
quickpkg libreoffice --include-config=y
cp /usr/portage/packages/app-office/libreoffice-${VERSION}.tbz2 ./libreoffice-base-java-${VERSION}.tbz2  || die "Copying package failed"

# kde flavor
echo "KDE"
echo "app-office/libreoffice ${IUSES_BASE} ${IUSES_NJ} ${IUSES_NG} ${IUSES_K}" > /etc/portage/package.use/libreo
emerge -v =libreoffice-${VERSION} || die "emerge failed"
quickpkg libreoffice --include-config=y
cp /usr/portage/packages/app-office/libreoffice-${VERSION}.tbz2 ./libreoffice-kde-${VERSION}.tbz2  || die "Copying package failed"

echo "KDE - java"
echo "app-office/libreoffice ${IUSES_BASE} ${IUSES_J} ${IUSES_NG} ${IUSES_K}" > /etc/portage/package.use/libreo
emerge -v =libreoffice-${VERSION} || die "emerge failed"
quickpkg libreoffice --include-config=y
cp /usr/portage/packages/app-office/libreoffice-${VERSION}.tbz2 ./libreoffice-kde-java-${VERSION}.tbz2  || die "Copying package failed"

# gnome flavor
echo "Gnome"
echo "app-office/libreoffice ${IUSES_BASE} ${IUSES_NJ} ${IUSES_G} ${IUSES_NK}" > /etc/portage/package.use/libreo
emerge -v =libreoffice-${VERSION} || die "emerge failed"
quickpkg libreoffice --include-config=y
cp /usr/portage/packages/app-office/libreoffice-${VERSION}.tbz2 ./libreoffice-gnome-${VERSION}.tbz2  || die "Copying package failed"

echo "Gnome -java"
echo "app-office/libreoffice ${IUSES_BASE} ${IUSES_J} ${IUSES_G} ${IUSES_NK}" > /etc/portage/package.use/libreo
emerge -v =libreoffice-${VERSION} || die "emerge failed"
quickpkg libreoffice --include-config=y
cp /usr/portage/packages/app-office/libreoffice-${VERSION}.tbz2 ./libreoffice-gnome-java-${VERSION}.tbz2  || die "Copying package failed"


