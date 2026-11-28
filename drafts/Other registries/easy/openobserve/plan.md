# openobserve — implementation plan
> Source: ./draft.md · Target: apps/openobserve/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Latest stable | `v1.2.0`, published 2026-11-24 (https://api.github.com/repos/openobserve/openobserve/releases/latest). The draft and TrueCharts use `v1.1.2` (published 2026-10-20, https://api.github.com/repos/openobserve/openobserve/releases/tags/v1.1.2). This plan targets `v1.2.0`, see section 10 for the gate. |
| Renovate | `datasource=github-releases depName=openobserve/openobserve versioning=semver` (the standard for GitHub tags; the GitHub release API confirms the tag format `vX.Y.Z`) |
| License | AGPL-3.0 (GitHub API `spdx_id`, https://api.github.com/repos/openobserve/openobserve) |
| Source URL | https://github.com/openobserve/openobserve |
| Download (amd64) | `https://downloads.openobserve.ai/releases/openobserve/v1.1.2/openobserve-v1.1.2-linux-amd64.tar.gz` returned HTTP 200 (`application/x-tar`, 147,627,958 bytes) on 2026-11-25. The `v1.2.0` amd64 URL also returned 200. |
| Download (arm64) | `.../openobserve-v1.1.2-linux-arm64.tar.gz` and `v1.2.0` amd64/arm64 URLs all returned HTTP 200 on a HEAD check (same host pattern). Earlier note:  The upstream Dockerfile only builds `x86_64-unknown-linux-gnu`, so arm64 availability is now confirmed by the HEAD check only (runtime untested). |
| Checksum source | UNVERIFIED: no checksum asset on the GitHub release (v1.1.2 and v1.2.0 list no assets; v1.2.0 lists only `openapi.json`). Checking the downloads host for a `.sha256` file is an open item. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/openobserve/openobserve/d16d693ba99bc20621a58b948ecbcad7ec7fa882/deploy/build/Dockerfile.tag.amd64. Stages: `node:24-trixie` (web build), `public.ecr.aws/zinclabs/rust:trixie-sccache` (`cargo build --profile release-prod --features mimalloc`), runtime `gcr.io/distroless/cc-debian13`. The runtime copies `/openobserve` and `liblzma.so.5`, `libz.so.1`, `libbz2.so.1.0` from the builder. It runs `/openobserve init-dir -p /data/` at build time, `CMD ["/openobserve"]`, and sets no `USER`, `EXPOSE`, `VOLUME` or `ENV` defaults. |
| Ports | UNVERIFIED: 5080 (from the draft; not on a fetched page). The upstream Dockerfile does not `EXPOSE` anything. |
| Env vars (real) | UNVERIFIED: the upstream Dockerfile sets none. The config reference (https://openobserve.ai/docs/) was not fetched. No env var is listed in `settings.yaml` until verified. |
| Data path | Upstream uses `/data/` (created by `init-dir`). The draft and TrueCharts say `/config` (chart uses `/data` PVC). Mismatch, see section 9. |
| Dependencies | None (single binary with embedded storage, per draft). |

## 2. Target layout

- `apps/openobserve/Dockerfile`
- `apps/openobserve/docker-bake.hcl`
- `apps/openobserve/settings.yaml`
- `apps/openobserve/container-test.yaml`
- `apps/openobserve/start.sh`

No `defaults/`, `etc/` or `health/`: openobserve creates its own data directory. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Fits because the binary is a glibc-linked Rust executable. The upstream runtime is distroless glibc (cc-debian13), so Ubuntu's glibc is compatible. Ubuntu already provides `ca-certificates`, `curl` and `tar`. Closest sibling for a prebuilt tarball download is `apps/adguardhome-sync` (same base, same download pattern).

## 4. Dockerfile

1. `FROM` line above, `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`.
2. Download and extract (mirrors `adguardhome-sync`):
   ```dockerfile
   RUN mkdir -p /app && curl -fsSL -o /tmp/openobserve.tar.gz \
       "https://downloads.openobserve.ai/releases/openobserve/${VERSION}/openobserve-${VERSION}-linux-${TARGETARCH}.tar.gz" \
    && tar xzf /tmp/openobserve.tar.gz -C /app/ \
    && rm /tmp/openobserve.tar.gz
   ```
   `TARGETARCH` (`amd64`, `arm64`) matches the asset names directly, so no mapping is needed. Confirm the tarball's top-level layout (expected: a single `openobserve` binary) before writing the extract path.
3. Shared-library check: run `ldd /app/openobserve` in the build stage. If `liblzma.so.5`, `libz.so.1` or `libbz2.so.1.0` are missing on Ubuntu 26.04, install the matching Ubuntu packages (`liblzma5`, `zlib1g`, `libbz2-1.0`), pinned against the base release, and do not copy them from the builder.
4. Chown and permissions: `chown -R apps:apps /app && chmod -R 755 /app`, then `rm -rf /tmp/*`.
5. Licence: the tarball has no licence file in the expected layout (UNVERIFIED). Source the AGPL-3.0 text from the repo's `LICENSE` file (https://github.com/openobserve/openobserve) and copy it to `/usr/share/licenses/openobserve/` as a build step, if the tarball does not ship one.
6. Tail, matching sibling apps:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 5080
   VOLUME /config
   ```
   `EXPOSE 5080` is included only after the port is verified (section 10). Otherwise leave it out.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "openobserve"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=openobserve/openobserve versioning=semver
  default = "v1.2.0"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/openobserve/openobserve"
}
```

Then the four standard targets and the default group, copied from `apps/adguardhome-sync/docker-bake.hcl`. `LICENSE` is `AGPL-3.0` per the GitHub API (not `-or-later`). Validate with `docker buildx bake --print`. `ARG VERSION` in the Dockerfile must equal `v1.2.0` (the tarball URL uses the `v` prefix, so the Dockerfile should use `${VERSION}` as is, and no arch mapping is needed).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/openobserve/openobserve"
ports: []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`ports` stays empty until the HTTP port is confirmed on a fetched page or by the running container (section 10). Only `TZ` is listed. The data-directory variable and the admin-credential variables are not added until their exact names are confirmed (they are not `settings.yaml` entries until then). Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data
cd /app
exec /app/openobserve
```

Idempotent: creates `/config/data` only, never writes to `/app`. The data directory must point at `/config/data` through the variable that the binary reads (name UNVERIFIED, see section 10). Add `export` of that variable before `exec` once confirmed. Bind address: openobserve listens on `0.0.0.0` by default (UNVERIFIED, check in the run log and with an external probe). `exec` is used so signals reach the binary.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5080'
http:
- port: '5080'
  path: /healthz
filePaths:
- /app/openobserve
```

The `tcp` and `http` probes depend on the verified port and health path. `/healthz` is UNVERIFIED: confirm the endpoint on the running container (`curl -i http://localhost:5080/healthz`) before keeping it. If it is not confirmed, use the `tcp` probe only and note it. Every port in `settings.yaml` needs a probe; with `ports: []` the `tcp` and `http` blocks are removed as well.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data/` (upstream image, `init-dir`) | Point the data directory at `/config/data` through the variable the binary reads (UNVERIFIED name). Created at start by `start.sh`. |
| `/tmp` (scratch) | Already writable under `--read-only --tmpfs /tmp`. No change. |
| `/app` (binary) | Read-only at runtime, nothing written there. |

Draft expectations reconciled: the draft says the data path is `/config`, which matches the rule. The upstream image's `/data` is not used. The chart's `/data` PVC maps to `/config/data` for existing users (manual migration note in the PR). The draft's expectations (UID 568, `readOnlyRootFilesystem: true`, not privileged) hold for this image: it runs as `apps`, and the rootfs stays read-only.

## 10. Risks, caveats and open questions

- Version gate: `v1.2.0` is the latest stable tag, and its amd64 and arm64 download URLs returned 200 (HEAD check). Re-check at implementation time.
- arm64: tarball URL exists (HEAD 200); runtime on arm64 is untested, so do not claim it as tested.
- Checksum: no published checksum found. Note in the PR that the download is not checksum-verified unless a `.sha256` file is found on the downloads host.
- Data-path variable and credentials: the draft says the first start needs admin credentials through environment variables. The variable names are UNVERIFIED and must come from the official docs (https://openobserve.ai/docs/) before they go into `settings.yaml`. Do not guess names.
- Port: 5080 (and gRPC 5081, inferred in the draft) are UNVERIFIED and not carried into `settings.yaml` until confirmed. The upstream image has no `EXPOSE`.
- Health endpoint: `/healthz` in section 8 is UNVERIFIED.
- Disk use: ingestion grows the data directory quickly (draft caveat, not re-verified). Mention in the docs part of the PR.
- Upstream image uses `/data`; the draft and chart use `/config`. Decision: `/config/data` (section 9).
- No blockers found for amd64. arm64 is the open item.

## 11. Build and test steps

```sh
cd apps/openobserve
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name openobserve-probe --read-only --tmpfs /tmp \
  -v openobserve-probe-config:/config openobserve:v1.2.0
docker logs -f openobserve-probe
forgetool containers test --image openobserve:v1.2.0 --config ./apps/openobserve/container-test.yaml
docker rm -f openobserve-probe; docker volume rm openobserve-probe-config
```

Readiness signal: a listening log line for the HTTP server on port 5080 (exact wording UNVERIFIED; take it from the first real run). Also confirm `/config/data` exists after start, and that a restart with the same volume keeps it. Check the process stays alive with no fatal errors. Run once with `-p 5080:5080` and probe from the host, to show it is not bound to localhost only.

## 12. PR checklist

- Branch `feat/add-openobserve`, commit and PR title `feat(openobserve): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is needed (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say what was not tested: arm64 build and run, checksum verification, the health endpoint, and any migration from `/data`.
- `docker buildx bake --print` must pass; `VERSION` in bake and Dockerfile must match; no assertion weakened.
