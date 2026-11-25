# monero-node — implementation plan
> Source: ./draft.md · Target: apps/monero-node/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **v0.18.5.4** (tag `v0.18.5.4`, published 2026-10-17, not prerelease). Matches chart image `ghcr.io/sethforprivacy/simple-monerod:v0.18.5.4`. Source: `gh api repos/monero-project/monero/releases/latest`; chart: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/monero-node/values.yaml |
| Renovate | `datasource=github-releases depName=monero-project/monero versioning=loose`. Same annotation the upstream wrapper uses (https://github.com/sethforprivacy/simple-monerod-docker/blob/08e993d/Dockerfile, line 1). |
| License | BSD-3-Clause (master `LICENSE` text read: "Copyright (c) 2014-2024, The Monero Project. All rights reserved." followed by the BSD terms; UNVERIFIED that the v0.18.5.4 tag is identical). Website https://getmonero.org. |
| Source URL | https://github.com/monero-project/monero |
| Upstream image Dockerfile reviewed | https://github.com/sethforprivacy/simple-monerod-docker/blob/08e993d/Dockerfile: builds a static monerod from source (`MONERO_BRANCH=v0.18.5.4`, `MONERO_COMMIT_HASH=85f036ba7019cd36f08e8a38a27c37ea7b522618`) on `alpine:3.24.4`; final stage has `ENTRYPOINT /entrypoint.sh` (root PID 1, drops to `PUID`/`PGID`, default 1000, via su-exec), `HEALTHCHECK /healthcheck.sh`, `HOME=/home/monero`, `EXPOSE 18080 18089`, and `CMD --rpc-restricted-bind-ip=0.0.0.0 --rpc-restricted-bind-port=18089 --no-igd --no-zmq --enable-dns-blocklist --ban-list=/home/monero/ban_list.txt`. We do not copy the source build; we use the official tarball. |
| Per-arch download (confirmed, HTTP 200) | amd64: https://downloads.getmonero.org/cli/monero-linux-x64-v0.18.5.4.tar.bz2 (Content-Length 85037503) · arm64: https://downloads.getmonero.org/cli/monero-linux-armv8-v0.18.5.4.tar.bz2 (Content-Length 74776406). Both are listed in the release body. |
| Checksum source | Release body says sha256 hashes are published, and a GPG-signed list is canonical at https://getmonero.org/downloads/hashes.txt. `https://downloads.getmonero.org/cli/hashes.txt` returned 404. UNVERIFIED: the signed list was not fetched. Locally computed this session: amd64 `ba2928962c101b609434bf8c1b43ad59ebe96c5525977284ca599d8bf0f02d10`, armv8 `d20d71e6522b41eb8e549c3425f7f4622c9c9a448fc7147525393fd0a6b59703`. These must match the signed list before being pinned. |
| Tarball layout | UNVERIFIED: inner directory name and `monerod` path not listed. Check with `tar -tjf` in step 2. |
| Env vars | Chart sets `HOME=/home/monero`. Upstream entrypoint reads `PUID`/`PGID` only for its root drop; we do not ship that entrypoint, so they are not added. |
| Ports | 18080/tcp (P2P; chart `main`), 18089/tcp (restricted RPC; chart `rpc`; upstream `EXPOSE` and CMD). The draft's `18081/http` is not used by the chart or upstream; 18081 is the unrestricted RPC port. Corrected to 18089. |
| Data write paths | Chart mounts `blockchainstorage` at `/home/monero/.bitmonero`; upstream default data dir is the same. Remapped to `/config/bitmonero` with `--data-dir` (section 7). |
| Security (chart) | `runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem false`, `privileged` not set. |
| arm64 | Yes: `monero-linux-armv8` tarball returns HTTP 200. |
| Dependencies | None. |

## 2. Target layout

- `apps/monero-node/Dockerfile`: required.
- `apps/monero-node/docker-bake.hcl`: required.
- `apps/monero-node/settings.yaml`: required.
- `apps/monero-node/container-test.yaml`: required.
- `apps/monero-node/start.sh`: required (sets `--data-dir` on `/config`, `exec` monerod).

Not needed: `defaults/` (monerod creates its own data dir), `root/` (never used). `DOWNSTREAM_CHANGES.md` not needed (not a FROM base).

Ban list: upstream passes `--ban-list` with a file from the monero ban-list repo. Not fetched. If the tarball ships it, copy it to `/app/monero/` and pass the flag; otherwise omit the flag (open question, section 10).

## 3. Base image

- FROM: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
- Why: the official tarballs are glibc builds, which run on the Ubuntu base; no runtime image needed.
- Closest siblings: `apps/adguardhome-sync` (tarball fetched in the ubuntu image, `USER apps`) and `apps/steamcmd` (`TARGETARCH` mapping).
- UNVERIFIED: whether the tarball needs libraries beyond the base. Confirm with `ldd` in step 2.

## 4. Dockerfile

Single stage:

1. `ARG VERSION` and `ARG TARGETARCH`; `ARG MONERO_SHA256_AMD64` and `ARG MONERO_SHA256_ARM64` (values from the signed `hashes.txt`, section 1); `USER root`.
2. Map arch:
   ```sh
   case "${TARGETARCH}" in
     amd64) MONERO_ARCH="linux-x64";   MONERO_SHA="${MONERO_SHA256_AMD64}" ;;
     arm64) MONERO_ARCH="linux-armv8"; MONERO_SHA="${MONERO_SHA256_ARM64}" ;;
     *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;;
   esac
   ```
3. Download, verify, extract to `/app/monero`:
   ```sh
   curl -fL -o /tmp/monero.tar.bz2 "https://downloads.getmonero.org/cli/monero-${MONERO_ARCH}-v${VERSION}.tar.bz2"
   echo "${MONERO_SHA}  /tmp/monero.tar.bz2" | sha256sum -c -
   mkdir -p /app/monero && tar -xjf /tmp/monero.tar.bz2 -C /app/monero --strip-components=1
   rm -f /tmp/monero.tar.bz2
   ```
   `tar -j` needs `bzip2`. Check the base first; add `apt-get install -y --no-install-recommends bzip2` only if missing (`kasmvnc` and `foldingathome` do this).
4. Smoke check in the build: `/app/monero/monerod --version` (fails the build on a broken tarball).
5. License: copy the tarball's LICENSE, if present, to `/usr/share/licenses/monero-node/LICENSE`; otherwise fetch it from the monero repo at tag `v0.18.5.4`. UNVERIFIED which applies.
6. `chown -R apps:apps /app/monero && chmod -R 755 /app/monero`.
7. Env: `ENV HOME=/config`.
8. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 18080 18089
   VOLUME /config
   ```
9. No `HEALTHCHECK`: forgetool probes are used instead.

## 5. docker-bake.hcl

Copy the layout of `apps/adguardhome-sync/docker-bake.hcl`:

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "monero-node"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=monero-project/monero versioning=loose
  default = "0.18.5.4"
}

variable "LICENSE" {
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://github.com/monero-project/monero"
}
```

The Dockerfile builds the URL as `v${VERSION}`, so `VERSION` stays without the `v`. Add the standard `group "default"`, `image`, `image-local` (`tags = ["${APP}:${VERSION}"]`) and `image-all` (`linux/amd64`, `linux/arm64`). The per-arch SHA values are passed as bake `args` from the same file, so they are versioned with `VERSION`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/monero-project/monero"
ports:
  - port: 18080
    protocol: tcp
    required: false
  - port: 18089
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Only what the app reads is listed. monerod is configured by CLI flags set in `start.sh`; no env var is invented.
- If `start.sh` later reads env for a flag (e.g. public-node or prune), add it here with its default. None by default.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
DATA_DIR=/config/bitmonero
mkdir -p "${DATA_DIR}"

cd /app/monero
exec /app/monero/monerod \
  --non-interactive \
  --data-dir="${DATA_DIR}" \
  --rpc-restricted-bind-ip=0.0.0.0 \
  --rpc-restricted-bind-port=18089 \
  --p2p-bind-ip=0.0.0.0 \
  --p2p-bind-port=18080 \
  --no-igd \
  --no-zmq \
  --enable-dns-blocklist
```

- `--non-interactive` keeps monerod in the foreground logging to stdout, as the upstream entrypoint does.
- `--data-dir=/config/bitmonero` replaces `/home/monero/.bitmonero`; this keeps `/app` read-only and state in `/config`.
- Idempotent: creates the directory only; never touches existing chain data.
- `--p2p-bind-ip=0.0.0.0` is explicit for clarity (UNVERIFIED that it differs from the default; confirm in step 4).
- `--ban-list` omitted unless the file ships (section 2).
- `--prune-blockchain` is not defaulted (section 10).
- `exec` so monerod gets signals. No `PUID`/`PGID` handling: the process runs as `apps`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '18080'
- port: '18089'
filePaths:
- /app/monero/monerod
- /usr/share/licenses/monero-node/LICENSE
```

- The test sets no env vars, matching the default start path.
- `timeoutSeconds: 300`: monerod loads state before binding listeners; a sibling value was not checked (UNVERIFIED).
- Each declared port has a `tcp` probe (protocol rule). These prove a listener inside the container, not reachability from other containers (test-rule caveat).
- No `http` probe: restricted RPC is JSON-RPC over POST, so a GET probe is not a meaningful assertion.
- If the LICENSE file is absent from the tarball, drop that filePath and keep the fetched license in the Dockerfile step.

## 9. Rootless and read-only-rootfs adaptations

| Upstream/chart behaviour | Our handling |
| --- | --- |
| Chart `runAsUser 0` / `runAsGroup 0`; upstream root PID 1 | Not reproduced. Runs as `apps`. Root was only needed to chown a host mount for `PUID`/`PGID`. |
| Chart `readOnlyRootFilesystem false` | Target `yes`. Writes go to `/config/bitmonero` (volume) and `/tmp`. Verified in step 4 under `--read-only --tmpfs /tmp`. |
| Upstream write path `/home/monero/.bitmonero` (chain, logs, p2p state) | Remapped to `/config/bitmonero` via `--data-dir`. |
| Chart `privileged` | Not set; not needed. |
| `numactl --interleave=all` in upstream entrypoint | Not reproduced; optional tuning. |
| Chain size | Needs a large `/config` volume. The draft's "well over 100 GB" is UNVERIFIED; put sizing guidance in docs. |

## 10. Risks, caveats and open questions

- **Checksums not confirmed against the signed list.** `getmonero.org/downloads/hashes.txt` was not fetched (the `downloads.getmonero.org/cli/hashes.txt` path returned 404). Blocker for merge until the pins come from the signed list.
- **Tarball contents** (directory name, `monerod` path, LICENSE, ban list) are UNVERIFIED. Confirm in step 2 before `start.sh` is final.
- **Prune choice.** The chart sets `pruneblockchain: true`. Pruning trades disk for sync/serving behaviour. Default here is full sync; decide and document.
- **Port correction.** Draft's 18081 for RPC is replaced by 18089, which the chart and upstream use.
- **Sync time.** Initial sync can take days (draft, UNVERIFIED). The test does not sync; readiness is the listeners.
- **arm64** is supported by the armv8 tarball; not yet built or run.
- **Blockers:** only the checksum confirmation. No GPU, no privileged need.

## 11. Build and test steps

From `apps/monero-node/` (protocol commands, `<app>` = `monero-node`):

1. `docker buildx bake --print` (must exit 0).
2. Inspect the tarball before finalizing `start.sh`: download to a scratch dir under `/tmp`, `sha256sum` it, `tar -tjf | head -20`, then `ldd` the extracted `monerod` in a throwaway ubuntu container.
3. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
4. Empty-config run, read-only with tmpfs:
   ```sh
   docker run --rm -d --name monero-node-probe --read-only --tmpfs /tmp \
     -v monero-node-probe-config:/config monero-node:0.18.5.4
   docker logs -f monero-node-probe
   ```
   Expected readiness signal: monerod logs its RPC and P2P listeners starting, the process stays running, no fatal errors. Sync progress is not required for readiness.
5. `forgetool containers test --image monero-node:0.18.5.4 --config ./container-test.yaml`. If forgetool is unavailable, check ports 18080 and 18089 inside the container and the file paths by hand.
6. Cleanup: `docker rm -f monero-node-probe; docker volume rm monero-node-probe-config`.
7. arm64 build only if an arm64-specific failure appears.

## 12. PR checklist

- Branch: `feat/add-monero-node`.
- Commit: `feat(monero-node): add new container`. PR title matches.
- PR body: template at `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes; check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge; only the user can sign. The `license/cla` check shows status.
- Not tested (state in the PR until done): signed-hash verification, arm64 build and run, full sync, tarball layout assumptions, SPDX license id. Do not check "Built container locally" unless the build ran.
