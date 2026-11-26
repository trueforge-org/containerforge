# aldostools/webMAN-MOD: _Projects_/ps3netsrv subtree

Source URL(s) + fetch date (2026-11-26):
- https://github.com/aldostools/webMAN-MOD/tree/master/_Projects_/ps3netsrv

## What it is
Older copy of the ps3netsrv source kept inside the webMAN-MOD repository (plan.md calls it the older copy). Same README content as the standalone repo.

## Contents (exact names)
- Folders: `bins`, `include`, `openwrt`, `src`
- Files: `.gitignore`, `LICENSE.TXT`, `Make.sh`, `Make_Linux_ARM.sh`, `Makefile`, `Makefile.linux`, `Makefile.linux.arm`, `Makefile.macos`, `README.md`, `_make.bat`, `meson.build`

## Build/usage
- Same as github-aldostools-ps3netsrv.md: Meson build (`meson buildrelease --buildtype=release` then `ninja -C buildrelease`), or `Make.sh` (Linux) / `_make.bat` (Windows) bundled-PolarSSL build.
- Usage: `ps3netsrv [rootdirectory] [port] [whitelist]`, default port 38008.

## Gotchas
- Use the standalone aldostools/ps3netsrv repo for the current release; this subtree is the older copy per plan.md. Draft cites both.
