# storm — implementation plan
> Source: ./draft.md · Target: apps/storm/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.3.0`, GitHub release `v1.3.0` published 2023-06-03. It is the latest release. Draft chart image `ghcr.io/relvacode/storm:v1.3.0` matches. |
| Renovate | `datasource=github-releases depName=relvacode/storm versioning=semver` |
| License | MIT (GitHub SPDX). Source: https://api.github.com/repos/relvacode/storm |
| Source URL | https://github.com/relvacode/storm |
| amd64 download | `https://github.com/relvacode/storm/releases/download/v1.3.0/storm-v1.3.0-linux-amd64.tar.gz` |
| arm64 download | `https://github.com/relvacode/storm/releases/download/v1.3.0/storm-v1.3.0-linux-arm64.tar.gz` |
| Checksum source | Per-asset `.sha256` file at the same URL plus `.sha256`. amd64 `a518f6c1935b4da5ea340cc83c59167d1931b33afa161fc8ce77d33c1381bb9a`, arm64 `4d3ebb4246cddec5ef7266e98d9702f2c9973ee1e2d5d09e3ac7866301c49b89`. The `.sha256` files contain only the hash, no filename (observed in the fetch). |
| Upstream Dockerfile reviewed | `Dockerfile` (tag v1.3.0): `golang:alpine` build with `CGO_ENABLED=0`, `go build -ldflags="-s -w" github.com/relvacode/storm/cmd/storm`; final `alpine`, `COPY --from=compiler /go/src/storm/storm /usr/bin/storm`, `ENTRYPOINT ["/usr/bin/storm"]`. No `USER`, `VOLUME` or `EXPOSE`. We take the binary only. |
| Env vars (real, README and `cmd/storm/server.go` at v1.3.0) | `LISTEN_ADDR` (default `:8221`), `STORM_BASE_PATH` (default `/`), `STORM_API_KEY` (optional auth), `DELUGE_RPC_HOSTNAME`, `DELUGE_RPC_PORT`, `DELUGE_RPC_USERNAME`, `DELUGE_RPC_PASSWORD`, `DELUGE_RPC_VERSION` (`v1` or `v2`, default `v1`). |
| Port | 8221/tcp (`LISTEN_ADDR` default). The draft's 8080 is wrong. |
| Data/config write paths | None. Storm takes its config only from env/flags and writes no files, per the README. |
| Dependencies | A reachable Deluge daemon with RPC enabled (`allow_remote: true`). Deluge auth is required. The draft's "debrid account and API token" caveat is wrong and is removed. `apps/deluge` exists in this repo. |
| arm64 | Yes (`linux-arm64` tarball). |
| UNVERIFIED | Whether storm starts cleanly with no Deluge reachable (affects the test run in section 8). Default `DELUGE_RPC_PORT` value is not in the fetched pages. Tarball internal layout (binary at root or in a subdirectory). |

## 2. Target layout

- `apps/storm/Dockerfile`
- `apps/storm/docker-bake.hcl`
- `apps/storm/settings.yaml`
- `apps/storm/container-test.yaml`
- `apps/storm/start.sh`

No `defaults/`, `etc/` or `health/`: storm has no config file to seed. No `DOWNSTREAM_CHANGES.md`: this image is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The Go binary is static (`CGO_ENABLED=0`), so glibc ubuntu is fine. The draft's `alpine` base is not needed. Closest sibling: `apps/adguardhome-sync` (prebuilt tarball on ubuntu).

## 4. Dockerfile

1. Header: `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download `storm-v${VERSION}-linux-${TARGETARCH}.tar.gz` and its `.sha256` into `/tmp/storm`. `TARGETARCH` values (`amd64`, `arm64`) match the asset names directly.
3. Verify: `echo "$(cat storm.sha256)  storm.tar.gz" | sha256sum -c -` (the `.sha256` file has no filename, so the filename is added here).
4. Extract to `/tmp/storm`, then `install -m 0755` the `storm` binary to `/app/storm`. Tarball layout is UNVERIFIED; check with `tar tzf` during the build.
5. Licence: ship `LICENSE` from the repo (`raw.githubusercontent.com/relvacode/storm/v${VERSION}/LICENSE`) to `/usr/share/licenses/storm/LICENSE`, since only the binary is extracted.
6. `rm -rf /tmp/storm`, `chown -R apps:apps /app`, `chmod -R 755 /app`.
7. `ENV HOME=/config`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8221
```

