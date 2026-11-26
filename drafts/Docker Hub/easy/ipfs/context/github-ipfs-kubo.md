# ipfs/kubo (GitHub)

Source URL(s) + fetch date:
- https://github.com/ipfs/kubo (repo)
- https://raw.githubusercontent.com/ipfs/kubo/v0.43.2/Dockerfile
- https://raw.githubusercontent.com/ipfs/kubo/v0.43.1/Dockerfile (draft's blob link; see differences below)
- https://raw.githubusercontent.com/ipfs/kubo/v0.43.2/bin/container_daemon (ENTRYPOINT script, installed as /usr/local/bin/start_ipfs)
- https://raw.githubusercontent.com/ipfs/kubo/v0.43.2/docs/environment-variables.md
- https://raw.githubusercontent.com/ipfs/kubo/v0.43.2/README.md
- https://raw.githubusercontent.com/ipfs/kubo/v0.43.2/LICENSE-MIT
- https://github.com/ipfs/kubo/releases/tag/v0.43.2 (release page; assets list did not load)
- Release tarball pattern (direct binary download, not fetched): https://github.com/ipfs/kubo/releases/download/v<V>/kubo_v<V>_linux-<arch>.tar.gz (+ `.sha512`, `.cid`); also dist.ipfs.tech/kubo/v<V>/
- Fetched 2026-11-26

## What it is
Kubo (formerly go-ipfs): the first and most widely used IPFS implementation. Go daemon with CLI, HTTP gateway (`/ipfs`, `/ipns`), RPC API (`/api/v0`), WebUI, HTTP Routing V1, experimental FUSE mounts, content blocking. Dual MIT / Apache-2.0.

## Install/build steps and build deps
Upstream image builds from source (`golang:${GO_VERSION}`, `GO_VERSION=1.26.5` in v0.43.2) but the ContainerForge plan uses the release tarball instead (no build).
Upstream v0.43.2 Dockerfile, four stages:
1. `builder`: `FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:${GO_VERSION}`; `ARG TARGETOS TARGETARCH`; `ARG IPFS_PLUGINS`; `ARG MAKE_TARGET=build`; `go mod download`; `make ${MAKE_TARGET} IPFS_PLUGINS=$IPFS_PLUGINS` with `GOOS`, `GOARCH`, `GOFLAGS=-buildvcs=false`.
2. `utilities`: `FROM debian:bookworm-slim`; apt installs `tini`, `gosu`, `fuse`, `ca-certificates`.
3. Final: `FROM busybox:stable-glibc`. Copies `gosu` to `/sbin/gosu`, `tini` to `/sbin/tini`, `fusermount` to `/usr/local/bin/fusermount` (then `chmod 4755`), ca certs, `ipfs` to `/usr/local/bin/ipfs`, `bin/container_daemon` to `/usr/local/bin/start_ipfs` (chmod 755), `bin/container_init_run` to `/usr/local/bin/container_init_run`.
4. `ENV IPFS_PATH=/data/ipfs`; `mkdir -p $IPFS_PATH /ipfs /ipns /mfs /container-init.d`; `adduser -D -h $IPFS_PATH -u 1000 -G users ipfs`; chown those dirs to `ipfs:users`.
- No USER instruction in the image. `gosu` used to drop privileges in container_daemon.

## Runtime deps
- glibc (busybox:stable-glibc base). Helpers: tini (PID 1), gosu, fusermount (FUSE, SUID), ca-certificates.

## Binaries/entrypoint/CLI flags
- `ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/start_ipfs"]`
- `CMD ["daemon", "--migrate=true", "--agent-version-suffix=docker"]`
- `container_daemon` (v0.43.2, verbatim logic):
  - If `id -u` is 0: `gosu ipfs test -w "$repo" || chown -R -- ipfs "$repo"`, then `exec gosu ipfs "$0" "$@"`.
  - `ipfs version`.
  - If `$repo/config` exists: "Found IPFS fs-repo at $repo".
  - Else: `ipfs init ${IPFS_PROFILE:+"--profile=$IPFS_PROFILE"}`; `ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001`; `ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080`.
  - Swarm key: `IPFS_SWARM_KEY` written via printf to `$repo/swarm.key` (chmod 0400); `IPFS_SWARM_KEY_FILE` copied with `install -m 0400` to `$repo/swarm.key` (overwrites). Both variables are unset afterward.
  - `find /container-init.d -maxdepth 1 \( -type f -o -type l \) -iname '*.sh' ... | xargs -n 1 -0 -r container_init_run` (runs on every start).
  - `exec ipfs "$@"`.
- Kubo command: `ipfs daemon --migrate=true ...`.

