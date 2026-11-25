# webp-server — implementation plan
> Source: ./draft.md · Target: apps/webp-server/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream | https://github.com/webp-sh/webp_server_go, docs https://docs.webp.sh/ (the `/usage/` page returned 404, so docs were not used; facts come from source) |
| Latest stable | `0.16.2` (tags 0.16.0, 0.16.1, 0.16.2 via `git ls-remote`; release page: published 06 Oct, commit `5efe1bf`, notes: x/image bump and ImageMap prefix fix). Matches the draft |
| Renovate | `datasource=github-releases depName=webp-sh/webp_server_go versioning=loose` (tags have no `v` prefix) |
| License | GNU GPL v3 text in `LICENSE`. UNVERIFIED: "only" vs "or later" (no header or README statement fetched); use `GPL-3.0-only` unless a header says otherwise |
| amd64 asset | `https://github.com/webp-sh/webp_server_go/releases/download/0.16.2/webp-server-linux-amd64` (HTTP 200, 17167760 bytes) |
| arm64 asset | `https://github.com/webp-sh/webp_server_go/releases/download/0.16.2/webp-server-linux-arm64` (HTTP 200, 15929056 bytes) |
| Checksum source | UNVERIFIED: the release lists 6 assets but the list failed to load, so a checksum file was not confirmed. Check `https://github.com/webp-sh/webp_server_go/releases/tag/0.16.2` when implementing. If none exists, fall back to the source build described in section 10 |
| Upstream Dockerfile reviewed | `5efe1bf`: builder `golang:1.27-trixie` + `libvips-dev`, runtime `debian:trixie-slim` with `libvips ca-certificates libjemalloc2 libtcmalloc-minimal4 curl libheif-plugin-aomenc libheif-plugin-aomdec`, binary to `/usr/bin/webp-server`, config at `/etc/config.json` rewritten by `sed` (`IMG_PATH` `/opt/pics`, `EXHAUST_PATH` `/opt/exhaust`, `HOST` `0.0.0.0`), `VOLUME /opt/exhaust`, `CMD webp-server --config /etc/config.json` |
| Native deps | The code uses `github.com/davidbyttow/govips/v2` (cgo, libvips). UNVERIFIED: whether the release binaries are dynamically linked to libvips (upstream runtime image installs it, so assume yes). Check with `readelf -d` inside the build |
| Port | `3333/tcp` (`PORT` default "3333") |
| CLI flags | `--config` (default `config.json`), `--prefetch`, `--prefetch-foreground`, `--jobs`, `--verbosity` (0-4, default 3), `--dump-config`, `-V` |
| Config | JSON file is mandatory (`log.Fatal` if it cannot be opened). Keys: `HOST`, `PORT`, `QUALITY`, `IMG_PATH`, `EXHAUST_PATH`, `METADATA_PATH`, `IMG_MAP`, `ALLOWED_TYPES`, `CONVERT_TYPES`, `ENABLE_EXTRA_PARAMS`, `STRIP_METADATA`, `READ_BUFFER_SIZE`, `CONCURRENCY`, `DISABLE_KEEPALIVE`, `CACHE_TTL`, `MAX_CACHE_SIZE`, `REMOTE_RAW_PATH` |
| Env overrides (verified in `config/config.go`) | `WEBP_HOST`, `WEBP_PORT`, `WEBP_IMG_PATH`, `WEBP_EXHAUST_PATH`, `WEBP_QUALITY`, `WEBP_ALLOWED_TYPES`, `WEBP_CONVERT_TYPES`, `WEBP_ENABLE_EXTRA_PARAMS`, `WEBP_EXTRA_PARAMS_CROP_INTERESTING`, `WEBP_STRIP_METADATA`, `WEBP_IMG_MAP`, `WEBP_READ_BUFFER_SIZE`, `WEBP_CONCURRENCY`, `WEBP_DISABLE_KEEPALIVE`, `WEBP_CACHE_TTL`, `WEBP_MAX_CACHE_SIZE`. No env override seen for `METADATA_PATH` (UNVERIFIED, grep covered most of the block), so it is set in the JSON |
| Repo default config | `HOST 127.0.0.1` (must be overridden), `IMG_PATH ./pics`, `EXHAUST_PATH ./exhaust` |

