#!/sbin/runscript
# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License, v2
# $Header: $

# This file (/etc/init.d/lxdm) is basically a mash-up of 
# /etc/init.d/xdm, /etc/X11/startDM.sh and /usr/sbin/lxdm 
# customized for lxdm.
#
# The /etc/init.d/xdm init script expects lxdm to run as a
# daemon (as gdm and kdm do).  However, lxdm runs until exit.
#
# If configured to launch from xdm, using /etc/conf.d/xdm, the
# init script will hang waiting for the daemon to launch.
# However, lxdm runs until it is exited.

# Original xdm notes follow:

# This is here to serve as a note to myself, and future developers.
#
# Any Display manager (gdm,kdm,xdm) has the following problem:  if
# it is started before any getty, and no vt is specified, it will
# usually run on vt2.  When the getty on vt2 then starts, and the
# DM is already started, the getty will take control of the keyboard,
# leaving us with a "dead" keyboard.
#
# Resolution: add the following line to /etc/inittab
#
#  x:a:once:/etc/X11/startDM.sh
#
# and have /etc/X11/startDM.sh start the DM in daemon mode if
# a lock is present (with the info of what DM should be started),
# else just fall through.
#
# How this basically works, is the "a" runlevel is a additional
# runlevel that you can use to fork processes with init, but the
# runlevel never gets changed to this runlevel.  Along with the "a"
# runlevel, the "once" key word means that startDM.sh will only be
# run when we specify it to run, thus eliminating respawning
# startDM.sh when "xdm" is not added to the default runlevel, as was
# done previously.
#
# This script then just calls "telinit a", and init will run
# /etc/X11/startDM.sh after the current runlevel completes (this
# script should only be added to the actual runlevel the user is
# using).
#
# Martin Schlemmer
# aka Azarah
# 04 March 2002

depend() {
	need localmount

	# this should start as early as possible
	# we can't do 'before *' as that breaks it
	# (#139824) Start after ypbind and autofs for network authentication
	# (#145219 #180163) Could use lirc mouse as input device
	# (#70689 comment #92) Start after consolefont to avoid display corruption
	# (#291269) Start after quota, since some dm need readable home
	after bootmisc consolefont modules netmount
	after readahead-list ypbind autofs openvpn gpm lircmd
	after quota
	before alsasound

	# Start before X
	use consolekit xfs
}

setup_dm() {
	local MY_XDM="$(echo "${DISPLAYMANAGER}" | tr '[:upper:]' '[:lower:]')"

	# Load our root path from profile.env
	# Needed for kdm
	PATH="${PATH}:$(. /etc/profile.env; echo "${ROOTPATH}")"

	EXE=/usr/sbin/lxdm-binary
	PIDFILE=/var/run/lxdm.pid

	if ! [ -x "${EXE}" ]; then
		echo "ERROR: LXDM DISPLAYMANAGER misconfiguration!"
		eend 255
	fi
}

# Check to see if something is defined on our VT
vtstatic() {
	if [ -e /etc/inittab ] ; then
		grep -Eq "^[^#]+.*\<tty$1\>" /etc/inittab
	elif [ -e /etc/ttys ] ; then
		grep -q "^ttyv$(($1 - 1))" /etc/ttys
	else
		return 1
	fi
}

start() {
	local EXE= NAME= PIDFILE=
	setup_dm

	if [ -f /etc/.noxdm ] ; then
		einfo "Skipping ${EXE}, /etc/.noxdm found"
		rm /etc/.noxdm
		return 0
	fi

	ebegin "Setting up ${EXE##*/}"

	# save the prefered DM
	save_options "service" "${EXE}"
	save_options "name"    "${NAME}"
	save_options "pidfile" "${PIDFILE}"

	if [ -n "${CHECKVT-y}" ] ; then
		if vtstatic "${CHECKVT:-7}" ; then
			if [ -x /sbin/telinit ] && [ "${SOFTLEVEL}" != "BOOT" ] && [ "${RC_SOFTLEVEL}" != "BOOT" ] ; then
				ewarn "Something is already defined on VT ${CHECKVT:-7}, will start X later"
				telinit a >/dev/null 2>/dev/null
				return 0
			else
				eerror "Something is already defined on VT ${CHECKVT:-7}, not starting"
				return 1
			fi
		fi
	fi

	# Incorporated from /etc/X11/startDM.sh

	# We need to source /etc/profile for stuff like $LANG to work
	# bug #10190.
	. /etc/profile

	. /etc/init.d/functions.sh

	# baselayout-1 compat
	if ! type get_options >/dev/null 2>/dev/null ; then
	        [ -r "${svclib}"/sh/rc-services.sh ] && . "${svclib}"/sh/rc-services.sh
	fi

	export SVCNAME=lxdm
	EXEC="$(get_options service)"
	NAME="$(get_options name)"
	PIDFILE="$(get_options pidfile)"

	# End section incorporated from /etc/X11/startDM.sh


	# Incorporated from /usr/sbin/lxdm

	[ -f /etc/sysconfig/i18n ] && . /etc/sysconfig/i18n

	if [ -z "$LANG" -a -e /etc/sysconfig/language ]; then
        	. /etc/sysconfig/language
	        if [ -n "$RC_LANG"]; then
        	        LANG=$RC_LANG
	        fi
	fi

	if [ -n "$LANG" ]; then
        	export LANG
	fi

	[ -f /etc/sysconfig/desktop ] && . /etc/sysconfig/desktop
	[ -f /etc/sysconfig/windowmanager ] && . /etc/sysconfig/windowmanager

	if [ -n "$DEFAULT_WM" ]; then
	        PREFERRED=$DEFAULT_WM
	fi

	if [ -n "$DESKTOP" ]; then
	        export DESKTOP
	fi

	if [ -n "$PREFERRED" ]; then
	        export PREFERRED
	fi

	# End section imported from /usr/sbin/lxdm script.


	start-stop-daemon --start --background --exec ${EXEC} \
	${NAME:+--name} ${NAME} ${PIDFILE:+--pidfile} ${PIDFILE} || \
	eerror "ERROR: could not start the LXDM Display Manager"

	eend 0
}

stop() {
	local retval=0
	local curvt=
	if [ -t 0 ] ; then
		if type fgconsole >/dev/null 2>/dev/null ; then
			curvt="$(fgconsole 2>/dev/null)"
		else
			curvt="$(tty)"
			case "${curvt}" in
				/dev/ttyv[0-9]*) curvt="${curvt#/dev/ttyv*}" ;;
				*) curvt= ;;
			esac
		fi
	fi
	local myexe="$(get_options "service")"
	local myname="$(get_options "name")"
	local mypidfile="$(get_options "pidfile")"
	local myservice=${myexe##*/}

	[ -z "${myexe}" ] && return 0

	ebegin "Stopping ${myservice}"

	if start-stop-daemon --quiet --test --stop --exec "${myexe}" ; then
		start-stop-daemon --stop --exec "${myexe}" --retry TERM/5/TERM/5 \
			${mypidfile:+--pidfile} ${mypidfile} \
			${myname:+--name} ${myname}
		retval=$?
	fi

	# switch back to original vt
	if [ -n "${curvt}" ] ; then
		if type chvt >/dev/null 2>/dev/null ; then
			chvt "${curvt}"
		else
			vidcontrol -s "$((${curvt} + 1))"
		fi
	fi

	eend ${retval} "Error stopping ${myservice}"
	return ${retval}
}

# vim: set ts=4 :
