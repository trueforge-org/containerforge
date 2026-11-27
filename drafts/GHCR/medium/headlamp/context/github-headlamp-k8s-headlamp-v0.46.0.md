# Upstream: headlamp-k8s/headlamp v0.46.0 (Dockerfile, container/ scripts, README, release page)

## Source URL(s) + date
- https://raw.githubusercontent.com/headlamp-k8s/headlamp/v0.46.0/Dockerfile (fetched 2026-11-27)
- https://raw.githubusercontent.com/headlamp-k8s/headlamp/v0.46.0/container/fetch-plugins.sh (fetched 2026-11-27; in repo at tag, not from the release tarball)
- https://raw.githubusercontent.com/headlamp-k8s/headlamp/v0.46.0/container/build-manifest.json (fetched 2026-11-27)
- https://raw.githubusercontent.com/headlamp-k8s/headlamp/main/README.md (fetched 2026-11-27)
- https://github.com/headlamp-k8s/headlamp/releases/tag/v0.46.0 (HTML, title "Release 0.46.0 · kubernetes-sigs/headlamp"; the repo is served under kubernetes-sigs)
- API `releases/tags/v0.46.0` returned 403 (see README).

## What it is
- Headlamp: Kubernetes web UI with plugin support. Go backend (`headlamp-server`) serves a React/TS frontend build.

## Build (Dockerfile)
| Stage | Base | Steps |
| --- | --- | --- |
| default-image-base | `alpine:3.24.2@sha256:294b...` | overridable via `ARG IMAGE_BASE` |
| backend-build | `golang:1.26.8@sha256:eb36...` | `GOOS/GOARCH` from TARGETOS/TARGETARCH; `CGO_ENABLED=0`; `cd ./backend && go mod download`; `go build -o ./headlamp-server ./cmd/` |
| frontend-build | `node:22@sha256:0e5f...` | `cd ./frontend && npm ci --only=prod` |
| frontend | frontend-build | `HEADLAMP_SOURCE_COMMIT`, `HEADLAMP_BUILD_MANIFEST` ARGs; `npm run build` with `./app` bind-mounted; copies plugins from `./.plugi*s` and `plugins-old` |
| static-plugins | frontend-build | `apt-get install jq`; `./fetch-plugins.sh /plugins/` using `container/build-manifest.json` |
| final | `image-base` (alpine default) | creates user/group `headlamp` (adduser/addgroup; apt branch for Debian bases); copies `/headlamp/headlamp-server`, `/headlamp/frontend`, `/headlamp/plugins`, `/headlamp/static-plugins`; `chown -R headlamp:headlamp /headlamp`; `USER headlamp` |

- `IMAGE_BASE` lets the final stage be built on another base (default alpine 3.24.2).

## Entrypoint/flags
- `ENTRYPOINT ["/headlamp/headlamp-server", "-html-static-dir", "/headlamp/frontend", "-plugins-dir", "/headlamp/plugins"]`. No CMD.

## Env vars (Dockerfile ENV)
| Name | Value |
| --- | --- |
| HEADLAMP_STATIC_PLUGINS_DIR | `/headlamp/static-plugins` |
| HEADLAMP_SOURCE_COMMIT | ARG (build) |
| HEADLAMP_BUILD_MANIFEST | ARG (build) |

## Ports
- `EXPOSE 4466`.

## Volumes/paths
- `/headlamp/plugins` (plugins dir), `/headlamp/frontend` (static UI), `/headlamp/static-plugins`. No VOLUME.

## User/UID
- `USER headlamp` (system user created in final stage).

## Plugins
- `container/build-manifest.json`: one plugin `prometheus`, archive `https://github.com/headlamp-k8s/plugins/releases/download/prometheus-0.9.1/prometheus-0.9.1.tar.gz`.
- `fetch-plugins.sh <destdir>`: reads manifest with jq, downloads each archive with curl, extracts `*/main.js`, `*/package.json`, `*/locales/*/translation.json`, copies into `<destdir>/<name>/`.

## Healthcheck
- None in Dockerfile.

## Version/asset naming
- Tag `v0.46.0`. Release assets served from kubernetes-sigs/headlamp (per plan). Checksums file per plan: `checksums.txt` on release (not fetched here).

## Arch
- Multi-arch via TARGETOS/TARGETARCH (backend). Frontend built on `$BUILDPLATFORM`.

## Gotchas
- Final stage requires `adduser`/`addgroup` (alpine branch) or apt (Debian branch); the `if command -v apt-get` branch covers both.
- `container/` scripts depend on `jq` (installed only in static-plugins stage).
- README points users to Artifact Hub for plugins, and in-cluster install docs at headlamp.dev.
