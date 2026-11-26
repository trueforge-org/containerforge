# mosdns wiki (v5) - upstream documentation

**Source URL(s) + fetch date:** https://irine-sistiana.gitbook.io/mosdns-wiki/ ; https://irine-sistiana.gitbook.io/mosdns-wiki/mosdns-v5.md ; https://irine-sistiana.gitbook.io/mosdns-wiki/mosdns-v5/ru-he-pei-zhi-mosdns.md · fetched 2026-11-26

## What it is
Wiki landing page: "一个 DNS 转发器" (a DNS forwarder). v5 is current; v4 documented separately; v3 and earlier wiki lost. Other links on landing page: GitHub source, releases, issues, discussions, Docker image `irinesistiana/mosdns`, `llms.txt` index. Prebuilt binaries and images are built on GitHub Actions.

## Binaries/entrypoint/CLI flags (from mosdns-v5 page)
- Single binary. Start: `mosdns start -c config_file -d working_dir`.
- `mosdns service install -d <abs working dir> -c <config path>`, then `service start|stop|uninstall`. Needs admin/root; registers autostart only, so `start` must still be run manually afterwards. Not supported on OpenWrt; tested on Windows, Ubuntu, Debian.

## Capabilities (as listed)
UDP, TCP, DoT, DoH (incl. H3), DoQ server and client; matchers on domain/type/source IP/response IP/CNAME; caching (no ECS); dual-stack detection; preset ECS; TTL change; hosts; blackhole; redirect; reverse lookup; ipset/nftables writing.

## Config files and formats (from configuration guide)
- YAML default; JSON/TOML accepted by extension.
- Top-level keys: `log` (level debug|info|warn|error default info; production; file - experimental), `api` (experimental; `http: "127.0.0.1:8080"`), `include` (list), `plugins`.
- Plugin: `tag` (optional), `type`, `args`. Initialised in file order.
- Server plugins: `udp_server` / `tcp_server` with `entry` (tag of a `sequence` or `forward`) and `listen` (example `127.0.0.1:5533`).
- Example forward plugin: `type: forward`, `args.upstreams[].addr` (example `https://8.8.8.8/dns-query`).

## Env vars
None mentioned.

## Gotchas
- Config guide examples bind 127.0.0.1; change to 0.0.0.0 for container use.
- Experimental features may change without notice.
- Plan.md's statements about wiki examples binding 127.0.0.1 are confirmed.
