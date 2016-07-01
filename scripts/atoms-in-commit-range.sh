#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
	echo atoms-in-commit-range.sh 4d20aafb548c7f9b7ef9a69fa2af37ec9d6312f8..999d41a089f4a74c145b2acecebf80a4eeae18c3 overlay
	exit 1
fi


git diff-tree --name-status -r --no-commit-id ${1} \
| grep -v "^D" \
| sed -r -e 's/^[a-zA-Z0-9]+[[:space:]]*//' -e 's:^([^/]+/[^/]+).*:\1:' \
| sort -u \
| grep -E '^(virtual/|[^/]+-)' \
| awk "{print \$1 \"::${2}\"}"
