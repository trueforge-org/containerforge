# kutzilla/docker-hetzner-ddns: README (master)
Source URL: https://github.com/kutzilla/docker-hetzner-ddns (README raw master, fetched 2026-11-26, 59 lines)

- Purpose: Dynamic DNS updater for Hetzner DNS; periodically checks the public IP and updates the record if it differs.
- Quick run: `docker run -e ZONE_NAME=... -e API_TOKEN=... -e RECORD_TYPE=A [-e RECORD_NAME_VPN=vpn -e RECORD_NAME_VPN_TTL=600 ...] kutzilla/hetzner-ddns`
- Args alternative: `docker run kutzilla/hetzner-ddns <zone> <token> <type>`
- Env: ZONE_NAME (req), API_TOKEN (req), RECORD_TYPE A|AAAA (req), RECORD_NAME (default @), RECORD_NAME_<NAME> + _TTL, CRON_EXPRESSION (default */5 * * * *), TTL (default 86400)
- Build: `docker build -t kutzilla/hetzner-ddns .`
