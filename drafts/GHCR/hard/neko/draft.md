# neko

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: neko
- **Rows**: 10
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/mozilla-firefox/firefox
- **Source repository**: https://github.com/brave/brave-browser
- **Website**: https://www.chromium.org
- **Website**: https://www.google.com/chrome/
- **Website**: https://www.microsoft.com/edge
- **Source repository**: https://github.com/FreeRDP/Remmina
- **Website**: https://gitlab.torproject.org/tpo/applications/tor-browser
- **Website**: https://vivaldi.com
- **Website**: https://code.videolan.org/videolan/vlc
- **Website**: https://gitlab.xfce.org/xfce
- **Documentation**: https://neko.m1k1o.net/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- Row 1: **Chart**: neko
- Row 1: **Role**: main
- Row 2: **Chart**: neko
- Row 2: **Role**: sidecar (braveImage)
- Row 3: **Chart**: neko
- Row 3: **Role**: sidecar (chromiumImage)
- Row 4: **Chart**: neko
- Row 4: **Role**: sidecar (chromeImage)
- Row 5: **Chart**: neko
- Row 5: **Role**: sidecar (edgeImage)
- Row 6: **Chart**: neko
- Row 6: **Role**: sidecar (remminaImage)
- Row 7: **Chart**: neko
- Row 7: **Role**: sidecar (torImage)
- Row 8: **Chart**: neko
- Row 8: **Role**: sidecar (vivaldiImage)
- Row 9: **Chart**: neko
- Row 9: **Role**: sidecar (vlcImage)
- Row 10: **Chart**: neko
- Row 10: **Role**: sidecar (xfceImage)

### Container

The image and tag the chart uses today.

