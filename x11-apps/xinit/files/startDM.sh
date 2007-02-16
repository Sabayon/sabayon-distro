#!/bin/bash
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License, v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xinit/files/startDM.sh,v 1.2 2006/07/01 00:48:30 vapier Exp $
#
# Author: Martin Schlemmer <azarah@gentoo.org>

source /etc/init.d/functions.sh

# We need to source /etc/profile for stuff like $LANG to work
# bug #10190.
source /etc/profile

# Great new Gnome2 feature, AA
# We enable this by default
export GDK_USE_XFT=1

if [[ -e ${svcdir}/options/xdm/service ]] ; then
	retval=0
	EXE=$(<"${svcdir}"/options/xdm/service)

	/sbin/start-stop-daemon --start --quiet --exec ${EXE}
	retval=$?
	# Fix bug #26125 for slower systems
	wait; sleep 2

	if [[ ${retval} -ne 0 ]] ; then
		# there was a error running the DM
		einfo "ERROR: could not start the Display Manager..."
		# make sure we do not have a misbehaving DM
		killall -9 ${EXE##*/}
	fi
fi

# vim:ts=4
