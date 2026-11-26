# Forceu/Gokapi (GitHub)

**Source URL(s) + fetch date**
- https://github.com/Forceu/Gokapi (repo; draft source link is `Forceu/gokapi`, same repo)
- https://raw.githubusercontent.com/Forceu/Gokapi/9a4b289c604198c05589e34314e889d2c25386d8/Dockerfile (draft's Dockerfile link, pinned commit)
- https://raw.githubusercontent.com/Forceu/Gokapi/9a4b289c604198c05589e34314e889d2c25386d8/dockerentry.sh (the Dockerfile's `COPY dockerentry.sh /app/run.sh`; `run.sh` at the repo root returned 404)
- https://raw.githubusercontent.com/Forceu/Gokapi/v2.2.4/internal/environment/Environment.go
- https://raw.githubusercontent.com/Forceu/Gokapi/v2.2.4/LICENSE.md
- https://github.com/Forceu/Gokapi/releases/tag/v2.2.4 (asset list did not load)
- https://gokapi.readthedocs.io/en/latest/ (index only, see docs summary)
- Fetched 2026-11-26

**What it is**
Lightweight file-sharing server: expiring links (by download count or days), file requests, multi-user, S3-compatible storage, CLI, REST API. Only authenticated users upload; anonymous visitors only download. Release binary, Go, licensed AGPL-3.0.

**Install/build steps and build deps (upstream Dockerfile at 9a4b289)**
- Stage 1 `FROM golang:1.26.1-alpine AS build_base`: `mkdir /compile && apk update && apk add --no-cache git`; `COPY . /compile`; `go generate ./...`; `CGO_ENABLED=0 go build -ldflags="-s -w -X '...environment.IsDocker=true' ..." ` with package `github.com/forceu/gokapi/cmd/gokapi`, output `/compile/gokapi`.
- Stage 2 `FROM alpine:3.19`: `addgroup -S gokapi && adduser -S gokapi -G gokapi`; `apk add --no-cache su-exec tini ca-certificates curl tzdata`; `mkdir /app && touch /app/.isdocker`; `COPY dockerentry.sh /app/run.sh`; `COPY --from=build_base /compile/gokapi /app/gokapi`; `WORKDIR /app`.
- `ENTRYPOINT ["/sbin/tini", "--"]`; `CMD ["/app/run.sh"]`.
- `HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD curl --fail http://127.0.0.1:53842 || exit 1`.
- No ARG, ENV, USER, VOLUME or EXPOSE. The `gokapi` user is created but not selected with USER (the entry script handles it).

**Runtime deps**
Release binary is static (CGO disabled in upstream build). Upstream runtime installs tini, su-exec, ca-certificates, curl, tzdata.

**Binaries/entrypoint/CLI flags**
- `/app/gokapi`. Flags (from docs / Environment.go notes): port, config dir, data dir, config path override. Setup flags `--config-dir`, `--data`, `--port`, `--config`, `--reconfigure` (plan.md; flags not re-read here).
- `dockerentry.sh` (`/app/run.sh`, marked DEPRECATED in its own header): if `DOCKER_NONROOT=true`, `chown -R` and `chmod -R 700` on `/app` for user `gokapi`, then `exec su-exec gokapi:gokapi /app/gokapi "$@"`. Otherwise `exec /app/gokapi "$@"` as the container's current user.

**Env vars (table; all names are `GOKAPI_` + tag name in Environment.go)**

