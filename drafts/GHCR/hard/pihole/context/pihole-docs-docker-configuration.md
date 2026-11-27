# Pi-hole docs: Docker configuration

**Source URL(s):** https://docs.pi-hole.net/docker/configuration/ (main + 2 continuation chunks), https://docs.pi-hole.net (index only) · fetched 2026-11-27

## Env var syntax
- FTL settings via env: `FTLCONF_[section_]setting` (example: `FTLCONF_dns_dnssec` = `dns.dnssec`).
- Env-set FTL settings become read-only in web UI/CLI; unsetting reverts to default.
- Array values delimited by `;` (or YAML block style).

## Recommended env
| var | purpose |
| --- | --- |
| TZ | log rotation at local midnight |
| FTLCONF_webserver_api_password | web password; if unset, random password printed to log; `''` = no password |
| FTLCONF_dns_upstreams | e.g. `8.8.8.8;8.8.4.4`; supports `#port` suffix and service names |
| WEBPASSWORD_FILE | password from secret file (alternative) |

## Optional variables
| var | default | purpose |
| --- | --- | --- |
| TAIL_FTL_LOG | 1 | tail FTL log in container (0 disables) |
| PIHOLE_UID | 1000 | overrides pihole uid (must be unused in container) |
| PIHOLE_GID | 1000 | overrides pihole gid |

## Advanced variables
| var | default | purpose |
| --- | --- | --- |
| FTL_CMD | no-daemon | dnsmasq startup options, e.g. `no-daemon -- --dns-forward-max 300` |
| DNSMASQ_USER | pihole | `root` needed on some systems (Synology) |
| ADDITIONAL_PACKAGES | unset | space-separated APKs (debug only) |

## Docker args
- `-p 53/80/443/67` ports; `--restart=unless-stopped`; `-v ./etc-pihole:/etc/pihole`; `--net=host` alternative; `--cap-add=NET_ADMIN`; `--dns`; `--env-file`.

## Capabilities
- CAP_NET_BIND_SERVICE (port 53), CAP_NET_RAW (DHCPv6, IP-in-use check), CAP_NET_ADMIN (routing, DHCP unicast), CAP_SYS_NICE, CAP_CHOWN (log/db ownership), CAP_SYS_TIME (NTP).
- Image grants these to FTLDNS if available, even as non-root.
- NET_ADMIN not default; add explicitly if DHCP/IPv6 RA used.

## Gotchas
- `pihole setpassword` to empty does not persist across restarts.
- Index page docs.pi-hole.net only lists sections (no content used).
