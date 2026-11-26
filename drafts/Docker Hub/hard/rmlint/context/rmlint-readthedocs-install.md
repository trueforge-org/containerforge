# rmlint docs: installation and dependencies

Sources: https://rmlint.readthedocs.io (index, version 2.11.0 "Evolving Echidna") and https://rmlint.readthedocs.io/en/latest/install.html (follow-up, merged). Also https://rmlint.readthedocs.io/en/master (same docs, not re-fetched). Fetched 2026-11-26.

## Hard deps
- glib >= 2.74 (libglib2.0-dev)
- libjson-glib (libjson-glib-dev on Debian/Ubuntu)

## Soft deps (optional features)
- libblkid (mountpoint detection; libblkid-dev)
- libelf (non-stripped binary detection; libelf-dev)

## Build deps
- git, scons (build system), pkgconf, gcc / build-essential
- gettext (optional)

## Debian/Ubuntu commands (docs)
- `sudo apt install git scons pkgconf build-essential libjson-glib-1.0-0 libjson-glib-dev`
- `sudo apt install gettext libelf-dev libglib2.0-dev libblkid-dev`
- Note: Debian and Ubuntu ship official rmlint packages.

## Optional
- Docs build: python3-sphinx, furo.
- GUI build/run: python3-setuptools, python3-build, python3-installer, python3-gi-cairo, gir1.2-gtksource-4, gir1.2-polkit-1.0, librsvg2-common, python3-colorlog.
- Tests: pytest, pytest-xdist, psutil, xattr, blake3, xxhash, cpuinfo.

## Gotchas
- Docs list distro packages for Ubuntu as the "Ubuntu-only" section (universe repo may be needed).