| Name | Default | Notes |
| --- | --- | --- |
| `GOKAPI_PORT` | `53842` | `DefaultPort`; a value below 1 falls back to default. |
| `GOKAPI_CONFIG_DIR` | `config` | |
| `GOKAPI_CONFIG_FILE` | `config.json` | |
| `GOKAPI_DATA_DIR` | `data` | |
| `GOKAPI_CHUNK_SIZE_MB` | `45` | |
| `GOKAPI_LENGTH_ID` | `15` | Minimum 5. |
| `GOKAPI_LENGTH_HOTLINK_ID` | `40` | Minimum 8. |
| `GOKAPI_LOG_STDOUT` | `false` | |
| `GOKAPI_MAX_FILESIZE` | `102400` | Minimum 5 after parsing. |
| `GOKAPI_MAX_MEMORY_UPLOAD` | `50` | Minimum 5 after parsing. |
| `GOKAPI_MAX_FILES_GUESTUPLOAD` | `100` | |
| `GOKAPI_MAX_SIZE_GUESTUPLOAD` | `10240` | |
| `GOKAPI_MAX_PARALLEL_UPLOADS` | `3` | |
| `GOKAPI_MIN_FREE_SPACE` | `400` | |
| `GOKAPI_MIN_LENGTH_PASSWORD` | `8` | Minimum 6. |
| `GOKAPI_GUEST_UPLOAD_BY_DEFAULT` | `false` | |
| `GOKAPI_TRUSTED_PROXIES` | `127.0.0.1` | Comma separated. |
| `GOKAPI_USE_CLOUDFLARE` | `false` | |
| `GOKAPI_DISABLE_API_MENU` | `false` | |
| `GOKAPI_DISABLE_CORS_CHECK` | `false` | |
| `GOKAPI_DISABLE_DOCKER_TRUSTED_PROXY` | `false` | |
| `GOKAPI_ENABLE_HOTLINK_VIDEOS` | `false` | |
| `GOKAPI_AWS_BUCKET`, `GOKAPI_AWS_REGION`, `GOKAPI_AWS_KEY`, `GOKAPI_AWS_KEY_SECRET`, `GOKAPI_AWS_ENDPOINT` | unset | S3 storage. |
| `GOKAPI_AWS_PROXY_DOWNLOAD` | `false` | |
| `TMPDIR` | unset | Read with `os.Getenv`. If empty and running in Docker, set to the data directory. |

No `GOKAPI_USERNAME` or `GOKAPI_PASSWORD` appear in Environment.go (see the TrueCharts summary, which sets them in the chart).

**Ports**
`53842` (`DefaultPort`). Upstream EXPOSE: none; HEALTHCHECK uses 53842.

**Volumes/paths and persistent data**
- Config dir `config` (default, relative) with `config.json`; `cloudconfig.yml` at config dir for AWS.
- Data dir `data`: uploads, SQLite database, logs.
- Upstream Docker image: `/app/config` and `/app/data` (chart mounts the same paths).
- Upload chunks go to the temp dir; upstream sets `TMPDIR` to the data dir in Docker mode.

**User/UID & permissions**
Upstream creates `gokapi` (system user). Runs as root unless `DOCKER_NONROOT=true` (deprecated, the dockerentry script says the next major version drops it). Upstream's Docker docs migrate to `docker --user`.

**Config files and formats**
`config.json` (created by the setup page or first start), `cloudconfig.yml` (AWS). Other formats not read here.

**Healthcheck/readiness endpoints**
`HEALTHCHECK curl --fail http://127.0.0.1:53842`. The first-run setup page is served on the same port (docs).

**Version/release info and asset naming**
- Tag `v2.2.4`, marked Latest, published 10 Mar (year not shown). Release notes warn about important security fixes (three moderate CVEs), Go 1.26.1 upgrade, a few UI and bug fixes.
- Release page reports 20 assets; the list did not load, so asset names and digests were not seen here. The draft's zip names (`gokapi-2.2.4_linux-amd64.zip`, `gokapi-2.2.4_linux-arm64.zip`) and plan.md's SHA-256 values are not re-verified in this run.

**Arch support**
amd64 and arm64 zips per plan.md (not re-verified). Upstream Dockerfile is arch-neutral (Go build).

**License**
GNU AGPL v3 (LICENSE.md at v2.2.4: "GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007"). The license text itself contains the "or any later version" wording in its notice template; the project's own statement was not found in the fetched part.

**Gotchas**
- `DOCKER_NONROOT` is deprecated and removed in a future major version (dockerentry.sh note).
- Upstream's setup page is unauthenticated on all interfaces until the first setup completes (plan.md, not re-verified here).

**Contradictions with plan.md**
- plan.md section 1 env var list (GOKAPI_* names and defaults) matches Environment.go.
- plan.md section 1 says the upstream Dockerfile is `golang:1.26.1-alpine` build and `alpine:3.19` runtime with tini, su-exec, curl, tzdata, `/app/.isdocker`, `/app/run.sh`, HEALTHCHECK. Matches.
- plan.md section 1 says the Docker Hub image has `v2.2.4`, `latest`, and `latest-dev`. The Hub page showed only `latest`; `latest-dev` not seen. Unverified.
- plan.md section 1: `IsDocker` build-time flag and setup form `localhost_sel` (setup.tmpl default `No`). Not re-checked here.