## 2. Target layout

```
apps/webp-server/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.json     # seeded to /config/config.json when missing
```

`defaults/` is needed for the mandatory JSON config. No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: standalone Go binary plus system libvips. Closest sibling: `apps/adguardhome-sync` (release binary to `/app`). The go-runtime rule (build stage) applies only to the source-build fallback.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (`amd64`/`arm64` match the asset suffix, no mapping). `USER root`. `ENV HOME=/config`.
2. apt (not in the base): `libvips42t64` (UNVERIFIED package name on 26.04; find it with `apt-cache search '^libvips'` and use the runtime lib, not `-dev`), `libheif-plugin-aomenc`, `libheif-plugin-aomdec` (as upstream, for HEIC/AVIF). Pin versions per the Dockerfile rules only if the app's version is tied to apt (it is not here, so unpinned runtime libs are acceptable; mention this in the PR). Skip `libjemalloc2`/`libtcmalloc-minimal4` unless the binary needs them (UNVERIFIED, check `readelf -d`). `ca-certificates` and `curl` are already in the base.
3. One `RUN`:
   - `curl -fsSL -o /app/webp-server "https://github.com/webp-sh/webp_server_go/releases/download/${VERSION}/webp-server-linux-${TARGETARCH}"`
   - Verify against the upstream checksum if one exists (see section 1).
   - `chmod 0755 /app/webp-server && chown -R apps:apps /app`
   - `mkdir -p /opt/pics /usr/share/licenses/webp-server && chown apps:apps /opt/pics` (empty mount point for source images)
   - `readelf -d /app/webp-server | grep NEEDED` (build-time sanity, remove once known)
   - License: fetch `https://raw.githubusercontent.com/webp-sh/webp_server_go/${VERSION}/LICENSE` to `/usr/share/licenses/webp-server/LICENSE`.
4. `ENV GOCACHE=/tmp/go-build WEBP_EXHAUST_PATH=/tmp/exhaust` (caches in `/tmp`).
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3333`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "webp-server" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=webp-sh/webp_server_go versioning=loose
  default = "0.16.2"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/webp-sh/webp_server_go" }
```

Standard targets from `apps/adguardhome-sync/docker-bake.hcl` (`docker-metadata-action`, `image`, `image-local`, `image-all`, `group "default"`). Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/webp-sh/webp_server_go"`.
- `ports`: `3333` / `tcp` / `required: false`.
- `env` (all `required: false`; defaults match `start.sh`): `WEBP_HOST` `0.0.0.0`, `WEBP_PORT` `3333`, `WEBP_IMG_PATH` `/opt/pics`, `WEBP_EXHAUST_PATH` `/tmp/exhaust`, `WEBP_QUALITY` `80`, `WEBP_ALLOWED_TYPES` `jpg,png,jpeg,gif,bmp,svg,heic,nef`, `WEBP_CONVERT_TYPES` `webp`, `WEBP_CACHE_TTL` `259200`, `WEBP_MAX_CACHE_SIZE` `0`, `WEBP_STRIP_METADATA` `true`, `WEBP_ENABLE_EXTRA_PARAMS` `false`, `LOG_VERBOSITY` `3` (read by `start.sh` and passed as `--verbosity`; not an upstream env var), `TZ` `Etc/UTC`.
- `volumes`: `/config` (required true), `/opt/pics` (required false, read-only source images).
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
[ -s /config/config.json ] || cp /defaults/config.json /config/config.json
export WEBP_HOST="${WEBP_HOST:-0.0.0.0}"
export WEBP_IMG_PATH="${WEBP_IMG_PATH:-/opt/pics}"
export WEBP_EXHAUST_PATH="${WEBP_EXHAUST_PATH:-/tmp/exhaust}"
mkdir -p "$WEBP_EXHAUST_PATH" /tmp/metadata
exec /app/webp-server --config /config/config.json --verbosity "${LOG_VERBOSITY:-3}"
```

`defaults/config.json` is the repo `config.json` with `HOST` `0.0.0.0`, `IMG_PATH` `/opt/pics`, `EXHAUST_PATH` `/tmp/exhaust`, `METADATA_PATH` `/tmp/metadata` (`METADATA_PATH` is a struct tag in `config.go`). Seeded only when missing, never overwritten. `WEBP_*` env vars override the file on every start. Binds all interfaces. Final `exec` as shown. Nothing is written to `/app`. If `/config/config.json` was seeded by an older image, `WEBP_HOST` still forces `0.0.0.0`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '3333'
filePaths:
- /app/webp-server
- /defaults/config.json
- /usr/share/licenses/webp-server/LICENSE
```

