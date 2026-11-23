# dockerregistry — implementation plan
> Source: ./draft.md · Target: apps/dockerregistry/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `v3.1.2` (latest release, published 2026-09-24). Draft chart image is `registry:3`, same major. |
| Renovate | `datasource=github-releases depName=distribution/distribution versioning=semver` (tag has `v` prefix; keep it in `VERSION`, as `apps/bazarr` does) |
| License | Apache-2.0 (GitHub SPDX `Apache-2.0`); `LICENSE` is inside the release tarball |
| Source | https://github.com/distribution/distribution |
| amd64 URL | `https://github.com/distribution/distribution/releases/download/v3.1.2/registry_3.1.2_linux_amd64.tar.gz` |
| arm64 URL | `https://github.com/distribution/distribution/releases/download/v3.1.2/registry_3.1.2_linux_arm64.tar.gz` |
| Checksums | Per-asset `<asset>.sha256` files on the release. Content is the bare hash with no file name (checked for arm64). amd64 `40df2224d410f72ae425c3371873b078bbdbda3b8b612be9571f0e6751f3acc8` (matches my own `sha256sum` of the download), arm64 `09d26f88d2c0f161bd1b8bfc6c123571cc3d291dcca8af5477b3cacc4ec95e73` (equals what the upstream library Dockerfile pins). Also `*.provenance.json` assets exist (not used). |
| Tarball content | `registry` (static Go binary: no NEEDED libraries per `readelf -d`), `LICENSE`, `README.md` |
| Upstream library Dockerfile | Reviewed (`distribution/distribution-library-image`): `alpine:3.24`, installs `ca-certificates`, extracts `registry` to `/bin/`, copies `config-example.yml` to `/etc/distribution/config.yml`, `ENV OTEL_TRACES_EXPORTER=none`, `VOLUME /var/lib/registry`, `EXPOSE 5000`, entrypoint `/entrypoint.sh`, `CMD ["/etc/distribution/config.yml"]`. |
| Entrypoint | `entrypoint.sh`: if `$1` ends in `.yaml` or `.yml` then `registry serve "$@"`; if `$1` is `serve`, `garbage-collect`, `help` or starts with `-` then `registry "$@"`; then `exec "$@"`. |
| Config example | `config-example.yml` in the library image repo (read 2026-11-23): `version: 0.1`, `log.fields.service: registry`, `storage.cache.blobdescriptor: inmemory`, `storage.filesystem.rootdirectory: /var/lib/registry`, `http.addr: :5000`, `health.storagedriver` (enabled, interval 10s, threshold 3). Its `log.level` was `debug` in the output I read (UNVERIFIED whether that is current); re-read the file when implementing. |
| Env overrides | `REGISTRY_<SECTION>_<KEY>` with underscores for nesting, e.g. `REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY` (from the configuration docs). The docs advise a base config file plus env tweaks. |
| Endpoints | Port 5000. `GET /v2/` is the API version check (Registry HTTP API V2; UNVERIFIED in this session, confirm in the run). Debug server (`http.debug.addr`, `/debug/health`) is off unless configured. |

## 2. Target layout

```
apps/dockerregistry/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.yml     # seeded to /config/config.yml when missing
```

`defaults/` is needed for the base config (allow-listed in `.dockerignore`). Never `root/`. No `DOWNSTREAM_CHANGES.md`. App name follows the draft/chart (`dockerregistry`), the binary stays `registry`.

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```

Static Go binary from the release tarball, so no build stage is needed (the "Go build stage" rule applies only when compiling). Closest sibling: `apps/adguardhome-sync`.

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. `ENV HOME=/config OTEL_TRACES_EXPORTER=none` (the second as in upstream, to stop tracing exporter noise).
3. One `RUN`:
   - `curl -fsSL -o /tmp/registry.tar.gz "https://github.com/distribution/distribution/releases/download/${VERSION}/registry_${VERSION#v}_linux_${TARGETARCH}.tar.gz"` (`TARGETARCH` is `amd64` or `arm64`, matching the asset names, no mapping needed).
   - `curl -fsSL -o /tmp/registry.tar.gz.sha256 "<same URL>.sha256"`; verify with `echo "$(cat /tmp/registry.tar.gz.sha256)  /tmp/registry.tar.gz" | sha256sum -c -`.
   - `tar xzf /tmp/registry.tar.gz -C /tmp registry LICENSE` then `install -m 0755 /tmp/registry /app/registry`; `mkdir -p /usr/share/licenses/dockerregistry && cp /tmp/LICENSE /usr/share/licenses/dockerregistry/LICENSE`.
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -f /tmp/registry*  /tmp/LICENSE`.
   - Optional sanity: `/app/registry --version`.
4. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 5000`; `VOLUME /config`.

No apt packages (`ca-certificates` is already in the ubuntu base).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "dockerregistry" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=distribution/distribution versioning=semver
  default = "v3.1.2"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/distribution/distribution" }
```

Plus the standard blocks (`docker-metadata-action`, `group "default"`, `image`, `image-local` tagged `${APP}:${VERSION}`, `image-all` for amd64 and arm64) copied from `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/distribution/distribution"
ports:
  - port: 5000
    protocol: tcp
    required: true
env:
  - name: REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY
    default: "/config/data"
    required: false
  - name: REGISTRY_STORAGE_DELETE_ENABLED
    default: "false"
    required: false
  - name: REGISTRY_LOG_LEVEL
    default: "info"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Env names are real `REGISTRY_*` overrides (upstream docs). They are not exported by `start.sh`; they are read directly by the registry, and the defaults equal the values in `defaults/config.yml`. Add more only when verified. No dependencies.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data
[ -f /config/config.yml ] || cp /defaults/config.yml /config/config.yml

exec /app/registry serve "${REGISTRY_CONFIG:-/config/config.yml}"
```

`defaults/config.yml` (derived from upstream `config-example.yml` at the tag, with the path changed):

```yaml
version: 0.1
log:
  level: info
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /config/data
http:
  addr: :5000
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
```

`:5000` binds all interfaces. Do not name a custom env `REGISTRY_CONFIG` unless declared in `settings.yaml` (it is the script's own optional override; either declare it or drop it, prefer dropping). Never write to `/app`. Upload staging lives under the root directory, so it is on `/config`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5000'
http:
- port: '5000'
  path: /v2/
filePaths:
- /app/registry
- /usr/share/licenses/dockerregistry/LICENSE
```

`/v2/` answers 200 with `{}` without authentication (default config has no auth). No env needed. Check the exact `tcp` + `http` combination against a sibling. Not a DB app, so no narrowing.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/var/lib/registry` (blobs, manifests, uploads) | `/config/data` via config and env default |
| `/etc/distribution/config.yml` (baked into image) | `/config/config.yml`, seeded from `/defaults` |
| Garbage collection and uploads | Same root directory, no `/tmp` need |

Draft/chart expectations: runs as UID 0 with a writable rootfs, data on `/var/lib/registry`. Here UID 568, read-only rootfs OK, not privileged. Users migrating mount their old data at `/config/data` (or set `REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/var/lib/registry` and mount it there; it must be writable by UID 568).

## 10. Risks, caveats and open questions

- No authentication by default (draft caveat). Document `REGISTRY_AUTH_*` in the PR; no auth config is shipped.
- Docker clients need TLS for non-local registries; use a reverse proxy or `insecure-registries`. TLS in the registry itself would need extra files, out of scope.
- Deleted layers need `registry garbage-collect /config/config.yml` by hand; `exec` into the container works because the binary is at `/app/registry`.
- `storage.delete.enabled` default is false (docs), so deletions via the API fail until enabled. Settings expose it.
- Draft sizes it as "easy": confirmed (static binary with checksums).
- Chart's data path `/var/lib/registry` differs from this image's `/config/data`; migration needed.

## 11. Build and test steps

```sh
cd apps/dockerregistry
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name dockerregistry-probe --read-only --tmpfs /tmp -v dockerregistry-probe-config:/config -p 5000:5000 dockerregistry:v3.1.2
docker logs -f dockerregistry-probe     # expect "listening on [::]:5000"
curl -fsS http://127.0.0.1:5000/v2/
# push round trip: docker tag busybox localhost:5000/busybox && docker push localhost:5000/busybox
forgetool containers test --image dockerregistry:v3.1.2 --config ./apps/dockerregistry/container-test.yaml
docker rm -f dockerregistry-probe; docker volume rm dockerregistry-probe-config
```

Restart on the same volume and confirm the pushed image is still listed at `/v2/_catalog`.

## 12. PR checklist

- Branch `feat/add-dockerregistry`; commit `feat(dockerregistry): add new container`; target `main`; same PR title.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick only the boxes that apply; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; see the `license/cla` check).
- Untested until run: arm64, push/pull round trip, behavior behind TLS or auth, `garbage-collect`.
- Pre-completion: `bake --print` passes, VERSION aligned between Dockerfile and bake, empty `/config` starts, no `DOWNSTREAM_CHANGES.md`.
