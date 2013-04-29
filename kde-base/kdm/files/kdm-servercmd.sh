#!/bin/bash

if [ -e /run/systemd/seats ]; then
	# logind running
	exec /usr/lib/systemd/systemd-multi-seat-x %SERVER_ARGS%
else
	exec %SERVER_CMD%
fi
