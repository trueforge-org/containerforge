# apt-cacher-ng — implementation plan
> Source: ./draft.md · Target: apps/apt-cacher-ng/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Ubuntu 26.04 (`resolute`) archive package `apt-cacher-ng 3.7.5-1.1` (packages.ubuntu.com/resolute/apt-cacher-ng; not re-fetched in this verification pass). The upstream image is stale: its last release is `v3.7.4-20220421` (sameersbn/docker-apt-cacher-ng, `gh api`). Build the package from apt, pinned to the resolute version (exact pocket UNVERIFIED). |
| Renovate | `apps/valkey/docker-bake.hcl` (apt-pinned sibling) has no renovate comment (repology disabled, version tied to the base image). No datasource is confirmed for this app. |
| License | MIT for the image repository (`gh api`). The Debian/Ubuntu package copyright file is UNVERIFIED; the apt-cacher-ng project is GPL-licensed in its upstream source tarball (UNVERIFIED). Use the package's `/usr/share/doc/apt-cacher-ng/copyright` as the source of truth for `LICENSE` once installed. |
| Source / docs | Application: https://www.unix-ag.uni-kl.de/~bloch/acng/ (not fetched). Docs: https://www.unix-ag.uni-kl.de/~bloch/acng/html/ (not fetched). |
| Per-arch download | Apt package, not a download. `amd64` and `arm64` availability of `apt-cacher-ng 3.7.5-1.1` on resolute is UNVERIFIED per arch (only the package page was read). |
| Checksum source | apt's signed repository metadata (the Ubuntu archive signing keys). No separate checksum file. |
| Upstream Dockerfile reviewed | Blob `6d0816a9e34a118c4695b48304a14ebde327c6c2` (2024-12-02). `FROM ubuntu:jammy-20230816`. `apt-cacher-ng=${APT_CACHER_NG_VERSION}*` (3.7.4). `sed` sets `ForeGround: 1` and `PassThroughPattern: .* #`. `EXPOSE 3142/tcp`, `HEALTHCHECK` on `http://localhost:3142/acng-report.html`, `ENTRYPOINT ["/sbin/entrypoint.sh"]`, `CMD ["/usr/sbin/apt-cacher-ng"]`. No `USER`. |
| Upstream entrypoint reviewed | `entrypoint.sh` at the same ref: creates `/run/apt-cacher-ng`, `/var/cache/apt-cacher-ng`, `/var/log/apt-cacher-ng` (chown to `apt-cacher-ng`), then `start-stop-daemon --start --chuid apt-cacher-ng:apt-cacher-ng --exec apt-cacher-ng -- -c /etc/apt-cacher-ng`. |
| Port | 3142/tcp (upstream `EXPOSE`; chart `service port 3142 protocol tcp`). The draft's `http` protocol label is a schema choice; the daemon serves HTTP on the TCP port. |
| Env vars | `APT_CACHER_NG_VERSION`, `APT_CACHER_NG_CACHE_DIR`, `APT_CACHER_NG_LOG_DIR`, `APT_CACHER_NG_USER` (upstream ENV, read by `entrypoint.sh`). Our image does not need the version variable. |
| Data path | Cache `/var/cache/apt-cacher-ng` (chart PVC mount). Logs `/var/log/apt-cacher-ng`. Pid `/run/apt-cacher-ng`. Config `/etc/apt-cacher-ng/acng.conf` (edited at build time). |
| Dependencies | None. |
| Draft versus verified | Draft's `copy-from` link (`ghcr.io/sameersbn/apt-cacher-ng:latest`) is an Ubuntu jammy (glibc) image, stale, not recommended. Use the apt package on the ContainerForge base instead. Draft's `Application binary` `apt:apt-cacher-ng` is correct. Draft's `amd64`/`arm64` = `yes` holds through apt. |

## 2. Target layout

- `apps/apt-cacher-ng/Dockerfile`
- `apps/apt-cacher-ng/docker-bake.hcl`
- `apps/apt-cacher-ng/settings.yaml`
- `apps/apt-cacher-ng/container-test.yaml`
- `apps/apt-cacher-ng/start.sh`