TCP only: with an empty `/opt/pics`, an HTTP request for an image returns an error, and the root path behavior is UNVERIFIED. Add an `http` probe only if `GET /` is confirmed to return 200 in the run step.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
| --- | --- |
| Config at `/etc/config.json`, baked with `sed` | `/config/config.json` seeded from `/defaults/config.json`, env overrides |
| Cache `EXHAUST_PATH` `/opt/exhaust` (volume) | `/tmp/exhaust`, ephemeral. Draft's extra pvc `/opt/exhaust` is dropped; users who want a persistent cache can set `WEBP_EXHAUST_PATH=/config/exhaust` |
| Metadata dir `./metadata` (relative to cwd) | `/tmp/metadata` via config |
| Source images `/opt/pics` | Read-only mount at `/opt/pics`; the empty dir is created in the image |
| Chart `runAsUser 0`, not read-only | `USER apps` (568), read-only rootfs, `/tmp` tmpfs |

## 10. Risks, caveats and open questions

- Cache in `/tmp` is lost on restart and fills the tmpfs. Mitigate with `WEBP_MAX_CACHE_SIZE` (MB) and document it.
- Source images must be mounted at `WEBP_IMG_PATH`; with none, the server returns no images.
- Checksum availability and libvips linkage are UNVERIFIED. Fallback if there is no checksum or the prebuilt binary does not run on Ubuntu 26.04 glibc/libvips: build in a `golang` stage (go 1.27 per `go.mod`, `libvips-dev`, `go build -ldflags="-s -w"` with `GOCACHE=/tmp/go-build`) and `COPY --from=build` into the ubuntu stage, as the upstream Dockerfile does. Do not touch `go.mod`.
- libvips package name and version on 26.04 are UNVERIFIED (govips v2.19.0 may require a minimum libvips version).
- License variant (only vs or-later) UNVERIFIED.

## 11. Build and test steps

```sh
cd apps/webp-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name webp-server-probe --read-only --tmpfs /tmp -v webp-server-probe-config:/config webp-server:0.16.2
docker logs -f webp-server-probe     # expect the fiber startup banner listing 0.0.0.0:3333
docker rm -f webp-server-probe; docker volume rm webp-server-probe-config
forgetool containers test --image webp-server:0.16.2 --config ./apps/webp-server/container-test.yaml
```

Manual extra: mount a folder of JPEGs at `/opt/pics`, request one with `Accept: image/webp` and confirm a cached file appears in `/tmp/exhaust`.

## 12. PR checklist

- Branch `feat/add-webp-server`, commit and title `feat(webp-server): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested until implemented: arm64 build and run, libvips linkage and package name, checksum step, HEIC/AVIF plugins, real conversion.
- Do not tick "Built container locally" unless it was built.
