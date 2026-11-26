# Privoce/vocechat-server-rust

Source URL(s) + fetch date: https://github.com/Privoce/vocechat-server-rust · https://raw.githubusercontent.com/Privoce/vocechat-server-rust/master/README.md · https://raw.githubusercontent.com/Privoce/vocechat-server-rust/96c0aa5d100cc1c9090c004dbeb662ba3a08a6cd/build/docker/Dockerfile · https://github.com/Privoce/vocechat-server-rust/releases/tag/v0.5.41 · fetched 2026-11-26

## What it is
- VoceChat: self-hosted chat server written in Rust, about 20 MB, DMs, group chat, file transfer, bots, webhooks and an open API. Mobile and web clients are separate projects.

## Install/build steps and build deps
- Official route in the README: Docker. Binary and source installs are documented at doc.voce.chat (see docs file).
- Upstream Docker build (`build/docker/Dockerfile` at 96c0aa5): `FROM alpine as certs` (installs ca-certificates), `FROM busybox`, copies `/etc/ssl/certs`, copies `vocechat-server` binary to `/home/vocechat-server/vocechat-server`, copies `config` to `/home/vocechat-server/config`, copies `docker-entrypoint.sh` to `/` (chmod +x), `EXPOSE 3000`, `WORKDIR /home/vocechat-server`, `ENTRYPOINT ["/docker-entrypoint.sh"]`.
- Upstream Dockerfile sets `VOCECHAT_FCM_PROJECT_ID`, `VOCECHAT_FCM_PRIVATE_KEY`, `VOCECHAT_FCM_CLIENT_EMAIL` (empty) and `VOCECHAT_FCM_TOKEN_URI` (Google OAuth token URL). Whether the binary reads them was not confirmed (plan.md agrees).
- The entrypoint script contents were not shown by the fetch (only that it exists).

## Runtime deps
- None listed. The web client is fetched at runtime (see the sh.voce.chat entry in README.md of this folder).

## Binaries/entrypoint/CLI flags
- Binary `vocechat-server`. Upstream entrypoint is `/docker-entrypoint.sh`. Config path argument: `config/config.toml` (plan.md, per official installer).
- Docker Hub args used by the TrueCharts chart: `--network.bind 0.0.0.0:<port>` and `--network.frontend_url <url>` (see truecharts file).
- The plan's `--network.domain` flag is not confirmed by any fetched page; the chart uses `--network.frontend_url`. See README.md "plan.md corrections".

## Env vars
- None documented in the README or on Docker Hub. Dockerfile-level FCM variables only (see above).

## Ports
- `3000/tcp` (EXPOSE; `[network] bind` default per plan.md is `0.0.0.0:3000`). Docker Hub example maps host port to 3000 and the README maps `3009:3000`.

## Volumes/paths and persistent data
- Docker Hub: mount a host directory at `/home/vocechat-server/data`. Chart mounts the same path. Docs say data is "completely controlled by the user" and back up is via the Settings "How to backup?" page (https://voce.chat/setting/backup-migration, not fetched).

## User/UID & permissions
- Upstream image: BusyBox base, no USER instruction (runs as root by default).

## Config files and formats
- `config/config.toml`, `config/config-tls.toml`, `config/templates/*.html` in the release zip (per plan.md). Not fetched directly; only referenced.

## Healthcheck/readiness endpoints
- None documented.

## Version/release info and asset naming
- Latest tag `v0.5.41`, release published "20 Nov" (no year shown), tag commit `96c0aa5` (verified signature). Release notes: only "Built from Privoce/vocechat-server at tag v0.5.41".
- Release assets: page reports 6 assets; the asset list did not load. Names given by draft/plan: `vocechat-server-v0.5.41-x86_64-unknown-linux-musl.zip` and `vocechat-server-v0.5.41-aarch64-unknown-linux-musl.zip`. Asset SHA256 digests in plan.md (`a5ec51...`, `04f51c...`) were NOT verified here.

## License
- README: server under "Big Time Public License"; Docker image under "Creative Commons Attribution-NonCommercial 4.0 International"; Flutter mobile, React web client and docs GPLv3. "Free for personal use" with up to 20 registered users; larger use requires a purchased license at "49$/version" (README).
- No LICENSE file was confirmed in the fetched content. plan.md's `LicenseRef-Big-Time-Public-License` is consistent with the README.

## Arch support
- Docker Hub page: Linux and ARM64 (doc site says Docker image supports Linux and Arm64). Server itself: Linux, Windows, ARM32/64.

## Gotchas
- README raw URL on `main` returned 404; `master` worked (see README.md).
- Docker Hub `latest` digest (`sha256:729a6a96...`) has the same prefix as the chart's `v0.5.41` digest, so they appear to be the same build (prefix match only).
