# owncast/owncast

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/owncast/owncast/v0.3.0/README.md
- https://raw.githubusercontent.com/owncast/owncast/v0.3.0/Dockerfile (draft pins blob `4b09a1b...`; the v0.3.0 tag Dockerfile was read instead)
- https://api.github.com/repos/owncast/owncast/releases/tags/v0.3.0 (release metadata and asset list)
- Fetched 2026-11-26.

**What it is**
- Self-hosted live video streaming and web chat server, written in Go. Ingests RTMP (OBS and similar), transcodes to HLS with ffmpeg, serves web player, chat and admin UI at `/admin`. MIT license.

**Install/build steps and build deps**
- Upstream release: prebuilt zip per arch (see Version/release). The zip contains the `owncast` binary only (per plan.md; not re-verified here).
- README (source build): C compiler and ffmpeg required; Go 1.24+. Build is `go run main.go` (not used by us).
- Upstream `Dockerfile` (v0.3.0, convenience only, not in CI per its header):
  - Build stage: `FROM golang:alpine AS build`; `apk add git gcc build-base linux-headers`; `CGO_ENABLED=1 go build -a ... -ldflags "-extldflags \"-static\" -s -w -X .../config.GitCommit=... -X .../config.VersionNumber=$VERSION -X .../config.BuildPlatform=$NAME" -o owncast .`
  - Runtime stage: `FROM alpine:3.24.0`; `apk add ffmpeg ffmpeg-libs ca-certificates && update-ca-certificates`; `addgroup -g 101 -S owncast && adduser -u 101 -S owncast -G owncast`; `WORKDIR /app`; `COPY --from=build /build/owncast /app/owncast`; `mkdir /app/data`; `chown -R owncast:owncast /app`; `USER owncast`; `ENTRYPOINT ["/app/owncast"]`; `EXPOSE 8080 1935`. No VOLUME, no CMD.

**Runtime deps**
- ffmpeg (required for transcoding; the upstream image installs `ffmpeg ffmpeg-libs ca-certificates`).

**Binaries/entrypoint/CLI flags**
- `/app/owncast` (upstream ENTRYPOINT). Flags (from runtime-flags docs, see docs-owncast-online-runtime-flags.md): `--adminpassword`, `--backupdir`, `--database` (default `data/owncast.db`), `--enableDebugFeatures`, `--enableVerboseLogging`, `--followervalidationinterval`, `--logdir`, `--restoreDatabase`, `--rtmpport` (default 1935), `--streamkey`, `--webserverip`, `--webserverport` (default 8080).

**Env vars**
- None documented. README and runtime-flags docs mention none. Configuration is flags, admin UI, and the database.

**Ports**
- 8080/tcp: web server, admin (`/admin`), HLS and player. Default per docs, saved to the database.
- 1935/tcp: RTMP ingest. Default per docs, saved to the database.
- RTMP listen address default `0.0.0.0` (server-setup docs). Web server IP default is not stated in the docs.

**Volumes/paths and persistent data**
- Upstream image: `/app/data` (created in the Dockerfile; not declared as VOLUME). Default database `data/owncast.db` relative to working dir (flags doc). Other write paths (HLS, tmp, logs, backup, emoji, public) per plan.md source reading; not re-verified here.

**User/UID & permissions**
- Upstream runtime user `owncast`, UID 101, GID 101 (created via `addgroup -g 101` and `adduser -u 101`).

**Config files and formats**
- Settings are stored in the database; flags marked "Saved to database" persist across starts (flags doc).

**Healthcheck/readiness endpoints**
- None documented in sources read.

**Version/release info and asset naming**
- Release `v0.3.0`, published 2026-09-03T16:31:05Z, not prerelease.
- Assets (verified from the API):
  - `owncast-0.3.0-linux-32bit.zip`
  - `owncast-0.3.0-linux-64bit.zip`
  - `owncast-0.3.0-linux-arm64.zip`
  - `owncast-0.3.0-linux-arm7.zip`
  - `owncast-0.3.0-macOS-64bit.zip`
  - `owncast-0.3.0-macOS-arm64.zip`
- Pattern: `owncast-<version>-linux-<64bit|arm64|arm7|32bit>.zip`. No checksum asset.

**Arch support**
- linux 64bit (amd64), arm64, arm7, 32bit. Dockerfile build is for `golang:alpine`; arm64 zip linkage not verified.

**Gotchas**
- Upstream Dockerfile says its containers are not part of continuous testing.
- The Owncast docs describe the default admin password only as a rule for user-chosen passwords; no default password is stated in docs. (plan.md's `abc123` default comes from `config/defaults.go` per plan, not re-verified here.)
- Docs: Windows not natively supported (WSL2 suggested). Not relevant to Linux container.
- Docs: `--streamkey` makes a session-only key and hides the Stream Keys admin tab.
- Port changes made in the admin UI need a restart.
- Plan check: release asset names, Dockerfile runtime (UID 101, ffmpeg, `/app/data`, `ENTRYPOINT ["/app/owncast"]`, `EXPOSE 8080 1935`), MIT license, and flag names/defaults match. No contradictions found.
