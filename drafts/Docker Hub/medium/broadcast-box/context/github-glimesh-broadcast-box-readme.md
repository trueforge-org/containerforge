# Glimesh/broadcast-box README

Source: https://raw.githubusercontent.com/Glimesh/broadcast-box/master/README.md (fetched 2026-11-26)

## What it is
- WebRTC (WHIP ingest / WHEP playback) sub-second broadcast/screen-share tool
- Go backend (pion); React+Vite frontend in `web/`; Go server serves `web/build`
- Clients: OBS (WHIP service), browser `/publish/<key>`, FFmpeg 8+, GStreamer

## Build
- Frontend: `cd web && npm install && npm run build` (output `web/build`); `npm start` (Vite dev, proxies /api)
- Backend: `go run .` at repo root (deps auto-fetched)
- Default listen `:8080`; WHIP endpoint `http://<IP>:8080/api/whip`; WHEP `/api/whep`; status `/api/status`
- Dev: `APP_ENV=development` loads `.env.development` (default `.env.production`)
- CLI: `go run . -createNewProfile -streamKey <key>` (prints reserved profile token)

## Docker (README)
- Local: `docker run -e UDP_MUX_PORT=8080 -e NAT_1_TO_1_IP=127.0.0.1 -p 8080:8080 -p 8080:8080/udp seaduboi/broadcast-box`
- Cloud: `docker run --net=host -e INCLUDE_PUBLIC_IP_IN_NAT_1_TO_1_IP=yes seaduboi/broadcast-box`
- Compose (LetsEncrypt, Watchtower): `export URL=my-server.com; docker-compose up -d`

## Env vars (key)
| Var | Purpose / default |
| --- | --- |
| APP_ENV | production in image |
| HTTP_ADDRESS | listen addr, default :8080 |
| ENABLE_HTTP_REDIRECT, HTTPS_REDIRECT_PORT | HTTP->HTTPS |
| SSL_CERT, SSL_KEY | TLS files |
| NETWORK_TEST_ON_START | exit if network test fails |
| DISABLE_STATUS, DISABLE_FRONTEND | toggles |
| FRONTEND_PATH | default ./web/build |
| FRONTEND_ADMIN_TOKEN | enables /admin |
| STREAM_PROFILE_PATH | default `profiles` |
| STREAM_PROFILE_POLICY | ANYONE_WITH_RESERVED (default) or RESERVED |
| WEBHOOK_URL | auth webhook (must return 200 + `{"streamKey":...}`) |
| UDP_MUX_PORT, UDP_MUX_PORT_WHEP, UDP_MUX_PORT_WHIP | UDP multiplex |
| TCP_MUX_ADDRESS, TCP_MUX_FORCE | WebRTC over TCP |
| NAT_1_TO_1_IP (sep `\|`), INCLUDE_PUBLIC_IP_IN_NAT_1_TO_1_IP, NAT_ICE_CANDIDATE_TYPE=srflx | NAT |
| INTERFACE_FILTER, NETWORK_TYPES, INCLUDE_LOOPBACK_CANDIDATE, APPEND_CANDIDATE, STUN_SERVERS | ICE |
| LOGGING_ENABLED, LOGGING_LEVEL, LOGGING_DIRECTORY, LOGGING_SINGLEFILE, LOGGING_NEW_FILE_ON_STARTUP, LOGGING_API_ENABLED, LOGGING_API_KEY | logging |
| CHAT_MAX_HISTORY, CHAT_DEFAULT_TTL, CHAT_CLEANUP_INTERVAL | chat |
| ENABLE_PROFILING | pprof localhost:6060 |
| DEBUG_* | debug prints |

## Ports
- TCP 8080 (HTTP/S); WebRTC media random UDP unless UDP_MUX_PORT set
- Reverse proxy: disable buffering on `/api/sse`

## Volumes
- none documented; profiles at STREAM_PROFILE_PATH

## License
- MIT

## Version naming
- none documented; frontend pkg `broadcast-box@0.1.0` in sample output
