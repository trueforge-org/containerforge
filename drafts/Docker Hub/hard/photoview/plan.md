# photoview — implementation plan
> Source: ./draft.md · Target: apps/photoview/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 2.4.0 (latest GitHub release `v2.4.0`, 2024-06-23, no assets). Matches the draft tag. |
| Renovate | datasource=github-releases, depName=photoview/photoview, versioning=semver |
| License | AGPL-3.0-only. UNVERIFIED: LICENSE fetch returned 404; confirm in repo (stated from memory). |
| Source URL | https://github.com/photoview/photoview/ |
| Download | Source tarball only: `https://github.com/photoview/photoview/archive/refs/tags/v${VERSION}.tar.gz` (both arches, compiled). No release binaries. |
| Checksum | None published. GitHub tag archive; no verification possible. |
| Upstream Dockerfile | Reviewed (master): stages `ui` (node:18, `npm ci`, `npm run build`), `dependencies` (photoview/dependencies:trixie artifacts), `api` (golang:1.27-trixie, CGO_ENABLED=1, go-face patched to drop `-march=native -lcblas`, `go build -v -o photoview .` in /app/api), `release` (debian:trixie-slim). Final files: `/app/photoview`, `/app/ui`, `/app/data` (incl. models), `/usr/local/lib/*.so*`, jellyfin-ffmpeg symlinked to /usr/local/bin/ffmpeg and ffprobe. Entrypoint `/app/photoview`, EXPOSE 80, user UID 999. |
| Env (upstream release stage) | `PHOTOVIEW_LISTEN_IP=127.0.0.1`, `PHOTOVIEW_LISTEN_PORT=80`, `PHOTOVIEW_API_ENDPOINT=/api`, `PHOTOVIEW_SERVE_UI=1`, `PHOTOVIEW_UI_PATH=/app/ui`, `PHOTOVIEW_FACE_RECOGNITION_MODELS_PATH=/app/data/models`, `PHOTOVIEW_MEDIA_CACHE=/home/photoview/media-cache` |
| Env (api/example.env) | `PHOTOVIEW_DATABASE_DRIVER` (sqlite/mysql/postgres), `PHOTOVIEW_SQLITE_PATH`, `PHOTOVIEW_MYSQL_URL`, `PHOTOVIEW_POSTGRES_URL`, `MAPBOX_TOKEN`, `PHOTOVIEW_VIDEO_HARDWARE_ACCELERATION`, `PHOTOVIEW_DEVELOPMENT_MODE` |
| Healthcheck | POST GraphQL `CheckInitialSetup` to `/api/graphql` |

## 2. Target layout

- `apps/photoview/Dockerfile` (multi-stage)
- `apps/photoview/docker-bake.hcl`
- `apps/photoview/settings.yaml`
- `apps/photoview/container-test.yaml`
- `apps/photoview/start.sh`
No `defaults/` needed, no `root/`, no DOWNSTREAM_CHANGES.md.

## 3. Base image

Final: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Build stages: Node (UI) and Go (api) images copied from the upstream Dockerfile; the Go stage must be a dedicated build stage with `COPY --from=` (go-runtime rule). Closest sibling: `apps/adguardhome-sync` (Go binary on ubuntu); no sibling does cgo with native libs.

## 4. Dockerfile

