# VoceChat docs and website

Source URL(s) + fetch date: https://doc.voce.chat/ · https://voce.chat/ · https://voce.chat/install/docker (404) · fetched 2026-11-26

## Docs (doc.voce.chat)
- Install routes: Docker, Docker + Caddy, Docker + Nginx, shell install. Also binary and source installs at doc.voce.chat/install.
- Server runs on Linux, Windows, Arm32/64. Docker image listed for Linux and Arm64, labelled "Non-commercial".
- Docker run example, volume and port are NOT on the docs landing page.
- Backup: "How to backup?" in Settings at https://voce.chat/setting/backup-migration (not fetched).
- Data "completely controlled by the user".
- License: server open-source; Enterprise SDK not open source. No specific license name on the docs page.

## Website (voce.chat)
- Docker one-liner pulls `privoce/vocechat-server:latest`, exposes port 3000, open localhost:3000.
- Server: Rust, about 20 MB. Open source with code at GitHub Privoce/vocechat-server.
- Pricing: Free ($0, 20-member cap); Pro $49 per server one-time; support tier from $139.
- Hosting: personal computer (Cloudflare Tunnel), VPS, Synology/UGREEN NAS, intranet.

## Gotchas
- https://voce.chat/install/docker returned HTTP 404. The docker install page could not be read. The docker run example and CLI flags are therefore taken from Docker Hub and the TrueCharts chart instead.
- Website pricing (Free 20-member cap, Pro $49 one-time) is consistent with the README's "20 users" and "49$/version" terms, but the website says "one-time" and the README says "/version". Not resolved.
