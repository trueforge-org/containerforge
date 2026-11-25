# autobrr — implementation plan
> Source: ./draft.md · Target: apps/autobrr/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v1.91.1` (latest stable, published 2026-11-20). Draft pins `v1.91.0` (published 2026-11-19), one release behind; build the latest unless the user wants 1.91.0. Source: https://api.github.com/repos/autobrr/autobrr/releases/latest |
| Renovate | `datasource=github-releases depName=autobrr/autobrr versioning=semver` (tag `v1.91.1`, strict semver) |
| License | GPL-2.0 (GitHub API `spdx_id`). Source: https://api.github.com/repos/autobrr/autobrr |
| Source URL | https://github.com/autobrr/autobrr |
| Download amd64 | https://github.com/autobrr/autobrr/releases/download/v1.91.1/autobrr_1.91.1_linux_x86_64.tar.gz (tarball, preferred) |
| Download arm64 | https://github.com/autobrr/autobrr/releases/download/v1.91.1/autobrr_1.91.1_linux_arm64.tar.gz |
| Draft packaging | The draft points at `.apk` files (`autobrr_1.91.0_linux_amd64.apk`). The `.tar.gz` assets are the same binaries without apk packaging, so use them and avoid unpacking apk metadata. |
| Checksum source | `https://github.com/autobrr/autobrr/releases/download/v1.91.1/autobrr_1.91.1_checksums.txt`. Values read: linux_x86_64.tar.gz `069c886d28c55beac9355c0110e8845edcaa4d43b4edaf6e3cda3f0d8e974947`; linux_arm64.tar.gz `bbd1cdb010178db154e0fc88405aa075af1401498adadd37a78970ee0d91ade1`. These are for v1.91.1 only. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/autobrr/autobrr/abad209f1e6a7041f27eadccc27a5468d1c555fc/Dockerfile (node:24.19.0-alpine3.24 web build, golang:1.27-alpine3.24 app build with `CGO_ENABLED=0`, alpine:3.24 runner, `ENV HOME=/config XDG_CONFIG_HOME=/config XDG_DATA_HOME=/config`, `VOLUME /config`, `ENTRYPOINT ["/usr/local/bin/autobrr", "--config", "/config"]`, `EXPOSE 7474`, no USER, no CMD). |
| Ports | 7474/tcp (EXPOSE). Only port. |
| Env vars (real) | Only `HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME` are confirmed (Dockerfile). Config keys in `config.toml` (`host`, `port`, `checkForUpdates`, etc.) and any `AUTOBRR__` env override names are UNVERIFIED (not read from the repo docs). Do not list them in settings.yaml until confirmed. |
| Data path | `/config` (upstream VOLUME). `autobrr --config /config` reads `/config/config.toml` and writes its database under `/config`. |
| Binary linkage | Built with `CGO_ENABLED=0`, so the Go binary is static. The tarball also contains `autobrrctl` (UNVERIFIED: listing not read; check with `tar -tzf` in the build). |
| Web UI | Embedded in the binary via `web/dist` (the upstream build copies `web/dist` before `go build`). The release also ships `web-dist.tar.gz`, not needed. |

## 2. Target layout

- `apps/autobrr/Dockerfile`
- `apps/autobrr/docker-bake.hcl`
- `apps/autobrr/settings.yaml`
- `apps/autobrr/container-test.yaml`
- `apps/autobrr/start.sh`

No `defaults/` needed unless the seeded config is kept as a file in the image; start.sh writes it (see section 7). No `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The app is a static Go binary, so the base needs only CA certificates and a shell. Closest sibling for a prebuilt-binary ubuntu app: `apps/adguardhome-sync`. Upstream's alpine base is not reused: the Go binary is static, so glibc is not an issue.

## 4. Dockerfile

1. Single stage on the ubuntu base (download, no compile).
2. `ARG VERSION`, `ARG TARGETARCH`, and per-arch checksum args `ARG SHA256_AMD64`, `ARG SHA256_ARM64` with the values above (kept in step with VERSION).
3. `USER root`, then `apt-get install -y --no-install-recommends ca-certificates curl` only if the base does not already provide them (check first; do not reinstall). Pin any added apt version and check it against VERSION.
4. Map arch: `amd64 -> x86_64` (tarball name), `arm64 -> arm64`.
5. `curl -fL https://github.com/autobrr/autobrr/releases/download/v${VERSION}/autobrr_${VERSION}_linux_${ARCH}.tar.gz -o /tmp/autobrr.tgz`, check sha256 against the per-arch ARG, `tar -xzf /tmp/autobrr.tgz -C /tmp autobrr autobrrctl`, `install -m 0755 /tmp/autobrr /tmp/autobrrctl /app/`, then `rm -rf /tmp/autobrr*`.
6. License: upstream LICENSE from the tag copied to `/usr/share/licenses/autobrr/LICENSE`.
7. `ENV HOME=/config XDG_CONFIG_HOME=/config XDG_DATA_HOME=/config` (matches upstream; `/config` is the persistent path).
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 7474
VOLUME /config
WORKDIR /app
```

`VERSION` must equal the value in docker-bake.hcl. The arch mapping uses `x86_64` for amd64 because that is the asset name.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "autobrr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=autobrr/autobrr versioning=semver
  default = "1.91.1"
}

variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/autobrr/autobrr"
}
```

