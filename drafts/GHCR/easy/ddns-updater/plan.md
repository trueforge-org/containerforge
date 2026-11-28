# ddns-updater — implementation plan
> Source: ./draft.md · Target: apps/ddns-updater/ · Difficulty: easy · Role (main) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v2.10.0 (latest release, published 2026-05-01). Matches the draft and chart image. Source: https://api.github.com/repos/qdm12/ddns-updater/releases/tags/v2.10.0 (via gh api) |
| Renovate | `datasource=github-releases depName=qdm12/ddns-updater versioning=semver` |
| License | MIT (GitHub SPDX). Source: https://github.com/qdm12/ddns-updater |
| Source URL | https://github.com/qdm12/ddns-updater |
| amd64 download | https://github.com/qdm12/ddns-updater/releases/download/v2.10.0/ddns-updater_2.10.0_linux_amd64 (sha256 `868b9ab40374ea51d5caff09974414d2f9b5d5456e948f98391fdc3a15d51522`) |
| arm64 download | https://github.com/qdm12/ddns-updater/releases/download/v2.10.0/ddns-updater_2.10.0_linux_arm64 (sha256 `d7b27ec100c5b04be0c24d9b6586a223991f2511a10561b3b0119557ecf53c84`) |
| Checksum source | `checksums.txt`: https://github.com/qdm12/ddns-updater/releases/download/v2.10.0/checksums.txt (lists both binaries) |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/qdm12/ddns-updater/v2.10.0/Dockerfile (full text too long for the fetch tool; reviewed by summary). Multi-stage Go build, final `FROM scratch`. WORKDIR /updater. `ENTRYPOINT ["/updater/ddns-updater"]`, no CMD. `ARG UID=1000`, `ARG GID=1000`, `USER ${UID}:${GID}`. `EXPOSE 8000`. HEALTHCHECK runs `/updater/ddns-updater healthcheck`. No VOLUME. |
| Port | 8000 (EXPOSE; `LISTENING_ADDRESS` default `:8000`) |
| Env vars (real, from upstream README table and Dockerfile ENV) | `CONFIG` (one-line JSON config, overrides the file), `PERIOD` (default `5m`), `UPDATE_COOLDOWN_PERIOD` (default `5m`), `LISTENING_ADDRESS` (default `:8000`), `HEALTH_HEALTHCHECKSIO_BASE_URL` (default `https://hc-ping.com`), `HEALTH_HEALTHCHECKSIO_UUID` (empty), `DATADIR` (default `/updater/data`), `CONFIG_FILEPATH` (default `/updater/data/config.json`), `BACKUP_PERIOD` (default `0`), `BACKUP_DIRECTORY` (default `/updater/data`), `SERVER_ENABLED` (default `yes`), `LOG_LEVEL` (default `info`), `HEALTH_SERVER_ADDRESS` (default `127.0.0.1:9999`). Source: https://github.com/qdm12/ddns-updater/blob/master/README.md and the upstream Dockerfile `ENV` block. |
| Data write paths | `DATADIR` (`/updater/data`), `CONFIG_FILEPATH`, `BACKUP_DIRECTORY`. Upstream also keeps `updates.json` in the data dir (README). |
| Dependencies | None. A DNS provider account with API credentials is supplied by the user through `CONFIG` or `CONFIG_FILEPATH`. |

## 2. Target layout

- `apps/ddns-updater/Dockerfile`
- `apps/ddns-updater/docker-bake.hcl`
- `apps/ddns-updater/settings.yaml`
- `apps/ddns-updater/container-test.yaml`
- `apps/ddns-updater/start.sh`

No `defaults/`, `etc/` or `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The app is one static Go binary, so it runs directly on ubuntu with no runtime image. Closest sibling: `apps/adguardhome-sync` (prebuilt Go binary on ubuntu).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config DATADIR=/config CONFIG_FILEPATH=/config/config.json BACKUP_DIRECTORY=/config` (settings.yaml defaults alone do not set the runtime env, so the image must).
2. Download the binary for the arch, verify it, and install it:
   ```dockerfile
   RUN curl -fsSL -o /app/ddns-updater \
         "https://github.com/qdm12/ddns-updater/releases/download/v${VERSION}/ddns-updater_${VERSION}_linux_${TARGETARCH}" && \
       echo "<sha256 for the arch>  /app/ddns-updater" | sha256sum -c - && \
       chmod 0755 /app/ddns-updater
   ```
   Use the two sha256 values from checksums.txt (one per arch). `TARGETARCH` values `amd64` and `arm64` match the asset names exactly, so no mapping is needed. Other arches are not supported: fail the build.
