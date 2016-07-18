# [![Build Status](https://travis-ci.org/Sabayon/sabayon-distro.svg?branch=master)](https://travis-ci.org/Sabayon/sabayon-distro) Sabayon-distro overlay

This is a Gentoo overlay that contains ebuilds that are Sabayon specific and thus are not upstreamable.

If you are submitting a pull request or committing keep in mind:

* If the ebuild/fixes you are submitting are already available in layman, the correct place is [community-repositories](https://github.com/Sabayon/community-repositories)
* If the ebuild/fixes is generic and can be applied to Gentoo (e.g. optimizations, fixes) the correct place is [sabayon overlay](https://github.com/Sabayon/for-gentoo)

Here goes:

* ebuilds that are developed for Sabayon
* ebuilds that are forked from Gentoo and customized for Sabayon, thus not upstreamable

# Layman

This overlay is available in layman:

    layman -a sabayon-distro
