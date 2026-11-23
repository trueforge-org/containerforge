# external-service — implementation plan
> Source: ./draft.md · Target: apps/external-service/ · Difficulty: easy · Role: main (TrueCharts `external-service` chart placeholder pod) · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Upstream project | Alpine Linux minirootfs, used by the chart only as a do-nothing placeholder (https://alpinelinux.org/) |
| Version (draft tag) | `alpine:3.24.4`. Verified on https://alpinelinux.org/downloads/ as the latest stable (released 2026-11-05). |
| Version to use in the image | `26.04`, the Ubuntu userland that is really in the image (see section 5). `3.24.4` is NOT used as `VERSION` because nothing from Alpine ships in the image. |
| Renovate | `datasource=docker depName=docker.io/library/ubuntu` (same as `apps/ubuntu/docker-bake.hcl`), default versioning |
| License | No upstream application. The image only contains the ContainerForge ubuntu base plus a keepalive script. Use the repo license `AGPL-3.0-or-later`, as sibling apps do. UNVERIFIED: whether maintainers prefer another SPDX id for a placeholder. |
| Source URL | https://alpinelinux.org/ (draft). Alternative: https://github.com/trueforge-org/containerforge. Pick one and use it for both `SOURCE` and `upstream_env_url`. |
| Download URLs | Not needed. For reference only: amd64 `https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/x86_64/alpine-minirootfs-3.24.4-x86_64.tar.gz`, arm64 `https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/aarch64/alpine-minirootfs-3.24.4-aarch64.tar.gz`. Checksum files exist at the same paths with a `.sha256` suffix. |
| Checksum source | Not applicable, nothing is downloaded. |
| Upstream Dockerfile reviewed | https://github.com/alpinelinux/docker-alpine (`x86_64/Dockerfile`, pinned commit in the draft): `FROM scratch` + `ADD alpine-minirootfs-...tar.gz /` + `CMD ["/bin/sh"]`. No ports, env vars or volumes. |
| Ports / env / paths | None. The chart only needs a pod that stays alive so its Service/Endpoints can point to an external address. UNVERIFIED: the chart's own command/args (not fetched), so the keepalive command is an assumption from the draft ("ubuntu base plus keepalive"). |

## 2. Target layout

```
apps/external-service/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
- `start.sh`: the base entrypoint (`/entrypoint.sh`) runs `/start.sh` if present, else needs a command. A baked-in keepalive is the whole app.
- No `defaults/`, `etc/`, `scripts/`, `health/`: nothing to seed. Never use `root/`.
- No `DOWNSTREAM_CHANGES.md`: nothing in this repo is expected to use it as `FROM`.

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```
Why: draft says "ubuntu alone is enough". Closest sibling: `apps/steamcmd` (ubuntu base, almost only `start.sh`) and `apps/adguardhome-sync` (shape of Dockerfile). `tini`, `bash`, `coreutils` (`sleep infinity`) already exist in the base.

## 4. Dockerfile

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION

USER apps
COPY --chmod=0755 . /

VOLUME /config
```
Step notes:
1. `ARG VERSION` is kept for bake alignment. It is not consumed by any command (label-only). Optionally `LABEL org.opencontainers.image.version="${VERSION}"`.
2. No `USER root` and no `apt-get`: nothing to install (ubuntu base already provides everything).
3. No download, so no checksum or `/usr/share/licenses/external-service/` step.
4. No `ENV`: the base already sets `HOME=/config`.
5. No `EXPOSE`: the app listens on nothing (draft: ports none).
6. `COPY --chmod=0755 . /` is mandatory; it places `/start.sh` through the allow-list in `include/.dockerignore`.
7. `VOLUME /config` for consistency with siblings; the app does not write to it.
8. Final `USER apps`.
Do not set `ENTRYPOINT`/`CMD`; the base `ENTRYPOINT ["/usr/bin/tini","--","/entrypoint.sh"]` execs `/start.sh`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "external-service"
}

variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/library/ubuntu
  default = "26.04"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://alpinelinux.org/"
}
```
Followed by the four standard blocks copied from `apps/adguardhome-sync/docker-bake.hcl`: `group "default" { targets = ["image-local"] }`, `target "image"` (inherits `docker-metadata-action`, `args.VERSION`, labels `org.opencontainers.image.source` and `.licenses`), `target "image-local"` (`output = ["type=docker"]`, `tags = ["${APP}:${VERSION}"]`), `target "image-all"` (`linux/amd64`, `linux/arm64`).
Validate: `cd apps/external-service && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://alpinelinux.org/"
ports:
  []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
```
- `ports: []` (same form as `apps/python/settings.yaml`), because nothing listens.
- `TZ` is read by the ubuntu base (`tzdata`) and used by `apps/adguardhome-sync/settings.yaml`. UNVERIFIED that `/entrypoint.sh` consumes it; if not, drop `env` to `[]` like `apps/python`.
- `dependencies:` omitted: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
# Placeholder container: keep the pod alive so an external Service can point at it.
echo "[external-service] placeholder container running, nothing to serve"
exec sleep infinity
```
- Idempotent, writes nothing, needs no `/config` seeding, no network binding.
- `exec` so `tini` signal handling reaches `sleep` (SIGTERM ends it immediately).
- Mode 0755 comes from the Dockerfile `COPY --chmod`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /start.sh
```
- No port is declared in `settings.yaml`, so there is no tcp/http probe to add. The assertion is file existence plus the container staying up (the main runner runs the image as built; `start.sh` is the keepalive).
- `timeoutSeconds` omitted: the schema enforces a 180 s minimum anyway and the app starts instantly.
- Not narrowed for DB reasons: no DB dependency.
- Do not copy `mainRunner.cmd: "sleep 999"` from `apps/ubuntu`; that is only needed because the ubuntu image has no `start.sh`.

## 9. Rootless and read-only-rootfs adaptations

| Concern | Handling |
|---|---|
| Write paths | None. `sleep` writes nothing. `/tmp` unused. |
| UID | Draft expects UID 568, non-root: matches base user `apps` (568). |
| `readOnlyRootFilesystem` | Draft expects true: satisfied (no writes at all). |
| Privileged | No: satisfied. |
| Extra persistence | Draft: none. `/config` is declared only for convention. |
| Draft security expectations | All reconciled; nothing to change. |

## 10. Risks, caveats and open questions

- Draft caveat: placeholder only, nothing to configure or use. Real behaviour (the chart's own command) is not verified.
- The `3.24.4` tag from the chart is deliberately not reproduced; the chart's `image.tag` will point at this image's tag (`26.04`). Whoever migrates the chart must update the tag, and must not rely on an Alpine userland (musl, `apk`, BusyBox `sh`). UNVERIFIED whether the chart executes anything inside the pod besides the keepalive.
- Open question: use `26.04` (honest to contents) or track Alpine `3.24.4`. The Dockerfile rules require the image to contain the version it is tagged with, so `26.04` is recommended.
- Image is much larger than Alpine minirootfs (~5 MB vs the Ubuntu base). Accepted by the draft.
- No blockers: no musl-only, GPU, privileged or arm64 limits (both arches build from the same base).

## 11. Build and test steps

```sh
cd apps/external-service
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create external-service-probe-config
docker run --rm -d --name external-service-probe --read-only --tmpfs /tmp \
  -v external-service-probe-config:/config external-service:26.04
docker logs external-service-probe        # expect the "placeholder container running" line, container still Up
docker rm -f external-service-probe; docker volume rm external-service-probe-config
forgetool containers test --image external-service:26.04 --config ./apps/external-service/container-test.yaml
```
Readiness signal: the startup line from `start.sh` and the container still running after about 10 s. Cap at 10 build/run/test rounds.

## 12. PR checklist

- [ ] Branch `feat/add-external-service`; commit and PR title `feat(external-service): add new container`, target `main`.
- [ ] Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only boxes that apply.
- [ ] Notes section contains `🤖 This PR is AI generated.` (no "Generated with" line).
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign; check `license/cla` on the PR.
- [ ] `docker buildx bake --print` passed; Dockerfile `ARG VERSION` equals bake `VERSION`.
- [ ] Not tested until run: build, empty-`/config` start under `--read-only`, forgetool test, arm64 build. Say so in the PR and do not tick "Built container locally" unless done.
- [ ] No `DOWNSTREAM_CHANGES.md` needed.