## Env vars
| Name | Meaning / default | Source |
| --- | --- | --- |
| `IPFS_PATH` | repo location; Dockerfile sets `/data/ipfs`; docs default `~/.ipfs` | Dockerfile, env doc |
| `IPFS_PROFILE` | `ipfs init --profile=`; used only on first init (docs: `server` example) | container_daemon, docker docs |
| `IPFS_SWARM_KEY` | key content written to `$IPFS_PATH/swarm.key` on first init | container_daemon |
| `IPFS_SWARM_KEY_FILE` | path of key file copied to `$IPFS_PATH/swarm.key` on first init | container_daemon |
| `GOLOG_LOG_LEVEL` | log level, default `error` (Dockerfile sets `""`) | env doc, Dockerfile |
| `GOLOG_LOG_FMT` | `color`, `nocolor`, `json` | env doc |
| `GOLOG_FILE`, `GOLOG_OUTPUT`, `GOLOG_TRACING_FILE` | log/tracing output | env doc |
| `IPFS_LOGGING` | deprecated alias of GOLOG_LOG_LEVEL | env doc |
| `IPFS_TELEMETRY` | `on`, `off`, `auto` (default `auto`) | env doc |
| `DO_NOT_TRACK` | opt out of telemetry | env doc |
| `IPFS_FD_MAX` | fd limit, default 2048 | env doc |
| `GOMEMLIMIT` | soft Go memory limit, not set | env doc |
| `GOMAXPROCS` | Go CPU count (docker docs example) | docker docs |
| `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY` | outbound proxy | env doc |
| `IPFS_HTTP_ROUTERS`, `IPFS_CONTENT_BLOCKING_DISABLE`, `IPFS_WAIT_REPO_LOCK`, `IPFS_DIST_PATH`, `IPFS_NS_MAP`, `IPFS_FUSE_DEBUG`, `YAMUX_DEBUG`, `LIBP2P_*` | advanced, see env doc | env doc |
- Not documented in env doc: `IPFS_PROFILE`, `IPFS_SWARM_KEY`, `IPFS_SWARM_KEY_FILE` (documented in docker docs instead).

## Ports
- EXPOSE: `4001` (TCP swarm), `4001/udp` (QUIC swarm), `5001` (RPC API, "keep private"), `8080` (gateway, "can be exposed via reverse proxy"), `8081` (swarm WebSockets, "expose publicly for browser-based peers").
- Container_daemon sets API to `/ip4/0.0.0.0/tcp/5001` and Gateway `/ip4/0.0.0.0/tcp/8080` on first init.

## Volumes/paths and persistent data
- `VOLUME $IPFS_PATH` (`/data/ipfs`). Dirs `/ipfs`, `/ipns`, `/mfs` (FUSE mount points), `/container-init.d` (scripts run on each start, must be idempotent).
- Repo contains `config`, `swarm.key`, blocks, datastore.

## User/UID & permissions
- `ipfs` user uid 1000, gid `users`. Entrypoint runs as root, chowns repo if not writable by `ipfs`, then `gosu` to `ipfs`.
- `fusermount` is SUID (`chmod 4755`) for FUSE by non-root.

## Config files and formats
- `$IPFS_PATH/config` (JSON, kubo config). `$IPFS_PATH/swarm.key` (private network key, mode 0400).

## Healthcheck/readiness endpoints
- HEALTHCHECK: `ipfs --api=/ip4/127.0.0.1/tcp/5001 diag healthy` (interval 30s, timeout 3s, start-period 5s, retries 3).

## Version/release info and asset naming
- Latest tag `v0.43.2`, release page dated 24 Nov (year not shown; 2026 per footer), released by dennis-tra; tag commit `6be1da3` (signed).
- Release page reports 32 assets, but the list did not load, so names and checksums were not confirmed here. Pattern used by draft/plan: `kubo_v<V>_linux-<arch>.tar.gz` with `.sha512` (plan says sha512 files exist; not confirmed from this fetch).
- Draft pins `v0.43.1` (Dockerfile blob link, release tarballs, and copy-from); plan says v0.43.2.
- Release page shows no sha256/sha512 digests, only git commit and GPG key IDs.

## Arch support
Release tarballs for linux amd64 and arm64 per draft/plan. Upstream Dockerfile builds `TARGETARCH` / `TARGETOS`.

## License
Dual MIT / Apache-2.0. LICENSE-MIT at v0.43.2: standard MIT text ("The MIT License (MIT)", "Permission is hereby granted, free of charge..."); no copyright line in the fetched text. LICENSE-APACHE and LICENSE not fetched.

## Differences v0.43.1 vs v0.43.2 Dockerfile
- None found on the fetched content: v0.43.1 Dockerfile matches v0.43.2 for ENV, EXPOSE, ENTRYPOINT, CMD, and HEALTHCHECK, as shown by the fetch summaries. Diff not run; fetched summaries read the same.

## Gotchas
- Upstream image runs ipfs as uid 1000 and repo at `/data/ipfs`. ContainerForge plan uses `/config/ipfs` and uid 568; an existing volume needs chown.
- `IPFS_SWARM_KEY` in env is in the process environment until unset; upstream unsets it after writing.
- Upstream CMD sets `--agent-version-suffix=docker`; plan uses `containerforge`.
- Docker docs warn never to expose RPC API (5001) publicly; it gives admin-level access.

## Contradictions with plan.md
- Plan section 1 says "The draft and chart still say the previous patch release." TrueCharts chart fetched 2026-11-26 is `appVersion: 0.43.2`, image `v0.43.2`. Plan line updated (see README).
- Plan section 1 says checksums `<asset>.sha512` are published and verified. Not confirmable from the release page fetch (asset list did not load). UNVERIFIED.
