# hotio.dev: hotio/rflood container page

**Source URL(s):** https://hotio.dev/containers/rflood (main page; 1 fetch) · fetched 2026-11-27

## Tags
- `latest`, `release`, `release-<sha>`, `release-0.16.29`, `release-v0`, `release-v0.16`, `release-v0.16.29`. Page modified 2026-11-26.

## Run
```
docker run --rm --name=rflood -p 3000:3000 \
  -e PUID=1000 -e PGID=1000 -e UMASK=002 -e TZ=Etc/UTC \
  -e WEBUI_PORTS=3000/tcp -e FLOOD_AUTH=false -e FLOOD_ARGS="" \
  -v <host_config>:/config -v <host_data>:/data \
  ghcr.io/hotio/rflood
```

## Env vars (documented)
| var | value/default |
| --- | --- |
| PUID / PGID | 1000 / 1000 |
| UMASK | 002 |
| TZ | Etc/UTC |
| WEBUI_PORTS | 3000/tcp (VPN firewall rules) |
| FLOOD_AUTH | false |
| FLOOD_ARGS | "" (extra Flood args) |

## Volumes
| path | purpose |
| --- | --- |
| /config | config, incl. rpc2/basic_auth_credentials |
| /data | downloads |

## Ports
- 3000 (Flood web UI). Nginx on port 5000 serves XML-RPC/JSON-RPC endpoints (/RPC2 as text/xml, /JSONRPC as application/json-rpc, /RPC).

## Auth
- XML-RPC/JSON-RPC: default credentials shown in first-start log; localhost needs none. Reset by removing/editing `/config/rpc2/basic_auth_credentials`.

## Gotchas
- VPN (WireGuard) support is a hotio feature, not used by the chart.
