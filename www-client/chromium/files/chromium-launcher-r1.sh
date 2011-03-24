#!/bin/bash
#
# Copyright (c) 2009 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Let the wrapped binary know that it has been run through the wrapper
export CHROME_WRAPPER="`readlink -f "$0"`"

PROGDIR="`dirname "$CHROME_WRAPPER"`"

case ":$PATH:" in
  *:$PROGDIR:*)
    # $PATH already contains $PROGDIR
    ;;
  *)
    # Append $PROGDIR to $PATH
    export PATH="$PATH:$PROGDIR"
    ;;
esac

# Set the .desktop file name
export CHROME_DESKTOP="chromium-browser-chromium.desktop"

exec -a "chromium-browser" "$PROGDIR/chrome" --extra-plugin-dir=/usr/lib/nsbrowser/plugins "$@"
