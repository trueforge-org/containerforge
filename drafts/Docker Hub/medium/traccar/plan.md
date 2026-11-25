# traccar — implementation plan
> Source: ./draft.md · Target: apps/traccar/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **6.17.0** (GitHub release `v6.17.0`, published 2026-11-01). Matches the draft's `traccar/traccar:6.17` chart pin in major/minor. |
| Renovate | `datasource=github-releases depName=traccar/traccar versioning=semver`. |
| License | Apache-2.0 (GitHub license API, `traccar/traccar`). |
| Source URL | https://github.com/traccar/traccar · Docs https://www.traccar.org/documentation/ |
| Release assets (v6.17.0) | `traccar-linux-64-6.17.0.zip`, `traccar-linux-arm-6.17.0.zip`, `traccar-other-6.17.0.zip`, `traccar-windows-64-6.17.0.zip` (GitHub release listing). |
| Asset choice | Use `traccar-other-${VERSION}.zip` for **both** amd64 and arm64. The upstream Dockerfile (`docker/Dockerfile.alpine`) uses this asset and supplies its own JRE with `jlink`, so the "other" zip is the architecture-neutral bundle without a runtime. UNVERIFIED: zip contents (confirm it holds `tracker-server.jar` and no `bin/java`). |
| Per-arch URLs | https://github.com/traccar/traccar/releases/download/v6.17.0/traccar-other-6.17.0.zip (both arches). Name-based alternatives: `traccar-linux-64-6.17.0.zip` (amd64, likely bundles a runtime; UNVERIFIED), `traccar-linux-arm-6.17.0.zip` (32-bit ARM by name; UNVERIFIED, not used). |
| Checksum source | UNVERIFIED: no checksum asset in the release listing. Record the zip's SHA-256 in the Dockerfile after the first download. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/traccar/traccar/master/docker/Dockerfile.alpine (master; the draft's pinned commit `45ae732` is the same path, not fetched at that commit). Stages: `FROM alpine AS package` (unzip `traccar-other-$VERSION.zip` to `/traccar`), `FROM eclipse-temurin:25-alpine AS jdk` (`jlink` JRE with `java.se`, `jdk.charsets`, `jdk.crypto.ec`, `jdk.net`, `jdk.unsupported`), `FROM alpine` (copy `/traccar` to `/opt/traccar` and the JRE to `/opt/traccar/jre`). No `apk add`, no `ENV`, no `EXPOSE`, no `VOLUME`, no `USER` (root). `WORKDIR /opt/traccar`. `ENTRYPOINT ["/opt/traccar/jre/bin/java","-XX:+ExitOnOutOfMemoryError"]`, `CMD ["-jar","tracker-server.jar","conf/traccar.xml"]`. |
| Config | `setup/traccar.xml` (repo): `database.driver=org.h2.Driver`, `database.url=jdbc:h2:./data/database`, `database.user=sa`, `database.password` empty. Path is relative: the data directory is `./data` under the working directory. |
| Web port | UNVERIFIED: `default.xml` fetch returned 404. The draft's 8082 is not confirmed by a fetched page. Confirm `web.port` from `src/main/resources/default.xml` at v6.17.0 before settings. |
| Device ports | Many TCP/UDP device protocol ports, set in config. Not fixed. Do not list device ports in `settings.yaml` unless they are enabled in the shipped config. |
| Java | The draft says Java 17 or later. Upstream runs Temurin 25 (`jlink` runtime). |
| Blockers | None confirmed. |

Difference from draft: the draft says the zip "includes a bundled runtime". The upstream Dockerfile builds its own JRE and copies it in, which suggests the zip has none. The draft's `java17` base is not the upstream runtime; `java25` matches the tested runtime (see section 3).

## 2. Target layout

- `apps/traccar/Dockerfile`
- `apps/traccar/docker-bake.hcl`
- `apps/traccar/settings.yaml`
- `apps/traccar/container-test.yaml`
- `apps/traccar/start.sh`
- `apps/traccar/defaults/traccar.xml` (seed config, copied to `/config` only when missing; the upstream `setup/traccar.xml` with the web port set and paths left relative)

No `etc/` or `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d`

Why: the upstream Dockerfile runs Temurin 25, so `java25` matches the tested JRE. The draft's `java17` is the minimum the server needs (Java 17+), and remains a fallback only if the server is verified on 17 with the same asset. Closest siblings: `apps/java25` (base), `apps/nzbhydra2` (Java app with `/config`, `apps` user, `start.sh` `exec java` pattern).

## 4. Dockerfile

1. `ARG VERSION` (`6.17.0`), `USER root`.
2. Fetch the release zip (no apt packages needed; `unzip` is required only if not in the base, check first):
   - `curl -fsSL -o /tmp/traccar.zip "https://github.com/traccar/traccar/releases/download/v${VERSION}/traccar-other-${VERSION}.zip"`
   - Verify the SHA-256 recorded in the Dockerfile (UNVERIFIED at plan time; record after first download).
   - `unzip -q /tmp/traccar.zip -d /app/traccar && rm /tmp/traccar.zip`
3. Confirm the layout: `/app/traccar/tracker-server.jar` and `/app/traccar/conf/traccar.xml` (UNVERIFIED that the zip contains `conf/`; the upstream `CMD` references both). Adjust the paths in `start.sh` to the zip's real layout.
4. License: `install -D /app/traccar/LICENSE /usr/share/licenses/traccar/LICENSE` if the zip ships one, else fetch the upstream `LICENSE` at tag `v6.17.0` (UNVERIFIED).
5. Permissions: `chown -R root:root /app/traccar && chmod -R 755 /app/traccar`. The app must not write to `/app`.
6. Seed config: `COPY` `defaults/traccar.xml` (see section 7) into `/defaults/traccar.xml` via the `COPY --chmod=0755 . /` line only if the file lives under `defaults/` (allowed in `.dockerignore`).
7. `ENV` (only real vars): none from upstream. `TZ` is handled by `settings.yaml`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8082
VOLUME /config
WORKDIR /config
```

Do not add `apt-get`. Do not add a JRE: the base provides it.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "traccar" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=traccar/traccar versioning=semver
  default = "6.17.0"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE" { default = "https://github.com/traccar/traccar" }
```

