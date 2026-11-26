# mtlynch/picoshare

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/mtlynch/picoshare/v1.5.5/README.md
- https://raw.githubusercontent.com/mtlynch/picoshare/v1.5.5/Dockerfile (draft pins blob `v1.5.5/Dockerfile`)
- https://raw.githubusercontent.com/mtlynch/picoshare/v1.5.5/docker-entrypoint
- https://raw.githubusercontent.com/mtlynch/picoshare/v1.5.5/cmd/picoshare/main.go
- https://raw.githubusercontent.com/mtlynch/picoshare/v1.5.5/litestream.yml
- https://github.com/mtlynch/picoshare/releases/tag/v1.5.5 (page; asset list did not load)
- https://api.github.com/repos/mtlynch/picoshare/releases/tags/v1.5.5 (asset names and digests)
- https://api.github.com/repos/mtlynch/picoshare (archive and move metadata)
- Fetched 2026-11-26.

**Status**
- Repository is ARCHIVED (GitHub API `archived: true`; release page: "This repository was archived by the owner on Nov 17, 2026. It is now read-only."). API description and homepage read "MOVED: https://codefloe.com/mtlynch/picoshare".
- codefloe.com/mtlynch/picoshare (Forgejo) is the moved home: 47 releases and 51 tags listed; a commit "Use Codefloe for repository links and release publishing" (2026-11-17). Its release asset names were not shown. Not used as the pinned source.

**What it is**
- PicoShare: minimal self-hosted file sharing service (direct download links, no ads, no size or type limits, uploads never re-encoded). Go binary, SQLite store. License AGPL (README badge; LICENSE file linked).

**Install/build steps and build deps**
- Upstream Dockerfile (v1.5.5), three stages:
  1. `FROM golang:1.26.1 AS builder`: copies source dirs, runs `./dev-scripts/build-backend "prod"`, output `/app/bin/picoshare`.
  2. `FROM debian:stable-20240311-slim AS litestream_downloader`: `ARG litestream_version="v0.3.13"`; downloads `litestream-${litestream_version}-linux-${ARCH}.tar.gz` from `benbjohnson/litestream` releases (ARCH `arm7` for linux/arm/v7, `arm64`, else `amd64`); extracts `litestream`.
  3. `FROM alpine:3.24.4`: `apk add --no-cache bash`; copies `picoshare` to `/app/picoshare`, `litestream` to `/app/litestream`, `docker-entrypoint` to `/app/docker-entrypoint`, `litestream.yml` to `/etc/litestream.yml`, `LICENSE` to `/app/LICENSE`. `ENV LITESTREAM_RETENTION=72h`, `ENV LITESTREAM_PATH=db`, `WORKDIR /app`, `ENTRYPOINT ["/app/docker-entrypoint"]`, `CMD ["-db", "/data/store.db"]`.
- No EXPOSE, USER or VOLUME upstream.

**Runtime deps**
- Go binary is self-contained (no runtime deps in the upstream image beyond bash for the entrypoint). Litestream optional.

**Binaries/entrypoint/CLI flags**
- `/app/picoshare` with `-db <path>` (default `data/store.db`, from `flag.String("db", "data/store.db", ...)`).
- Upstream entrypoint `docker-entrypoint` (bash): parses `-db` to set `DB_PATH`, exports it; if `LITESTREAM_BUCKET` is set, prints Litestream info, restores when no DB exists (`/app/litestream restore -if-replica-exists "${DB_PATH}"`), then `exec /app/litestream replicate -exec "$PS_LAUNCH_CMD"`; otherwise `exec /app/picoshare "$@"`. Args are single-quoted for Litestream 0.3's shellwords parsing.

