#!/bin/bash

if [ -e /run/systemd/seats ]; then
	# logind running
	exec /usr/lib/systemd/systemd-multi-seat-x
else
	exec %SERVER_CMD%
fi
