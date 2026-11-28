# soft-serve — implementation plan
> Source: ./draft.md · Target: apps/soft-serve/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.12.4` (GitHub release `v0.12.4`, published 2026-10-23). Matches the draft. Chart image `ghcr.io/charmbracelet/soft-serve:v0.12.4`. Source: `gh api repos/charmbracelet/soft-serve/releases/latest`. |
| Renovate | `datasource=github-releases depName=charmbracelet/soft-serve versioning=semver` |
| License | MIT. https://github.com/charmbracelet/soft-serve/blob/main/LICENSE |
| Source URL | https://github.com/charmbracelet/soft-serve |
| Download amd64 | `https://github.com/charmbracelet/soft-serve/releases/download/v0.12.4/soft-serve_0.12.4_Linux_x86_64.tar.gz` (sha256 `bcf2e49bd95c34946708a7efe8ed5040125f84ed213bbc1a4a59982811af636b`) |
| Download arm64 | `https://github.com/charmbracelet/soft-serve/releases/download/v0.12.4/soft-serve_0.12.4_Linux_arm64.tar.gz` (sha256 `9f70fbd02577abcad05c9bf2c91cf22f6026f92da6ae0f834dcead65271153eb`). This is a glibc-compatible tarball. The draft's arm64 link (`soft-serve_0.12.4_aarch64.apk`) is an Alpine package and is not used. |
| Checksum source | (both sha256 values above match `checksums.txt`, checked 2026-11-25) `https://github.com/charmbracelet/soft-serve/releases/download/v0.12.4/checksums.txt` (also `checksums.txt.sigstore.json` for signature verification, UNVERIFIED whether we verify the signature). |
| Upstream Dockerfile reviewed | https://github.com/charmbracelet/soft-serve/blob/v0.12.4/Dockerfile: `FROM alpine:latest`, `WORKDIR /soft-serve`, `VOLUME /soft-serve`, `ENV SOFT_SERVE_DATA_PATH=/soft-serve SOFT_SERVE_INITIAL_ADMIN_KEYS="" CI=1`, `EXPOSE 23231/tcp 23232/tcp 23233/tcp 9418/tcp`, `ENTRYPOINT ["/usr/local/bin/soft","serve"]`, apk installs `git bash openssh`, `COPY soft /usr/local/bin/soft`. No `USER` line, so upstream runs as root. |
| Ports (real) | 23231/tcp SSH (git over SSH and TUI), 23232/tcp HTTP, 23233/tcp stats, 9418/tcp git protocol. Confirmed by the upstream Dockerfile and docker.md. |
| Env vars (real) | `SOFT_SERVE_DATA_PATH` (data dir, default `/soft-serve` in image), `SOFT_SERVE_INITIAL_ADMIN_KEYS` (newline-joined public keys, first admin), `SOFT_SERVE_DEFAULT_REPO` (README), `SOFT_SERVE_NAME`, `SOFT_SERVE_CONFIG_LOCATION` (README), `SOFT_SERVE_SSH_LISTEN_ADDR`, `SOFT_SERVE_SSH_PUBLIC_URL`, `SOFT_SERVE_SSH_ENABLED`, `SOFT_SERVE_GIT_LISTEN_ADDR`, `SOFT_SERVE_GIT_ENABLED` (from `pkg/config/config.go` and the README), `CI=1` (upstream workaround for slow docker TTY). HTTP and stats listen var names are inferred from the same pattern (`SOFT_SERVE_HTTP_LISTEN_ADDR`, `SOFT_SERVE_STATS_LISTEN_ADDR`), UNVERIFIED in code. |
| Default listen addresses | SSH `:23231` (README/config yaml sample). |
| Data path | `SOFT_SERVE_DATA_PATH`. Repos, `ssh/soft_serve_host` host key, `ssh/known_hosts`, sqlite DB. Config file optional via `SOFT_SERVE_CONFIG_LOCATION`. |
| apt needs | `git` (repo operations), `bash` (upstream installs it), `openssh-client` (ssh remotes for mirror/import, from `pkg/config/ssh.go` client settings). Exact need of `openssh-client` is UNVERIFIED for the default config. |
| Dependencies | none (soft-serve embeds its database). |