No `VOLUME /config`: storm writes no state (see section 9). No `apt-get`, so no package pins apply.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "storm"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=relvacode/storm versioning=semver
  default = "1.3.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/relvacode/storm"
}
```

Then the standard `group "default"`, `image`, `image-local` and `image-all` targets, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `cd apps/storm && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/relvacode/storm"
ports:
  - port: 8221
    protocol: tcp
    required: true
env:
  - name: LISTEN_ADDR
    default: "0.0.0.0:8221"
    required: false
  - name: STORM_BASE_PATH
    default: "/"
    required: false
  - name: DELUGE_RPC_HOSTNAME
    default: ""
    required: false
  - name: DELUGE_RPC_PORT
    default: ""
    required: false
  - name: DELUGE_RPC_USERNAME
    default: ""
    required: false
  - name: DELUGE_RPC_PASSWORD
    default: ""
    required: false
  - name: DELUGE_RPC_VERSION
    default: "v1"
    required: false
  - name: STORM_API_KEY
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
dependencies:
  - deluge
```

Notes: `DELUGE_RPC_*` are optional at this level because storm can start without them (see section 10). `STORM_API_KEY` is a secret and has an empty default. `dependencies` lists `deluge` (exists as `apps/deluge`), marked as a runtime dependency for storm to be useful. `DELUGE_RPC_PORT` has an empty default; do not invent a port number (UNVERIFIED).

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- Export `LISTEN_ADDR=0.0.0.0:8221` only if unset, and `DELUGE_RPC_VERSION=v1` only if unset.
- Do not echo `DELUGE_RPC_PASSWORD` or `STORM_API_KEY`; do not pass them as command-line flags (they would show in the process list). Storm reads them from env.
- `cd /app` and `exec /app/storm` (no flags; the binary reads env via its option parser).
- No `/config` seeding (no state). Writes: nothing. No caches.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8221'

filePaths:
- /app/storm
```

The test runs with no env vars, so the Deluge RPC code path is not exercised. If storm needs Deluge to reach its listener, the tcp probe will fail, and the fix is to run the Deluge path per the build-test protocol rather than weaken the probe (UNVERIFIED; check during step 3 of section 11). Timeout: default (no `timeoutSeconds` in sibling `adguardhome-sync`).

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (UID from base image). Port 8221 is above 1024, so no privileged port is needed.
- The draft's `runAsUser 0` and `readOnlyRootFilesystem: false` from the chart are not needed: storm writes nothing, so the image works with `--read-only --tmpfs /tmp`.
- No `/config` volume: storm persists nothing. If a later version adds state, add `volumes: /config` at that point.
- `STORM_API_KEY` is a secret and must come from env only (section 7).

## 10. Risks, caveats and open questions

- Draft caveat "debrid service account and API token" is wrong. Storm needs a Deluge daemon, documented in the README. Corrected in sections 1 and 6.
- Draft port 8080 is wrong. The default is 8221. Corrected in section 6.
- Draft caveat "config must be created in /config by hand" is not supported by any fetched page. Storm reads config from env only.
- Whether storm exits when Deluge is unreachable at start is UNVERIFIED. If it exits, the test in section 8 needs a Deluge stub or a narrowed assertion that is annotated per the protocol (the database exception does not apply: Deluge is not a database).
- Chart migration: the chart's `runAsUser 0` and `readOnlyRootFilesystem: false` overrides go away with this image.
- No blockers: no arm64 gap, no privileged port, no GPU, no musl-only binary.

## 11. Build and test steps

1. `cd apps/storm && docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name storm-probe --read-only --tmpfs /tmp storm:1.3.0`, then `docker logs -f storm-probe`. Expected readiness signal: `Ready to serve HTTP connections on :8221/` (the exact text from `cmd/storm/server.go`, line 94). Also confirm the container is still running after the startup window.
4. Clean up: `docker rm -f storm-probe`. No volume is created because the image has no `/config` volume.
5. `forgetool containers test --image storm:1.3.0 --config ./apps/storm/container-test.yaml`.
6. Optional: run with a Deluge stub (or a real `apps/deluge` container on a shared network) and `DELUGE_RPC_HOSTNAME` set, to confirm the RPC path logs no fatal errors.

## 12. PR checklist

- Branch `feat/add-storm`, commit `feat(storm): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested: arm64 build, live Deluge RPC connection (unless run with a Deluge stub).
