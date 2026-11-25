# gonic — implementation plan
> Source: ./draft.md · Target: apps/gonic/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.23.0` (GitHub release `v0.23.0`, published 2026-10-22T17:14:13Z; latest per the releases/latest API). Matches the chart image `ghcr.io/sentriz/gonic:v0.23.0`. |
| Renovate | `// renovate: datasource=github-releases depName=sentriz/gonic versioning=semver` (tags carry a `v` prefix; semver strips it). The repo's own renovate config was not fetched. |
| License | GPL-3.0 (GitHub API `license.spdx_id`: `GPL-3.0`, https://api.github.com/repos/sentriz/gonic). Confirm whether `GPL-3.0-only` or `GPL-3.0-or-later` is meant before setting `LICENSE`; the API id alone does not settle it. |
| Source URL | https://github.com/sentriz/gonic |
| Download (amd64) | https://github.com/sentriz/gonic/releases/download/v0.23.0/gonic-linux-amd64-v0.23.0 (listed on the release; HTTP status not re-checked) |
| Download (arm64) | https://github.com/sentriz/gonic/releases/download/v0.23.0/gonic-linux-arm64-v0.23.0 (listed on the release) |
| Checksum source | None published: the release assets list contains no checksum file (a filter for `sha`, `checksum` and `txt` matched nothing). UNVERIFIED: no upstream checksum to verify against. See section 10. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/sentriz/gonic/v0.23.0/Dockerfile. Builder on `golang:1.27-alpine3.24`, `CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /out/ ./cmd/...` (static Go build). Final stage `alpine:3.24` with `ffmpeg mpv ca-certificates tzdata tini shared-mime-info`. `VOLUME ["/cache", "/data", "/music", "/podcasts"]`, `EXPOSE 80`, `ENTRYPOINT ["/sbin/tini", "--"]`, `CMD ["gonic"]`. |
| Upstream env (set by image) | `GONIC_DB_PATH=/data/gonic.db`, `GONIC_LISTEN_ADDR=:80`, `GONIC_MUSIC_PATH=/music`, `GONIC_PODCAST_PATH=/podcasts`, `GONIC_CACHE_PATH=/cache`, `GONIC_PLAYLISTS_PATH=/playlists`, `TZ=`. Source: the same Dockerfile. |
| Env vars (README at tag v0.23.0) | `GONIC_MUSIC_PATH` (comma-separated list supported), `GONIC_PODCAST_PATH`, `GONIC_PLAYLISTS_PATH`, `GONIC_CACHE_PATH`, `GONIC_DB_PATH` (optional), `GONIC_HTTP_LOG` (default on), `GONIC_LISTEN_ADDR` (default `0.0.0.0:4747`), `GONIC_TLS_CERT`, `GONIC_TLS_KEY`, `GONIC_PROXY_PREFIX`, `GONIC_SCAN_INTERVAL`, `GONIC_SCAN_AT_START_ENABLED`, `GONIC_SCAN_WATCHER_ENABLED`, `GONIC_SCAN_EMBEDDED_COVER_ENABLED` (default `true`), `GONIC_JUKEBOX_ENABLED`, `GONIC_JUKEBOX_MPV_EXTRA_ARGS`, `GONIC_PODCAST_PURGE_AGE`, `GONIC_EXCLUDE_PATTERN`, `GONIC_MULTI_VALUE_GENRE`, `GONIC_MULTI_VALUE_ARTIST`, `GONIC_MULTI_VALUE_ALBUM_ARTIST`, `GONIC_MULTI_VALUE_ISRC`, `GONIC_TRANSCODE_CACHE_SIZE`, `GONIC_TRANSCODE_EJECT_INTERVAL`, `GONIC_EXPVAR`. Source: https://raw.githubusercontent.com/sentriz/gonic/v0.23.0/README.md |
| Ports | 4747/tcp (README default listen address). The upstream image listens on 80 via `GONIC_LISTEN_ADDR=:80`; the draft's 4747 follows the README default. |
| Arm64 | Confirmed: release asset `gonic-linux-arm64-v0.23.0` exists. |

Differences from the draft:
- Draft says "database and cache in /config": confirmed as a remap. Upstream uses `/data` (DB) and `/cache`, plus `/playlists` and `/podcasts`.
- Draft says "music library mounted read-only": the upstream image declares `/music` as a plain `VOLUME`, with no read-only setting. The read-only mount is the user's choice in the chart, so the plan documents it rather than enforcing it.
- Draft says the chart runs as root (`runAsUser 0`): ContainerForge runs as `apps`, so this is a deliberate change (section 9).
- Draft's "default admin account is created on first run": UNVERIFIED (not found on a fetched page). Check the README or the running app in step 3.
- Draft's "first scan takes a long time": UNVERIFIED on a fetched page; treat as expected behaviour, not a measured fact.

## 2. Target layout

Files under `apps/gonic/`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required: sets the `GONIC_*` paths under `/config`, then `exec`s gonic)

