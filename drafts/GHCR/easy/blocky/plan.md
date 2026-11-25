# blocky — implementation plan
> Source: ./draft.md · Target: apps/blocky/ · Difficulty: easy · Role: main (k8s_gateway sidecar is a separate, out-of-scope companion, see section 10) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **0.37.0** (latest release, published 2026-11-21). The draft's chart image `v0.36.0` is one release behind. Source: https://github.com/0xERR0R/blocky/releases/tag/v0.37.0 |
| Renovate | `datasource=github-releases depName=0xERR0R/blocky versioning=semver` (tags are `v`-prefixed; UNVERIFIED that Renovate strips the `v` for this datasource in this repo, check a v-prefixed sibling such as apps/adguardhome-sync) |
| License | Apache-2.0 (GitHub license API, https://api.github.com/repos/0xERR0R/blocky/license) |
| Source URL | https://github.com/0xERR0R/blocky |
| Per-arch download (confirmed asset names) | amd64: `https://github.com/0xERR0R/blocky/releases/download/v0.37.0/blocky_v0.37.0_Linux_x86_64.tar.gz`; arm64: `https://github.com/0xERR0R/blocky/releases/download/v0.37.0/blocky_v0.37.0_Linux_arm64.tar.gz` |
| Checksum source | `https://github.com/0xERR0R/blocky/releases/download/v0.37.0/blocky_checksums.txt`: `784d0617cb39944ca80197a9fe7ac2d796bcf1154dafb36a598c776a6c18da0e  blocky_v0.37.0_Linux_x86_64.tar.gz`, `7ebd9f112d847eb37f8bb60930822865a2909627a33f1f969ded1557da56a904  blocky_v0.37.0_Linux_arm64.tar.gz` |
| Upstream Dockerfile reviewed | https://github.com/0xERR0R/blocky/blob/master/Dockerfile: `golang:alpine` build stage, CGO-free cross-compile (`make build`, output `/bin/blocky`), final `FROM scratch`, `USER 100`, `WORKDIR /app`, `COPY --from=build /bin/blocky /app/blocky`, `ENV BLOCKY_CONFIG_FILE=/app/config.yml`, `ENTRYPOINT ["/app/blocky"]`. Seeded `/app/cache` and `/logs` owned by 100:100. |
| Env vars (real) | `BLOCKY_CONFIG_FILE` (set by upstream image, default `/app/config.yml`). No other env vars confirmed. All other settings live in the YAML config (https://github.com/0xERR0R/blocky/blob/master/docs/config.yml). |
| Ports (docs/config.yml `ports`) | `dns` default 53 (TCP and UDP); `tls` unset (853 example); `https` unset (443 example); `http` unset (4000 example, REST API, metrics, DoH). Listeners bind all interfaces when given a bare port. |
| Config and data paths | Config file from `BLOCKY_CONFIG_FILE`. Cache path set in config (docs example `cachePath: /app/cache`, docs/configuration.md; exact parent key UNVERIFIED). Logs go to stdout by default (UNVERIFIED that nothing is written to `/logs`). |
| Upstream runs as | UID 100 (docs/configuration.md, Docker section). ContainerForge uses `apps` user instead. |
| Health probe (upstream) | `dig @127.0.0.1 -p 53 healthcheck.blocky +short` (https://github.com/0xERR0R/blocky/blob/master/docs/configuration.md) |
| Blocklists | Downloaded at runtime from URLs in config, so outbound HTTP is needed when lists are configured. |

## 2. Target layout

- `apps/blocky/Dockerfile`
- `apps/blocky/docker-bake.hcl`
- `apps/blocky/settings.yaml`
- `apps/blocky/container-test.yaml`
- `apps/blocky/start.sh`
- `apps/blocky/defaults/config.yml` (seed config, copied to `/config/config.yml` only when missing). `defaults/` is allowed by `include/.dockerignore`. Needed because blocky has no usable default config: without a file it tries port 53, which an unprivileged user cannot bind.

Not needed: `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage. The blocky binary is static (CGO-free, per upstream Dockerfile), so ubuntu is only a userland for the seeded config and the start script. Closest sibling for a prebuilt-binary app: `apps/adguardhome-sync` (listed as the exemplar in the brief).

## 4. Dockerfile

1. `ARG VERSION` (no inline default; value comes from bake), `ARG TARGETARCH`. Map `amd64` to `x86_64` and `arm64` to `arm64` with a `case`. Fail the build on any other arch.
2. `USER root` only for the install step. Download the tarball for the arch to `/tmp/blocky`, verify it with `echo "<sha256>  <file>" | sha256sum -c -` using the checksums in section 1, extract, then `install -m0755 blocky /app/blocky`.
3. License: install the upstream `LICENSE` to `/usr/share/licenses/blocky/LICENSE`. UNVERIFIED whether the release tarball ships a LICENSE file; if not, fetch it from the source tag.
4. Remove `/tmp/blocky*` in the same `RUN` so the layer stays small.
5. `ENV BLOCKY_CONFIG_FILE=/config/config.yml`.
6. `COPY --chmod=0755 . /` (required, brings `start.sh` and `defaults/`).
7. `EXPOSE 4000 5353/tcp 5353/udp`.
8. `VOLUME /config`.
9. `USER apps`. Entry command runs `/start.sh`, which execs `/app/blocky`.

Pins: `VERSION` must equal `docker-bake.hcl` `VERSION`. The checksums must be updated together with `VERSION`.

## 5. docker-bake.hcl

- `variable "APP" { default = "blocky" }`
- `variable "VERSION"` with `// renovate: datasource=github-releases depName=0xERR0R/blocky versioning=semver` and `default = "0.37.0"`.
- `variable "LICENSE" { default = "Apache-2.0" }`
- `variable "SOURCE" { default = "https://github.com/0xERR0R/blocky" }`
- Standard targets: `docker-metadata-action`, `image` (args `VERSION`, labels `org.opencontainers.image.source` and `.licenses`), `image-local` (`output = ["type=docker"]`, tags `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default" { targets = ["image-local"] }`.
- Validate with `docker buildx bake --print` in `apps/blocky`.

## 6. settings.yaml

- Schema header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json` and `schema_version: 1`.
- `upstream_env_url: "https://github.com/0xERR0R/blocky"`.
- `ports`:
  - `4000` tcp, `required: false` (HTTP API, metrics, DoH).
  - `5353` tcp, `required: false` (DNS over TCP, unprivileged default, see section 9).
  - `5353` udp, `required: false` (DNS over UDP). `protocol: udp` is used by sibling settings (for example `apps/emby/settings.yaml`, `apps/gluetun/settings.yaml`), so it is accepted; the container-test has no udp probe, so state that reason in the PR.
- `env`: `BLOCKY_CONFIG_FILE`, default `/config/config.yml`, `required: false`. Only var actually read.
- `volumes`: `/config`, `required: true`.
- `dependencies`: none (valkey and postgresql in the chart are optional, not needed for the base image).

## 7. start.sh

Bash, `set -euo pipefail`:
1. `mkdir -p /config`. Copy `/defaults/config.yml` (path from the `defaults/` copy) to `/config/config.yml` only when `/config/config.yml` is missing or empty. Never overwrite existing user state.
2. `mkdir -p /tmp/blocky-cache`. Caches live in `/tmp`, never in `/config` or `/app`.
3. `exec /app/blocky` with `BLOCKY_CONFIG_FILE` honored (default `/config/config.yml`). `exec` keeps PID 1 signal handling.

Seed config (`defaults/config.yml`), minimal and no network at start:
- `ports.dns: 5353` (unprivileged) and `ports.http: 4000`. Both bind all interfaces.
- Cache path set to `/tmp/blocky-cache` (exact key UNVERIFIED, see section 1).
- No block lists configured, so the test start makes no outbound request.

## 8. container-test.yaml

- Schema header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json`
- `timeoutSeconds`: copy the value from `apps/adguardhome-sync/container-test.yaml` (blocky starts in under a second once config is seeded).
- `tcp: port '4000'` and `tcp: port '5353'`. Every port in `settings.yaml` gets a probe (rule: coverage minimum). Optional extra: `http` probe on `4000` path `/` if the forgetool schema allows it (UNVERIFIED).
- The test runs with no env vars. Blocky does not need any, because the seed config is in the image. No `filePaths` needed for the startup path.
- Limit: `tcp` on 5353 checks only TCP DNS. UDP is not covered by the probe. Say so in the PR.

## 9. Rootless and read-only-rootfs adaptations

- Upstream UID 100 becomes `apps`. The binary lives in `/app/blocky` (read-only at runtime, which is fine).
- Config in `/config`, cache in `/tmp`. Nothing is written to `/app`.
- Port 53: blocky needs `CAP_NET_BIND_SERVICE` to bind 53 as non-root. The default seed uses 5353. Users who want 53 can set `ports.dns: 53` in `/config/config.yml` and add `cap_add: [NET_BIND_SERVICE]` (or equivalent) themselves. Do not add the capability to the image.
- Read-only rootfs: blocky writes nothing to its install path. Logs go to stdout. Run test: `--read-only --tmpfs /tmp`.
- Chart security defaults (draft section Security expectations, confidence medium): non-root yes, read-only yes, privileged no. The chart's `CAP_NET_BIND_SERVICE` note applies only if port 53 is kept.
- No extra persistence beyond `/config`. PostgreSQL and redis in the chart are external and not needed for the base app.

## 10. Risks, caveats and open questions

- **Version drift**: the draft and chart use v0.36.0; this plan uses v0.37.0. Confirm the chart bump is acceptable (it is a new upstream release, not a chart change).
- **k8s_gateway sidecar** (draft row 2, `ghcr.io/k8s-gateway/k8s_gateway:1.8.2`, Apache-2.0, release assets confirmed: `k8s_gateway_1.8.2_linux_amd64.tar.gz` and `..._arm64.tar.gz`, checksums `d552add7995dc4f603939e60d0ef8641ae9c2bb6e902104a4d7f47d61db37f1b` and `65a6c6413f8e0e527ada4147c9c4d4491da481f3f5c5ffb9fe186368f26457b0`). It is a separate container and out of scope for this plan. It only does useful work inside a Kubernetes cluster. Open question: does the user want a second app `apps/k8s-gateway`? Not created here.
- **Port 53 vs 5353** (see section 9). The chart's behavior on 53 is not reproduced by default.
- **Runtime downloads**: block lists are fetched at runtime. The seed config has none, so this is not tested. Users who add lists need outbound HTTP.
- **Renovate `v` prefix**: UNVERIFIED (section 1).
- **UDP probe**: not covered by `tcp` probes (section 8).
- **Blockers**: none. No musl-only, GPU, privileged or arm64 problem found in upstream. arm64 binary is published.
- **UNVERIFIED**: cache key placement in config, `/logs` usage, readiness log line, udp in the forgetool schema.

## 11. Build and test steps

From `apps/blocky`:
1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe run: `docker run --rm -d --name blocky-probe --read-only --tmpfs /tmp -v blocky-probe-config:/config blocky:0.37.0`, then `docker logs -f blocky-probe`. Expected: process still running after startup, DNS and HTTP listeners up. Readiness signal UNVERIFIED: take the exact line from the first real run and record it in the PR. Cleanup: `docker rm -f blocky-probe; docker volume rm blocky-probe-config`.
4. Repeat step 3 with a fresh named volume (empty `/config`) per round.
5. `forgetool containers test --image blocky:0.37.0 --config ./apps/blocky/container-test.yaml`. If forgetool is missing, check ports 4000 and 5353 by hand.
6. arm64 is not built locally unless the amd64 build is clean and the failure is arm64-specific (protocol).

## 12. PR checklist

- Branch `feat/add-blocky`, commit `feat(blocky): add new container`, PR title the same.
- PR template `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept, only applicable boxes checked.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; `license/cla` check shows status).
- State what is untested: arm64 runtime, DNS over UDP, port 53 with capability, block-list downloads, k8s_gateway companion. Do not tick "Built container locally" unless the build was actually run.
