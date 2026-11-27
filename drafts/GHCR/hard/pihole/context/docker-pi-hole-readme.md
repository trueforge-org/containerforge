# docker-pi-hole README (master)

**Source URL(s):** https://raw.githubusercontent.com/pi-hole/docker-pi-hole/master/README.md · fetched 2026-11-27

## What it is
Upstream Docker image readme. Network-wide ad blocking.

## Quick start (compose)
- Image `pihole/pihole:latest`.
- Ports: 53/tcp, 53/udp, 80/tcp, 443/tcp; optional 67/udp (DHCP), 123/udp (NTP).
- Env: `TZ`, `FTLCONF_webserver_api_password`, `FTLCONF_dns_listeningMode: 'ALL'` (for bridge networking).
- Volume: `/etc/pihole` (recommended). Optional `/etc/dnsmasq.d` (needs `FTLCONF_misc_etc_dnsmasq_d: 'true'` for v5 migration).
- cap_add: NET_ADMIN (DHCP), SYS_TIME (NTP client), SYS_NICE (optional).
- restart: unless-stopped.

## Notes
- Cron baked in; list refresh weekly (Sunday small hours).
- Avoid `--privileged` from 2022.04 on; use explicit caps.
- Tags: `latest`, date-based (e.g. 2022.04.0), `nightly` (development branch).

## Gotchas
- Dockerhub image name in README: `pihole/pihole`; TrueCharts pulls `ghcr.io/pi-hole/pihole`.
