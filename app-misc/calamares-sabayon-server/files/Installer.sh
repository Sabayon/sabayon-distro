#!/bin/sh
# Workaround for locales since locale parsing is tricky in calamares
cp -rf /etc/locale.gen.bak /etc/locale.gen
calamares-pkexec