3. License: upstream repo has a LICENSE (MIT). Ship it to `/usr/share/licenses/ddns-updater/LICENSE`, fetched from the tag `https://raw.githubusercontent.com/qdm12/ddns-updater/v2.10.0/LICENSE` (UNVERIFIED that the file is at this path; check with curl during the build).
4. `chown -R apps:apps /app && chmod -R 755 /app`.
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8000`, `VOLUME /config`.
6. Do not pin `UID` the way upstream does. ContainerForge runs as `apps` (568) from the base.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "ddns-updater"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=qdm12/ddns-updater versioning=semver
  default = "2.10.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/qdm12/ddns-updater"
}
```

Then the four standard targets and `group "default"` copied from `apps/adguardhome-sync/docker-bake.hcl`. The Dockerfile URL uses `v${VERSION}` for the tag and `${VERSION}` in the asset name. Validate with `cd apps/ddns-updater && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/qdm12/ddns-updater"
ports:
  - port: 8000
    protocol: tcp
    required: false
env:
  - name: CONFIG
    default: ""
    required: false
  - name: PERIOD
    default: "5m"
    required: false
  - name: UPDATE_COOLDOWN_PERIOD
    default: "5m"
    required: false
  - name: LISTENING_ADDRESS
    default: ":8000"
    required: false
  - name: LOG_LEVEL
    default: "info"
    required: false
  - name: DATADIR
    default: "/config"
    required: false
  - name: CONFIG_FILEPATH
    default: "/config/config.json"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: none. Defaults for `DATADIR` and `CONFIG_FILEPATH` differ from upstream on purpose (remapped to `/config`). Do not list `SERVER_ENABLED`, `HEALTH_*` or `BACKUP_*` unless the start script sets them. `CONFIG` is documented upstream as a one-line JSON config and is kept as an optional env var.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config
cd /config || exit 1

exec /app/ddns-updater
```

Notes: idempotent, seeds nothing. The binary writes `config.json` and `updates.json` into `DATADIR` on first run, so `/config` may be empty. The `DATADIR`, `CONFIG_FILEPATH` and `LISTENING_ADDRESS` defaults come from settings.yaml and the image `ENV`. No writes to `/app`. `exec` for signal handoff. Listening address `:8000` is all interfaces.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8000'
http:
- port: '8000'
  path: /
filePaths:
- /app/ddns-updater
- /usr/share/licenses/ddns-updater/LICENSE
```

Every settings.yaml port has a tcp probe. The http probe path `/` is UNVERIFIED for a 200 response with no config; check during the run and use the status the app returns. The test runs without env vars, so the app must start with no DNS credentials. Check that it does (the updater waits or logs an error without config, which is the reason for the readiness signal check in step 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/updater/data` (`config.json`, `updates.json`, backups) | `DATADIR=/config`, `CONFIG_FILEPATH=/config/config.json`, `BACKUP_DIRECTORY=/config` (set as image `ENV` defaults in settings.yaml) |
| `HOME` | `/config` (no cache writes confirmed; if any appear, point them at `/tmp`) |

Security reconciliation: the draft expects non-root (568), read-only rootfs and not privileged. Upstream image uses UID 1000 (`USER 1000:1000`). ContainerForge uses `apps` (568) from the base, so the runtime differs from upstream but the expectation holds. Read-only rootfs is compatible because writes go to `/config` and `/tmp`. The chart's extra persistence `/updater/data` maps to `/config`.

## 10. Risks, caveats and open questions

- The app must start with an empty `/config` and no credentials. Its behavior with no DNS config is UNVERIFIED: it may exit. If it exits without config, the test cannot use the readiness check; in that case treat it as a config-required app and document it.
- `HEALTH_SERVER_ADDRESS` defaults to `127.0.0.1:9999` upstream, which is localhost-only. Leave it unchanged (it is an internal health server, not a published port).
- The built-in `healthcheck` subcommand's behavior with `DATADIR=/config` is UNVERIFIED. The image does not need a HEALTHCHECK for ContainerForge (forgetool probes ports).
- Upstream `scratch` final stage is not reused: ubuntu base is needed for `/config`, `apps` user and certificates.
- Blockers: none known. No GPU, no privileged needs, arm64 binary available.

## 11. Build and test steps

```sh
cd apps/ddns-updater
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ddns-updater-probe --read-only --tmpfs /tmp \
  -v ddns-updater-probe-config:/config ddns-updater:2.10.0
docker logs -f ddns-updater-probe   # expect a listen line on :8000 or the updater start line
docker rm -f ddns-updater-probe; docker volume rm ddns-updater-probe-config
forgetool containers test --image ddns-updater:2.10.0 --config ./apps/ddns-updater/container-test.yaml
```

Expected readiness signal: process stays running, the log shows the server listening on `:8000`, and no fatal error about the missing config. Use an empty `/config`. Test arm64 only if the amd64 run fails for an arch-specific reason.

## 12. PR checklist

- Branch: `feat/add-ddns-updater`. Commit: `feat(ddns-updater): add new container`. PR title matches the commit.
- PR template: `.github/PULL_REQUEST_TEMPLATE.md`. Keep its sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Say what was not tested: arm64 run, and DNS updates (no provider account).