Note: the upstream tag is `v1.91.1`, so the download URL adds the `v` prefix in the Dockerfile. Standard four targets and default group copied from `apps/k8s-sidecar/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/autobrr/autobrr"
ports:
  - port: 7474
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

Only `TZ` (the common env used across siblings) and the port and volume are confirmed. Add autobrr's own env names only after they are read from its source. The `TZ` default is a sibling convention, not a verified autobrr variable: it is set in start.sh only if the sibling does so (check `apps/valkey` or `apps/adguardhome-sync`).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export HOME=/config XDG_CONFIG_HOME=/config XDG_DATA_HOME=/config

mkdir -p /config

if [ ! -s /config/config.toml ]; then
  cat > /config/config.toml <<'EOF'
host = "0.0.0.0"
port = 7474
EOF
fi

exec /app/autobrr --config /config
```

Notes:
- Seeds `config.toml` only when missing or empty (never overwrites user state), per the start-script rules.
- `host = "0.0.0.0"` and `port = 7474` are UNVERIFIED key names: confirm against autobrr's default config template before the PR. If the key names differ, correct them; do not guess.
- No writes to `/app`. `/tmp` is the only scratch space.
- `exec` for signal handoff.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '7474'
http:
- port: '7474'
  path: /
filePaths:
- /app/autobrr
- /app/autobrrctl
- /config/config.toml
- /usr/share/licenses/autobrr/LICENSE
```

- `timeoutSeconds` 60 is a sibling-free guess for a single Go binary: check a sibling Go app and match it.
- `/config/config.toml` is in `filePaths` because the test runs with no env vars and a fresh `/config`, so seeding is exercised.
- Port 7474 has both a tcp and an http probe (coverage rule).

## 9. Rootless and read-only-rootfs adaptations

| Upstream | Remap |
| --- | --- |
| Runs as root (no USER) | `USER apps` |
| `HOME`, `XDG_*` at `/config` | Kept (persistent) |
| Chart `config.toml` configmap mount (read-only) | Not used. start.sh seeds `/config/config.toml`, and UI changes persist in `/config`. The draft's caveat about read-only config does not apply to this image. |
| Ephemeral scratch | `/tmp` only |

Chart expectations (runAsUser 568, read-only rootfs) match this plan.

## 10. Risks, caveats and open questions

- Draft version is one release behind (1.91.0 vs 1.91.1). Confirm the target version with the user if it matters.
- `config.toml` key names and the bind address default are UNVERIFIED (section 7). Check before writing.
- Checksum values are for 1.91.1 only; a version bump must refresh both ARGs.
- The apk assets in the draft are not used; the tarball is the same build without apk packaging. If the tarball's binary differs from the apk's, note it (UNVERIFIED: not compared).
- The first admin account is created in the web UI on first visit (draft caveat, UNVERIFIED by a read of the source). Test for the login page only; no admin is created by the test.
- No blockers: amd64 and arm64 both available, static binary, single process, no privileged access.

## 11. Build and test steps

```sh
cd apps/autobrr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name autobrr-probe --read-only --tmpfs /tmp \
  -v autobrr-probe-config:/config autobrr:1.91.1
docker logs -f autobrr-probe
forgetool containers test --image autobrr:1.91.1 --config ./apps/autobrr/container-test.yaml
docker rm -f autobrr-probe; docker volume rm autobrr-probe-config
```

Readiness signal: the log shows the HTTP server listening on 7474 (exact text UNVERIFIED until a run captures it), the process stays up, and `/config/config.toml` exists after start. Test an empty `/config` each round, as the protocol requires.

## 12. PR checklist

- Branch `feat/add-autobrr`, commit and PR title `feat(autobrr): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows the status).
- Say what was not tested if the build or run did not happen, and state the version choice (1.91.1 over the draft's 1.91.0).
- No `FROM` users expected (check with `grep -rn autobrr apps/*/Dockerfile`).
