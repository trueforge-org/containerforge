# GitHub: dlandon/z80pack Dockerfile (upstream image source)

## Source URL(s) + date
- https://raw.githubusercontent.com/dlandon/z80pack/ae67a0f2e18868f5ccc99eff31973183c4965aa6/Dockerfile (2026-11-27)
- Blob URL in urls.txt is the same file.

## Base / build
- `FROM phusion/baseimage:jammy-1.0.4` (Ubuntu 22.04, glibc).
- ENV: `Z80PACK_VERS="1.37"`, `CPMTOOLS_VERS="2.24"`, `DISABLE_SSH=true`, `HOME=/root`, `LANG=en_US.UTF-8`, `TZ=Etc/UTC`, `DEBIAN_FRONTEND=noninteractive`.
- Copies `init/` to `/etc/my_init.d/` and `packages/` to `/root/packages/`.
- Removes `/etc/service/cron`.
- apt (runtime+build): ca-certificates tzdata sudo nano shellinabox make gcc libncurses5-dev libncursesw5-dev.
- Build z80pack: `tar xzf packages/z80pack-${Z80PACK_VERS}.tar.gz`, then `cpmsim/srcsim` `make -f Makefile.linux`, then `cpmsim/srctools` `make && make install` (INSTALLDIR uncommented via sed).
- Build cpmtools: `packages/cpmtools-${CPMTOOLS_VERS}.tar.gz`, `./configure && make && make install`.
- Then purges make/gcc/ncurses-dev. Removes `/root/packages`.
- Copies `cpmsim/disks/library/*` to `cpmsim/disks/backups`.
- Adds user `vintage` (home `/root/z80pack/cpmsim`, bash, sudo group), password set in Dockerfile (not reproduced here).
- Renames two shellinabox CSS files (+/_ prefix normalisation).
- `chmod +x /etc/my_init.d/*.sh`, apt upgrade, cleanup.

## Entrypoint / runtime
- `VOLUME ["/config"]`, `EXPOSE 4200`, `CMD ["/sbin/my_init"]`. No ENTRYPOINT, no USER (root).

## Ports
- 4200/tcp (shellinabox).

## Volumes / paths
- `/config`; emulator at `/root/z80pack/cpmsim`.

## Version / asset naming
- Source tarball name `z80pack-<ver>.tar.gz`, cpmtools `cpmtools-<ver>.tar.gz` (both pre-downloaded into `packages/`, not in this repo file).

## Gotchas
- Pins z80pack 1.37 (upstream release 1.38 exists, see github-udo-munk-z80pack.md).
- Hard-coded `vintage:computer` login in the image. Do not copy.
- Uses phusion/baseimage (runit, my_init); drop in rootless rewrite.
