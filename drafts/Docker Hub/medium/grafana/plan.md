# grafana — implementation plan
> Source: ./draft.md · Target: apps/grafana/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v13.3.2, published 2026-11-24. Draft pins 13.3.1, which is older: use 13.3.2. Source: GitHub releases/latest page and API (partial). |
| Docker Hub tags | `13.3.2`, `13.3.2-slim`, `13.3.2-distroless-slim`, `13.3` (last_updated 2026-11-24). Platforms: amd64, arm64, arm/v7. |
| Renovate | Proposed: `datasource=github-releases depName=grafana/grafana versioning=semver` (inferred from the GitHub-release source; the docker datasource is also valid for `grafana/grafana`). |
| License | AGPL-3.0 for the OSS build. Source: https://raw.githubusercontent.com/grafana/grafana/main/LICENSE. The draft's `grafana-enterprise` `.deb` is a separate, commercial-license package and is not used. |
| Source URL | https://github.com/grafana/grafana |
| Download, OSS amd64 | https://github.com/grafana/grafana/releases/download/v13.3.2/grafana_13.3.2_44555861735_linux_amd64.deb |
| Download, OSS arm64 | https://github.com/grafana/grafana/releases/download/v13.3.2/grafana_13.3.2_44555861735_linux_arm64.deb |
| Enterprise `.deb` (not used) | `grafana-enterprise_13.3.2_44555861735_linux_{amd64,arm64}.deb` on the same release. |
| Checksum source | UNVERIFIED: no `.sha256` file was fetched. Read the checksums from the v13.3.2 release page before pinning, and put one sha256 per arch in the Dockerfile. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/grafana/grafana/main/Dockerfile (main branch; the draft pins commit `5db6ba88` for 13.3.1). Upstream builds an image from Alpine, Ubuntu and distroless bases, not from a `.deb`. |
| Upstream bases | `alpine:3.24.4`, `ubuntu:24.04`, `golang:1.27.4-alpine`, `node:26.13.0-alpine3.24`, `gcr.io/distroless/static-debian13`. Final stages: `final-alpine` (default), `final-ubuntu`, `final-distroless`. |
| Upstream USER | `"$GF_UID"`, default `GF_UID=472` (`GF_GID` default 0). Not used here (see section 9). |
| Upstream EXPOSE | `3000` (http). |
| Upstream VOLUME | None. |
| Upstream ENTRYPOINT | `/run.sh` (alpine and ubuntu finals). |
| Upstream ENV | `GF_PATHS_CONFIG=/etc/grafana/grafana.ini`, `GF_PATHS_DATA=/var/lib/grafana`, `GF_PATHS_HOME=/usr/share/grafana`, `GF_PATHS_LOGS=/var/log/grafana`, `GF_PATHS_PLUGINS=/var/lib/grafana/plugins`, `GF_PATHS_PROVISIONING=/etc/grafana/provisioning`, `PATH` includes `/usr/share/grafana/bin`. |
| Port | `3000/tcp`. |
| Upstream write paths | `/var/lib/grafana` (data and plugins), `/var/log/grafana` (logs), `/etc/grafana/provisioning`. All are remapped in section 9. |
| arm64 | Yes: the `.deb` for arm64 and the Docker Hub manifest both exist. |
| Binary path inside the `.deb` | UNVERIFIED: `PATH` implies `/usr/share/grafana/bin/grafana`. Confirm with `dpkg-deb -c` before writing `start.sh`. |

## 2. Target layout

- `apps/grafana/Dockerfile`
- `apps/grafana/docker-bake.hcl`
- `apps/grafana/settings.yaml`
- `apps/grafana/container-test.yaml`
- `apps/grafana/start.sh`
- `apps/grafana/etc/` is not needed: the `.deb` config is copied in by the Dockerfile from the extraction stage (section 4). Add it only if a config change is required, because `etc/` is an allow-listed path in `include/.dockerignore`.

