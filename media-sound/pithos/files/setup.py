# replacement for setup.py for pithos as the included one is.. less than ideal

from os import walk
from glob import glob
from os.path import join
from setuptools import setup, find_packages

DATA_DIR = '/usr/share/pithos/'
ICON_DIR = '/usr/share/icons/hicolor/'
APP_DIR = '/usr/share/applications'

datadir = 'data'
datadirs = ['ui', 'media']
icondir = 'data/icons'
bindir = 'bin'

datafiles = [[(join(DATA_DIR, root.partition(datadir)[2].lstrip('/')), [join(root, f) for f in files])
             for root, dirs, files in walk(join(datadir, data))][0] for data in datadirs]

datafiles += ([(join(ICON_DIR, root.partition(icondir)[2].lstrip('/')), [join(root, f) for f in files])
               for root, dirs, files in walk(icondir)])

datafiles += [(APP_DIR, glob('*.desktop'))]

setup(
    name='pithos',
    version='0.3',
    ext_modules=[],
    license='GPL-3',
    author='Kevin Mehall',
    author_email='km@kevinmehall.net',
    description='Pandora.com client for the GNOME desktop',
    packages=find_packages(),
    url='https://launchpad.net/pithos',
    data_files=datafiles,
    scripts=glob('bin/*'),
)
