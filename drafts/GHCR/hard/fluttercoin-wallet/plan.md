# fluttercoin-wallet — implementation plan
> Source: ./draft.md · Target: apps/fluttercoin-wallet/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.7.5.22-flt (tag `v0.7.5.22-flt`), published 2018-03-02. The upstream project has had no release since 2018 (https://api.github.com/repos/ofeefee/fluttercoin/releases/latest). The draft's chart uses `latest` on the third-party image, which is a different build. |
| Renovate | `datasource=github-releases depName=ofeefee/fluttercoin versioning=loose`. The tag `v0.7.5.22-flt` is not strict semver, so `loose` is used per the bake rules. |
| License | MIT (GitHub license API, `spdx_id` MIT: https://api.github.com/repos/ofeefee/fluttercoin/license). The README was not checked for conflicts. |
| Source URL | https://github.com/ofeefee/fluttercoin |
| Download (amd64) | `https://github.com/ofeefee/fluttercoin/releases/download/v0.7.5.22-flt/fluttercoin-64-linux-v0.7.5.22.zip` (7119207 bytes, asset name confirmed by the release API) |
| Download (arm64) | None. The release only has `-32-linux`, `-64-linux`, Windows and macOS builds. |
| Zip contents | Listed from the zip (not run): `fluttercoind` (7267344 bytes), `fluttercoin-qt` (11172494 bytes), `themes/`. The headless daemon is `fluttercoind`. |
| Checksum source | None published on the release. Local SHA-256 of the amd64 zip at fetch time: `4d53d27e33c7467d89dd57a793aba99eec8fa94d3e24ff11b26dfecd37b33938`. This is our own computed value, not an upstream one. Pin it in the Dockerfile and re-verify before use. |
| Upstream Dockerfile | https://raw.githubusercontent.com/ich777/docker-fluttercoin/master/Dockerfile: `FROM ich777/novnc-baseimage:buster_amd64`, installs `libqtgui4` and `unzip`, sets `DATA_DIR=/fluttercoin`, `NOVNC_PORT=8080`, `RFB_PORT=5900`, `UID=99`, `GID=100`, `USER=fluttercoin`, `EXPOSE 8080 7408 7474`, `ENTRYPOINT ["/opt/scripts/start.sh"]`. It is a noVNC desktop image, not a headless one. |
| Ports (upstream source README) | P2P 7408 and RPC 7474 (https://raw.githubusercontent.com/ofeefee/fluttercoin/master/README.md). The draft's 9998 and 9999 are wrong and must not be used. |
| Config keys and data path | UNVERIFIED: the daemon's config file name, `datadir` flag and RPC keys were not read from upstream. The fork is Bitcoin-derived, so Bitcoin-style keys are a guess and must be confirmed. |
| arm64 | Not supported upstream (draft and release assets agree). |

## 2. Target layout

Exact file list for `apps/fluttercoin-wallet/`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required)
- `defaults/` is not needed (no seed files). `etc/`, `health/` and `scripts/` are not needed. `root/` is never used.
- `DOWNSTREAM_CHANGES.md` is not needed (not a `FROM` base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the build and the final stage. The draft's reason is confirmed: a headless daemon from a zip needs only the ubuntu base.
- Closest sibling: any apps/* with an ubuntu base and a single prebuilt binary, for example `apps/adguardhome-sync` (prebuilt binary on ubuntu). Check its layout before writing.
- Not `ich777/novnc-baseimage`: the upstream base is a Debian buster desktop image. It is not used.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`. Fail early on arm64 with a clear message, since there is no arm64 build.
   ```dockerfile
   ARG TARGETARCH
   RUN case "${TARGETARCH}" in amd64) ;; *) echo "fluttercoin-wallet: unsupported arch ${TARGETARCH}" >&2; exit 1 ;; esac
   ```
2. `USER root` for installs only. Install `unzip` only if `unzip` is missing from the base (UNVERIFIED: the base's package list was not read). Alternative: python3 `zipfile` is not in ubuntu base; prefer apt `unzip` with a pinned version checked against `VERSION`.
3. Download and verify:
   ```dockerfile
   ARG FLT_VERSION=0.7.5.22
   ARG FLT_SHA256=4d53d27e33c7467d89dd57a793aba99eec8fa94d3e24ff11b26dfecd37b33938
   RUN curl -fsSL "https://github.com/ofeefee/fluttercoin/releases/download/v${FLT_VERSION}-flt/fluttercoin-64-linux-v${FLT_VERSION}.zip" -o /tmp/flt.zip \
    && echo "${FLT_SHA256}  /tmp/flt.zip" | sha256sum -c - \
    && unzip -j /tmp/flt.zip fluttercoind -d /app/fluttercoin/bin \
    && chmod 0755 /app/fluttercoin/bin/fluttercoind
   ```
   The `FLT_SHA256` value is self-computed (section 1). Re-verify on a fresh download before the PR. Do not extract `fluttercoin-qt` or `themes/`.
4. Ship the license and notices: `/usr/share/licenses/fluttercoin-wallet/` gets the upstream `LICENSE` (UNVERIFIED: the file name inside the zip was not listed; the repository LICENSE must be fetched and copied).
5. Data path: `ENV HOME=/config` and pass `-datadir=/config/data` (or the equivalent flag) in `start.sh`. Confirm the flag name (section 10).
6. Writable paths: all caches and temp to `/tmp`. Nothing is written to `/app`.
7. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 7408 7474
   VOLUME /config
   ```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "fluttercoin-wallet"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ofeefee/fluttercoin versioning=loose
  default = "v0.7.5.22-flt"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/ofeefee/fluttercoin"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = ["linux/amd64"]
}
```

- `image-all` is amd64-only: arm64 is not built (section 4). Do not list arm64.
- `VERSION` is the tag. The Dockerfile derives `FLT_VERSION` by stripping `v` and `-flt`, so keep them in step; this is a version alignment point. Pass `FLT_VERSION` from bake too, or derive it in the Dockerfile and check it against the bake value.
- Validate with `docker buildx bake --print` from `apps/fluttercoin-wallet`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ofeefee/fluttercoin"
ports:
  - port: 7408
    protocol: tcp
    required: true
  - port: 7474
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `7408` (P2P) is `required: true`: the node cannot sync without it. `7474` (RPC) is optional for a wallet that only runs locally.
- Ports 9998 and 9999 from the draft are removed; they were not confirmed.
- `env`: only `TZ` until the daemon's real env or flags are confirmed (section 10). Do not invent env names.
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data
exec /app/fluttercoin/bin/fluttercoind -datadir=/config/data -printtoconsole
```

- Idempotent: the data folder is created only if missing. Nothing is seeded into `/config` (the daemon creates its own state on first run).
- No writes to `/app`.
- `exec` so signals reach the daemon.
- The flags `-datadir` and `-printtoconsole` are UNVERIFIED for this fork; confirm with `fluttercoind -help` in the run step before the script is accepted.
- RPC bind: the default RPC bind is `127.0.0.1`. To be reachable from other containers, set the bind to `0.0.0.0` in the config (UNVERIFIED key name). Do not set a password in the script; configure the RPC user only if the key is confirmed.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
  - port: '7408'
  - port: '7474'
filePaths:
  - /app/fluttercoin/bin/fluttercoind
  - /usr/share/licenses/fluttercoin-wallet/LICENSE
```

- Every port in `settings.yaml` has a `tcp` probe: 7408 and 7474.
- Long timeout: a first sync can take time, but the probe only checks the port, not the chain. UNVERIFIED: the daemon may bind RPC only after sync. If so, the 7474 probe needs narrowing, and that must follow the protocol's database-dependent exception, which does not apply here. Do not weaken the assertion; fix the start path instead.
- No `http` probe: the daemon speaks JSON-RPC, not HTTP GET. A `tcp` check is the honest probe.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write or bind | ContainerForge remap |
| --- | --- |
| `DATA_DIR=/fluttercoin` (upstream) | `/config/data` via `-datadir`, with `HOME=/config` |
| `USER=fluttercoin`, `UID=99`, `GID=100` (upstream) | `apps` (the base user), `USER apps` |
| `/root/.ccache` and build caches (upstream) | Not used at runtime. Build caches go to `/tmp` only |
| `/usr/share/novnc`, `/etc/.fluxbox`, desktop | Not used: the headless daemon has no desktop |
| `UMASK=000`, `DATA_PERM=770` (upstream) | Not needed for the daemon. Keep the base default |

- The draft's security expectations (non-root no, read-only no, privileged no) are the chart's defaults. The ContainerForge target is non-root, read-only-rootfs compatible and not privileged. The binary is writable only under `/config`.
- Read-only rootfs passes if the daemon writes only to `/config` and `/tmp`. Confirm with the run step.

## 10. Risks, caveats and open questions

- Draft caveat confirmed: arm64 is not supported. The bake target is amd64-only.
- Draft caveat confirmed: the upstream GUI wallet needs `libQtGui.so.4` (Qt4). It is not on ubuntu 26.04, so the GUI wallet and the noVNC desktop are not reproduced. Headless only.
- New caveat: the binary is a 2018 glibc build and has not been run on ubuntu 26.04 here. It may fail to start (missing libs, or the glibc symbol versions). The run step decides this. If it fails, the app is `unfixable` under the protocol's round limit.
- New caveat: the chart uses `ghcr.io/ich777/fluttercoin:latest`, a third-party image built on Debian buster (glibc). Using `COPY --from` on it is not the plan, because it is not the upstream build and it is not pinned. The zip is the source.
- New caveat: the release is from 2018 and the upstream project is unmaintained. The plan pins the tag and the self-computed SHA-256; a future fork would need a new review.
- UNVERIFIED: config file keys (RPC user/password, bind address, datadir flag), the daemon's default ports for this build, and whether RPC binds before sync.
- UNVERIFIED: whether `unzip` is in the ubuntu base.
- Blockers: none that stop the amd64 headless build, if the binary runs. The GUI and arm64 are out of scope.

## 11. Build and test steps

Run from `apps/fluttercoin-wallet`:

```sh
cd apps/fluttercoin-wallet
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name fluttercoin-wallet-probe --read-only --tmpfs /tmp \
  -v fluttercoin-wallet-probe-config:/config fluttercoin-wallet:v0.7.5.22-flt
docker logs -f fluttercoin-wallet-probe
forgetool containers test --image fluttercoin-wallet:v0.7.5.22-flt --config ./container-test.yaml
docker rm -f fluttercoin-wallet-probe; docker volume rm fluttercoin-wallet-probe-config
```

- Expected readiness signal: the daemon logs its startup line (for example `init message` or `Done loading`, UNVERIFIED for this build) and the P2P port 7408 is open. The exact line is confirmed on the first run.
- Empty `/config`: fresh named volume each round.
- Also confirm `fluttercoind -help` shows the flags used in `start.sh` before relying on them.
- If `forgetool` is unavailable, run `ss -ltn` inside the container and check 7408 and 7474.

## 12. PR checklist

- Branch: `feat/add-fluttercoin-wallet`.
- Commit: `feat(fluttercoin-wallet): add new container`.
- PR title matches the commit.
- Use `.github/PULL_REQUEST_TEMPLATE.md`. Check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Honest list of what is untested: whether the 2018 binary starts on ubuntu 26.04, the config keys and flags, arm64 (not supported), the self-computed SHA-256, and any run result. Do not check "Built container locally" unless the build and the run and test steps were done.