No `defaults/` and no `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the extraction stage and the final stage.

Fits: the app is a Go binary shipped as a `.deb` for each arch, with its own bundled assets. No language base needed. The `.deb` is a Debian archive, so `dpkg-deb -x` extracts it on glibc Ubuntu. Closest sibling: `apps/pwndrop` (download a release artifact in a build stage and copy it into an ubuntu runtime stage).

## 4. Dockerfile

1. Extraction stage: `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download the `.deb` for `${TARGETARCH}` and verify it:

   ```dockerfile
   RUN case "${TARGETARCH}" in \
         amd64) GRAFANA_SHA256="<sha256 amd64>" ;; \
         arm64) GRAFANA_SHA256="<sha256 arm64>" ;; \
         *) echo "unsupported arch"; exit 1 ;; \
       esac && \
     curl -fL -o /tmp/grafana.deb \
       "https://github.com/grafana/grafana/releases/download/v${VERSION}/grafana_${VERSION}_44555861735_linux_${TARGETARCH}.deb" && \
     echo "${GRAFANA_SHA256}  /tmp/grafana.deb" | sha256sum -c -
   ```

   The build number `44555861735` is in the file name, so it must be set per release, not as a fixed value. Make it an `ARG` next to `VERSION`, and keep it in sync with `docker-bake.hcl`. The checksums are UNVERIFIED (section 1).
3. Extract without installing: `dpkg-deb -x /tmp/grafana.deb /tmp/grafana-root`. Leave the extracted tree in `/tmp/grafana-root`; the final stage copies `usr/share/grafana` and `etc/grafana` out of it (step 4). Remove the `.deb` only; `/tmp/grafana-root` is discarded with the build stage.
4. Final stage: `FROM <ubuntu>`, `ARG VERSION`, `USER root`.

   ```dockerfile
   COPY --from=build /tmp/grafana-root/usr/share/grafana /app/grafana
   COPY --from=build /tmp/grafana-root/etc/grafana /etc/grafana
   COPY --from=build /tmp/grafana-root/usr/share/doc/grafana/copyright /usr/share/licenses/grafana/LICENSE
   ```

   The third line's source path is UNVERIFIED (use the `.deb`'s copyright file if it exists; otherwise copy the LICENSE from the release tag).
5. Environment, pointing every write path at `/config` or `/tmp` (section 9):

   ```dockerfile
   ENV GF_PATHS_CONFIG=/etc/grafana/grafana.ini \
     GF_PATHS_HOME=/app/grafana \
     GF_PATHS_DATA=/config/data \
     GF_PATHS_LOGS=/config/log \
     GF_PATHS_PLUGINS=/config/plugins \
     GF_PATHS_PROVISIONING=/etc/grafana/provisioning \
     PATH=/app/grafana/bin:$PATH
   ```

