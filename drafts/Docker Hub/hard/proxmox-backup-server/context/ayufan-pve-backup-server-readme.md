# ayufan/pve-backup-server-dockerfiles README

Source: https://github.com/ayufan/pve-backup-server-dockerfiles (raw README, master), fetched 2026-11-26

## What it is
- Unofficial, unmaintained (per Hub) compilation of Proxmox Backup Server for AMD64 and ARM64 in a container.
- Author: Kamil Trzciński, 2020-2025, built from git.proxmox.com sources.

## Pre-built / release assets
- Hub: `ayufan/proxmox-backup-server:latest` (stable) and `:beta` (pre-release).
- GitHub Releases binary assets:
  - `proxmox-backup-server-*.tgz` (Debian install files + `./install` script)
  - `proxmox-backup-client-*.tgz` (statically linked client)
- Tag naming in docs: `v4.0.12` style (`proxmox-backup-server-v<tag>-$(dpkg --print-architecture).tgz`).

## Run / ports / login
- Example compose: docker-compose.yml on repo (not fetched).
- Web UI: HTTPS port 8007 (`https://<ip>:8007/`).
- Default login per README: `admin / pbspbs` (change after first login).
- Auth-failure note: `/run` must be a tmpfs (requirement for 2.1.x).

## Config / volumes (from README examples)
- Optional persistence binds: `/etc/proxmox-backup`, `/var/log/proxmox-backup`, `/var/lib/proxmox-backup` (examples use pbs_etc, pbs_logs, pbs_lib).
- Datastore: add a dir volume (example `/backups`), then add datastore in PBS UI.
- TZ env var (example `Europe/Warsaw`).
- Devices for SMART: `devices: [/dev/sda...]` + `cap_add: [SYS_RAWIO]`.

## Features NOT working in container
- ZFS (not installed); shell access (PVE auth only); PAM auth (no persisted /etc).

## Gotchas
- Synology with kernel 3.1 needs upstream PR #15 and manual rebuild.
- Self-signed cert by default; PVE integration fingerprint via `proxmox-backup-manager cert info`.
- Build from source: see PROCESS.md (not fetched).
