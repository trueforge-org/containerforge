# signal-cli-rest-api — implementation plan
> Source: ./draft.md · Target: apps/signal-cli-rest-api/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Draft pins container `bbernhard/signal-cli-rest-api:0.101` (release 2026-09-25, tag commit `74253a3a41c2cade40fd4a53cf3fb7a3fdf305dc`). Latest stable release is `0.102` (published 2026-11-21, no release assets). Source: https://api.github.com/repos/bbernhard/signal-cli-rest-api/releases |
| Draft differences | Draft says "state under /config" in the Overview: wrong for upstream, whose state dir is `SIGNAL_CLI_CONFIG_DIR=/home/.local/share/signal-cli`. Draft's java25 sibling choice matches upstream (`openjdk-25-jre`). Draft's "compile" for both arches is correct: no binary is published. |
| Renovate | Proposed: `datasource=github-releases depName=bbernhard/signal-cli-rest-api versioning=semver`. UNVERIFIED against a live renovate run. |
| License | MIT (https://api.github.com/repos/bbernhard/signal-cli-rest-api/license; LICENSE at https://raw.githubusercontent.com/bbernhard/signal-cli-rest-api/0.101/LICENSE) |
| Source URL | https://github.com/bbernhard/signal-cli-rest-api |
| Download, REST server | Source only (no release assets). Compiled from the tag. |
| Download, signal-cli | `https://github.com/AsamK/signal-cli/releases/download/v<ver>/signal-cli-<ver>-Linux-client.tar.gz` (client tarball needs a JVM). Latest upstream signal-cli is `v0.14.10` (2026-11-07), assets `signal-cli-0.14.10-Linux-client.tar.gz` and `...-Linux-native.tar.gz`, from https://api.github.com/repos/AsamK/signal-cli/releases/latest. The 0.101 Dockerfile pins `SIGNAL_CLI_VERSION=0.14.8`. |
| Checksum source | signal-cli: `.asc` GPG signatures only; no sha256 asset found. UNVERIFIED which hash source to use. REST server: git tag commit SHA. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/bbernhard/signal-cli-rest-api/0.101/Dockerfile (summary; the fetch tool did not return the verbatim text). Build stage `golang:1.26-trixie`, runtime `debian:trixie-slim`. ARGs: `SIGNAL_CLI_VERSION=0.14.8`, `LIBSIGNAL_CLIENT_VERSION=0.102.1`, `SWAG_VERSION=1.16.4`, `S6_OVERLAY_VERSION=v3.2.2.0`. Runtime installs `openjdk-25-jre` and s6-overlay. ENV `PORT=8080`, `SIGNAL_CLI_CONFIG_DIR=/home/.local/share/signal-cli`, `S6_READ_ONLY_ROOT=1`, `GIN_MODE=release`. `EXPOSE ${PORT}`, `USER signal-api` (UID/GID 1000), `ENTRYPOINT ["/init"]`, healthcheck `GET /v1/health`. |
| Port | 8080/tcp, `PORT` env, default 8080 (upstream Dockerfile, confirmed in summary). |
| arm64 | UNVERIFIED for the upstream image. Upstream removes the native signal-cli binary only on armv7l, so arm64 is intended. |
| Dependencies | None (no database). JVM is bundled through `apps/java25`. Signal account registration through the REST API is required before messages can be sent. |

## 2. Target layout

- `apps/signal-cli-rest-api/Dockerfile`
- `apps/signal-cli-rest-api/docker-bake.hcl`
- `apps/signal-cli-rest-api/settings.yaml`
- `apps/signal-cli-rest-api/container-test.yaml`
- `apps/signal-cli-rest-api/start.sh`

No `defaults/`, `etc/` or `root/`. `DOWNSTREAM_CHANGES.md` is not needed (not a `FROM` base).

## 3. Base image

- Final stage: `ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d` (JRE, runs the signal-cli JVM child process).
- Build stage: Go in a dedicated stage (`FROM golang:1.26-trixie AS build`, taken from the upstream build stage; digest pinned at build time, UNVERIFIED digest). The REST server needs Go; signal-cli needs only the JVM at runtime.
- Closest sibling: `apps/java25` (same JVM runtime pattern) and `apps/adguardhome-sync` (Go binary copied from a build stage).
- Alternative: ubuntu base with `apt` `openjdk-25-jre-headless`, only if java25 proves unusable. Not planned.

## 4. Dockerfile

1. `FROM golang:1.26-trixie@sha256:... AS build` (UNVERIFIED digest). `ARG VERSION`, `ARG SIGNAL_CLI_VERSION=0.14.10`, `ARG TARGETARCH`.
2. Build the REST server from the pinned tag: `git clone --depth 1 --branch "${VERSION}" https://github.com/bbernhard/signal-cli-rest-api /src`. Build steps follow the upstream Dockerfile (libsignal-client native library, swag docs). The libsignal-client step is the hardest part: its per-arch native library source is UNVERIFIED. Blocker if it needs a network download with no checksum.
3. Download signal-cli: `curl -fL -o /tmp/signal-cli.tgz https://github.com/AsamK/signal-cli/releases/download/v${SIGNAL_CLI_VERSION}/signal-cli-${SIGNAL_CLI_VERSION}.tar.gz` (the JVM-based tarball, arch-independent). Verify the `.asc` signature with the AsamK key if the key is available, or record UNVERIFIED for the checksum source.
4. Final stage: `FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:...`, `ARG VERSION`, `ARG SIGNAL_CLI_VERSION`, `USER root`.
5. `COPY --from=build /out/rest-server /app/signal-cli-rest-api` (binary path from the build stage; UNVERIFIED until built). Extract signal-cli to `/app/signal-cli-${SIGNAL_CLI_VERSION}` and symlink `/app/bin/signal-cli`.
6. License: `COPY --from=build /src/LICENSE /usr/share/licenses/signal-cli-rest-api/LICENSE`, plus signal-cli's LICENSE from its tarball to `/usr/share/licenses/signal-cli-rest-api/signal-cli-LICENSE`.
7. `chown -R apps:apps /app && chmod -R 755 /app`. Clean up `/tmp` downloads.
8. `ENV PORT=8080 GIN_MODE=release SIGNAL_CLI_CONFIG_DIR=/config/signal-cli SIGNAL_CLI_REST_API_PLUGIN_SHARED_OBJ_DIR=/usr/bin/ HOME=/config` (remap the upstream `/home/.local/share/signal-cli` to `/config/signal-cli`; see section 9).
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /config
```

Upstream `ENTRYPOINT ["/init"]` (s6-overlay) is not copied: we use a plain `start.sh`, which needs no s6.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "signal-cli-rest-api"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=bbernhard/signal-cli-rest-api versioning=semver
  default = "0.101"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/bbernhard/signal-cli-rest-api"
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
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

`VERSION` is `0.101` to match the draft. Decide between `0.101` and `0.102` before the first build (section 10). Validate with `docker buildx bake --print`. Add `SIGNAL_CLI_VERSION` as a second `variable` with its own renovate annotation (`datasource=github-releases depName=AsamK/signal-cli`), aligned with the Dockerfile `ARG`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/bbernhard/signal-cli-rest-api"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: PORT
    default: "8080"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

`dependencies`: none. No DB. The JVM comes from the java25 base, not a ContainerForge dependency app.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/signal-cli
export PORT="${PORT:-8080}"
export SIGNAL_CLI_CONFIG_DIR="${SIGNAL_CLI_CONFIG_DIR:-/config/signal-cli}"
cd /app
exec /app/signal-cli-rest-api
```

Rules: idempotent (`mkdir -p` only), no writes to `/app`, state only under `/config`, bind `0.0.0.0` (upstream `PORT` binds all interfaces; confirm in the first run), and `exec` the process. Caches (`GOCACHE`, any JVM temp) go to `/tmp` via `JAVA_TOOL_OPTIONS=-Djava.io.tmpdir=/tmp` (UNVERIFIED that the REST server honours this; confirm with a `--read-only` run).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /v1/health
filePaths:
- /app/signal-cli-rest-api
- /app/signal-cli-0.14.10/bin/signal-cli
- /usr/share/licenses/signal-cli-rest-api/LICENSE
```

Both `tcp` and `http` probes on 8080, per the coverage rule. `/v1/health` is the upstream healthcheck path (from the upstream Dockerfile summary). Without an account, the health endpoint should still return 200 (UNVERIFIED: confirm on first run; if it does not, use `path: /` and record why). `timeoutSeconds: 120` because the JVM and REST startup are slow. The account-registration code path needs env vars or a number, so it is not tested here; it is out of scope for the suite (no required env).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/home/.local/share/signal-cli` (SIGNAL_CLI_CONFIG_DIR) | `/config/signal-cli`. Chart's targetSelector mounts `/home/.local/share/signal-cli` (pvc). Existing users must move their data to `/config/signal-cli` or mount the volume there. |
| `WORKDIR /home`, `HOME` | `HOME=/config` (writable). |
| s6-overlay runtime (`S6_RUNTIME_PATH=/tmp/s6-runtime`, `S6_READ_ONLY_ROOT=1`) | Not used. Plain `start.sh`, so no s6 runtime writes. |
| JVM temp files | `/tmp` via `-Djava.io.tmpdir=/tmp` (UNVERIFIED need). |
| Runtime user | Upstream `signal-api` (UID 1000). Ours `apps` (568). The chart's runAsUser 0 override is not carried over. |
| Chart `readOnlyRootFilesystem: false` | Our image should run with `--read-only --tmpfs /tmp` and a `/config` volume; verify in step 11. |

## 10. Risks, caveats and open questions

- Version choice: `0.101` (draft, container tag) versus `0.102` (latest release, no assets). Decide before the first build, then align the bake `VERSION`, the Dockerfile `ARG` and the upstream tag. UNVERIFIED whether 0.102 changes the signal-cli pin.
- signal-cli pin: upstream 0.101 uses `0.14.8`; the latest signal-cli is `0.14.10`. Keep `0.14.8` for parity with upstream, or move to `0.14.10` and test. Either way, record the choice in the PR.
- libsignal-client native library: the hardest build step, and its arch-specific source is UNVERIFIED. If it cannot be built reliably for amd64 and arm64, this app is blocked and must be reported rather than hacked around.
- Account state: the phone-number account must persist in `/config/signal-cli`, or it must be re-registered and rate limits may apply (draft caveat, accepted).
- JVM memory: small RAM limits may kill the child process (draft caveat, inferred, not tested).
- Chart port and state path must be updated in the downstream chart when the image moves from `/home/.local/share/signal-cli` to `/config/signal-cli`. This is a chart concern, not an image one.
- Draft says `copy-from` is `bbernhard/signal-cli-rest-api:0.101` for both arches. That image is debian-based and runs `signal-api` as UID 1000, so `COPY --from` is possible in principle, but the draft chose compile. Keep compile unless the libsignal step is blocked; then document the copy-from fallback in the PR (UNVERIFIED for arm64 availability of that image).
- Blockers (current): libsignal-client arch-specific native library, unverified. Otherwise none confirmed.

## 11. Build and test steps

```sh
cd apps/signal-cli-rest-api
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name signal-cli-rest-api-probe --read-only --tmpfs /tmp \
  -v signal-cli-rest-api-probe-config:/config signal-cli-rest-api:0.101
docker logs -f signal-cli-rest-api-probe
forgetool containers test --image signal-cli-rest-api:0.101 --config ./apps/signal-cli-rest-api/container-test.yaml
docker rm -f signal-cli-rest-api-probe; docker volume rm signal-cli-rest-api-probe-config
```

Readiness signal: the REST server log line for `PORT` 8080 listening (UNVERIFIED wording; capture from the first run), and `GET /v1/health` returns 200. Also run once with a fresh `/config`, then restart on the same volume to confirm `/config/signal-cli` persists.

## 12. PR checklist

- Branch `feat/add-signal-cli-rest-api`, commit and PR title `feat(signal-cli-rest-api): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows the status.
- Say what was not tested: the REST server build on arm64, the libsignal-client step on each arch, account registration, and the chart state-path move.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`.
