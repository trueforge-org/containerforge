# generic-device-plugin — implementation plan
> Source: ./draft.md · Target: apps/generic-device-plugin/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.2.0` (annotated git tag peeled to commit `a3d6f47`). Also mirrored as tag `generic-device-plugin-0.2.0`. Draft pins `ghcr.io/squat/generic-device-plugin:latest` by digest (`sha256:6fd80237…`, from the TrueCharts chart); the plan does not use that image and builds the source tag instead. Release date of 0.2.0: 2026-10-19 (GitHub release listing). Source: https://github.com/squat/generic-device-plugin |
| Renovate | `datasource=github-tags depName=squat/generic-device-plugin versioning=semver` (tag `0.2.0`, not `generic-device-plugin-*`). |
| License | Apache-2.0. Source: https://raw.githubusercontent.com/squat/generic-device-plugin/f7c3291/LICENSE |
| Source URL | https://github.com/squat/generic-device-plugin |
| Download | Source tarball `https://github.com/squat/generic-device-plugin/archive/refs/tags/${VERSION}.tar.gz`. No standalone binary release. The 0.2.0 release ships only a Helm chart (`generic-device-plugin-0.2.0.tgz`). |
| Per-arch download URLs | None. Compile per arch from source. |
| Checksum source | None published upstream for the source tarball. Pinned by tag; record the sha256 of the fetched tarball in the Dockerfile comment at implementation time, or verify it against the commit (UNVERIFIED: no upstream checksum file exists). |
| Upstream Dockerfile reviewed | `Dockerfile` at f7c3291: `nixos/nix:2.35.3` builds `.#generic-device-plugin-cross-$TARGETOS-$TARGETARCH`, final `FROM scratch`, `ENTRYPOINT ["/generic-device-plugin"]`. The Nix flake (`flake.nix`, 0.2.0) uses `buildGoModule`, `CGO_ENABLED=0`, `ldflags -s -w -X github.com/squat/generic-device-plugin/version.Version=…`, `vendorHash = null`. Module `github.com/squat/generic-device-plugin`, `go 1.25.0`. The main package is at the repo root (`main.go`, Apache-2.0 header). |
| Listen address | `viper.GetString("listen")` used with `net.Listen("tcp", listen)`. Default value is set outside the reviewed file (UNVERIFIED). |
| Flags / env | Viper keys read in `main.go`: `domain` (DNS-1123 subdomain, required), `device` (device specs), `log-level`, `listen`, `plugin-directory`. Viper env binding not seen in `main.go` (UNVERIFIED whether env vars are accepted). |
| Ports | TrueCharts chart: service `main` 8080/tcp (values.yaml). Whether the binary listens on 8080 by default is UNVERIFIED. |
| Data / write paths | `plugin-directory` (device-plugin socket dir, chart: `/var/lib/kubelet/device-plugins`). Default unknown (UNVERIFIED). `/dev` is read for device discovery (chart hostPath `/dev`). |
| Chart security | `readOnlyRootFilesystem: true`, `privileged: true`, `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/generic-device-plugin/values.yaml |
| Dependencies | None. |
| Operating context | Kubernetes device plugin. It registers with the kubelet over the device-plugins socket. Without a kubelet the plugin is not functional (inferred from design; see section 10). |

## 2. Target layout

- `apps/generic-device-plugin/Dockerfile`
- `apps/generic-device-plugin/docker-bake.hcl`
- `apps/generic-device-plugin/settings.yaml`
- `apps/generic-device-plugin/container-test.yaml`
- `apps/generic-device-plugin/start.sh`

No `defaults/`, `etc/`, `health/`, `root/` needed: the plugin takes all config from args and has no config file. `DOWNSTREAM_CHANGES.md` not needed (no downstream `FROM`; verify with `grep -rl "apps/generic-device-plugin\|generic-device-plugin" apps/*/Dockerfile` before the PR).

## 3. Base image

Build stage: `docker.io/library/golang:1.27` (go.mod needs at least 1.25.0; the official image is the build toolchain, not shipped). Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.

Pinned Go image digest is UNVERIFIED: resolve it at implementation time and pin it. Alternative: `apt-get install golang-go` on the ubuntu build stage, as `apps/pwndrop` does, but the Ubuntu Go version is UNVERIFIED against `go 1.25.0`, so the official image is preferred.

Closest siblings: `apps/pwndrop` (Go build stage, then `COPY --from=buildstage` into the ubuntu runtime stage). Upstream final stage is `scratch`, which is not a ContainerForge base, so it is replaced by ubuntu.

## 4. Dockerfile

1. `FROM docker.io/library/golang:1.27@sha256:<UNVERIFIED> AS build`, `ARG VERSION`, `ARG TARGETOS`, `ARG TARGETARCH`.
2. Fetch: `curl -fL https://github.com/squat/generic-device-plugin/archive/refs/tags/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1` (use `/tmp`, not `/app`).
3. Build (mirrors the Nix flake, no Nix):
   ```dockerfile
   RUN cd /tmp/src && CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
     GOCACHE=/tmp/gocache GOPATH=/tmp/gopath \
     go build -trimpath -ldflags "-s -w -X github.com/squat/generic-device-plugin/version.Version=${VERSION}" \
     -o /tmp/out/generic-device-plugin .
   ```
   `GOCACHE` and `GOPATH` point at `/tmp` (protocol rule). `go mod download` is implicit through `go build`; use `-mod=mod` only if vendoring is absent (check `vendor/` in the tarball).
4. Final stage: `FROM <ubuntu>`, `ARG VERSION`, `USER root`.
5. `COPY --from=build /tmp/out/generic-device-plugin /app/generic-device-plugin/generic-device-plugin`, `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/generic-device-plugin/LICENSE`.
6. `chown -R apps:apps /app/generic-device-plugin && chmod -R 755 /app/generic-device-plugin`.
7. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   EXPOSE 8080
   VOLUME /config
   ```
   `VOLUME /config` is required by the protocol even though the plugin writes nothing there; it is also how `settings.yaml` exposes `/config`.
8. No apt packages are needed beyond the base (`curl`, `tar` already present).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "generic-device-plugin" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=squat/generic-device-plugin versioning=semver
  default = "0.2.0"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE" { default = "https://github.com/squat/generic-device-plugin" }
```

Use the four standard targets (`docker-metadata-action`, `image`, `image-local`, `image-all`) and `group "default" { targets = ["image-local"] }` from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` in `apps/generic-device-plugin/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/squat/generic-device-plugin"
ports:
  - port: 8080
    protocol: tcp
    required: false   # UNVERIFIED: list only once the listen default is confirmed in step 3
env:
  - name: DOMAIN
    default: "truecharts.org"
    required: false
  - name: LISTEN
    default: "0.0.0.0:8080"
    required: false
  - name: LOG_LEVEL
    default: "info"
    required: false
  - name: PLUGIN_DIR
    default: "/tmp/device-plugins"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Env: `DOMAIN`, `LISTEN`, `LOG_LEVEL`, `PLUGIN_DIR` are image-level names read only by `start.sh` (which maps them to the verified flags `--domain`, `--listen`, `--log-level`, `--plugin-directory`); the binary itself does not read them (UNVERIFIED whether it reads any env). Defaults match `start.sh`. `required` flags stay false because the plugin needs args (`--domain`, `--device`), which are not env. Ports: keep 8080 only if step 3 shows the listener; otherwise remove it and drop the matching probe.

## 7. start.sh

Idempotent wrapper that builds the arg list from optional env values and then `exec`s the binary. Keep `/config` untouched (no state). Plan:

```bash
#!/usr/bin/env bash

DOMAIN="${DOMAIN:-truecharts.org}"   # placeholder default; UNVERIFIED default for ContainerForge
LISTEN="${LISTEN:-0.0.0.0:8080}"
LOG_LEVEL="${LOG_LEVEL:-info}"
PLUGIN_DIR="${PLUGIN_DIR:-/tmp/device-plugins}"

mkdir -p "${PLUGIN_DIR}"
exec /app/generic-device-plugin/generic-device-plugin \
  --domain "${DOMAIN}" --listen "${LISTEN}" --log-level "${LOG_LEVEL}" \
  --plugin-directory "${PLUGIN_DIR}" "$@"
```

Notes: `--device` is a YAML block in the chart, so `start.sh` must not hard-code it; pass it through `"$@"` or from a config file under `/config` (not implemented here, to stay minimal). Bind `0.0.0.0`, not localhost (protocol rule). Do not write to `/app`. Plugin socket dir must be on a writable path: `/tmp` under read-only rootfs, or a hostPath in Kubernetes (chart value).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8080'
filePaths:
- /app/generic-device-plugin/generic-device-plugin
- /usr/share/licenses/generic-device-plugin/LICENSE
```

Only if 8080 is confirmed (section 6). If the plugin exits without a kubelet (section 10), this suite cannot pass honestly; do not add a `http` or `process` probe that hides a crash. Test runs with no env vars, so `--domain` default must make startup succeed without any env: confirm in step 3.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path / need | Remap |
| --- | --- |
| Device-plugin socket dir (`/var/lib/kubelet/device-plugins`, chart hostPath) | `plugin-directory` default changed to `/tmp/device-plugins` in standalone mode. In Kubernetes the chart still mounts the hostPath; that is a chart decision, not an image one. |
| `/dev` device discovery (chart hostPath `/dev`) | Read-only access is enough to discover nodes, but creating device nodes or passing device files requires the host `/dev` mount and typically privileged. Not an image change. |
| `GOCACHE` / build caches | `/tmp` only, in the build stage. |
| Runtime user | Upstream chart forces root and `privileged: true`. The image itself does not need root for listing `/dev` in the common case, but `USER apps` is the ContainerForge rule. Whether `apps` can read device nodes and open the kubelet socket is UNVERIFIED and is the main reconciliation point: the chart's root and privileged settings are expectations to verify, not requirements the image can drop. |
| `readOnlyRootFilesystem` | Compatible: the binary and `/config` are the only writable locations, and `/config` is not written. |

## 10. Risks, caveats and open questions

- **Standalone readiness (blocker risk).** Protocol step 3 requires the process to stay up and log a readiness signal. A device plugin normally registers with the kubelet at start; without the kubelet socket it may log errors and exit. Verify in step 3 before writing `container-test.yaml`. If it exits, record `unfixable` or ask the user whether a non-kubelet mode exists (UNVERIFIED).
- Privileged access: chart sets `privileged: true`, runs as root. ContainerForge rule is `USER apps`. Whether the plugin works as `apps` is UNVERIFIED. Do not add root to make tests pass.
- The Nix build is replaced by a plain `go build`. Output may differ from upstream (no Nix `--impure`, no `filter-syscalls` option). The `-trimpath` flag is an addition and is UNVERIFIED against upstream output.
- Upstream release has no binary. The image is only as good as the local Go build for each arch. arm64 build is UNVERIFIED until built.
- Draft caveat that `:latest` changes behaviour: the plan pins `0.2.0`, so this is resolved by design.
- Listening port 8080 and default `--listen`: UNVERIFIED.
- Draft says `hard` difficulty is correct: hardware/host access by design.

## 11. Build and test steps

From `apps/generic-device-plugin/`, with the protocol's commands:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name generic-device-plugin-probe --read-only --tmpfs /tmp \
  -v generic-device-plugin-probe-config:/config generic-device-plugin:0.2.0
docker logs -f generic-device-plugin-probe
forgetool containers test --image generic-device-plugin:0.2.0 --config ./container-test.yaml
docker rm -f generic-device-plugin-probe; docker volume rm generic-device-plugin-probe-config
```

Expected readiness signal: a listen log line on the chosen address (exact text UNVERIFIED until step 3). Also run once with a `--device` config to exercise the non-default path (not covered by the test suite, since tests have no env).

## 12. PR checklist

- Branch `feat/add-generic-device-plugin`; commit `feat(generic-device-plugin): add new container`; PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only they can sign; the `license/cla` check shows status).
- Say what was not tested: arm64 build, the kubelet integration, and any path needing `/dev` or privileges, unless verified.
- Do not check "Built container locally" unless step 2 and 3 passed.
- Confirm no other app has `FROM` on this image before the PR (no `DOWNSTREAM_CHANGES.md` expected).