Not needed: `defaults/`, `etc/`, `health/`, `app/`. Never use `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`
- Why it fits: the release binary is a static Go build (`CGO_ENABLED=0` upstream, and the release asset is the same kind of build; confirm with `file` in step 2). It needs no runtime beyond CA certificates and, for transcoding, `ffmpeg` (see section 4). The ubuntu base already has `ca-certificates` and `curl`.
- Closest sibling: `apps/adguardhome-sync` (ubuntu base, a single downloaded binary per `TARGETARCH`, `USER apps`, `COPY --chmod=0755 . /`).
- No `golang` build stage: the release binary is used as-is, so the go-runtime rule about build stages does not apply.

## 4. Dockerfile

Step list:

1. `FROM` the ubuntu base digest above. `ARG VERSION`, `ARG TARGETARCH`. `USER root` for installs only.
2. Install the transcoding dependency with apt, pinned, if the version can be checked against the archive. `ffmpeg` is in the upstream image; whether gonic needs it for every feature is UNVERIFIED. Pin with the same `test "${PACKAGE_VERSION%%-*}"` style as `apps/valkey` once the package version is chosen. Do not add `mpv`: it is only for the jukebox feature, which is off by default (`GONIC_JUKEBOX_ENABLED` is not set).
3. Download the binary and install it to `/app/gonic`:
   ```dockerfile
   RUN set -eux; \
       asset="gonic-linux-${TARGETARCH}-v${VERSION}"; \
       curl -fsSL -o "/tmp/${asset}" \
         "https://github.com/sentriz/gonic/releases/download/v${VERSION}/${asset}"; \
       mkdir -p /app/gonic; \
       install -m 0755 "/tmp/${asset}" /app/gonic/gonic; \
       rm -f "/tmp/${asset}"; \
       chown -R apps:apps /app/gonic
   ```
   `TARGETARCH` values `amd64` and `arm64` match the asset names. The checksum step from `apps/adguardhome-sync`'s pattern does not apply because no upstream checksum exists (section 10).
4. `apt-get purge` / `rm -rf /var/lib/apt/lists/*` after any apt step, as in `apps/valkey`.
5. Environment (keep all writes off `/app`; caches off `/config` unless persistence is needed):
   ```dockerfile
   ENV HOME=/config \
       GONIC_LISTEN_ADDR=0.0.0.0:4747 \
       GONIC_DB_PATH=/config/gonic.db \
       GONIC_MUSIC_PATH=/music \
       GONIC_PODCAST_PATH=/config/podcasts \
       GONIC_PLAYLISTS_PATH=/config/playlists \
       GONIC_CACHE_PATH=/config/cache
   ```
   Section 7 explains the cache choice.
6. `USER apps`, then `COPY --chmod=0755 . /`.
7. `EXPOSE 4747`, `VOLUME /config`, `CMD ["/start.sh"]`.

No compile step, so no `GOCACHE` to point at `/tmp`.

## 5. docker-bake.hcl

Standard layout from `apps/adguardhome-sync/docker-bake.hcl`, with:

```hcl
variable "APP" {
  default = "gonic"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=sentriz/gonic versioning=semver
  default = "0.23.0"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/sentriz/gonic"
}
```

`LICENSE` must be settled first (section 1: GPL-3.0 variant). `image`, `image-local` (`${APP}:${VERSION}`) and `image-all` (linux/amd64, linux/arm64) follow the sibling. `VERSION` has no `v` prefix and must equal `ARG VERSION`. Validate with `cd apps/gonic && docker buildx bake --print`.

## 6. settings.yaml

- Header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json` and `schema_version: 1`.
- `upstream_env_url: "https://github.com/sentriz/gonic"`.
- `ports`: `port: 4747`, `protocol: tcp`, `required: false`.
- `env` (names gonic reads, defaults matching the Dockerfile and `start.sh`):
  - `GONIC_LISTEN_ADDR`, default `0.0.0.0:4747`, `required: false`
  - `GONIC_DB_PATH`, default `/config/gonic.db`, `required: false`
  - `GONIC_MUSIC_PATH`, default `/music`, `required: false`
  - `GONIC_CACHE_PATH`, default `/config/cache`, `required: false`
  - `GONIC_PODCAST_PATH`, default `/config/podcasts`, `required: false`
  - `GONIC_PLAYLISTS_PATH`, default `/config/playlists`, `required: false`
  - `TZ`, default `Etc/UTC`, `required: false` (sibling convention)
- `volumes`:
  - `- path: /config`, `required: true`
  - `- path: /music`, `required: false` (read-only mount, documented as user choice)
- `dependencies` / `opt_dependencies`: none. gonic uses SQLite (`GONIC_DB_PATH`), so no database app is needed.

## 7. start.sh

Requirements: idempotent, empty `/config` works, no writes to `/app`, `exec` at the end.

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/cache /config/playlists /config/podcasts

export GONIC_LISTEN_ADDR="${GONIC_LISTEN_ADDR:-0.0.0.0:4747}"
export GONIC_DB_PATH="${GONIC_DB_PATH:-/config/gonic.db}"
export GONIC_MUSIC_PATH="${GONIC_MUSIC_PATH:-/music}"
export GONIC_CACHE_PATH="${GONIC_CACHE_PATH:-/config/cache}"
export GONIC_PODCAST_PATH="${GONIC_PODCAST_PATH:-/config/podcasts}"
export GONIC_PLAYLISTS_PATH="${GONIC_PLAYLISTS_PATH:-/config/playlists}"

exec /app/gonic/gonic
```

