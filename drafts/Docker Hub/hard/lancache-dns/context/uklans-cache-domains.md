# uklans/cache-domains

Source URL(s): https://github.com/uklans/cache-domains. Fetched 2026-11-26.

- MIT, copyright 2017 UK LAN Techs. Branch `master`. No releases.
- Lists hostnames for LAN game content caches (DNS spoofing / Squid WCCP).
- `cache_domains.json`: top-level `cache_domains` array; entries have `name`, `description`, `notes`, `domain_files`.
- Per-service `.txt` files (steam.txt, blizzard.txt, epicgames.txt, riot.txt, uplay.txt, xboxlive.txt, windowsupdates.txt, origin.txt, etc.). One hostname per line, `#` comments, trailing newline, wildcard `*.` first char only (bare domain not matched).
- `scripts/create-squid.sh` converts wildcards to Squid ACL.
- HTTPS-only CDNs tracked under label `https-cantfix`.
