# crazymax.dev ddns-route53 docs: configuration

Source URL(s) + fetch date:
- https://crazymax.dev/ddns-route53/config/ · 2026-11-26

## Config keys (example keys; types inferred, defaults not stated)
- `credentials.accessKeyID` (string), `credentials.secretAccessKey` (string)
- `route53.hostedZoneID` (string)
- `route53.recordsSet[]`: `name` (string), `type` (A, AAAA), `ttl` (int, e.g. 300, 600)
- `wanip.providers.ipv4`, `wanip.providers.ipv6`: lists of URLs
- Unset options (including nested) fall back to their defaults (defaults not listed on this page).

## File search paths (in order)
1. `/etc/ddns-route53/`
2. `$XDG_CONFIG_HOME/`
3. `$HOME/.config/`
4. `.` (working dir)
- File name `ddns-route53.yml` or `.yaml`. `--config` flag or `CONFIG` env overrides the search.

## Env var mapping
- Prefix `DDNSR53_`, nested keys joined by `_` and uppercased (e.g. `credentials.accessKeyID` -> `DDNSR53_CREDENTIALS_ACCESSKEYID`).
- Array index is a zero-based path segment (`DDNSR53_ROUTE53_RECORDSSET_0_NAME`).
- String lists are comma separated (`DDNSR53_WANIP_PROVIDERS_IPV4=https://a,https://b`).

## Precedence
- Page says "Configuration sources are evaluated in the order listed above" (file first, env second). It does not explicitly say env overrides file. Plan.md's claim is not confirmed by this page.
