# tdarr-node — implementation plan
> Source: ./draft.md · Target: apps/tdarr-node/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 3.09.00 (GitHub latest release, published 2026-11-22: https://api.github.com/repos/HaveAGitGat/Tdarr/releases/latest). Draft says 3.08.00; the TrueCharts chart already pins 3.09.00 (`ghcr.io/haveagitgat/tdarr_node:3.09.00@sha256:0b9a1a5217629930e4fe361047471c78f20a884bdd91f120960cca0a12613742`, https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tdarr-node/values.yaml). Use 3.09.00. |
| Renovate | `datasource=github-releases depName=HaveAGitGat/Tdarr versioning=loose` (UNVERIFIED: no renovate precedent checked in this run; tags are plain 3.x.y). |
| License | UNVERIFIED: GitHub reports `NOASSERTION` for https://github.com/HaveAGitGat/Tdarr. Read the LICENSE file in the repo before setting `LICENSE`. |
| Source URL | https://github.com/HaveAGitGat/Tdarr |
| Download (amd64) | `https://tdarrs.s3.us-west-000.backblazeb2.com/dev/versions/$VERSION/linux_x64/Tdarr_Node_$DATE.zip` (from upstream Dockerfile, https://raw.githubusercontent.com/HaveAGitGat/Tdarr/9ec31178f6807861c207f8a65a1b8156e46c5b85/docker/Dockerfile.final). |
| Download (arm64) | `https://tdarrs.s3.us-west-000.backblazeb2.com/dev/versions/$VERSION/linux_arm64/Tdarr_Node_$DATE.zip` (same source). UNVERIFIED that the zip exists for 3.09.00 (not fetched). |
| `$DATE` value | UNVERIFIED: the upstream Dockerfile takes `DATE` as a build arg from the upstream `tdarr_acc` base tag `base_${VERSION}_${DATE}`. The DATE for 3.09.00 was not found. tdarr.io/downloads returned no links and the GitHub release asset list returned no data (HTTP 403 on WebFetch). Resolve it before writing the Dockerfile. |
| Checksum source | None: the upstream Dockerfile has no checksum step. Record the zip SHA-256 at build time and check it in the Dockerfile, or mark it as UNVERIFIED in the PR. |
| Upstream Dockerfile reviewed | `docker/Dockerfile.final`: `FROM docker.io/haveagitgat/tdarr_acc:base_${VERSION}_${DATE}`; apt curl, unzip, mkvtoolnix, libtesseract-dev; `ENV WEB_UI_PORT=8265 SERVER_PORT=8266 NODE_PORT=8267 PUID=1000 PGID=1000 UMASK=002 TZ=Etc/UTC HOME=/home/Tdarr inContainer=true`; zip fetched only when MODULE is Tdarr_Server, saved to /tmp/Tdarr_Node.zip; no WORKDIR, VOLUME, USER or LABEL; `ENTRYPOINT ["/init"]`; EXPOSE 8267, 8265, 8266. |
| Ports | Chart: node `serverPort` 8266, `serverIP` 0.0.0.0, chart `main` service disabled (values.yaml above). Upstream exposes 8265 (web UI, server only), 8266 (server), 8267 (node web port). A node-only container needs no listening port; see section 10. |
| Env vars (real) | `NODE_PORT`, `SERVER_PORT`, `WEB_UI_PORT`, `PUID`, `PGID`, `UMASK`, `TZ`, `HOME`, `inContainer`, `BASE_LINK`, `MODULE_LINK`, `NODE_LINK`. The chart sets `serverIP` and `serverPort`, which the node reads from its own config (UNVERIFIED which of these env names the node binary reads). |
| Data and config paths (chart) | `/app/configs`, `/app/logs`, `/temp` (transcode cache), `/media` (media mount). Upstream `HOME=/home/Tdarr`. |
| arm64 | Upstream publishes an arm64 node zip (see download above). |
| Dependencies | Tdarr server on the network, port 8266, same major version (draft, inferred; not confirmed on a fetched page). No ContainerForge dependency container. |

## 2. Target layout

Files under `apps/tdarr-node/`:

- `Dockerfile`
- `docker-bake.hcl`
- `settings.yaml`
- `container-test.yaml`
- `start.sh`
- `defaults/` only if a default node config is needed on first start (reason: the node expects `configs/`; decide after reading the zip).

Not used: `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (ubuntu base, same as the repo's other ubuntu images). The upstream `tdarr_acc` base (accelerated, GPU drivers, pre-built ffmpeg/HandBrake) does not match the ContainerForge runtime model, so do not use it. Closest siblings: `apps/adguardhome-sync` (prebuilt binary on ubuntu), `apps/steamcmd` (ubuntu base with apt packages).

## 4. Dockerfile

1. `ARG VERSION=3.09.00`, `ARG DATE=<resolved, see section 1>`, both matched in `docker-bake.hcl`.
2. `FROM <ubuntu> AS base`, `USER root`.
3. Install only what the base lacks: check `curl`, `unzip` (ubuntu base ships curl; unzip is UNVERIFIED), `ffmpeg`, `mkvtoolnix`, `libtesseract-dev` (draft inferred `ffmpeg` and `handbrake-cli`; `handbrake-cli` is not confirmed on ubuntu 26.04). Pin apt versions and check them against `VERSION` where the package is tied to the app (UNVERIFIED pins).
4. Download the zip for `TARGETARCH` (amd64 to `linux_x64`, arm64 to `linux_arm64`) to `/tmp/Tdarr_Node.zip`. Verify its checksum (see section 1). Unzip into `/app/tdarr-node/`.
5. Ship the license and notices to `/usr/share/licenses/tdarr-node/`.
6. Symlink the node's writable folders to `/config`: `/app/tdarr-node/configs -> /config/configs`, `/app/tdarr-node/logs -> /config/logs`. Symlinks are created at build time; the target directories are created by `start.sh`.
7. `ENV HOME=/config PUID=1000 PGID=1000 UMASK=002 TZ=Etc/UTC inContainer=true`. Use `NODE_PORT`, `SERVER_PORT` only if the node reads them (see section 1).
8. `chown -R apps:apps /config` and keep `/app` owned by root (read-only at runtime).
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8267
VOLUME /config
WORKDIR /app/tdarr-node
```

Port 8267 is included only if the node opens its web port; otherwise drop the `EXPOSE` line.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "tdarr-node" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=HaveAGitGat/Tdarr versioning=loose
  default = "3.09.00"
}
variable "LICENSE" { default = "NOASSERTION" } // replace with the SPDX id from the LICENSE file (section 1)
variable "SOURCE" { default = "https://github.com/HaveAGitGat/Tdarr" }
```

Use the four standard targets and the default group from `apps/adguardhome-sync/docker-bake.hcl`. Add `DATE` as a second variable with its own renovate comment if it is needed. Validate with `docker buildx bake --print` before any build.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/HaveAGitGat/Tdarr"
ports:
  - port: 8266
    protocol: tcp
    required: false
env:
  - name: serverIP
    default: "0.0.0.0"   # UNVERIFIED: confirm the env name the node reads
    required: false
  - name: serverPort
    default: "8266"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /temp
    required: false      # transcode cache, see section 10
dependencies: []
```

Only list env vars the node actually reads (see section 1, UNVERIFIED). Port 8266 is listed only if the node binds it; a worker that only makes outbound connections should have no `ports` entry. Decide that after the first run.

## 7. start.sh

Plan (no code yet, all items to verify):

- `mkdir -p /config/configs /config/logs /config/transcode` on first start only; never overwrite existing files.
- Set `serverIP`/`serverPort` from env with defaults.
- Create the transcode dir and check it is writable; fail with a clear message if not.
- `cd /app/tdarr-node` and `exec ./Tdarr_Node` (binary name UNVERIFIED from the zip).
- Do not write to `/app`. Caches go to `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /start.sh
- /app/tdarr-node
- /usr/share/licenses/tdarr-node/LICENSE
```

If the node exposes a port (section 6), add a `tcp` probe for it. The node cannot run without a server, so a full functional test is not feasible in a single container. Per the protocol exception, if the app meets all three criteria, annotate with `# narrowed: requires external tdarr server; full functional test not feasible in single-container suite`. Otherwise the process must stay running with no fatal log line.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/configs` | Symlink to `/config/configs` (build time). |
| `/app/logs` | Symlink to `/config/logs` (build time). |
| `/temp` (transcode cache) | Volume mount at `/temp`, not `/config`, because the cache can be very large. Must be writable by `apps`. |
| `/home/Tdarr` (HOME) | `HOME=/config`. |
| `/tmp/Tdarr_Node.zip` | Build stage only, removed after unzip. |
| `/media` | Read-only mount by the user; not written by the container. |
| Root user | Chart runs `runAsUser 0`, `runAsNonRoot false`, `readOnlyRootFilesystem false` (chart values, confirmed). Rework: `USER apps` and read-only rootfs. Root is not kept. |

## 10. Risks, caveats and open questions

- Draft security expectations (root, writable rootfs) are not kept. The chart's root setting is not a requirement for the node.
- Transcode cache is a large volume at `/temp`, which is not `/config`. Open question: is `/temp` also used by the node, or only the chart? Confirm from the node's zip or docs.
- `DATE` for the zip is not resolved (section 1). This blocks the Dockerfile.
- `handbrake-cli` and `ffmpeg` on ubuntu 26.04 are UNVERIFIED. The upstream image got them from `tdarr_acc`, not apt.
- The node zip bundles its own Node runtime (draft, inferred; UNVERIFIED).
- The draft's "node must reach the server on 8266 and match the major version" is inferred, not verified.
- Blockers: none confirmed. Possible blocker: GPU-accelerated transcodes are not in scope (CPU-only build).

## 11. Build and test steps

From `apps/tdarr-node/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name tdarr-node-probe --read-only --tmpfs /tmp -v tdarr-node-probe-config:/config ghcr.io/trueforge-org/tdarr-node:3.09.00`, then `docker logs -f tdarr-node-probe`. Expected readiness signal: UNVERIFIED (the node prints a connection line; confirm on first run).
4. `forgetool containers test --image <image>:3.09.00 --config ./apps/tdarr-node/container-test.yaml`
5. Clean up: `docker rm -f tdarr-node-probe; docker volume rm tdarr-node-probe-config`.

## 12. PR checklist

- Branch: `feat/add-tdarr-node`
- Commit: `feat(tdarr-node): add new container`
- PR title: same as commit
- Use `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections and checkboxes; only tick boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Say what was not tested: the `$DATE` value, the arm64 build, the node-to-server connection, and any live transcode.
