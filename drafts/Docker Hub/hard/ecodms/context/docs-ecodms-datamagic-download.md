# ecoDMS Linux download page (ecodms.datamagic.at/download/)

Source URL(s) + fetch date:
- https://ecodms.datamagic.at/download/
- Fetched 2026-11-26

## Windows downloads (26.01)
- Server 26.01-3 (1104 MB), All-in-One Server 26.01-3 (1902 MB), Client 26.01-3 (244 MB), PDF/A printer 26.01-3 (216 MB). Exe names `ecoDMS-Server-26.01-3.exe`, `ecoDMS-AllInOne-26.01-3.exe`, etc. (heading says 26.01-2; files are 26.01-3).
- Add-ons: LibreOffice Addon 1.0.6, MS Office Plugin 2.1.3, Thunderbird Addon 3.0.10, separator sheet PDF.

## Linux (heading "ecoDMS 26-01 Linux")
- Supported: Debian 64-bit and derived distributions, including Ubuntu and Linux Mint. Only 64-bit named as architecture.
- Repo lines (written to `/etc/apt/sources.list.d/ecodms.list`):
  - Ubuntu 24.04 (noble): `deb http://www.ecodms.de/ecodms_260164/noble /`
  - Debian 13 (trixie): `deb http://www.ecodms.de/ecodms_260164/trixie / /`
  - Debian 12 (bookworm): `deb http://www.ecodms.de/ecodms_260164/bookworm / /`
- Key import (as root, same for Ubuntu and Debian): `wget -qO /etc/apt/trusted.gpg.d/ecodms.asc http://www.ecodms.de/gpg/ecodms.key`
- Install: `apt-get update` then `apt-get install ecodmsserver`.
- Repo and key use plain http. No Docker mention. No macOS. Installation manual referenced for details.
- Ubuntu 26.04 not listed.

## Gotchas
- Repository path segment `260164` is the 26.01 build marker; it changes per release.
