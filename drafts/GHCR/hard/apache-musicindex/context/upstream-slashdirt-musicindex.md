# mod_musicindex upstream (hacks.slashdirt.org)

Source URL(s) + date: http://hacks.slashdirt.org/sw/musicindex/ (fetched 2026-11-27). Original `http://hacks.slashdirt.org/musicindex` returned 404 (Apache 2.4.71 Debian); the `/sw/musicindex/` link from the site home page was used as the alternative.

## What it is
- mod_musicindex: Apache module (C), alternative to Perl Apache::MP3.
- Displays directories of MP3, FLAC, Ogg Vorbis, MP4/AAC; sorting, streaming/download, playlists, search, RSS and podcast feeds, multiple CSS, archive downloads.
- Languages: EN, FR, DE, IT, NL, pt-BR. Works on Linux, BSD, macOS, Solaris.
- License: LGPLv2.1.
- Last release on page: 1.4.1 (page last modified 26 Oct 2014).

## Install/build
- Source tarball and INSTALL/README/UPGRADING/ChangeLog linked from the page (not fetched; follow-up pages not read).
- Distro packages are the practical route: see ubuntu-packages-musicindex.md.

## Gotchas
- Upstream site is plain HTTP; use the Ubuntu package for the build rather than the upstream tarball unless needed.
