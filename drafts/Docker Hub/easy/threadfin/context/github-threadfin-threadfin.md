# Threadfin/Threadfin (application source, releases, Dockerfile)

**Source URL(s) + fetch date**
- https://github.com/Threadfin/Threadfin (repo root)
- https://raw.githubusercontent.com/Threadfin/Threadfin/c459dd5a3a3227dfe08143183370a9898185203a/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/Threadfin/Threadfin/master/README.md (fetched 2026-11-26)
- https://raw.githubusercontent.com/Threadfin/Threadfin/1.2.37/threadfin.go (fetched 2026-11-26)
- https://raw.githubusercontent.com/Threadfin/Threadfin/1.2.37/LICENSE (fetched 2026-11-26)
- https://github.com/Threadfin/Threadfin/releases (fetched 2026-11-26)
- https://github.com/Threadfin/Threadfin/releases/download/1.2.37/Threadfin_linux_amd64 and `.../Threadfin_linux_arm64`: direct binary downloads, not fetched; recorded in the release section below.

**What it is**
M3U/XMLTV proxy for IPTV streams. It exposes a SiliconDust HDHomeRun-style tuner for clients such as Plex, Emby and Jellyfin, serving `.ts` and HLS (`.m3u8`) streams. Written in Go. Has a web UI.

**Install/build steps and build deps (upstream Dockerfile at c459dd5)**
- Builder: `FROM golang:1.23-bullseye AS builder`, `WORKDIR /app`, `COPY go.mod go.sum`, `go mod download`, `COPY . .`, then `CGO_ENABLED=0 go build -mod=mod -ldflags="-s -w" -trimpath -o threadfin threadfin.go`.
- Runtime: `FROM ubuntu:24.04` (standard) or `nvidia/cuda:12.8.0-base-ubuntu24.04` (`USE_NVIDIA` build arg).
- Runtime apt (one layer, `--no-install-recommends`): `ca-certificates curl ffmpeg vlc tzdata gnupg apt-transport-https`. `sed -i 's/geteuid/getppid/' /usr/bin/vlc` is applied.
- Jellyfin repo added (`repo.jellyfin.org/master/ubuntu noble main`) and `jellyfin-ffmpeg7` installed. `gnupg apt-transport-https` are removed afterwards. Apt lists cleaned.
- `mkdir -p $THREADFIN_BIN $THREADFIN_CONF $THREADFIN_TEMP $THREADFIN_HOME/cache`, `chmod a+rwX` on conf and temp.
- `COPY --from=builder /app/threadfin $THREADFIN_BIN/`, `chmod +rx`.

**Runtime deps**
ffmpeg (distro), vlc, jellyfin-ffmpeg7 (upstream). VLC is an optional stream buffer per the README.

**Binaries/entrypoint/CLI flags**
- Entrypoint (upstream): `sh -c "${THREADFIN_BIN}/threadfin -port=${THREADFIN_PORT} -bind=${THREADFIN_BIND_IP_ADDRESS} -config=${THREADFIN_CONF} -debug=${THREADFIN_DEBUG}"`.
- Flags defined in `threadfin.go` (1.2.37):
  - `-port` (string, default 34400 per usage text)
  - `-bind` (string, bind IP)
  - `-config` (string, config folder; default is the home directory based path)
  - `-debug` (int, 0-3, default 0; above 3 calls `flag.Usage()`)
  - `-branch` (string, `main|beta`, default main)
  - `-dev` (bool, developer mode; uses local web interface files and needs the source)
  - also `restore`, `info`, `h`.
- `threadfin.go` reads no `os.Getenv` variables. The `THREADFIN_*` env vars are consumed only by the upstream image's shell entrypoint.
- `threadfin.go` sets `GitHub = {Branch: "Main", User: "Threadfin", Repo: "Threadfin", Update: true}`, then calls `src.BinaryUpdate()`. The update logic is in the `src` package, which was not fetched.

**Env vars (upstream image ENV, consumed by the entrypoint shell, not the binary)**

