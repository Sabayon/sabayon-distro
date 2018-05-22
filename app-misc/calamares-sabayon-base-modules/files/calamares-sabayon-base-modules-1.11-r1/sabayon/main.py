#!/usr/bin/env python3
# encoding: utf-8

import os
import subprocess
import shutil
import libcalamares


def set_grub_background():
    libcalamares.utils.target_env_call(['mkdir', '-p', '/boot/grub/'])
    libcalamares.utils.target_env_call(
        ['cp', '-f', '/usr/share/grub/default-splash.png',
         '/boot/grub/default-splash.png'])


def setup_locales(root_install_path):
    locale = libcalamares.globalstorage.value('lcLocale')
    if not locale:
        locale = 'en_US.UTF-8'
    locale_conf_path = os.path.join(root_install_path, 'etc/env.d/02locale')
    locale = locale.split(' ')[0]
    with open(locale_conf_path, 'w') as locale_conf:
        locale_conf.write('LANG={!s}\n'.format(locale))
        locale_conf.write('LANGUAGE={!s}\n'.format(locale))
        locale_conf.write('LC_NUMERIC={!s}\n'.format(locale))
        locale_conf.write('LC_TIME={!s}\n'.format(locale))
        locale_conf.write('LC_MONETARY={!s}\n'.format(locale))
        locale_conf.write('LC_MEASUREMENT={!s}\n'.format(locale))
        locale_conf.write('LC_MEASUREMENT={!s}\n'.format(locale))
        locale_conf.write('LC_COLLATE={!s}\n'.format('C'))
    libcalamares.utils.target_env_call(['env-update'])


def setup_audio(root_install_path):
    asound_state_filename = 'asound.state'
    asound_state_orig = '/etc/' + asound_state_filename
    if os.path.isfile(asound_state_orig) and os.access(asound_state_orig,
                                                       os.R_OK):
        asound_state_alsa_dest_1 = root_install_path + '/etc/'
        asound_state_alsa_dest_2 = root_install_path + '/var/lib/alsa/'
        os.makedirs(asound_state_alsa_dest_1, mode=0o755, exist_ok=True)
        os.makedirs(asound_state_alsa_dest_2, mode=0o755, exist_ok=True)
        shutil.copy2(asound_state_orig, asound_state_alsa_dest_1)
        shutil.copy2(asound_state_orig, asound_state_alsa_dest_2)


def setup_xorg(root_install_path):
    # Copy current xorg.conf
    live_xorg_conf = '/etc/X11/xorg.conf'
    if not os.path.isfile(live_xorg_conf):
        return
    xorg_conf = root_install_path + live_xorg_conf
    if os.path.isfile(xorg_conf):
        shutil.move(xorg_conf, xorg_conf + '.original')
    shutil.copy2(live_xorg_conf, xorg_conf)


def configure_services(root_install_path):
    def is_virtualbox():
        """
        Return a virtualization environment identifier using
        systemd-detect-virt. This code is systemd only.
        """
        proc = subprocess.run(['/usr/bin/systemd-detect-virt'],
                              stdout=subprocess.PIPE)
        exit_st = proc.returncode
        outcome = proc.stdout
        if exit_st == 0:
            return outcome.decode().strip() == 'oracle'

    if is_virtualbox():
        libcalamares.utils.target_env_call(
            ['systemctl', '--no-reload', 'enable',
             'virtualbox-guest-additions.service'])
    else:
        libcalamares.utils.target_env_call(
            ['systemctl', '--no-reload', 'disable',
             'virtualbox-guest-additions.service'])
        libcalamares.utils.target_env_call(
            ['rm', '-rf', '/etc/xdg/autostart/vboxclient.desktop'])

    install_data_dir = os.path.join(root_install_path, 'install-data')
    if os.path.isdir(install_data_dir):
        shutil.rmtree(install_data_dir, True)


