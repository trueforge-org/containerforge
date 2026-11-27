# Lyrion: getting started (lyrion.org)

Source URL(s), fetched 2026-11-27:
- https://lyrion.org/getting-started

## Install paths (v9.1.1 text on page)
- Windows: 64-bit installer (14 MB). LMS 9 is 64-bit only; installer removes 32-bit version. Runs as a service.
- Raspberry Pi OS: arm .deb (26 MB), `sudo apt install <deb>`.
- Debian/Ubuntu: amd64 .deb (20 MB) or ARM .deb (26 MB), `apt install`.
- Perl < 5.26: use the `*_all.deb`.
- RPM (Red Hat/Fedora/CentOS, 81 MB): `sudo dnf install <rpm URL>`; openSUSE via `zypper`.
- macOS: .dmg (43 MB), menu bar item for start/stop.
- Raspberry Pi easy path: piCorePlayer.

## Ports
- 9000 (HTTP web UI). No other ports mentioned.

## First run
- Browse to web UI on port 9000 and configure there.

## Config/data
- Config/data directory locations: not stated.
- Service users/permissions: not stated.

## Docker
- Images: Docker Hub `lmscommunity/lyrionmusicserver`; GHCR `lms-community/lyrionmusicserver`.
- Guides exist for Synology, QNAP, OMV, and adding locales to the container. No run flags, volumes or ports given here.
