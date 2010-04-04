#!/bin/sh
TARGET=hbaapi_build_2.2.tar.gz
./bootstrap.sh
tar --exclude build.sh --exclude .git --exclude ${TARGET} -zcf ${TARGET} .
