#!/bin/bash

DIR=$(realpath $(dirname "$0"))
cd "${DIR}"
exec java -jar "${DIR}/frd.jar" "$@"
