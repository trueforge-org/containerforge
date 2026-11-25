# reg — implementation plan
> Source: ./draft.md · Target: apps/reg/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Latest stable | `v3.1.2` (GitHub release, published 2026-09-24). Draft also says 3.1.2 (`registry:3`). |
| Renovate | `datasource=github-releases depName=distribution/distribution versioning=semver` |
| License | Apache-2.0 (GitHub API `license.spdx_id`; the archive ships a `LICENSE` file per the upstream releaser stage) |
| Source URL | https://github.com/distribution/distribution |
| amd64 | https://github.com/distribution/distribution/releases/download/v3.1.2/registry_3.1.2_linux_amd64.tar.gz |
| arm64 | https://github.com/distribution/distribution/releases/download/v3.1.2/registry_3.1.2_linux_arm64.tar.gz |
| Checksums | One `.sha256` asset per tarball (`registry_3.1.2_linux_<arch>.tar.gz.sha256`). Upstream library image pins amd64 `40df2224d410f72ae425c3371873b078bbdbda3b8b612be9571f0e6751f3acc8`, arm64 `09d26f88d2c0f161bd1b8bfc6c123571cc3d291dcca8af5477b3cacc4ec95e73`. |
| Tarball contents | `registry`, `README.md`, `LICENSE` (from upstream `releaser` stage in distribution's Dockerfile). Static binary (`CGO_ENABLED=0`, `xx-verify --static`), so it runs on glibc Ubuntu. |
| Start command | `registry serve <config.yml>` (upstream image: `ENTRYPOINT registry`, `CMD serve /etc/distribution/config.yml`; the library-image `entrypoint.sh` rewrites `*.yml` to `registry serve *.yml` then `exec`). |
| Port | 5000 (`EXPOSE 5000`, config `http.addr: :5000`). The example config also opens a debug/metrics server on 5001; do not enable it. |
| Env | `OTEL_TRACES_EXPORTER=none` is set in the upstream image. UNVERIFIED: the `REGISTRY_<SECTION>_<KEY>` config override convention is from the Distribution docs and not re-fetched here; confirm during the build with one override. |
| Upstream Dockerfiles reviewed | https://github.com/distribution/distribution-library-image/blob/775973b655bb4b11561db92a1cf50113148ce530/Dockerfile (alpine, per-arch tarball + sha256, `config-example.yml`, VOLUME `/var/lib/registry`) and distribution/distribution `Dockerfile`. |

## 2. Target layout

```
apps/reg/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.yml     # seed config, copied to /config/config.yml only when missing
```
- No `root/`. No `DOWNSTREAM_CHANGES.md` (no other Dockerfile uses `apps/reg` as FROM; the draft says it matches an existing "dockerregistry" chart image, and `apps/` has no `dockerregistry` or `registry` folder).
- App name `reg` follows the draft folder. Open question: `distribution` or `registry` would be a more accurate name (see section 10).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

A static Go binary needs no runtime stack, so plain ubuntu is enough (`curl`, `tar`, `sha256sum` are already used the same way by `apps/adguardhome-sync`). Closest sibling: `apps/adguardhome-sync` (release tarball extracted to `/app`, config seeded from `defaults/`).

## 4. Dockerfile

Single stage (the binary is a prebuilt release, so the Go "build stage" rule does not apply).

1. `ARG VERSION`, `ARG TARGETARCH` (values `amd64`/`arm64` map 1:1 onto the asset names, no mapping needed).
2. `USER root` for the install step only.
3. `ENV HOME=/config OTEL_TRACES_EXPORTER=none`.
4. One `RUN`:
```sh
set -eux
base="https://github.com/distribution/distribution/releases/download/v${VERSION#v}"
f="registry_${VERSION#v}_linux_${TARGETARCH}.tar.gz"
curl -fsSL -o "/tmp/${f}" "${base}/${f}"
curl -fsSL -o "/tmp/${f}.sha256" "${base}/${f}.sha256"
echo "$(cut -d' ' -f1 "/tmp/${f}.sha256")  /tmp/${f}" | sha256sum -c -
mkdir -p /tmp/registry /usr/share/licenses/reg
tar xzf "/tmp/${f}" -C /tmp/registry
install -m 0755 /tmp/registry/registry /app/registry
install -m 0644 /tmp/registry/LICENSE /usr/share/licenses/reg/LICENSE
chown -R apps:apps /app && chmod -R 755 /app
rm -rf /tmp/registry "/tmp/${f}" "/tmp/${f}.sha256"
```
   The v3.1.2 `.sha256` assets are a bare hash (checked for both arches, and equal to the library-image pins); `cut` handles that.
5. `USER apps`, then `COPY --chmod=0755 . /`.
6. `EXPOSE 5000`, `VOLUME /config`.
- No apt packages. Cache/HOME go to `/config`/`/tmp`; nothing is written to `/app`.

## 5. docker-bake.hcl

Copy `apps/adguardhome-sync/docker-bake.hcl` and set:
```hcl
variable "APP" { default = "reg" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=distribution/distribution versioning=semver
  default = "3.1.2"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/distribution/distribution" }
```
Keep `docker-metadata-action`, `image` (args VERSION, labels source/licenses), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default" { targets = ["image-local"] }`. Validate with `docker buildx bake --print`. Note: the release tag has a `v` prefix, so the renovate version `3.1.2` is re-prefixed in the Dockerfile URL.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/distribution/distribution"
ports:
  - port: 5000
    protocol: tcp
    required: false
env:
  - name: OTEL_TRACES_EXPORTER
    default: "none"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
- Dependencies: none.
- `REGISTRY_*` overrides are not listed individually (they are open-ended); mention them in the PR notes.

## 7. start.sh

```sh
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config/data
[ -f /config/config.yml ] || cp /defaults/config.yml /config/config.yml
export OTEL_TRACES_EXPORTER="${OTEL_TRACES_EXPORTER:-none}"
exec /app/registry serve /config/config.yml
```
`defaults/config.yml` (own file, modeled on the `config-example.yml` of `distribution-library-image` at the commit in section 1, but without the debug server and with rootless paths. The `cmd/registry/config-example.yml` in the `distribution` repo at `v3.1.2` is different: it enables htpasswd auth, so do not copy that one unchanged):
```yaml
version: 0.1
log:
  level: info
  fields:
    service: registry
storage:
  filesystem:
    rootdirectory: /config/data
  delete:
    enabled: true
  cache:
    blobdescriptor: inmemory
http:
  addr: :5000
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
```
`http.addr: :5000` binds all interfaces. That example uses `log.level: debug`; `info` is chosen for production. `delete.enabled: true` comes from the same example. With no auth this also lets any client delete images, so a maintainer should confirm it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '5000'
http:
- port: '5000'
  path: /v2/
filePaths:
- /app/registry
- /usr/share/licenses/reg/LICENSE
```
`GET /v2/` returns 200 with no auth configured (Distribution API version check). `timeoutSeconds` is a guess (adguardhome-sync has none; bookstack uses 180); keep 60 unless slow. No env needed, so everything runs in the test.

## 9. Rootless and read-only-rootfs adaptations

- Draft: non-root 568, readOnlyRootFilesystem true, `/config` mount, no extra persistence. Matches: user `apps`, binary in read-only `/app`.
- Writes: image blobs, manifests and uploads go to `rootdirectory: /config/data` (persistent). Nothing else needs write access; the registry does not use `/tmp` for uploads when the filesystem driver is used (UNVERIFIED, check with a push test under `--read-only --tmpfs /tmp`).
- Config seeded only when `/config/config.yml` is missing, so user edits (auth, TLS, proxy) survive restarts.

## 10. Risks, caveats and open questions

- Draft caveat: the config needs `storage`, `http` and optional `auth`; the seeded default has no auth, so anyone who can reach port 5000 can push. Document htpasswd/token auth in PR notes; do not ship a default credential.
- Draft caveat: pushing needs TLS or `insecure-registries` on clients. Not solved here; TLS settings are user config in `/config/config.yml`.
- Naming: `reg` is the TrueCharts chart name, but the binary is the Distribution `registry`; the draft says it is the same `registry:3` image as another chart, `dockerregistry`. Confirm whether a second app is wanted before creating both.
- Draft mentions `genuinetools/reg` (a CLI client) as a resource; that is a different project and is not used.
- No blockers: static binary, amd64 and arm64 assets exist.

## 11. Build and test steps

```sh
cd apps/reg
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name reg-probe -p 5000:5000 --read-only --tmpfs /tmp -v reg-probe-config:/config reg:3.1.2
docker logs -f reg-probe          # expect: "listening on [::]:5000"
curl -fsS http://localhost:5000/v2/   # through the published port (also try from another container); expect {} / 200
docker rm -f reg-probe; docker volume rm reg-probe-config
forgetool containers test --image reg:3.1.2 --config ./apps/reg/container-test.yaml
```
Extra manual check: push and pull one image to confirm uploads work on a read-only rootfs. Optionally try `--platform linux/arm64`.

## 12. PR checklist

- Branch `feat/add-reg`, commit and PR title `feat(reg): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` keeping its sections; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- State honestly what is untested: arm64 build and run, `REGISTRY_*` env overrides, push/pull on read-only rootfs, until actually executed.
- Check boxes only for steps really done; "Built container locally" only if built.
