# uklans/cache-domains

Source URL(s): https://github.com/uklans/cache-domains. Fetched 2026-11-26.

- MIT, copyright 2017 UK LAN Techs. Branch `master`. No releases. Hostname lists for LAN game content caches (DNS spoofing / Squid WCCP).
- `cache_domains.json`: `cache_domains` array, entries with `name`, `description`, `notes`, `domain_files`.
- One `.txt` per service (steam, blizzard, epicgames, riot, uplay, xboxlive, windowsupdates, origin, nintendo, sony, etc).
- Format: one hostname per line, `#` comments, trailing newline; wildcard `*.` first char only (bare domain not matched).
- `scripts/create-squid.sh` converts to Squid ACL. HTTPS-only CDNs tracked under `https-cantfix`.
- New CDN needs a `.txt` and a `cache_domains.json` entry.