No `defaults/` needed unless a config file is shipped. Use `etc/apt-cacher-ng/acng.conf` only if the config must change from the packaged default (the packaged file already has `ForeGround: 0`, so `start.sh` or an `etc/` override must set it; see section 4). Never `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, as the draft says (`Runtime image: none`). Ubuntu alone is enough: `apt-cacher-ng` is a single daemon. Closest sibling: `apps/valkey` (single daemon, apt-installed on ubuntu, pinned package version, `health` dir, `start.sh`). The draft's `Runtime image: none` is confirmed.

## 4. Dockerfile

1. `ARG VERSION`, `ARG PACKAGE_VERSION`, `USER root`. Follow the `apps/valkey` pattern exactly:
   ```dockerfile
   # hadolint ignore=DL3007
   FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

   ARG VERSION
   ARG PACKAGE_VERSION

   USER root

   # hadolint ignore=DL3008,DL3015
   RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
       apt-get update && \
       apt-get install -y --no-install-recommends \
           "apt-cacher-ng=${PACKAGE_VERSION}" \
       && apt-get purge -y --auto-remove \
       && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
   ```
   `VERSION` is `3.7.5` (upstream version without the Debian revision) and `PACKAGE_VERSION` is `3.7.5-1.1`, so the `test` aborts the build when the two disagree (the `valkey` rule). Confirm the exact `PACKAGE_VERSION` string from the resolute archive at build time.
2. Config for read-only rootfs and no daemonize: the packaged `/etc/apt-cacher-ng/acng.conf` sets `ForeGround: 0` by default. Either set `ForeGround: 1` with a `sed` in the same RUN (as upstream does), or set it in `start.sh` by passing `-c` to a config copy in `/tmp` (decide once; the `sed` in the Dockerfile matches upstream and keeps `start.sh` simple). Also set `PassThroughPattern: .* #` as upstream does, so HTTPS passthrough is allowed (this is an upstream behaviour choice; note it in the PR).
3. Move the cache and log paths to where they can be written. The packaged defaults are `/var/cache/apt-cacher-ng` and `/var/log/apt-cacher-ng`, both on the read-only rootfs. Either:
   - Set `CacheDir: /config/cache` and `LogDir: /config/log` in the config via `sed`, so state lives on `/config`; or
   - Keep the defaults and mount them as volumes (not recommended: the chart's PVC is `/var/cache/apt-cacher-ng`, which fits only if `/config` is not used).

   Choose `CacheDir: /config/cache` and `LogDir: /config/log` to match the ContainerForge `/config` model, and record this as a deliberate change from the chart path.
4. `PidFile: /tmp/apt-cacher-ng.pid` (or `/run` if writable through tmpfs; `/tmp` is the tested tmpfs). Confirm the package's config key name for the pid file (UNVERIFIED key name in `acng.conf` for 3.7.5).
5. `COPY --chmod=0755 health /health` only if a health script is needed (not needed: the daemon's `acng-report.html` is the probe; the `valkey` pattern is for its own scripts).
6. License: `mkdir -p /usr/share/licenses/apt-cacher-ng && cp /usr/share/doc/apt-cacher-ng/copyright /usr/share/licenses/apt-cacher-ng/LICENSE`. Confirm the file exists after install (UNVERIFIED path on 26.04).
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3142

VOLUME /config
CMD ["/start.sh"]
```

`apt-cacher-ng` installs its own user `apt-cacher-ng`. The final `USER apps` runs the daemon as `apps`, which is the ContainerForge rule. The packaged daemon needs to bind port 3142 (above 1024, so no root needed) and to write only to `/config` and `/tmp`. Make `/config` owned by `apps` through `start.sh`, not at build time (volume ownership is set at first start).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "apt-cacher-ng"
}

variable "VERSION" {
  // NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile (same as apps/valkey, which has no renovate comment)
  default = "3.7.5"
}

variable "PACKAGE_VERSION" {
  default = "3.7.5-1.1"
}

variable "LICENSE" {
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://www.unix-ag.uni-kl.de/~bloch/acng/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
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
  platforms = ["linux/amd64", "linux/arm64"]
}
```

`LICENSE` (`GPL-2.0-or-later`) is UNVERIFIED: confirm from the package copyright file before merging (draft and repo give MIT only for the image repo). `apps/valkey/docker-bake.hcl` carries no renovate datasource comment for its apt package (a NOTE says the version is tied to the base image), so none is invented here; the docker-bake rule asking for one cannot be met for an apt package without a confirmed datasource. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.unix-ag.uni-kl.de/~bloch/acng/"
ports:
  - port: 3142
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

The `protocol` is `tcp` to match the upstream `EXPOSE 3142/tcp` and the chart's `protocol: tcp`. The draft's `http` label in the ports list is a description, not the schema value. `env` lists only what the image reads (none beyond `TZ`); the version and directory variables are image-internal and are not listed.

## 7. start.sh

```bash
#!/usr/bin/env bash

set -e

mkdir -p /config/cache /config/log

# The daemon runs as apps (USER apps), so no chown or --chuid is used here.
exec /usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng
```

- Idempotent: creates the dirs only when missing and does not overwrite the cache or the config.
- `exec` hands PID 1 to the daemon. `ForeGround: 1` (section 4) keeps it in the foreground, so no `start-stop-daemon` is needed.
- Runtime identity: the script runs as `apps`. The package's `apt-cacher-ng` user is not used. If the daemon refuses to run as `apps` (for example it insists on its own user for the cache), this is a blocker to resolve in section 10 before the script is final; do not add a root-only `chown` to paper over it.
- Listen address: apt-cacher-ng listens on all interfaces by default (confirm `BindAddress` in `acng.conf`; UNVERIFIED default for 3.7.5). Do not set it to localhost.
- No write to `/app`. No `/app` files are used.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '3142'
http:
- port: '3142'
  path: /acng-report.html
filePaths:
- /usr/sbin/apt-cacher-ng
- /etc/apt-cacher-ng/acng.conf
- /usr/share/licenses/apt-cacher-ng/LICENSE
```

- Port 3142 has both `tcp` and `http` probes. `/acng-report.html` is the upstream healthcheck path, so the HTTP probe checks the same thing the upstream healthcheck does.
- `timeoutSeconds: 60` is a starting value (daemon start is fast); align with `apps/valkey` (not read in this run).
- No env-gated path. The test runs with no env and the daemon starts with defaults.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/cache/apt-cacher-ng` (chart PVC) | `/config/cache` (`CacheDir` in `acng.conf`). |
| `/var/log/apt-cacher-ng` | `/config/log` (`LogDir` in `acng.conf`). |
| `/run/apt-cacher-ng` (pid dir) | `/tmp/apt-cacher-ng` (`PidFile` in `acng.conf`; key name UNVERIFIED). |
| `/etc/apt-cacher-ng/acng.conf` | Edited at build time only (`sed` in Dockerfile). Not written at runtime. |
| Chart `runAsUser 0` | Not used. Runs as `apps`. Port 3142 needs no root. |
| Chart `readOnlyRootFilesystem: false` | Our image is tested with `--read-only --tmpfs /tmp`. |
| Chart `privileged` | `no`. |

Upstream runs `start-stop-daemon --chuid apt-cacher-ng`. Our image runs as `apps`, so that step is dropped; the daemon config must be readable by `apps` (confirm the `/etc/apt-cacher-ng` file mode is readable; UNVERIFIED on 26.04).

## 10. Risks, caveats and open questions

- **Runtime identity**: the package expects `apt-cacher-ng` as the user; the ContainerForge rule is `USER apps`. Running the daemon as `apps` needs the package to accept a non-root user for its cache and log dirs (confirm at first run). If it refuses, the fallback is to keep the package user and make `/config` owned by it, which conflicts with `USER apps`. Decide and record this in the PR before writing `start.sh`.
- **Cache growth**: the cache grows with every package downloaded, so the `/config` volume needs enough space (draft caveat, confirmed as a general fact about apt-cacher-ng).
- **Clients must be configured**: each apt client needs `Acquire::http::Proxy "http://<host>:3142";` (draft caveat, not verified in this run).
- **Upstream stale**: the sameersbn image is from 2022 and jammy. Using the resolute package avoids its staleness. `copy-from` is not used.
- **`PassThroughPattern: .* #`**: upstream allows all HTTPS passthrough (`CONNECT`). This widens what the proxy forwards; keep it only if the PR accepts it, and say so in the notes. Consider dropping it (UNVERIFIED that the apt clients need it for HTTPS repos).
- **Chart tag `latest`**: the draft says the chart uses `latest`. This plan pins the apt version, so the chart's digest (`ghcr.io/sameersbn/apt-cacher-ng:latest@sha256:82f55f9c8f627cee8ef5f710c1745388d79d3a3f2f3150353e6500021bec11b4`) is not reused.
- **Per-arch**: apt package arch availability for `arm64` on resolute UNVERIFIED.
- **Health probe**: the `HEALTHCHECK` upstream is not carried to the Dockerfile; forgetool's `http` probe covers it. Add a `HEALTHCHECK` only if the schema requires it (UNVERIFIED).

## 11. Build and test steps

From `apps/apt-cacher-ng/`:

1. `docker buildx bake --print` must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe with an empty config volume:
   ```sh
   docker volume create apt-cacher-ng-probe-config
   docker run --rm -d --name apt-cacher-ng-probe --read-only --tmpfs /tmp \
     -v apt-cacher-ng-probe-config:/config apt-cacher-ng:3.7.5
   docker logs -f apt-cacher-ng-probe
   ```
   Expected readiness signal: `apt-cacher-ng` log line showing the daemon started and listening on port 3142 (confirm the exact text from a real run). Also `wget -qO- http://localhost:3142/acng-report.html` inside the container should return HTML. Then `docker rm -f apt-cacher-ng-probe; docker volume rm apt-cacher-ng-probe-config`.
4. `forgetool containers test --image apt-cacher-ng:3.7.5 --config ./container-test.yaml`.

## 12. PR checklist

- Branch `feat/add-apt-cacher-ng`, commit `feat(apt-cacher-ng): add new container`, PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept; only check what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested: arm64 build, the non-root daemon run if not verified, and the client-side proxy configuration.
- If the image could not be built or run, say so; do not tick "Built container locally".
