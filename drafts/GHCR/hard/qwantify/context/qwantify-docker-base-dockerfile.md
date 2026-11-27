# qwantify docker/base/Dockerfile (master)

**Source URL(s):** https://raw.githubusercontent.com/wanjohiryan/qwantify/master/docker/base/Dockerfile · fetched 2026-11-27 (first 4000 chars; file truncated in fetch)

## What it is
Base image for a systemd + X + Docker-in-image stack (usage comment names `ghcr.io/wanjohiryan/arc3dia:base`). Not a single-app game image.

## Build
- `FROM ubuntu:jammy`, `ARG UBUNTU_RELEASE=22.04`.
- apt: systemd, systemd-sysv, libsystemd0, ca-certificates, dbus, iptables, iproute2, kmod, locales, sudo, udev; then wget, vim, software-properties-common, gpg-agent, jq, xvfb, pulseaudio.
- ffmpeg from PPA `savoury1/ffmpeg4` and `savoury1/ffmpeg6` (add-apt-repository), then `apt-get install ffmpeg`.
- Non-root user `admin` (ARG USERNAME=admin, ENV PASSWD=admin), NOPASSWD sudo.
- Docker Engine via get.docker.com; openssh-server; systemd units masked (udevd, sys-kernel-debug, sys-kernel-tracing).
- Later stages (not fully in fetch): Selkies js-interposer, Warp client download.

## Runtime
- ENV LANG/LANGUAGE/LC_ALL en_US.UTF-8, TZ UTC.

## Gotchas
- Runs systemd and sshd; root-level init. Not compatible with ContainerForge rules (USER apps, read-only rootfs).
- Fetch truncated before the end of the file.