| Variable | Default | Notes |
|---|---|---|
| `THREADFIN_BIN` | `/home/threadfin/bin` | binary location |
| `THREADFIN_CONF` | `/home/threadfin/conf` | config folder |
| `THREADFIN_HOME` | `/home/threadfin` | WORKDIR |
| `THREADFIN_TEMP` | `/tmp/threadfin` | `VOLUME` upstream |
| `THREADFIN_CACHE` | `/home/threadfin/cache` | created in the image |
| `THREADFIN_UID` / `THREADFIN_GID` | `31337` / `31337` | upstream user |
| `THREADFIN_USER` | `threadfin` | |
| `THREADFIN_BRANCH` | `main` | Docker Hub page mentions `beta` as an option |
| `THREADFIN_DEBUG` | `0` | 0-3 |
| `THREADFIN_PORT` | `34400` | |
| `THREADFIN_LOG` | `/var/log/threadfin.log` | set but not used by the entrypoint shown |
| `THREADFIN_BIND_IP_ADDRESS` | `0.0.0.0` | |
| `DEBIAN_FRONTEND` | `noninteractive` | build-time |

**Ports**
`EXPOSE $THREADFIN_PORT` (34400). The README's compose maps `34400:34400`. The web UI path (for example `/web/`) is not documented in the fetched files (it would be in the `src` package, not fetched).

**Volumes/paths and persistent data**
- `$THREADFIN_CONF` = `/home/threadfin/conf` (`VOLUME`). README compose maps `./data/conf:/home/threadfin/conf`.
- `$THREADFIN_TEMP` = `/tmp/threadfin` (`VOLUME`). README compose maps `./data/temp:/tmp/threadfin:rw`.
- Docker Hub page lists `/home/threadfin/conf/data` (data) and `/home/threadfin/conf/backup` (backup) under the conf folder.
- `$THREADFIN_CACHE` = `/home/threadfin/cache` created in the image, but not declared as a volume.

**User/UID & permissions**
- The upstream Dockerfile has **no `USER` directive**, so the image runs as root. The UID/GID env (31337) are set but not used by any shown instruction.
- The Docker Hub page says "runs as an unprivileged user" (contradicts the Dockerfile; see gotchas).

**Config files and formats**
Not documented in the fetched sources. Settings live in the conf folder (file names are in the `src` package, not fetched).

**Healthcheck/readiness endpoints**
None documented in the fetched sources.

**Version/release info and asset naming**
- Latest release: `1.2.37`, dated 11 Sep (year not shown), tag without a `v` prefix (per plan.md, and the releases page lists 1.2.37 as "Latest"). Earlier: 1.2.36 (26 Aug), 1.2.35 (01 Jul), 1.2.34 and 1.2.33 (27 May), 1.2.32 (07 Apr), 1.2.31 (14 Mar).
- The 1.2.37 release shows 11 assets, but the asset list failed to load on the fetch. Asset names (for example `Threadfin_linux_amd64`, `Threadfin_linux_arm64`) are NOT confirmed by this fetch. Checksum presence unknown.
- Git branch selection: `-branch main|beta`.

**Arch support**
amd64 and arm64 are targeted by the plan's build (`TARGETARCH`). The Dockerfile has jellyfin repo arch logic for `arm` (armhf) and other arches. The Docker Hub page describes an x86_64 build only. Asset presence for arm64 not confirmed by this fetch.

**Licence**
MIT (the `LICENSE` file at tag 1.2.37: "MIT License", copyright line "Copyright (c) 2022 fyb3roptik@threadfin").

**Gotchas**
- Docker Hub description (fyb3roptik image) says the image "runs as an unprivileged user", but the upstream Dockerfile has no `USER`. Contradiction, unverified which is correct for the published image.
- Upstream ships VLC and jellyfin-ffmpeg7 for stream buffering. The README says FFMPEG and VLC are the recommended buffer options, and that the app uses a RAM-based buffer.
- README build steps mention `tsc -p ./ts/tsconfig.json` and `threadfin -dev` for web files.
- Forks should change the `GitHub` owner in `threadfin.go` or disable `Update`, otherwise updates pull from upstream.
- The README points to the xTeVe documentation for setup, not to Threadfin docs.
- `Threadfin_linux_*` binary names not confirmed by the asset listing.

**plan.md consistency**
- Matches: Dockerfile content at `c459dd5`; ports 34400; ENV names and defaults; `-port -bind -config -debug` flags; `-branch` and `-dev` in README; VOLUME list; MIT license; version 1.2.37.
- Not supported by fetched sources: the `ThreadfinAutoUpdate` setting and `/.dockerenv` check (plan section 10). `threadfin.go` has neither; the logic is in the un-fetched `src` package. Unverified.
- Not confirmed: the `/web/` UI path used in plan section 8 (unverified; no route shown).
- Not confirmed: the release asset names and the arm64 download (asset list failed to load).
- Plan section 1 "the README's docker example mounts it read-write" ✓.
