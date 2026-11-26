# komga — implementation plan
> Source: ./draft.md · Target: apps/komga/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.30.2` (latest stable, published 2026-11-24, https://api.github.com/repos/gotson/komga/releases/latest). Draft pins `1.30.1`; use `1.30.2`. |
| Renovate | `datasource=github-releases depName=gotson/komga versioning=semver` (standard form; not confirmed against a fetched page for this app). |
| License | MIT (GitHub SPDX, https://api.github.com/repos/gotson/komga). |
| Source URL | https://github.com/gotson/komga |
| Download | Release jar `https://github.com/gotson/komga/releases/download/${VERSION}/komga-${VERSION}.jar`. Architecture-neutral JVM jar. |
| Checksum source | Release asset `checksums_sha256.txt` (https://github.com/gotson/komga/releases/download/1.30.2/checksums_sha256.txt). SHA-256 for `komga-1.30.2.jar`: `a5736468b0847eb319bf8628760f7853cecb8e52dd23e23855fabebf3e04a43b`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/gotson/komga/1.30.1/komga/docker/Dockerfile.tpl (template; re-check against 1.30.2 before porting). |
| Upstream base | Multi-stage: `eclipse-temurin:17-jre` builder (Spring Boot layer extraction), `ubuntu:26.04` runner stages per arch with a Temurin 25 JRE copied in and the `kepubify` binary. |
| Upstream runtime | ENTRYPOINT `java -Dspring.profiles.include=docker --enable-native-access=ALL-UNNAMED -jar application.jar --spring.config.additional-location=file:/config/`. EXPOSE 25600. VOLUME `/config`. No USER set (runs as base default user), WORKDIR `/app`. |
| Upstream env (real) | `KOMGA_CONFIGDIR=/config`, `JAVA_HOME=/opt/java/openjdk`, `LANG=en_US.UTF-8`, `LANGUAGE=en_US:en`, `LC_ALL=en_US.UTF-8`, `LD_LIBRARY_PATH` per arch. |
| Ports | 25600/tcp (web UI and API). Source: upstream EXPOSE. |
| Dependency | None. Komga uses an embedded database under `/config`. |
| arm64 | Yes. Upstream builds an arm64 stage with an arm64 `kepubify` binary; the jar itself is architecture-neutral. |
| copy-from | Not needed: the release jar is taken directly. `ghcr.io/gotson/komga:1.30.1` is the image the chart uses, not a copy source here. |

## 2. Target layout

- `apps/komga/Dockerfile`
- `apps/komga/docker-bake.hcl`
- `apps/komga/settings.yaml`
- `apps/komga/container-test.yaml`
- `apps/komga/start.sh`
- `apps/komga/etc/` only if a custom Spring/Komga config is needed (reason: none planned; leave out unless required).
- No `defaults/`, no `root/`, no `DOWNSTREAM_CHANGES.md` (not used as `FROM`).

## 3. Base image

`FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:bba631340c8aefc1a10656a894475312bd89a9dd75d9e5da12c3098242f1e8f2` (copied from an existing `apps/*/Dockerfile`). Fits because Komga is a Spring Boot jar that runs on Java 21 and the java21 sibling provides the JRE. The upstream runner uses Temurin 25; Komga 1.30.2 is built against that runtime upstream, so `komga/build.gradle.kts` at tag 1.30.2 sets `jvmTarget = JVM_17`, so Java 21 should be enough; confirm on first run. If it does not, switch to `ghcr.io/trueforge-org/java25` and record that in section 10. Closest sibling: `apps/airsonic-advanced` (Java web app, same java21 digest) and `apps/nzbhydra2` (`/config` data, USER apps).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG JAR_SHA256`.
2. `USER root`.
3. `apt-get install -y --no-install-recommends curl ca-certificates` only if the base lacks them (check first; do not reinstall what the base has). Clean apt lists.
4. `mkdir -p /app/komga`.
5. Download and verify:
   `curl -fsSL -o /app/komga/komga.jar "https://github.com/gotson/komga/releases/download/${VERSION}/komga-${VERSION}.jar"` then `echo "${JAR_SHA256}  /app/komga/komga.jar" | sha256sum -c -`. `JAR_SHA256` is `a5736468b0847eb319bf8628760f7853cecb8e52dd23e23855fabebf3e04a43b` for 1.30.2.
6. `chown -R root:root /app/komga && chmod -R 755 /app/komga`.
7. License: `install -D` the upstream `LICENSE` from the source repo (fetched from the tag, or write the MIT text from the repo into `/usr/share/licenses/komga/LICENSE`).
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME ["/config"]
EXPOSE 25600
```

Set `ENV KOMGA_CONFIGDIR=/config LANG=en_US.UTF-8` (the upstream image sets these; include only what the app reads). Temp and thumbnail paths go to `/tmp` through `-Djava.io.tmpdir=/tmp` (added in start.sh, section 7).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "komga"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=gotson/komga versioning=semver
  default = "1.30.2"
}

