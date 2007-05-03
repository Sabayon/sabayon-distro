#!/bin/bash
#
progname="skype"
progpath="/opt/${progname}/"
progopts="--resources-path ${progpath}"


#Going to "homedir"
cd ${progpath}
skypecmd="${progpath}${progname}"
XMODIFIERS=@im=none QT_IM_MODULE=simple exec ${skypecmd} ${progopts} $@
