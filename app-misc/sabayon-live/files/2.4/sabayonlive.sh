#!/bin/bash

. /sbin/sabayon-functions.sh

CMDLINE=$(cat /proc/cmdline 2> /dev/null)

setup_password() {
    local cmdline_autoscramble_exist=$(echo ${CMDLINE} | grep autoscramble)
    if [ -n "${cmdline_autoscramble_exist}" ]; then
        echo "Autoscrambling root and live user passwords"
        echo root:\`pwgen -s 16\` | chpasswd  > /dev/null 2>&1
        echo ${LIVE_USER}:\`pwgen -s 16\` | chpasswd  > /dev/null 2>&1
    fi
}

setup_x() {
    if systemd_running; then
        [ -x /sbin/gpu-configuration ] && /sbin/gpu-configuration
    else
        while [ -e "/etc/x-setup-configuration-running" ]; do
            sleep 1
        done
    fi
}

setup_settingsd() {
    if [ -e /usr/share/eselect/modules/settingsd.eselect ]; then
        if systemd_running; then
            eselect settingsd set systemd > /dev/null
        elif openrc_running; then
            eselect settingsd set openrc > /dev/null
        fi
    fi
}

setup_desktop() {
    # create LIVE_USER if it does not exist
    sabayon_setup_live_user "${LIVE_USER}" "1000"
    if [ "${?}" = "1" ]; then
        # if user is already available, then setup skel
        # Copy ${LIVE_USER} directory
        rm -rf /home/${LIVE_USER}
        cp /etc/skel /home/${LIVE_USER} -Rp
        chown ${LIVE_USER}:users /home/${LIVE_USER} -R
    fi

    local liveinst_desktop="/usr/share/applications/liveinst.desktop"
    local liveinst_desktop_name="$(basename ${liveinst_desktop})"
    if [ -f "${liveinst_desktop}" ]; then
        [[ -d "/home/${LIVE_USER}/Desktop" ]] || \
            mkdir -p "/home/${LIVE_USER}/Desktop"
        cp "${liveinst_desktop}" "/home/${LIVE_USER}/Desktop"
        chown ${LIVE_USER}:users "/home/${LIVE_USER}/Desktop" -R
        chmod +x "/home/${LIVE_USER}/Desktop/${liveinst_desktop_name}"
        rm -f /etc/skel/Desktop/Anaconda*.desktop \
            /home/${LIVE_USER}/Desktop/Anaconda*.desktop
    fi

    # Disable memory eating services
    rm -f /etc/xdg/autostart/hplip-systray.desktop \
        /etc/xdg/autostart/beagle-search-autostart.desktop \
        /etc/xdg/autostart/tracker*.desktop \
        /etc/xdg/autostart/magneto.desktop \
        /etc/xdg/autostart/beagled-autostart.desktop \
        /usr/share/autostart/magneto.desktop \
        /usr/share/autostart/nepomukserver.desktop

    # Remove broken entries in /etc/mtab
    if [ ! -L /etc/mtab ]; then
        sed -i '/.*newroot.*/d' /etc/mtab
    fi

    # create /overlay, this way df -h won't bitch
    [[ -d "/overlay" ]] || mkdir /overlay

    return 0
}

setup_keymap() {
    local keymap_toset=
    local keymap_toset_model=

    for word in ${CMDLINE}; do
        case ${word} in
            console-setup/layoutcode=*)
                keymap_toset="${word/*=}"
                ;;
            console-setup/modelcode=*)
                keymap_toset_model="-${word/*=}"
                ;;
            KEYMAP=*)
                keymap_toset="${word/*=}"
                ;;
            keymap=*)
                keymap_toset="${word/*=}"
                ;;
            vconsole.keymap=*)
                keymap_toset="${word/*=}"
                ;;
            vconsole.keymap.model=*)
                keymap_toset_model="-${word/*=}"
                ;;
        esac
    done

    if [ -n "${keymap_toset}" ]; then
        aggregated_keymap="${keymap_toset}${keymap_toset_model}"
        /sbin/keyboard-setup-2 "${aggregated_keymap}" all &> /dev/null
        if [ "${?}" = "0" ]; then
            openrc_running && /etc/init.d/keymaps restart --nodeps
            # systemd not needed here, this script runs before vconsole-setup
        fi
    fi
}

setup_locale() {
    for word in ${CMDLINE}; do
        case ${word} in
            locale=*)
                lang_toset="${word/*=}"
                ;;
            LANG=*)
                lang_toset="${word/*=}"
                ;;
            lang=*)
                lang_toset="${word/*=}"
                ;;
        esac
    done
    if [ -n "${lang_toset}" ]; then
        files=(
            "/etc/env.d/02locale"
            "/etc/locale.conf"
        )
        for path in "${files[@]}"; do
            if [ -e "$path" ]; then
                sed -i "s/^LC_ALL=.*/LC_ALL=${lang_toset}.UTF-8/g" \
                    "${path}"
                sed -i "s/^LANG=.*/LANG=${lang_toset}.UTF-8/g" "${path}"
                sed -i "s/^LANGUAGE=.*/LANGUAGE=${lang_toset}.UTF-8/g" \
                    "${path}"
            else
                echo "LC_ALL=${lang_toset}.UTF-8" > "${path}"
                echo "LANG=${lang_toset}.UTF-8" >> "${path}"
                echo "LANGUAGE=${lang_toset}.UTF-8" >> "${path}"
            fi
        done

        sed -i "s/^export LC_ALL=.*/export LC_ALL=${lang_toset}.UTF-8/g" \
            "/etc/profile.env"
        sed -i "s/^export LANG=.*/export LANG=${lang_toset}.UTF-8/g" \
            "/etc/profile.env"
        sed -i "s/^export LANGUAGE=.*/export LANGUAGE=${lang_toset}.UTF-8/g" \
            "/etc/profile.env"

    fi
}


main() {
    . /sbin/sabayon-functions.sh

    # Perform configuration only in live mode
    if ! sabayon_is_live; then
        echo "Skipping Live system configuration"
        return 0
    fi

    setup_settingsd
    setup_desktop
    setup_password
    setup_keymap
    setup_x
    # MOVED HERE TO AVOID RACE CONDITIONS ON WRITING
    # /etc/profile.env variables
    setup_locale
    sabayon_setup_autologin
    sabayon_setup_motd
    sabayon_setup_vt_autologin
    sabayon_setup_oem_livecd
}

main
