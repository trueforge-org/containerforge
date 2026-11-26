# ayufan Dockerfile.build (tag v4.2.0-1)

Source: https://github.com/ayufan/pve-backup-server-dockerfiles/blob/v4.2.0-1/dockerfiles/Dockerfile.build (raw), fetched 2026-11-26

## Stages
| Stage | Base | Purpose |
| --- | --- | --- |
| toolchain | `${IMAGE_PREFIX}debian:trixie` | apt build deps, rustup, cargo-deb/debcargo |
| builder | toolchain | compiles PVE/PBS components via `./scripts/build/make.bash <repo> <targets>` |
| deb_env | debian:trixie | bundles release tgz via `scripts/release/bundle-tgz.bash` |
| release_env | debian:trixie | installs packages with `/release/install`, adds configs, runit |

- Rust: `RUSTUP_TOOLCHAIN=1.89`; `proxmox-backup --rust 1.89 make_deb`.
- Toolchain apt: build-essential git-core lintian pkg-config quilt patch cargo nodejs node-colors node-commander libudev-dev libapt-pkg-dev libacl1-dev libpam0g-dev libfuse3-dev libsystemd-dev uuid-dev libssl-dev libclang-dev libjson-perl libcurl4-openssl-dev dh-exec dh-nodejs wget rsync jq.
- Builder repos built in order: pve-eslint, proxmox-biome, proxmox-widget-toolkit, perlmod, proxmox-ve-rs, proxmox-perl-rs, pve-common, extjs, proxmox-i18n, proxmox-mini-journalreader, libjs-qrcodejs, proxmox-acme, pve-xtermjs, proxmox-backup.

## Release stage
- Build args: `VERSION`, `ARCH` (default empty), `TAG`. Tarball name: `proxmox-backup-server-${TAG:-$VERSION}-${ARCH:-dev}.tgz`.
- Install: `apt install -y runit ssmtp cron` then `/release/install`.
- Default configs: `ADD /dockerfiles/pbs/ /etc/proxmox-backup-default/`.
- Volumes: `/etc/proxmox-backup`, `/var/log/proxmox-backup`, `/var/lib/proxmox-backup`.
- `ADD /dockerfiles/runit/ /runit/`.
- `ENTRYPOINT ["/runit/entrypoint.sh"]`, `CMD ["runsvdir", "/runit"]`.

## Gotchas
- This is a BUILD file: the final runtime Dockerfile and runit scripts are not in this file (not fetched).
- Base Debian trixie (13); not Ubuntu.
- Expects build context with `packages/`, `scripts/`, `repos/`, `dockerfiles/` (git submodules/checkout).
