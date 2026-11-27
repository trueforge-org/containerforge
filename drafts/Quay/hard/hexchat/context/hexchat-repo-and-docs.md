# HexChat upstream: github.com/hexchat/hexchat, hexchat.github.io, hexchat.readthedocs.io

Source URL(s): https://github.com/hexchat/hexchat ; https://raw.githubusercontent.com/hexchat/hexchat/master/COPYING ; https://hexchat.github.io ; https://hexchat.readthedocs.io (fetched 2026-11-27)

## What it is
- GTK+ IRC client for Windows and Unix-like systems, derived from X-Chat (XChat-WDK lineage). Scripting: Lua, Python, Perl.
- Repo ARCHIVED by owner 2024-02-10 (read-only).
- License: GPL-2.0 (COPYING is GNU GPL v2, June 1991) with an OpenSSL linking exception stated in README.

## Build
- Build system: Meson (meson.build, meson_options.txt, meson_post_install.py). No CMake mentioned.
- Build deps (GTK+, OpenSSL) implied only; not listed on the page.
- Packaging dirs in repo: flatpak, osx, win32; fedora-mingw64.ini for Windows cross-compile.

## Config / runtime
- Default config path: NOT stated on the homepage or repo page. Docs have a "Config Files" section under Settings (readthedocs; not expanded here).
- Command-line flags: none shown on the docs index.

## Docs index (readthedocs, HexChat 2.16.0)
- Client: Getting Started, Settings (config files, network list, set command), Commands, Appearance (themes), Addons, Tips & Tricks.
- Contributor: translation, bug reports, developer/plugin interface, scripting.

## Gotchas
- No install commands on the homepage; points to downloads page (hexchat.github.io/downloads.html), not fetched.
