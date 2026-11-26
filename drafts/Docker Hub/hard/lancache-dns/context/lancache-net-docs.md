# lancache.net docs index

Source URL(s): https://lancache.net/docs. Fetched 2026-11-26.

- Containers: monolithic (`/docs/containers/monolithic/`, variables and cache_domains pages), lancache-dns (`/docs/containers/dns/`, `/variables/`), sniproxy (`/docs/containers/sniproxy/`, `/variables/`).
- General: Ubuntu/CentOS host with official Docker install. Quickstart: shallow clone compose repo, edit `.env`, `docker compose up -d`.
- DNS: lancache-dns must be the ONLY DNS handed to clients; other upstream DNS in `UPSTREAM_DNS`.
- `.env` keys: `LANCACHE_IP`, `DNS_BIND_IP` (optional), `CACHE_ROOT` (separate volume), `CACHE_DISK_SIZE` (g/t), `MIN_DISK_FREE` (~10g), `CACHE_INDEX_SIZE`.
- No port numbers or host networking requirements stated.
