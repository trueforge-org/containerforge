# getchannels.com/dvr-server/ (Channels DVR Server product and install page)

Source URL(s) + fetch date:
- https://getchannels.com/dvr-server/ · fetched 2026-11-26
- https://getchannels.com/dvr/ · attempted 2026-11-26 (returned only a "Redirecting…" placeholder; no facts). One follow-up was not attempted.

## What it is
"Flexible, standalone media server" for a home computer or NAS; no cloud. Channels apps find it on the LAN. It powers personal media, live TV and DVR features.

## Platforms and requirements (Linux)
- CPU: 1 GHz, 64-bit Intel or 32/64-bit ARM. RAM 512 MB minimum, 1 GB recommended.
- Installer detects systemd, upstart or init.d (OS installer).
- Raspberry Pi: standard Linux instructions; page says Pi is no longer suggested; hardware transcoding not fully supported on Pi 4; TV Everywhere unsupported there.
- Intel hardware acceleration: add the user to `video` and `render` groups so the transcoder can use `/dev/dri`.
- TV Everywhere (native installs): install chrome or chromium plus xvfb (example `apt-get install chromium-browser xvfb`).
- Firewall: port 5353 TCP/UDP must be open for Bonjour/zeroconf discovery.

## Install / download options
- Linux: `curl -f -s https://getchannels.com/dvr/setup.sh | sh` (see getchannels-setup-sh.md).
- macOS 11+ zip; Windows 10+ 64-bit installers (AMD/Intel and ARM64); NAS packages (Synology DSM 7 .spk, QNAP .qpkg QTS 4.3.5+, WD MyCloud .bin, Netgear ReadyNAS .deb OS 6.2, Seagate/LaCie .rbw NAS OS 4.2, Asustor .apk); Unraid template; TrueNAS Scale via Linux or Docker.
- Native Synology and QNAP packages have limited TV Everywhere support; Docker is suggested for those.

## Port
8089 (web interface `http://localhost:8089`). QNAP Virtualization Station also uses 8089.

## Data / config directories
- Linux: the installer creates `channels-dvr` in the current directory; recommended `~/channels-dvr`; alternative `/usr/local/channels-dvr` (create first). Use an external disk if `/` is small or slow.
- Windows: `c:\ProgramData\ChannelsDVR`. macOS: `~/Library/Application Support/ChannelsDVR`.
- Docker: config mapped to `/channels-dvr`, recordings to `/shares/DVR`.

## Licence / subscription
The page does not state a server licence, trial or subscription terms. It links to "Manage Subscription" (under Support). Plan.md's "needs a Channels subscription/trial" is not confirmed here.

## Docker notes
See dockerhub-fancybits-channels-dvr.md (image `fancybits/channels-dvr`, tags `latest` and `tve`).