Four standard targets and the default group copied from `apps/nzbhydra2/docker-bake.hcl`. Validate with `docker buildx bake --print`. The Dockerfile consumes `VERSION` through `ARG VERSION`, and the asset URL uses `v${VERSION}`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/traccar/traccar"
ports:
  - port: 8082
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

- Port 8082 is the draft's web port and must be confirmed (section 1). Confirm it before merge.
- Device ports (5055 example, plus the protocol ports): do not list until the seeded config enables them. Listing an unopened port is forbidden by the settings rules.
- No dependencies: the embedded H2 database is the default. PostgreSQL stays an optional, unlisted option until its wiring is verified (see section 10).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data /config/logs

if [[ ! -s /config/traccar.xml ]]; then
    cp /defaults/traccar.xml /config/traccar.xml
fi

# Relative paths in traccar.xml (./data/database) resolve against the working directory,
# so run from /config to keep the database and state on the persistent volume.
cd /config

exec /opt/java/openjdk/bin/java -XX:+ExitOnOutOfMemoryError \
  -jar /app/traccar/tracker-server.jar /config/traccar.xml
```

Notes:
- `JAVA_HOME` in `java25` is `/opt/java/openjdk` (UNVERIFIED: confirm in the base before using the absolute path; prefer `exec java ...` if `PATH` includes it).
- Seed `/config/traccar.xml` only when missing or empty (`-s`). Never overwrite an existing config.
- Bind all interfaces: the seeded config's web listener must bind 0.0.0.0 (UNVERIFIED: default bind address; set it explicitly in the seed if the config has a bind key).
- Database: the relative `./data/database` in the seed resolves to `/config/data/database` with `cd /config`. No `database.url` edit needed.
- Idempotent. No writes to `/app`. Caches (none expected) go to `/tmp`.
- Only `TZ` is an env var; do not invent others.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 240
tcp:
- port: '8082'
http:
- port: '8082'
  path: /
filePaths:
- /app/traccar/tracker-server.jar
- /defaults/traccar.xml
```

- Port 8082 must match `settings.yaml` after the confirmation in section 1. Device ports are not probed (not in settings).
- The HTTP probe path and status for the web UI are UNVERIFIED: confirm with `curl -i` in the build test and set the expected status.
- `timeoutSeconds: 240`: the Java server takes a while to start its listeners; compare with `apps/nzbhydra2` and raise if needed.
- No required-env code path (no env vars are read).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `./data` relative to `/opt/traccar` (H2 database; draft says `/opt/traccar/data`) | `/config/data` (via `cd /config` in `start.sh`). |
| Logs (UNVERIFIED path; likely `./logs` or stdout) | `/config/logs` if written to a file; confirm in the build test. |
| Media (UNVERIFIED; setup/traccar.xml does not show media path) | `/config/data/media` if the seed sets it; confirm. |
| JVM temp (`java.io.tmpdir`) | `/tmp` (default). |
| `/app/traccar` | read-only in the image. |

Draft expectations reconciled: the chart runs as root (UID 0) with read-only rootfs false. This image runs as `apps` and works under `--read-only --tmpfs /tmp`, which is an improvement over the chart. The chart's `/opt/traccar/data` PVC maps to `/config/data`. Existing users migrating from the chart must move their data into `/config/data`.

## 10. Risks, caveats and open questions

- Web port 8082 is not confirmed on a fetched page (section 1). Blocking for settings and tests until confirmed.
- Zip contents: UNVERIFIED that `traccar-other` has no runtime and that the zip layout matches `conf/traccar.xml`. If it includes a runtime, the image still works with `java25`, but the file is bigger.
- Java: upstream uses Temurin 25 (jlink); `java25` is the match. `java17` is the draft's minimum and is a fallback only after a verified run.
- Device ports: each protocol port must be published by the user; they are not in `settings.yaml` until enabled in the seed. The draft's caveat stands.
- Upstream runs as root. The image must run as `apps` with a writable `/config`. The seed and start script handle that. Verify the server does not need privileged ports below 1024 (the default device ports are above 1024, but confirm the web port).
- PostgreSQL: optional per the draft and not used by default (embedded H2). Not wired in this plan; add an `opt_dependencies` entry only with verified wiring.
- arm64: the "other" zip is the same asset for both arches (section 1); the arm64 runtime is the base image's JRE. Not verified on arm64 in this plan.
- Blockers: none confirmed.

## 11. Build and test steps

```sh
cd apps/traccar
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name traccar-probe --read-only --tmpfs /tmp \
  -v traccar-probe-config:/config traccar:6.17.0
docker logs -f traccar-probe
forgetool containers test --image traccar:6.17.0 --config ./apps/traccar/container-test.yaml
docker rm -f traccar-probe; docker volume rm traccar-probe-config
```

Readiness signals: the Java process stays up, the log shows the web server listening on the configured port (exact wording UNVERIFIED, check on first run), `/config/data/database` is created, and a restart keeps the data. Also curl from outside the container (`-p 8082:8082`).

## 12. PR checklist

- Branch `feat/add-traccar`, commit and PR title `feat(traccar): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the web port, the zip layout and checksum, the arm64 build and run, the `--read-only` start, and the device ports.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
