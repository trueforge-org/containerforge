# Upstream README: relvacode/storm

Source URL(s) + date: https://raw.githubusercontent.com/relvacode/storm/master/README.md (fetched 2026-11-27)

## What it is
- Remote web UI for Deluge (Torrent client), mobile-friendly, installable as home-screen app.
- Go backend (REST API talking to Deluge RPC daemon) + Angular frontend embedded in the binary (single binary).

## Install / run
```
docker run --name storm --network deluge -p 8221:8221 \
  -e DELUGE_RPC_HOSTNAME=deluge -e DELUGE_RPC_USERNAME=username \
  -e DELUGE_RPC_PASSWORD=password ghcr.io/relvacode/storm
```
- Deluge must have `"allow_remote": true` in core.conf and a valid auth config.
- Put Storm and Deluge on the same Docker network.

## Runtime deps
- Reachable Deluge daemon (RPC, v1 or v2).

## Entrypoint/flags
- Binary `storm` (Dockerfile ENTRYPOINT). CLI flags mentioned: `--api-key` (same as STORM_API_KEY), `--listen`, `--dev-mode` (dev only).

## Env vars
| Env | Description |
| --- | --- |
| DELUGE_RPC_HOSTNAME | Deluge RPC hostname |
| DELUGE_RPC_PORT | Deluge RPC port |
| DELUGE_RPC_USERNAME | Deluge auth username |
| DELUGE_RPC_PASSWORD | Deluge auth password |
| DELUGE_RPC_VERSION | `v1` or `v2`; README says default is v1 |
| STORM_API_KEY | Enables API key auth |
| STORM_BASE_PATH | Base URL path, default `/` |

## Ports
- 8221 (example in docs)

## Gotchas
- No auth by default; README recommends HTTPS and STORM_API_KEY when exposed.
- Deluge v2: RPC users cannot see torrents added by other RPC users (issue #38).
- Dev workflow uses `frontend/` npm build and `go run ./cmd/storm --listen=127.0.0.1:8221 --dev-mode`.
