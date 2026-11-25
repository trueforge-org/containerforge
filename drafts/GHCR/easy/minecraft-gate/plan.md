# minecraft-gate — implementation plan
> Source: ./draft.md · Target: apps/minecraft-gate/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.82.3 (GitHub release, published 2026-11-22). Source: https://github.com/minekube/gate/releases/latest. The draft pins v0.82.0 and the chart runs the rolling `ghcr.io/minekube/gate:latest`; the plan uses 0.82.3, the current stable release. |
| Renovate | `datasource=github-releases depName=minekube/gate versioning=semver` |
| License | Apache-2.0 (https://raw.githubusercontent.com/minekube/gate/master/LICENSE) |
| Source URL | https://github.com/minekube/gate |
| Download amd64 | https://github.com/minekube/gate/releases/download/v0.82.3/gate_0.82.3_linux_amd64 (confirmed asset name, https://github.com/minekube/gate/releases/expanded_assets/v0.82.3) |
| Download arm64 | https://github.com/minekube/gate/releases/download/v0.82.3/gate_0.82.3_linux_arm64 (confirmed asset name) |
| Musl variants | `gate_0.82.3_linux_amd64_musl` / `_arm64_musl` exist. Not used: glibc Ubuntu base. |
| Checksum source | `checksums.txt` on the same release (asset name confirmed). Hash values UNVERIFIED: file contents were not fetched. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/minekube/gate/master/Dockerfile: golang:1.27 build with `CGO_ENABLED=0`, distroless `gcr.io/distroless/base-debian12` final, `ENTRYPOINT ["/gate"]`, `VOLUME ["/var/cache/gate"]`, `XDG_CACHE_HOME=/var/cache/gate`. No USER, EXPOSE or CMD. The jre stage (eclipse-temurin) is a separate variant, not used. |
| Ports | 25565/tcp (Minecraft proxy). Confirmed only by the draft (the upstream Dockerfile has no EXPOSE). |
| Env vars | Upstream sets only `XDG_CACHE_HOME`. Gate's own config env vars: UNVERIFIED (README/config docs not fetched). Do not invent any. |
| Config file | Gate reads a config file; its default path and name: UNVERIFIED (docs at https://gate.minekube.com not fetched). The chart mounts a `config.yml` (draft). |
| Dependencies | At least one reachable Minecraft backend server (external, not a ContainerForge app). |

## 2. Target layout

- `apps/minecraft-gate/Dockerfile`
- `apps/minecraft-gate/docker-bake.hcl`
- `apps/minecraft-gate/settings.yaml`
- `apps/minecraft-gate/container-test.yaml`
- `apps/minecraft-gate/start.sh`

No `defaults/` unless a default config is confirmed (see section 10). No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Gate is a static Go binary, so no runtime packages are needed. Closest sibling: `apps/adguardhome-sync` (single binary download, same layout). No runtime image needed (draft: "ubuntu alone is enough").

## 4. Dockerfile

1. `# syntax` not required. `FROM <ubuntu> AS base` and `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download and verify in one step (no separate build stage: the upstream binary is used, not compiled here):
   - `curl -fL -o /tmp/gate "https://github.com/minekube/gate/releases/download/v${VERSION}/gate_${VERSION}_linux_${TARGETARCH}"`
   - `curl -fL -o /tmp/checksums.txt "https://github.com/minekube/gate/releases/download/v${VERSION}/checksums.txt"`
   - `cd /tmp && grep " gate_${VERSION}_linux_${TARGETARCH}$" checksums.txt | sha256sum -c -` (confirm the checksum line format once the file is fetched at build time; UNVERIFIED).
3. `install -m 0755 /tmp/gate /app/gate`, then `chown -R apps:apps /app` and `chmod -R 755 /app`.
4. License: Apache-2.0 is in the source tarball only. Fetch `LICENSE` from `https://raw.githubusercontent.com/minekube/gate/v${VERSION}/LICENSE` and install to `/usr/share/licenses/minekube-gate/LICENSE` (optional if the binary is shipped without notices, per dockerfile rule for downloads).
5. Cleanup: `rm -f /tmp/gate /tmp/checksums.txt`.
6. `ENV HOME=/config XDG_CACHE_HOME=/tmp/gate-cache`. Override the upstream `/var/cache/gate` (not writable at runtime). Caches go to `/tmp`.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 25565
VOLUME /config
```

The `ARG VERSION` default must match `docker-bake.hcl`. Use `curl`'s `-fL` so a missing asset fails the build.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "minecraft-gate"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=minekube/gate versioning=semver
  default = "0.82.3"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/minekube/gate"
}

group "default" {
  targets = ["image-local"]
}

target "image" { ... }        // inherits docker-metadata-action, args VERSION, OCI source and licenses labels
target "image-local" { ... }  // inherits image, output docker, tags ${APP}:${VERSION}
target "image-all" { ... }    // inherits image, platforms linux/amd64 and linux/arm64
```

The four targets and group copy `apps/adguardhome-sync/docker-bake.hcl` exactly. Validate with `docker buildx bake --print` from `apps/minecraft-gate`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/minekube/gate"
ports:
  - port: 25565
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Ports: 25565/tcp is from the draft and the chart; upstream has no EXPOSE, so it is confirmed only by the draft (flag in section 10). Env: only TZ until Gate's config env vars are confirmed. Dependencies: none in the ContainerForge sense; the backend Minecraft server is external.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config /tmp/gate-cache
cd /config

exec /app/gate "$@"
```

- Config file seeding: none confirmed. If a default config is needed for an empty `/config`, copy it from `/defaults/` with `cp -n` (sibling pattern in `apps/adguardhome-sync/start.sh`). Requires a verified default and `defaults/` in the include allow-list (it is allowed).
- The exact config flag (for example `--config`) is UNVERIFIED. Do not guess it; check the Gate docs or `gate --help` on the built image, then wire it in with `CONFIGFILE:-/config/config.yml` style, as `apps/adguardhome-sync` does.
- Bind: Gate listens on the configured address; ensure it binds all interfaces (`0.0.0.0:25565` or `:25565`) per the start-script rule. Confirm the default bind (UNVERIFIED).
- `exec` the binary so signals reach PID 1.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '25565'
filePaths:
- /app/gate
- /start.sh
```

- Every settings port has a tcp probe (25565).
- No http probe: no HTTP port is confirmed.
- The test runs with no env vars. Gate may refuse to start without a backend in its config. If it exits on an empty `/config`, the tcp probe fails; the fix is a valid default config (section 10), not a weaker test.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/cache/gate` (`XDG_CACHE_HOME`, `VOLUME`) | `XDG_CACHE_HOME=/tmp/gate-cache`; no VOLUME for cache |
| Config file (chart: `/config.yml` configmap) | `/config` (persistent) |
| Binary | `/app/gate` (read-only at runtime) |

- Runs as `apps` (UID from the base image). No privileged, no extra capabilities.
- Rootfs: read-only with `--tmpfs /tmp`; `/config` is the only persistent write path.
- Draft expectations: non-root yes, read-only yes, privileged no, extra persistence none. Reconciled: no conflicts.

## 10. Risks, caveats and open questions

- Version: draft pinned v0.82.0; current stable is v0.82.3. Confirm the chosen tag before build. The chart's `latest` tag is rolling and must not be used.
- UNVERIFIED: checksum hash values and checksum file line format (`checksums.txt` not fetched).
- UNVERIFIED: Gate's config file name, default path, and whether it starts without a config. Without a verified default the empty-`/config` start may fail; the readiness check depends on this.
- UNVERIFIED: Gate's own env vars (none are invented).
- UNVERIFIED: LICENSE file at tag v0.82.3 (repo master LICENSE is Apache-2.0; the tag was not fetched).
- Gate needs a reachable backend server; the readiness probe checks only the proxy listener, not backend connectivity.
- arm64: supported by upstream (`gate_0.82.3_linux_arm64`); not validated locally.
- Blockers: none known. Not musl-only, no GPU, no privileged need.

## 11. Build and test steps

From `apps/minecraft-gate/`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create minecraft-gate-probe-config
docker run --rm -d --name minecraft-gate-probe --read-only --tmpfs /tmp \
  -v minecraft-gate-probe-config:/config minecraft-gate:0.82.3
docker logs -f minecraft-gate-probe
docker rm -f minecraft-gate-probe; docker volume rm minecraft-gate-probe-config
forgetool containers test --image minecraft-gate:0.82.3 --config ./container-test.yaml
```

- Expected readiness signal: a log line showing the listener on 25565 (exact text UNVERIFIED until the binary runs), and the process still running.
- Also run once with a backend-less config to confirm the no-backend behavior is clear and not a crash loop.
- arm64: build only if the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-minecraft-gate`, commit `feat(minecraft-gate): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep sections and checkboxes; check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge; only they can sign it. The `license/cla` check shows status.
- Say in the PR what was not tested: arm64 build, checksum values, config behavior (see section 10).
- Do not check "Built container locally" unless the image was built and run.