Decisions to confirm:
- Cache location: `/config/cache` keeps covers and transcodes across restarts, but the transcode cache can grow large. The protocol says caches go to `/tmp`. The alternative, `/tmp/gonic-cache`, is ephemeral and would be re-created on every start. Recommendation: `/config/cache`, because covers are expensive to rebuild and `GONIC_TRANSCODE_CACHE_SIZE` can cap growth. Record the choice in the PR. This is an open decision, not settled by this plan.
- The music path: if `/music` is empty or missing, gonic's start behaviour is UNVERIFIED. The test runs with no mounts, so gonic must start with an empty music path. Confirm in step 3; if it fails, `start.sh` should create `/music` only as a directory the process can read, not seed content.
- Admin account: the README does not describe a default account on a fetched page. Do not seed credentials. Document whatever gonic does on first run.
- `GONIC_*` defaults in `start.sh` must match `settings.yaml` exactly.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '4747'
  timeoutSeconds: 180

filePaths:
- /app/gonic/gonic
```

- The test runs with no env vars and no mounts, so it exercises the defaults in `start.sh` and an empty `/music`.
- `timeoutSeconds: 180` is the most common value across sibling tests. A first scan can be slow, but the scan is not started by the test (`GONIC_SCAN_AT_START_ENABLED` is not set), so 180 should be enough; confirm in step 3.
- The `tcp` probe proves a listener inside the container only.

## 9. Rootless and read-only-rootfs adaptations

| Draft / upstream expectation | Plan |
| --- | --- |
| Chart runs as root (`runAsNonRoot false`, `runAsUser 0`) | Runs as `apps` (uid 568). gonic listens on 4747, which needs no privilege. |
| `readOnlyRootFilesystem` (common default true) | Compatible: all writes go to `/config`. |
| Upstream `/data`, `/cache`, `/playlists`, `/podcasts` | Remapped to `/config/gonic.db`, `/config/cache`, `/config/playlists`, `/config/podcasts` through `GONIC_*` variables. |
| Music mounted read-only (chart) | Plan documents `/music` as a user mount; read-only is the user's choice, not enforced by the image. |
| `privileged` | No. No capabilities needed. |

Migration note for users with existing chart data at `/data` (uid differs): ownership on their PVC must be changed to `568`, or the DB will be unreadable. Document this in the PR; do not add a root init container.

## 10. Risks, caveats and open questions

- Checksums: no upstream checksum is published. The Dockerfile downloads the asset over HTTPS and does not verify it. To check it, record the sha256 of each asset (amd64, arm64) as an `ARG` with a comment giving the source URL and the date it was computed, then verify it in the Dockerfile. Computing it means downloading the asset once, which the protocol allows. Flag this to the user as a supply-chain point needing their sign-off.
- ffmpeg: the upstream image bundles ffmpeg for transcoding. Whether the transcode path is needed for a default start is UNVERIFIED; the plan installs it, which adds size. Decide before merging, and record the decision.
- `LICENSE`: GPL-3.0 variant to confirm (section 1).
- Music path behaviour on an empty library: UNVERIFIED (section 7).
- Arm64 is available as a release asset; the arm64 binary has not been run.
- Blockers: none found for the amd64 binary.

## 11. Build and test steps

```sh
cd apps/gonic
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker rm -f gonic-probe 2>/dev/null; docker volume rm gonic-probe-config 2>/dev/null
docker run --rm -d --name gonic-probe --read-only --tmpfs /tmp \
  -v gonic-probe-config:/config gonic:0.23.0
docker logs -f gonic-probe                     # until idle
docker exec gonic-probe sh -c 'ss -ltn | grep -q ":4747 "' && echo "listening"
docker rm -f gonic-probe; docker volume rm gonic-probe-config

forgetool containers test --image gonic:0.23.0 --config ./apps/gonic/container-test.yaml
```

Also run once with a small sample music folder mounted read-only (`-v /path/to/sample:/music:ro`) to check the scan and the `/config/gonic.db` creation. Readiness: the process is still running, port 4747 listens, and the log shows gonic's listen line with no fatal errors. Exact text UNVERIFIED; take it from the first run.

Test on a restart too (same `/config` volume) to confirm idempotent start.

## 12. PR checklist

- Branch: `feat/add-gonic`
- Commit: `feat(gonic): add new container`
- PR title: `feat(gonic): add new container`
- PR description: from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Only check boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user the PR needs a signed Contributor License Agreement at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested: this plan was written without building or running the image. Include the missing checksum, the ffmpeg decision, the cache path decision, arm64, and the license variant as open items.
- Version alignment: `VERSION` in `docker-bake.hcl` (`0.23.0`) equals `ARG VERSION` in the Dockerfile.
- Not a `FROM` base: no `DOWNSTREAM_CHANGES.md`.
