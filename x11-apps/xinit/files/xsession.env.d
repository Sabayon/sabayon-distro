# /etc/env.d/90xsession

# XSESSION is a new variable to control what window manager to start
# default with X if run with xdm, startx or xinit.  The default behavior
# is to look in /etc/X11/Sessions/ and run the script in matching the
# value that XSESSION is set to.  The support scripts are smart enough to
# look in all bin directories if it cant find a match in /etc/X11/Sessions/,
# so setting it to "enlightenment" can also work.  This is basically used
# as a way for the system admin to configure a default system wide WM,
# allthough it will work if the user export XSESSION in his .bash_profile, etc.
#
# NOTE:  1) this behaviour is overridden when a ~/.xinitrc exists, and startx
#           is called.
#        2) even if ~/.xsession exists, if XSESSION can be resolved, it will
#           be executed rather than ~/.xsession, else KDM breaks ...
#
# Defaults depending on what you install currently include:
#
# Gnome - will start gnome-session
# kde-<version> - will start startkde (look in /etc/X11/Sessions/)
# Xfce4 - will start a XFCE4 session
# Xsession - will start a terminal and a few other nice apps

#XSESSION="Gnome"