- Row 1: **Container**: `ghcr.io/m1k1o/neko/firefox:3.2.0`
- Row 2: **Container**: `ghcr.io/m1k1o/neko/brave:3.2.0`
- Row 3: **Container**: `ghcr.io/m1k1o/neko/chromium:3.2.0`
- Row 4: **Container**: `ghcr.io/m1k1o/neko/google-chrome:3.2.0`
- Row 5: **Container**: `ghcr.io/m1k1o/neko/microsoft-edge:3.2.0`
- Row 6: **Container**: `ghcr.io/m1k1o/neko/remmina:3.2.0`
- Row 7: **Container**: `ghcr.io/m1k1o/neko/tor-browser:3.2.0`
- Row 8: **Container**: `ghcr.io/m1k1o/neko/vivaldi:3.2.0`
- Row 9: **Container**: `ghcr.io/m1k1o/neko/vlc:3.2.0`
- Row 10: **Container**: `ghcr.io/m1k1o/neko/xfce:3.2.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- Row 1: **Dockerfile**: [Dockerfile](https://github.com/m1k1o/neko/blob/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/firefox/Dockerfile)
- Row 2: **Dockerfile**: [Dockerfile](https://github.com/m1k1o/neko/blob/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/brave/Dockerfile)
- Row 3: **Dockerfile**: [Dockerfile](https://github.com/m1k1o/neko/blob/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/chromium/Dockerfile)
- Row 4: **Dockerfile**: [Dockerfile](https://github.com/m1k1o/neko/blob/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/google-chrome/Dockerfile)
- Row 5: **Dockerfile**: [Dockerfile](https://github.com/m1k1o/neko/blob/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/microsoft-edge/Dockerfile)
- Row 6: **Dockerfile**: [Dockerfile](https://github.com/m1k1o/neko/blob/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/remmina/Dockerfile)
- Row 7: **Dockerfile**: [Dockerfile](https://github.com/m1k1o/neko/blob/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/tor-browser/Dockerfile)
- Row 8: **Dockerfile**: [Dockerfile](https://github.com/m1k1o/neko/blob/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/vivaldi/Dockerfile)
- Row 9: **Dockerfile**: [Dockerfile](https://github.com/m1k1o/neko/blob/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/vlc/Dockerfile)
- Row 10: **Dockerfile**: [Dockerfile](https://github.com/m1k1o/neko/blob/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/xfce/Dockerfile)

### Application source

The application's own source repository or project page.

- Row 1: **Application source**: [source](https://github.com/mozilla-firefox/firefox)
- Row 2: **Application source**: [source](https://github.com/brave/brave-browser)
- Row 3: **Application source**: [source](https://www.chromium.org)
- Row 4: **Application source**: [source](https://www.google.com/chrome/)
- Row 5: **Application source**: [source](https://www.microsoft.com/edge)
- Row 6: **Application source**: [source](https://github.com/FreeRDP/Remmina)
- Row 7: **Application source**: [source](https://gitlab.torproject.org/tpo/applications/tor-browser)
- Row 8: **Application source**: [source](https://vivaldi.com)
- Row 9: **Application source**: [source](https://code.videolan.org/videolan/vlc)
- Row 10: **Application source**: [source](https://gitlab.xfce.org/xfce)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- Row 1: **Application binary**: [amd64](https://ftp.mozilla.org/pub/firefox/releases/160.0.1/linux-x86_64/en-US/firefox-160.0.1.tar.xz) · [arm64](https://ftp.mozilla.org/pub/firefox/releases/160.0.1/linux-aarch64/en-US/firefox-160.0.1.tar.xz)
- Row 2: **Application binary**: binary: `apt:brave-browser`
- Row 3: **Application binary**: binary: `apt:chromium`
- Row 4: **Application binary**: [amd64](https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb) · [arm64](https://dl.google.com/linux/direct/google-chrome-stable_current_arm64.deb)
- Row 5: **Application binary**: [amd64](https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/)
- Row 6: **Application binary**: binary: `apt:remmina`
- Row 7: **Application binary**: [amd64](https://aus1.torproject.org/torbrowser/update_3/release/download-linux-x86_64.json (tor-browser-linux-x86_64 tar.xz)) · [arm64](https://dist.torproject.org/torbrowser/16.0.1/tor-browser-linux-aarch64-16.0.1.tar.xz)
- Row 8: **Application binary**: [amd64](https://downloads.vivaldi.com/stable/vivaldi-stable_amd64.deb) · [arm64](https://downloads.vivaldi.com/stable/vivaldi-stable_arm64.deb)
- Row 9: **Application binary**: binary: `apt:vlc`
- Row 10: **Application binary**: binary: `apt:xfce4`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- Row 1: **Difficulty**: hard
- Row 2: **Difficulty**: hard
- Row 3: **Difficulty**: hard
- Row 4: **Difficulty**: hard
- Row 5: **Difficulty**: hard
- Row 6: **Difficulty**: hard
- Row 7: **Difficulty**: hard
- Row 8: **Difficulty**: hard
- Row 9: **Difficulty**: hard
- Row 10: **Difficulty**: hard

### Reason

- Row 1: **Reason**: Firefox running under the neko WebRTC streaming stack with supervisord and several processes on a neko base. Apt installs firefox-esr for both arches, but multiple services and the desktop display stack need a real rework to run rootless on a read-only root.
- Row 2: **Reason**: Desktop-in-a-container: needs the neko base (Xorg, openbox, pulseaudio, supervisord, neko server with WebRTC/GStreamer) plus a browser/app; multiple services and a VNC-like desktop stack, often wanting root and shm. Heavy rework for rootless and read-only rootfs. Brave comes from its apt repo.
- Row 3: **Reason**: Desktop-in-a-container: needs the neko base (Xorg, openbox, pulseaudio, supervisord, neko server with WebRTC/GStreamer) plus a browser/app; multiple services and a VNC-like desktop stack, often wanting root and shm. Heavy rework for rootless and read-only rootfs. Chromium is a Debian/Ubuntu package.
- Row 4: **Reason**: Desktop-in-a-container: needs the neko base (Xorg, openbox, pulseaudio, supervisord, neko server with WebRTC/GStreamer) plus a browser/app; multiple services and a VNC-like desktop stack, often wanting root and shm. Heavy rework for rootless and read-only rootfs. Chrome is closed-source but the vendor .deb is downloadable.
- Row 5: **Reason**: Desktop-in-a-container: needs the neko base (Xorg, openbox, pulseaudio, supervisord, neko server with WebRTC/GStreamer) plus a browser/app; multiple services and a VNC-like desktop stack, often wanting root and shm. Heavy rework for rootless and read-only rootfs. Edge is closed source and Microsoft publishes only an amd64 Linux package.
- Row 6: **Reason**: Desktop-in-a-container: needs the neko base (Xorg, openbox, pulseaudio, supervisord, neko server with WebRTC/GStreamer) plus a browser/app; multiple services and a VNC-like desktop stack, often wanting root and shm. Heavy rework for rootless and read-only rootfs. Remmina is an apt package.
- Row 7: **Reason**: Desktop-in-a-container: needs the neko base (Xorg, openbox, pulseaudio, supervisord, neko server with WebRTC/GStreamer) plus a browser/app; multiple services and a VNC-like desktop stack, often wanting root and shm. Heavy rework for rootless and read-only rootfs. Tor Browser tarball is fetched from torproject.
- Row 8: **Reason**: Desktop-in-a-container: needs the neko base (Xorg, openbox, pulseaudio, supervisord, neko server with WebRTC/GStreamer) plus a browser/app; multiple services and a VNC-like desktop stack, often wanting root and shm. Heavy rework for rootless and read-only rootfs. Vivaldi is closed source but the vendor .deb is redistributable via download.
- Row 9: **Reason**: Desktop-in-a-container: needs the neko base (Xorg, openbox, pulseaudio, supervisord, neko server with WebRTC/GStreamer) plus a browser/app; multiple services and a VNC-like desktop stack, often wanting root and shm. Heavy rework for rootless and read-only rootfs. VLC is an apt package.
- Row 10: **Reason**: Desktop-in-a-container: needs the neko base (Xorg, openbox, pulseaudio, supervisord, neko server with WebRTC/GStreamer) plus a browser/app; multiple services and a VNC-like desktop stack, often wanting root and shm. Heavy rework for rootless and read-only rootfs. XFCE desktop comes via apt metapackages.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- Row 1: **amd64**: yes
- Row 1: **arm64**: yes
- Row 2: **amd64**: yes
- Row 2: **arm64**: yes
- Row 3: **amd64**: yes
- Row 3: **arm64**: yes
- Row 4: **amd64**: yes
- Row 4: **arm64**: yes
- Row 5: **amd64**: yes
- Row 5: **arm64**: no
- Row 6: **amd64**: yes
- Row 6: **arm64**: yes
- Row 7: **amd64**: yes
- Row 7: **arm64**: yes
- Row 8: **amd64**: yes
- Row 8: **arm64**: yes
- Row 9: **amd64**: yes
- Row 9: **arm64**: yes
- Row 10: **amd64**: yes
- Row 10: **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- Row 1: **copy-from amd64**: [ghcr.io/m1k1o/neko/firefox:3.2.0](https://ghcr.io/m1k1o/neko/firefox)
- Row 1: **copy-from arm64**: [ghcr.io/m1k1o/neko/firefox:3.2.0](https://ghcr.io/m1k1o/neko/firefox)
- Row 2: **copy-from amd64**: [ghcr.io/m1k1o/neko/brave:3.2.0](https://ghcr.io/m1k1o/neko/brave)
- Row 2: **copy-from arm64**: [ghcr.io/m1k1o/neko/brave:3.2.0](https://ghcr.io/m1k1o/neko/brave)
- Row 3: **copy-from amd64**: [ghcr.io/m1k1o/neko/chromium:3.2.0](https://ghcr.io/m1k1o/neko/chromium)
- Row 3: **copy-from arm64**: [ghcr.io/m1k1o/neko/chromium:3.2.0](https://ghcr.io/m1k1o/neko/chromium)
- Row 4: **copy-from amd64**: [ghcr.io/m1k1o/neko/google-chrome:3.2.0](https://ghcr.io/m1k1o/neko/google-chrome)
- Row 4: **copy-from arm64**: [ghcr.io/m1k1o/neko/google-chrome:3.2.0](https://ghcr.io/m1k1o/neko/google-chrome)
- Row 5: **copy-from amd64**: [ghcr.io/m1k1o/neko/microsoft-edge:3.2.0](https://ghcr.io/m1k1o/neko/microsoft-edge)
- Row 5: **copy-from arm64**: no
- Row 6: **copy-from amd64**: [ghcr.io/m1k1o/neko/remmina:3.2.0](https://ghcr.io/m1k1o/neko/remmina)
- Row 6: **copy-from arm64**: [ghcr.io/m1k1o/neko/remmina:3.2.0](https://ghcr.io/m1k1o/neko/remmina)
- Row 7: **copy-from amd64**: [ghcr.io/m1k1o/neko/tor-browser:3.2.0](https://ghcr.io/m1k1o/neko/tor-browser)
- Row 7: **copy-from arm64**: no
- Row 8: **copy-from amd64**: [ghcr.io/m1k1o/neko/vivaldi:3.2.0](https://ghcr.io/m1k1o/neko/vivaldi)
- Row 8: **copy-from arm64**: [ghcr.io/m1k1o/neko/vivaldi:3.2.0](https://ghcr.io/m1k1o/neko/vivaldi)
- Row 9: **copy-from amd64**: [ghcr.io/m1k1o/neko/vlc:3.2.0](https://ghcr.io/m1k1o/neko/vlc)
- Row 9: **copy-from arm64**: [ghcr.io/m1k1o/neko/vlc:3.2.0](https://ghcr.io/m1k1o/neko/vlc)
- Row 10: **copy-from amd64**: [ghcr.io/m1k1o/neko/xfce:3.2.0](https://ghcr.io/m1k1o/neko/xfce)
- Row 10: **copy-from arm64**: [ghcr.io/m1k1o/neko/xfce:3.2.0](https://ghcr.io/m1k1o/neko/xfce)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

❌ means it is missing too.

- Row 1: **Dependency containers**: brave (braveImage) ❌, google-chrome (chromeImage) ❌, chromium (chromiumImage) ❌, microsoft-edge (edgeImage) ❌, remmina (remminaImage) ❌, tor-browser (torImage) ❌, vivaldi (vivaldiImage) ❌, vlc (vlcImage) ❌, xfce (xfceImage) ❌
- Row 2: **Dependency containers**: -
- Row 3: **Dependency containers**: -
- Row 4: **Dependency containers**: -
- Row 5: **Dependency containers**: -
- Row 6: **Dependency containers**: -
- Row 7: **Dependency containers**: -
- Row 8: **Dependency containers**: -
- Row 9: **Dependency containers**: -
- Row 10: **Dependency containers**: -