6. Tail:

   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 3000
   VOLUME /config
   ```

   `USER apps` is the ContainerForge user (UID 568), not the upstream UID 472.
7. Clean apt lists and `/tmp/*` in the final stage.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "grafana"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=grafana/grafana versioning=semver
  default = "13.3.2"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/grafana/grafana"
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

- `LICENSE` is `AGPL-3.0` as confirmed. Check the exact SPDX id against the LICENSE text (`-only` or `-or-later`) before committing.
- Build number ARG: if it is needed, add `variable "BUILD" { default = "44555861735" }` next to VERSION and pass it as `args.BUILD`. Keep both values in sync.
- Copy the four standard targets and the default group from `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/grafana/grafana"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: GF_SECURITY_ADMIN_PASSWORD
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
```

- `GF_SECURITY_ADMIN_PASSWORD` is UNVERIFIED: it is Grafana's usual admin-password variable, but it is not in the facts. Confirm it in the Grafana docs before adding it. If not confirmed, leave it out and say so in the PR. Do not set a default password, because the default admin password is a security risk; use an empty default or no entry.
- `GF_PATHS_*` are NOT user settings: they are set in the Dockerfile. Do not list them in `settings.yaml`.
- `opt_dependencies: postgresql` is correct: the `apps/postgresql` directory exists and the TrueCharts chart lists it as optional.
- `k8s-sidecar` (`apps/k8s-sidecar` exists) is a sidecar for the chart's dashboard reloads. Not needed for the main image: do not list it.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data /config/log /config/plugins

cd /app/grafana || exit 1
exec /app/grafana/bin/grafana server \
  --homepath=/app/grafana \
  --config=/etc/grafana/grafana.ini
```

- Idempotent: creates directories only; does not overwrite anything under `/config`.
- Writes nothing under `/app` or `/etc`.
- `--packaging=docker` is an upstream flag, UNVERIFIED for this `.deb` build; leave it out unless the binary needs it.
- Grafana creates `grafana.db` on first start; the empty-`/config` case is covered by the directory creation above.
- `exec` keeps the server as PID 1 for signal handling.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/grafana/bin/grafana
- /etc/grafana/grafana.ini
- /usr/share/licenses/grafana/LICENSE
```

- `timeoutSeconds: 240`: Grafana is a large Go app with a slow first start (240 is used by a few other apps; Grafana's real startup time is UNVERIFIED).
- The http probe on `/` is UNVERIFIED for the status code a fresh install returns; confirm before relying on it. A health path such as `/api/health` is NOT in the facts, so do not use it without a check.
- No env vars are set by the test; the default admin password is never needed to start.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/lib/grafana` (data, sqlite db, plugins) | `GF_PATHS_DATA=/config/data`, `GF_PATHS_PLUGINS=/config/plugins`. Persistent, so `/config`. |
| `/var/log/grafana` (logs) | `GF_PATHS_LOGS=/config/log`. Persistent logs are the ContainerForge default for this kind of app; change to `/tmp/log` if logs should be ephemeral. |
| `/etc/grafana/provisioning` | Stays in the image at `/etc/grafana/provisioning` (read-only at runtime, Grafana only reads it). Users who want provisioning mount it in `/config` later (UNVERIFIED if a `/config` provisioning path needs a `GF_PATHS_PROVISIONING` change). |
| Temporary files | Grafana's temp location is UNVERIFIED; run the `--read-only --tmpfs /tmp` probe and check the logs for write errors. |
| `GF_UID=472` (upstream USER) | Not used. Files under `/app/grafana` and `/etc/grafana` are readable by `apps`; ContainerForge's `apps` user is UID 568. |

Reconciled draft expectations: the chart runs as UID 568 (no override), `readOnlyRootFilesystem: false`, `privileged: false`, and persists `/var/lib/grafana` through a PVC. This image persists `/config` instead, so existing users must copy their old `/var/lib/grafana` into `/config/data`. The chart's emptyDirs (`/app/tmp`, `/tmp/dashboards`, provisioning subdirs) and the configmaps for `grafana.ini` and `ldap.toml` are not copied; the `grafana.ini` is the one shipped in the `.deb`.

## 10. Risks, caveats and open questions

- Version: 13.3.2 is the latest stable found; the draft's 13.3.1 is outdated.
- Checksums are UNVERIFIED (section 1). The build must fail if they are wrong, so pin them only after reading them from the release page.
- Build number `44555861735` is part of the `.deb` file name. Check it per release, or renovate bumps will break the download URL. A renovate regex or a second annotation may be needed (UNVERIFIED).
- The OSS `.deb` is used on purpose: the enterprise `.deb` needs a license for enterprise features, and the license line in the bake file must match the package.
- The `.deb` is not the Alpine/Ubuntu image upstream builds. Its internal paths (e.g. `/usr/share/grafana/conf`, `/usr/share/grafana/public`) are read by the server relative to `GF_PATHS_HOME`; verify with a real start.
- Admin password: the first login uses the admin account; the password must be set via env or changed in the UI (see section 6, UNVERIFIED variable name).
- arm64: the `.deb` exists; the build is expected to work but is not tested in this run.
- No blockers: no musl-only build, no GPU, no privileged need.

## 11. Build and test steps

```sh
cd apps/grafana
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name grafana-probe --read-only --tmpfs /tmp \
  -v grafana-probe-config:/config grafana:13.3.2
docker logs -f grafana-probe
forgetool containers test \
  --image grafana:13.3.2 \
  --config ./apps/grafana/container-test.yaml
docker rm -f grafana-probe
docker volume rm grafana-probe-config
```

- Readiness signal: Grafana's startup log lines naming the HTTP listener on `:3000` (UNVERIFIED exact text). The process must stay up after the startup window.
- Check that `/config/data/grafana.db` exists after start and that a restart keeps it.
- Check the logs for write errors on `--read-only`.

## 12. PR checklist

- Branch `feat/add-grafana`, commit `feat(grafana): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections; check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required. Tell the user; only they can sign it at https://cla-assistant.io/trueforge-org/containerforge. The `license/cla` check shows the status.
- State honestly what is untested: the checksums (if not read from the release page), the SPDX id, the admin variable name, the http probe status, the `/config` log and data paths on a real first start, the upgrade path from the chart's `/var/lib/grafana`, and arm64.
- Check: `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
