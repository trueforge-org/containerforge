# qwantify gamevm/base/Dockerfile (pinned commit 2d4c204)

**Source URL(s):** https://raw.githubusercontent.com/wanjohiryan/qwantify/2d4c204c8902da9026fc15baf21eab0fedc0f0dd/gamevm/base/Dockerfile · fetched 2026-11-27 (first 4000 chars, truncated). The same path on `master` returned 404.

## What it is
Neko-based game VM image (3 stages). Pinned commit resolves; master does not.

## Build stages
- `server`: `FROM golang:1.18-bullseye`. apt: git, cmake, make, libx11-dev, libxrandr-dev, libxtst-dev, gstreamer dev/plugins. Builds libclipboard (jtanx) from git. `COPY server/`; `go build -o bin/neko cmd/neko/main.go`.
- `client`: `FROM node:14-bullseye-slim`. `COPY client/package*.json`, `npm install`, `npm run build`.
- runtime: `FROM nvcr.io/nvidia/cudagl:11.2.2-runtime-ubuntu20.04`. ARG UBUNTU_RELEASE=20.04, CUDA_VERSION=11.2.2.

## Runtime deps (runtime stage)
- wget, ca-certificates, supervisor, pulseaudio, dbus-x11, xvfb, mingw-w64, ffmpeg, libcairo2, libxcb1, libxrandr2, libxv1, libopus0, libvpx6, gnupg2, software-properties-common, cabextract, aptitude, vim, curl.
- GPU/VA-API: libgtk-3-bin, mesa-utils, mesa-va-drivers, mesa-vulkan-drivers, libvulkan-dev, vdpauinfo, intel-media-va-driver-non-free, libva2, vainfo, gstreamer vaapi plugin.
- fonts: fonts-noto-color-emoji, fonts-takao-mincho, fonts-wqy-zenhei.

## User
- ARG USERNAME=neko, USER_UID=1000, USER_GID=$USER_UID; groups audio, video, pulse.

## Env
- NVIDIA_DRIVER_CAPABILITIES=all, REFRESH=60, DPI=96, CDEPTH=24, DEBIAN_FRONTEND=noninteractive, VGL_DISPLAY=egl. NVIDIA_VISIBLE_DEVICES ARG=all.

## Gotchas
- CUDA runtime base, Go 1.18 and Node 14: the stack the plan calls "not confirmed" for qwantify:20.04.
- Fetch truncated mid-file. Which Dockerfile built `ghcr.io/wanjohiryan/qwantify:20.04` is not confirmed by this file alone.
