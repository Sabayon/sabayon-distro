#!/bin/bash

. /sbin/sabayon-functions.sh

if sabayon_is_gui_install; then
	sabayon_setup_autologin
	sabayon_setup_gui_installer
fi