variable "JAR_SHA256" {
  default = "a5736468b0847eb319bf8628760f7853cecb8e52dd23e23855fabebf3e04a43b"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/gotson/komga"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    JAR_SHA256 = "${JAR_SHA256}"
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

The `JAR_SHA256` value is from the upstream `checksums_sha256.txt` (section 1). `docker buildx bake --print` must pass after any change.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/gotson/komga"
ports:
  - port: 25600
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: KOMGA_CONFIGDIR
    default: "/config"
    required: false
volumes:
  - path: /config
    required: true
```

Only env vars confirmed in the upstream Dockerfile are listed (`KOMGA_CONFIGDIR`, `TZ` as a ContainerForge convention). Library data is a user-mounted path, not an env var; do not invent one. UNVERIFIED: any other Komga env vars such as `SERVER_PORT`; confirm in the Komga docs before listing.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

exec java \
    -Dspring.profiles.include=docker \
    -Djava.io.tmpdir=/tmp \
    --enable-native-access=ALL-UNNAMED \
    -jar /app/komga/komga.jar \
    --spring.config.additional-location=file:/config/ \
    "$@"
```

Notes: Komga creates its own database and config under `KOMGA_CONFIGDIR` (`/config`) on first start, so nothing is seeded. The `--spring.config.additional-location` flag reads `/config/application.yml` when present. No writes to `/app`. Bind on all interfaces is the Spring default; confirm with `server.address` unset in the first run. Thumbnails and temp go to `/tmp` (set via `java.io.tmpdir` and the Komga thumbnail path if one exists; UNVERIFIED that Komga has a separate thumbnail path setting).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '25600'
http:
- port: '25600'
  path: /
filePaths:
- /app/komga/komga.jar
- /usr/share/licenses/komga/LICENSE
```

`timeoutSeconds: 180` because the Spring Boot first start (database init, library scan setup) is slow. Look at a Java sibling (`apps/airsonic-advanced`, `apps/nzbhydra2`) for the house value and match it if it is higher. The http probe on `/` is expected to return 200 or a redirect to the web UI; confirm the status on the first run.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (KOMGA_CONFIGDIR, DB, settings, thumbnails) | `/config` (persistent, empty at first start) |
| Java temp, thumbnail generation scratch | `/tmp` via `-Djava.io.tmpdir=/tmp` |
| Library data (draft `/data`, chart PVC) | User-mounted; recommend read-only mount (`:ro`) in docs, because Komga only reads library files (UNVERIFIED: Komga does not write into library folders) |

Draft expectations reconciled: the chart runs non-root (UID 568 default) and has `readOnlyRootFilesystem: true`. This image also runs as `apps` (568), with `--read-only --tmpfs /tmp` as the test target. Not privileged. The chart's `/data` extra persistence becomes a library mount that is not owned by the image; it is documented, not created.

## 10. Risks, caveats and open questions

- Java version: java21 base is planned; upstream runner uses Temurin 25. Verify 1.30.2 starts on java21 (UNVERIFIED), else use `java25`.
- Komga 1.30.2 is newer than the draft's 1.30.1. The jar checksum is for 1.30.2 only; the checksum for 1.30.1 was not fetched.
- Thumbnail generation is CPU-heavy on the first library scan (draft caveat). Document, no code change.
- Spring Boot needs RAM for large libraries; no `-Xmx` is set by the plan (UNVERIFIED default). If the chart sets one, carry it into start.sh as an env var that is listed in settings.yaml.
- Library mounts: library folders must be mounted; read-only is recommended. Not a container defect.
- arm64: the release jar is neutral; the upstream arm64 `kepubify` binary is not used by the plan (kepub conversion is an optional feature; UNVERIFIED whether it is needed at runtime). If kepub is required, add the arm64/amd64 `kepubify` download with checksum.
- Blockers: none confirmed. No musl-only build, no GPU, no privileged need.

## 11. Build and test steps

```sh
cd apps/komga
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name komga-probe --read-only --tmpfs /tmp \
  -v komga-probe-config:/config komga:1.30.2
docker logs -f komga-probe
forgetool containers test --image komga:1.30.2 --config ./apps/komga/container-test.yaml
docker rm -f komga-probe; docker volume rm komga-probe-config
```

Expected readiness signal: Spring Boot logs `Started KomgaKt` (or the Komga main class; UNVERIFIED wording) and `Tomcat started on port 25600`. Confirm that `/config` gets the database on first start and keeps it on restart. Check from outside the container with `-p 25600:25600` that the UI answers.

## 12. PR checklist

- Branch `feat/add-komga`, commit and PR title `feat(komga): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: arm64, the java21 vs java25 choice on 1.30.2, the kepubify feature, library mount behaviour, and the `--read-only` start if not run.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; `JAR_SHA256` matches the upstream checksum; no assertion weakened.