def remove_proprietary_drivers(root_install_path):
    def get_opengl():
        if root_install_path is None:
            oglprof = os.getenv('OPENGL_PROFILE')
            if oglprof:
                return oglprof
        ogl_path = '' if root_install_path is None else str(
            root_install_path) + '/etc/env.d/000opengl'
        if os.path.isfile(ogl_path) and os.access(ogl_path, os.R_OK):
            with open(ogl_path, 'r') as f:
                cont = [x.strip() for x in f.readlines() if \
                        x.strip().startswith('OPENGL_PROFILE')]
                if cont:
                    xprofile = cont[-1]
                    if 'nvidia' in xprofile:
                        return 'nvidia'
                    elif 'ati' in xprofile:
                        return 'ati'
        return 'xorg-x11'

    bb_enabled = os.path.exists('/tmp/.bumblebee.enabled')

    xorg_x11 = get_opengl() == 'xorg-x11'

    if xorg_x11 and not bb_enabled:
        libcalamares.utils.target_env_call(['rm', '-f', '/etc/env.d/09ati'])
        libcalamares.utils.target_env_call(
            ['rm', '-rf', '/usr/lib/opengl/ati'])
        libcalamares.utils.target_env_call(
            ['rm', '-rf', '/usr/lib/opengl/nvidia'])
        libcalamares.utils.target_env_call(
            ['equo', 'rm', '--nodeps', '--norecursive', 'ati-drivers'])
        libcalamares.utils.target_env_call(
            ['equo', 'rm', '--nodeps', '--norecursive', 'ati-userspace'])
        libcalamares.utils.target_env_call(
            ['equo', 'rm', '--nodeps', '--norecursive', 'nvidia-settings'])
        libcalamares.utils.target_env_call(
            ['equo', 'rm', '--nodeps', '--norecursive', 'nvidia-drivers'])
        libcalamares.utils.target_env_call(
            ['equo', 'rm', '--nodeps', '--norecursive', 'nvidia-userspace'])

    # bumblebee support
    if bb_enabled:
        libcalamares.utils.target_env_call(
            ['systemctl', '--no-reload', 'enable', 'bumblebeed.service'])

        udev_bl = root_install_path + '/etc/modprobe.d/bbswitch-blacklist.conf'
        with open(udev_bl, 'w') as bl_f:
            bl_f.write("""
            # Added by the Sabayon Installer to avoid a race condition
            # between udev loading nvidia.ko or nouveau.ko and bbswitch,
            # which wants to manage the driver itself.
            blacklist nvidia
            blacklist nouveau
            """)


def setup_nvidia_legacy(root_install_path):
    running_file = '/lib/nvidia/legacy/running'
    drivers_dir = '/install-data/drivers'
    if not os.path.isfile(running_file):
        return
    if not os.path.isdir(drivers_dir):
        return

    with open(running_file) as f:
        nv_ver = f.readline().strip()
        matches = [
            '=x11-drivers/nvidia-drivers-' + nv_ver + '*',
            '=x11-drivers/nvidia-userspace-' + nv_ver + '*',
        ]
        files = [
            'x11-drivers:nvidia-drivers-' + nv_ver,
            'x11-drivers:nvidia-userspace-' + nv_ver,
        ]

    libcalamares.utils.target_env_call(
        ['equo', 'rm', '--nodeps', '--norecursive', 'nvidia-drivers'])
    libcalamares.utils.target_env_call(
        ['equo', 'rm', '--nodeps', '--norecursive', 'nvidia-userspace'])

    # install new
    available_packages_files = os.listdir(drivers_dir)
    packages = [os.path.join(drivers_dir, file) for file in
                available_packages_files if
                any(file.startswith(target_file) for target_file in files)]

    completed = True

    for pkg_filepath in packages:

        pkg_file = os.path.basename(pkg_filepath)
        if not os.path.isfile(pkg_filepath):
            continue

        dest_pkg_filepath = os.path.join(
            root_install_path + '/', pkg_file)
        shutil.copy2(pkg_filepath, dest_pkg_filepath)

        _completed = 0 == libcalamares.utils.target_env_call(
            ['equo', 'install', '--nodeps', '--norecursive',
             dest_pkg_filepath])

        try:
            os.remove(dest_pkg_filepath)
        except OSError:
            pass

        if not _completed:
            libcalamares.utils.debug(
                'An issue occured while installing {}'.format(pkg_file)
            )
            libcalamares.utils.debug(
                'Legacy Nvidia Drivers installation failed')
            completed = False
            break

    if completed:
        # mask all the nvidia-drivers, this avoids having people
        # updating their drivers resulting in a non working system
        mask_file = os.path.join(root_install_path + '/',
                                 'etc/entropy/packages/package.mask')
        unmask_file = os.path.join(root_install_path + '/',
                                   'etc/entropy/packages/package.unmask')

        if os.access(mask_file, os.W_OK) and os.path.isfile(mask_file):
            with open(mask_file, 'aw') as f:
                f.write('\n# added by the Sabayon Installer\n')
                f.write('x11-drivers/nvidia-drivers\n')
                f.write('x11-drivers/nvidia-userspace\n')

        if os.access(unmask_file, os.W_OK) and os.path.isfile(unmask_file):
            with open(unmask_file, 'aw') as f:
                f.write('\n# added by the Sabayon Installer\n')
                for dep in matches:
                    f.write('%s\n' % (dep,))

    libcalamares.utils.target_env_call(
        ['eselect', 'opengl', 'set', 'xorg-x11', '&>', '/dev/null'])
    libcalamares.utils.target_env_call(
        ['eselect', 'opengl', 'set', 'nvidia', '&>', '/dev/null'])


def run():
    """ Sabayon Calamares Post-install module """
    # Get install path
    install_path = libcalamares.globalstorage.value('rootMountPoint')
    set_grub_background()
    setup_locales(install_path)
    setup_audio(install_path)
    setup_xorg(install_path)
    configure_services(install_path)
    remove_proprietary_drivers(install_path)
    setup_nvidia_legacy(install_path)
    libcalamares.utils.target_env_call(['env-update'])

    return None
