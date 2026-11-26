# Cloudflare docs: cloudflared run parameters (followed from tunnel docs)

Source URL(s) + fetch date:
- https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/cloudflared-parameters/run-parameters/ · 2026-11-26 (URL was not linked from the draft; reached by a guessed path)

## Env vars (name · flag · meaning · default · min version)
| Env var | Flag | Meaning | Default | Min version |
|---|---|---|---|---|
| `TUNNEL_DISABLE_PATH_NORMALIZATION` | `--disable-path-normalization` | URL normalization before ingress matching (Access-validated tunnels) | `true` | 2026.10.0 |
| `TUNNEL_DNS_RESOLVER_ADDRS` | `--dns-resolver-addrs` | Custom DNS resolvers ip:port (max 10) | not found | 2025.7.0 |
| `TUNNEL_EDGE_BIND_ADDRESS` | `--edge-bind-address` | Outgoing IP to Cloudflare | OS decides | not found |
| `TUNNEL_EDGE_IP_VERSION` | `--edge-ip-version` | `auto`, `4`, `6` | `4` | not found |
| `TUNNEL_GRACE_PERIOD` | `--grace-period` | Wait for in-flight requests on SIGINT/SIGTERM | `30s` | not found |
| `TUNNEL_LOGDIRECTORY` | `--log-directory` | Writes `cloudflared.log` (rotates at 1 MB, 5 backups) | not found | not found |
| `TUNNEL_LOGFILE` | `--logfile` | Log file path, no rotation; overrides log-directory | not found | not found |
| `TUNNEL_LOGLEVEL` | `--loglevel` | `debug`, `info`, `warn`, `error`, `fatal` | `info` | not found |
| `TUNNEL_METRICS` | `--metrics` | Prometheus endpoint `IP:PORT` | see Metrics | not found |
| `NO_AUTOUPDATE` | `--no-autoupdate` | Disables automatic updates | not found | not found |
| `TUNNEL_LOG_OUTPUT`, `TUNNEL_MANAGEMENT_OUTPUT` | `--output` | `default` or `json` | `default` | 2025.6.1 |
| `TUNNEL_ORIGIN_CERT` | `--origincert` | Account cert path (locally-managed only) | `~/.cloudflared/cert.pem` | not found |
| `TUNNEL_PIDFILE` | `--pidfile` | Writes PID after first successful connection | not found | not found |
| `TUNNEL_POST_QUANTUM` | `--post-quantum` | PQ-only key agreement on quic, no fallback | not found | not found |
| `TUNNEL_TRANSPORT_PROTOCOL` | `--protocol` | `auto`, `http2`, `quic` | `auto` | not found |
| `TUNNEL_REGION` | `--region` | Only `us` available | empty (global) | not found |
| `TUNNEL_RETRIES` | `--retries` | Max retries for connection/protocol errors | `5` | not found |
| `TUNNEL_TAG` | `--tag` | Custom KEY=VAL tags | not found | not found |
| `TUNNEL_TOKEN` | `--token` | Tunnel token (remotely-managed only) | not found | not found |
| `TUNNEL_TOKEN_FILE` | `--token-file` | File containing the token (remotely-managed only) | not found | 2025.4.0 |

Not env vars: `autoupdate-freq` (default `24h`), `config` (default `~/.cloudflared/config.yml`).

## Metrics
- `--metrics <IP:PORT>` / `TUNNEL_METRICS`. Default bind address and port in normal and container modes: NOT found on this page (points to the Tunnel metrics page, not fetched).

## NO_AUTOUPDATE
- Disables auto-updates. Does not apply on Windows, package-manager installs, or interactive terminal runs. Package-manager installs are detected via `/usr/local/etc/cloudflared/.installedFromPackageManager`.
- Updates restart cloudflared and can interrupt connections.

## TUNNEL_TOKEN_FILE
- Remotely-managed tunnels only, needs 2025.4.0+. Flag `--token-file <PATH>`.

## Gotchas / contradictions with plan.md
- `TUNNEL_EDGE_IP_VERSION` default is `4` per this page. plan.md settings.yaml sets `default: ""` with comment "unset: cloudflared uses its own default", which matches in effect (cloudflared default is 4). Not edited.
- plan.md's claim of metrics defaults (127.0.0.1 on ports 20241-20245 for non-container, 0.0.0.0:<PORT> for container) is NOT confirmed by this page. Still unverified.
- `TUNNEL_TRANSPORT_PROTOCOL` default `auto`, `TUNNEL_LOGLEVEL` default `info`, `TUNNEL_TOKEN_FILE` min 2025.4.0: all consistent with plan.md.
