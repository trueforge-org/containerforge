# static-web-server.net (landing page)

## Source URL(s) + date
- https://static-web-server.net
- Fetched 2026-11-27

## Facts (examples only, not defaults)
- Example run flags: `--port=8080`, `--root=./public`, `--log=info`.
- Config file is TOML (`sws.toml`) with `[general]` table; keys include host, port, root, compression, cache-control-headers, http2, security-headers, basic-auth, page-fallback.
- Config via CLI flags, env vars, or TOML.
- Docker image shown: `ghcr.io/static-web-server/static-web-server:2`; mapping example `-p 8080:80 -v $PWD:/public`.
- Bases: scratch, Alpine, Debian. Health & metrics feature mentioned.

## Gaps
- Default port, default root, `SERVER_*` env names, default container user and health path NOT stated. Docs pages (`/v3/configuration/file/`, `/v3/download-install/`) not fetched (follow-up budget used on the README).