**Env vars**
| Name | Default | Read by | Notes |
| --- | --- | --- | --- |
| `PORT` | `4001` | binary (`os.Getenv`) | listens on `:PORT` on all interfaces |
| `PS_SHARED_SECRET` | none | binary | admin passphrase; required unless `PS_SHARED_SECRET_FILE` set |
| `PS_SHARED_SECRET_FILE` | none | binary | file path; wins over `PS_SHARED_SECRET` when non-empty; trailing `\r`/`\n` stripped |
| `PS_BEHIND_PROXY` | unset | binary | any non-empty value enables proxy IP headers (gorilla ProxyIPHeadersHandler) |
| `LITESTREAM_BUCKET` | unset | entrypoint | enables replication when set |
| `LITESTREAM_ENDPOINT` | none | entrypoint/litestream.yml | S3 endpoint; `force-path-style: true` |
| `LITESTREAM_ACCESS_KEY_ID` | none | litestream.yml | |
| `LITESTREAM_SECRET_ACCESS_KEY` | none | litestream.yml | |
| `LITESTREAM_PATH` | `db` | Dockerfile ENV | path in bucket |
| `LITESTREAM_RETENTION` | `72h` | Dockerfile ENV | snapshots and WAL retention |
| `DB_PATH` | from `-db` | entrypoint, litestream.yml | exported by entrypoint |

- Startup error if neither secret is set: `PS_SHARED_SECRET or PS_SHARED_SECRET_FILE must be set`; main logs `failed to read shared secret: %v` and exits 1.
- Passphrase validation errors: `invalid PS_SHARED_SECRET: %w` and `invalid PS_SHARED_SECRET_FILE: %w`; file read error `failed to read PS_SHARED_SECRET_FILE: %w`.

**litestream.yml (verbatim, upstream)**
```yaml
access-key-id: ${LITESTREAM_ACCESS_KEY_ID}
secret-access-key: ${LITESTREAM_SECRET_ACCESS_KEY}
dbs:
  - path: ${DB_PATH}
    replicas:
      - type: s3
        bucket: ${LITESTREAM_BUCKET}
        path: ${LITESTREAM_PATH}
        endpoint: ${LITESTREAM_ENDPOINT}
        force-path-style: true
        retention: ${LITESTREAM_RETENTION}
        snapshot-interval: 24h
```

**Ports**
- 4001/tcp by default (`PORT`). The draft's 8080 is wrong (code default).

**Volumes/paths and persistent data**
- DB default `data/store.db` relative to cwd; upstream image run uses `/data/store.db` (CMD). Upload handling: plan.md notes multipart spooling to `/tmp` (not verified here).
- Litestream metadata lives next to the DB.

**User/UID & permissions**
- No USER upstream (root by default).

**Config files and formats**
- `/etc/litestream.yml` (above). No picoshare config file.

**Healthcheck/readiness endpoints**
- None documented in sources read. Ready log line: `listening on http://%s:%s` (hostname from `os.Hostname()`, fallback `localhost`).

**Version/release info and asset naming**
- Release `v1.5.5`, published 2026-11-16T19:50:01Z, not prerelease, marked Latest. 5 assets per release page; API lists 3 (asset list via API):
  - `picoshare-v1.5.5-linux-amd64.tar.gz`, digest `sha256:72ab7116e861c2daecae6dbeb9912cdfe33182fdace86b5b7780671971f07bb4`
  - `picoshare-v1.5.5-linux-arm64.tar.gz`, digest `sha256:94559027867322dc67b130ceb4f9dea9a9ab8f9e41440e75c5eb8ba2bfe10260`
  - `picoshare-v1.5.5-linux-armv7.tar.gz`, digest `sha256:fe7bc5ac5111fc6edf3501b1584f4fcfcfa9e9702fd47ba0885332dd054a793e`
- Pattern: `picoshare-v<version>-linux-<amd64|arm64|armv7>.tar.gz`. No checksum file in the API list (page says 5 assets; 2 others not shown).
- Litestream upstream pin: `v0.3.13` (Dockerfile ARG). Chart/Docker Hub text says `0.3.8` (stale, see Docker Hub summary).

**Arch support**
- linux amd64, arm64, armv7 (picoshare). Litestream arm7 path exists in upstream Dockerfile.

**Gotchas**
- Upstream repo archived 2026-11-17; work moved to codefloe.com (see Status).
- Without a secret the binary refuses to start.
- `docker-entrypoint` single-quotes `-exec` args for Litestream 0.3 (shellwords); keep quoting if paths contain spaces.
- Plan check: port 4001 default, `PS_SHARED_SECRET_FILE` precedence, `PS_BEHIND_PROXY` semantics, Litestream 0.3.13 pin, entrypoint/CMD and `/etc/litestream.yml` match. The plan's "upstream says it moved to codefloe.com" is supported by the API `description`/`homepage` fields (release page itself has no move notice).