1. Stage `ui`: `FROM node:<LTS>` (upstream uses node:18, EOL; UNVERIFIED a newer node works with the UI), copy `${VERSION}` source tarball (`ARG VERSION`), `cd ui && npm ci && npm run build` with `UI_PUBLIC_URL=/`, `npm_config_cache=/tmp/npm`.
2. Stage `api`: `FROM golang:<ver>-trixie` (upstream 1.27-trixie; read `api/go.mod` for the exact need), `ENV CGO_ENABLED=1 GOCACHE=/tmp/gocache`, install build deps (libheif, libraw, dlib, libjpeg, libpng, etc.) via the upstream `scripts/` helper scripts (build_deps, runtime_deps; UNVERIFIED exact package lists, read them from the tag), patch go-face as upstream, `go build -v -o /out/photoview .`. Prefer reusing the `photoview/dependencies:trixie` artifacts like upstream (UNVERIFIED that image is public/versioned for the tag; check).
3. Final stage `FROM ghcr.io/trueforge-org/ubuntu:...`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`: `apt-get install -y --no-install-recommends` the runtime libs matched to the compiled libs (upstream runtime_deps script) and ffmpeg (jellyfin-ffmpeg .deb as upstream, or ubuntu `ffmpeg`, UNVERIFIED parity); `darktable` only if upstream RAW pipeline requires it (UNVERIFIED).
4. `COPY --from=api /out/photoview /app/photoview`, `COPY --from=api /app/api/data /app/data`, `COPY --from=ui /app/ui/dist /app/ui` (UNVERIFIED path), `COPY --from=api` the self-built `/usr/local/lib/*.so*` then `ldconfig`.
5. Licenses: copy `LICENSE.md` and the face-model / go-face third-party notices to `/usr/share/licenses/photoview/`.
6. `chown -R apps:apps /app`, `chmod -R 755 /app`.
7. ENV: `HOME=/config`, `PHOTOVIEW_LISTEN_IP=0.0.0.0`, `PHOTOVIEW_LISTEN_PORT=8080`, `PHOTOVIEW_SERVE_UI=1`, `PHOTOVIEW_UI_PATH=/app/ui`, `PHOTOVIEW_API_ENDPOINT=/api`, `PHOTOVIEW_FACE_RECOGNITION_MODELS_PATH=/app/data/models`, `PHOTOVIEW_MEDIA_CACHE=/config/cache`, `PHOTOVIEW_SQLITE_PATH=/config/photoview.db`.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "photoview" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=photoview/photoview versioning=semver
  default = "2.4.0"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/photoview/photoview/" }
```
Plus the 4 standard targets (`docker-metadata-action`, `image` with args.VERSION and OCI labels, `image-local`, `image-all` amd64+arm64) and `group "default"` -> image-local. Run `docker buildx bake --print`.

## 6. settings.yaml

Header + `schema_version: 1`, `upstream_env_url: "https://github.com/photoview/photoview/"`.
- ports: `8080` tcp required false (draft says 80; non-root cannot bind 80 without sysctl, so 8080).
- env (names confirmed from example.env/Dockerfile): `PHOTOVIEW_DATABASE_DRIVER` default `sqlite`; `PHOTOVIEW_SQLITE_PATH` default `/config/photoview.db`; `PHOTOVIEW_POSTGRES_URL` default "" (required false); `PHOTOVIEW_LISTEN_PORT` default `8080`; `PHOTOVIEW_MEDIA_CACHE` default `/config/cache`; `MAPBOX_TOKEN` default ""; `TZ` default `Etc/UTC`.
- volumes: `/config` required true; `/photos` required false (media mount).
- dependencies: `postgresql` ✅ (optional; SQLite works without it).

## 7. start.sh

`mkdir -p /config /config/cache /tmp/photoview`; no seeding beyond dirs; if `PHOTOVIEW_DATABASE_DRIVER=postgres` and `PHOTOVIEW_POSTGRES_URL` empty, log a clear error and exit non-zero; export the defaults matching settings.yaml; `cd /app`; final `exec /app/photoview`. Binds 0.0.0.0 via `PHOTOVIEW_LISTEN_IP`. No writes to /app. `ldconfig` must not run at runtime (done at build).

## 8. container-test.yaml

Schema header; `timeoutSeconds: 120`; `tcp: - port: '8080'`; `http: - port: '8080' path: /` (UI is served with SERVE_UI=1); `filePaths`: `/app/photoview`, `/app/ui/index.html`, `/app/data/models`, `/usr/share/licenses/photoview`. Runs with sqlite default, so no DB-exception narrowing applies (postgres is optional).

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: SQLite file (-> /config), media cache `/home/photoview/media-cache` (-> `/config/cache`), face models read from /app/data (read-only OK), tmp files (-> /tmp).
- Draft expectation: UID 568 default, readOnlyRootFilesystem true; consistent with `USER apps`. Photos mounted at /photos read-only, user needs read permission.
- Upstream UID 999 user and `/home/photoview` are replaced by `apps` and `HOME=/config`.

## 10. Risks, caveats and open questions

- Heavy cgo build (libheif, dlib, libraw, ffmpeg) is slow, especially arm64 under QEMU; upstream `dependencies` image may be required.
- glibc/library mismatch if build stages are Debian trixie and the final stage is ubuntu 26.04: prefer building the libs from the same ubuntu base, or verify with `ldd`.
- The go-face patch that drops `-march=native -lcblas` must be kept, or the binary may not run on other CPUs.
- Node 18 UI build is EOL; may need newer Node.
- Face recognition needs models in /app/data/models and CPU features; ffmpeg hardware acceleration not planned.
- Version 2.4.0 is from 2024; check for unreleased fixes.
- UNVERIFIED: license, exact build script package lists, UI dist path.

## 11. Build and test steps

```sh
cd apps/photoview
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name photoview-probe --read-only --tmpfs /tmp \
  -v photoview-probe-config:/config photoview:2.4.0
docker logs -f photoview-probe
forgetool containers test --image photoview:2.4.0 --config ./apps/photoview/container-test.yaml
docker rm -f photoview-probe; docker volume rm photoview-probe-config photoview-probe-cache
```
Expected readiness: Photoview startup log lines showing the server listening on port 8080 (exact text UNVERIFIED) and `curl localhost:8080/api/graphql` answering. Also run once with postgres to test that optional path (not covered by container-test).

## 12. PR checklist

- Branch `feat/add-photoview`; commit `feat(photoview): add new container`; PR template filled; Notes contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested to list honestly: cgo build, arm64, read-only run, postgres mode, face recognition, RAW/HEIC thumbnailing.
