#!/usr/bin/env python3
# encoding: utf-8
# === This file is part of Calamares - <http://github.com/calamares> ===
#
#   Calamares is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   Calamares is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Calamares. If not, see <http://www.gnu.org/licenses/>.

import os
import subprocess

import libcalamares

import shutil

def run():
    """ Sabayon Calamares Hack """

    # Grub set background
    libcalamares.utils.chroot_call(['mkdir', '-p', '/boot/grub/'])
    libcalamares.utils.chroot_call(['cp', '-f', '/usr/share/grub/default-splash.png', '/boot/grub/default-splash.png'])


    return None

