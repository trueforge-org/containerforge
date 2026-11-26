# AdGuard Home docs: getting started and overview pages

## Source URL(s) + date
- https://adguard-dns.io/kb/adguard-home/getting-started (fetched 2026-11-26)
- https://adguard-dns.io/kb/adguard-home/overview (fetched 2026-11-26; title/text not extracted beyond Docker mention)
- https://adguard.com/en/adguard-home/overview.html (fetched 2026-11-26; title only: "AdGuard Home | Network-wide software for any OS: Windows, macOS, Linux")

## Getting started (key lines)
- Docker: "official AdGuard Home docker image" is listed among install methods.
- Initial installation uses **3000/TCP**.
- Wizard: after start, open `http://127.0.0.1:3000` (or `http://[::1]:3000`); the page shows the server on `0.0.0.0:3000` and the wizard runs the initial configuration.
- DNS servers bind to **port 53**, which needs superuser privileges "most of the time". Docs give a Linux method to allow non-root binding of port 53 (capability/sysctl style; not extracted in full).
- Auto-updates are disabled for Docker installs: "Update the image instead."

## Overview
- Docker is listed as an install option (no extra facts extracted).

## Gotchas
- Port 53 issue is documented upstream; plan.md section 10 already covers it (sysctl `ip_unprivileged_port_start` or remap).
