# traggo/server (application source, Dockerfile, releases)

**Source URL(s) + fetch date**
- https://github.com/traggo/server (repo root)
- https://raw.githubusercontent.com/traggo/server/6321119c3c2d55f04e2e4967f6492aabd6067b76/docker/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/traggo/server/master/README.md (fetched 2026-11-26; no install or config content)
- https://github.com/traggo/server/releases/tag/v0.8.3 (fetched 2026-11-26)
- https://raw.githubusercontent.com/traggo/server/v0.8.3/config/config.go (fetched 2026-11-26)
- https://github.com/traggo/server/releases/download/v0.8.3/traggo_0.8.3_linux_amd64.tar.gz and `..._linux_arm64.tar.gz`: direct archive downloads, not fetched (pattern recorded below).

**What it is**
A self-hosted, tag-based time tracking server with a web UI (dashboards, list and calendar views, themes, basic user management). Go binary, SQLite storage. Versioning follows SemVer.

**Install/build steps and build deps (upstream Dockerfile at 6321119, `docker/Dockerfile`)**
- `FROM scratch`
- `LABEL org.opencontainers.image.source="https://github.com/traggo/server"`
- `WORKDIR /opt/traggo`, `COPY traggo /opt/traggo`, `EXPOSE 3030`, `ENTRYPOINT ["./traggo"]`
- No ARG, ENV, RUN, USER or CMD. No apt packages. The binary is static.
- Build from source is documented on the traggo.net dev pages (not fetched in detail).

**Runtime deps**
None (static binary on `scratch`).

**Binaries/entrypoint/CLI flags**
- Binary: `traggo`. No CLI flags were documented in the fetched sources.
- Config comes from env vars (prefix `TRAGGO_`) and files (see below).

**Env vars** (from `config/config.go`, v0.8.3, envconfig prefix `traggo`, `split_words`)

| Variable | Default | Meaning |
|---|---|---|
| `TRAGGO_PORT` | `3030` | HTTP port |
| `TRAGGO_LOG_LEVEL` | `info` | debug, info, warn, error, fatal, panic |
| `TRAGGO_DEFAULT_USER_NAME` | `admin` | initial account name |
| `TRAGGO_DEFAULT_USER_PASS` | `admin` | initial account password |
| `TRAGGO_PASS_STRENGTH` | `10` | bcrypt strength |
| `TRAGGO_DATABASE_DIALECT` | `sqlite3` | only dialect documented; the code shows no validation |
| `TRAGGO_DATABASE_CONNECTION` | `data/traggo.db` | file path for sqlite3 (relative to working directory) |

`envconfig.Process` failure logs `cannot parse env params` at fatal level.

**Config files and formats**
Lookup order (first definition wins; env vars take precedence):
1. Env vars
2. `.env.local` next to the binary
3. `.env` next to the binary
4. `$HOME/.config/traggo/server.ini`
5. `/etc/traggo/server.ini`

Dotenv-style files (`.env.development.local`, `.env.development`, `.env.local`, `.env`) are loaded with `godotenv.Load` (base dir is the executable's directory; falls back to working directory). A load failure is fatal. `server.ini` uses the same key names (see traggo.net config page, in the docs file).

**Ports**
3030/tcp (`TRAGGO_PORT`). `EXPOSE 3030`. The `traggo.net/install` Docker example maps host 80 to 3030.

**Volumes/paths and persistent data**
- SQLite DB at `TRAGGO_DATABASE_CONNECTION` (default `data/traggo.db`, relative to working dir, so `/opt/traggo/data/traggo.db` in the upstream image with WORKDIR `/opt/traggo`).
- Upstream docs use the volume `/opt/traggo/data` (install page: `-v /opt/traggo/data:/opt/traggo/data`).
- No other persistent paths documented.

**User/UID & permissions**
No USER directive upstream (scratch image). The default app account is `admin`/`admin` until changed.

**Healthcheck/readiness endpoints**
None documented in the fetched sources.

**Version/release info and asset naming**
- Latest release: `v0.8.3`, dated "01 Mar" on the release page (year not shown; plan.md says 2026-03-01). Created by user `jmattheis`.
- Release page shows "Assets 6". The list did not load, so names are unconfirmed. Plan.md says four archives (`traggo_<ver>_linux_<arch>.tar.gz` for amd64 and arm64 among them) and no checksum asset. Six could be four uploads plus two auto source archives, but this is UNVERIFIED.
- Asset naming pattern (plan.md, not fetched directly): `traggo_${VERSION}_linux_${arch}.tar.gz`, where `arch` is `amd64` or `arm64`, and the tag is `v${VERSION}`.
- Tarball content (plan.md, not verified here): `traggo`, `LICENSE`, `README.md`, `.env.sample`.
- Tags on the repo: `v0.8.3` latest. The v0.0.9 example in the install docs is outdated.

**Arch support**
The traggo.net install page says the Docker image supports amd64, 386, ppc64le, s390x, arm64 and arm v7. Release tarball arches (amd64 and arm64 per plan.md) not confirmed by the asset list.

**Licence**
GPL-3.0 per GitHub (plan.md); GPLv3 text in the tarball LICENSE (plan.md). The `or later` wording was not checked.

**Gotchas**
- Default admin account `admin`/`admin` is created when none exists. The docs recommend changing both.
- `TRAGGO_DATABASE_DIALECT`: the docs list only `sqlite3` as supported; the Go code fetched shows no validation of the value.
- Docker Hub `traggo/server:latest` digest starts `sha256:8bf510774…` (same digest as TrueCharts' 0.8.3 pin).
- `config.go` does not show how `Addr` is built (that is in `server/server.go`, not fetched).

**plan.md consistency**
- Matches: Dockerfile (`FROM scratch`, `WORKDIR /opt/traggo`, `EXPOSE 3030`, `ENTRYPOINT ./traggo`); all seven `TRAGGO_*` env names and defaults except that the plan's list omits `TRAGGO_DATABASE_DIALECT` from settings (intentional); config file lookup paths (`.env*` next to binary, `~/.config/traggo/server.ini`, `/etc/traggo/server.ini`).
- Unverified: the tarball file listing, 4 vs 6 assets, arm64 asset present, no checksum asset, `Addr` in `server/server.go`, the `DATABASE_DIALECT` "only valid value" claim (docs say the only supported one, code does not validate).