## 2. Target layout

- `apps/soft-serve/Dockerfile`
- `apps/soft-serve/docker-bake.hcl`
- `apps/soft-serve/settings.yaml`
- `apps/soft-serve/container-test.yaml`
- `apps/soft-serve/start.sh`

No `defaults/`, `etc/` or `health/` are needed. The app creates its own data on first start. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits because soft-serve ships a prebuilt, self-contained Go binary (no compile needed) and runs on glibc Ubuntu. Closest sibling: `apps/adguardhome-sync` (prebuilt binary tarball extracted to `/app`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`. `ENV HOME=/tmp CI=1`.
2. `apt-get install -y --no-install-recommends git bash openssh-client` then `rm -rf /var/lib/apt/lists/*`. Check against the ubuntu archive: UNVERIFIED whether the package versions need pinning. Pin only if the archive version differs in a way that matters, as `apps/valkey` does. Confirm `git` is not already in the base before installing.
3. Arch mapping (TARGETARCH to Goreleaser name): `amd64` -> `Linux_x86_64`, `arm64` -> `Linux_arm64`.
4. `curl -fsSL -o /tmp/soft.tar.gz "https://github.com/charmbracelet/soft-serve/releases/download/v${VERSION}/soft-serve_${VERSION}_${ARCH_NAME}.tar.gz"`, verify with `sha256sum -c` against the line from `checksums.txt` for that file (download `checksums.txt` alongside and grep the line).
5. `mkdir -p /app/soft-serve && tar xzf /tmp/soft.tar.gz -C /app/soft-serve soft`. Contents of the archive are UNVERIFIED beyond the `soft` binary that the upstream Dockerfile copies. Confirm with `tar tzf` during the build.
6. Ship the license: `mkdir -p /usr/share/licenses/soft-serve` and copy `LICENSE` from the tarball if present, or fetch `https://raw.githubusercontent.com/charmbracelet/soft-serve/v0.12.4/LICENSE` (MIT).
7. `chown -R apps:apps /app && chmod -R 755 /app`, `rm -rf /tmp/*`.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 23231 23232 23233 9418`, `VOLUME /config`, `ENV SOFT_SERVE_DATA_PATH=/config/soft-serve`.

`ARG VERSION` must match `docker-bake.hcl`. The `v` prefix comes from the tag only.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "soft-serve" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=charmbracelet/soft-serve versioning=semver
  default = "0.12.4"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/charmbracelet/soft-serve" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print` from `apps/soft-serve`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/charmbracelet/soft-serve"
ports:
  - port: 23231
    protocol: tcp
    required: true
  - port: 23232
    protocol: tcp
    required: false
  - port: 23233
    protocol: tcp
    required: false
  - port: 9418
    protocol: tcp
    required: false
env:
  - name: SOFT_SERVE_DATA_PATH
    default: "/config/soft-serve"
    required: false
  - name: SOFT_SERVE_INITIAL_ADMIN_KEYS
    default: ""
    required: false
  - name: SOFT_SERVE_DEFAULT_REPO
    default: ""
    required: false
  - name: SOFT_SERVE_SSH_LISTEN_ADDR
    default: ":23231"
    required: false
  - name: SOFT_SERVE_GIT_LISTEN_ADDR
    default: ":9418"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only env vars the app really reads are listed. `SOFT_SERVE_HTTP_LISTEN_ADDR` and `SOFT_SERVE_STATS_LISTEN_ADDR` are UNVERIFIED names and are left out until confirmed in code. `TZ` is listed as the standard ContainerForge convention, not as an upstream var.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p "${SOFT_SERVE_DATA_PATH:-/config/soft-serve}"

exec /app/soft-serve/soft serve
```

- Idempotent. Soft-serve creates its own host key and database under the data path on first start. Nothing is seeded.
- Nothing is written to `/app`. Repos and keys live under `/config/soft-serve`.
- `exec` hands PID 1 to the server.
- Admin bootstrap is via `SOFT_SERVE_INITIAL_ADMIN_KEYS`, read by soft-serve itself. `start.sh` does not transform it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '23231'
- port: '23232'
- port: '23233'
- port: '9418'
http:
- port: '23232'
  path: /
filePaths:
- /app/soft-serve/soft
- /usr/share/licenses/soft-serve
```

- Every port in `settings.yaml` gets a `tcp` probe. HTTP probe on 23232 `/` is UNVERIFIED (must return 200; check during the run).
- `filePaths` covers the binary and license. The test runs with no env vars, so the admin-key path is not exercised.
- `timeoutSeconds` 120 is the sibling default for ssh-based apps, UNVERIFIED against a sibling.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/soft-serve` (repos, ssh host key, `known_hosts`, sqlite) | `SOFT_SERVE_DATA_PATH=/config/soft-serve`, persistent `/config` volume |
| `$HOME` (git global config, ssh client files) | `HOME=/tmp`. Ephemeral and read-only-rootfs safe. |
| Upstream runs as root (`runAsUser 0`, `runAsNonRoot false` in the chart) | `USER apps`. All four ports (23231, 23232, 23233, 9418) are above 1024, so `apps` can bind them without extra capabilities. |

Chart expectations to reconcile: draft says non-root no and read-only rootfs no. Our image runs as `apps` and is read-only compatible, so the chart values must be overridden when it is ported.

## 10. Risks, caveats and open questions

- Draft caveat confirmed: the upstream arm64 artifact is an Alpine `.apk`. This plan uses the glibc `Linux_arm64.tar.gz` instead, so the caveat is resolved.
- Port 9418 (git protocol) is above 1024, so no sysctl or capability is needed. The git daemon is enabled by default upstream (UNVERIFIED: confirm 9418 opens in the first run, otherwise drop its tcp probe and mark the port optional).
- First admin key: the first key in `SOFT_SERVE_INITIAL_ADMIN_KEYS` is the only admin. It must be set before first use (manual setup).
- SSH host keys are generated on first start in `/config/soft-serve/ssh`. Losing `/config` changes the host identity.
- `CI=1` is an upstream workaround for slow TTY in docker. It is kept as an env default in the Dockerfile.
- No blockers found: no GPU, no privileged needs, arm64 published.

## 11. Build and test steps

From `apps/soft-serve/`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name soft-serve-probe --read-only --tmpfs /tmp \
  -v soft-serve-probe-config:/config soft-serve:0.12.4
docker logs -f soft-serve-probe
docker rm -f soft-serve-probe; docker volume rm soft-serve-probe-config
forgetool containers test --image soft-serve:0.12.4 --config ./apps/soft-serve/container-test.yaml
```

- Expected readiness signal: the process stays up and logs show the SSH and git listeners starting on 23231 and 9418. The exact log line is UNVERIFIED, so check it during the run.
- Also run once with `SOFT_SERVE_INITIAL_ADMIN_KEYS` set and confirm the admin works over SSH. This path is not covered by the test suite.
- arm64: build only if the amd64 build fails in an arm64-specific way (per the protocol).

## 12. PR checklist

- Branch `feat/add-soft-serve`, commit `feat(soft-serve): add new container`, PR title matches.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections and checkboxes, and only ticks boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`.
- Tell the user the CLA is needed: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- State what is untested: the arm64 build, SSH admin flow, and whether 9418 opens by default, unless verified.

## Fix attempt (2026-11-28)

- Wrote the full file set. Verified: v0.12.4 is still the latest release; both Linux checksums match `checksums.txt`; the tarball holds `soft-serve_0.12.4_Linux_x86_64/{soft,LICENSE,...}`, so the Dockerfile uses `--strip-components=1`; `SOFT_SERVE_{SSH,HTTP,GIT,STATS}_LISTEN_ADDR` names confirmed in `pkg/config/config.go`. Upstream defaults the stats listener to `localhost:23233`, so `start.sh` sets `:23233`.
- Base digest corrected to `f01a4295...` (as in `apps/adguardhome-sync`).
- Not verified: no build or run; apt packages are not version-pinned; `/` on 23232 returning 200; the README marks the project as sunset (no further security updates), which the PR should mention.
