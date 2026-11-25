# teedy-docs — implementation plan
> Source: ./draft.md · Target: apps/teedy-docs/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.12` (tag `v1.12`, published 2026-11-23). The draft pins `v1.11`, which is superseded. Source: `gh api repos/sismics/docs/releases/latest` |
| Docker Hub tag | `sismics/docs:v1.12` (last pushed 2026-11-23) and `sismics/docs:latest` (same date). Source: https://hub.docker.com/v2/repositories/sismics/docs/tags?page_size=5 |
| Renovate | `datasource=github-releases depName=sismics/docs versioning=semver` (tags carry a `v` prefix; the Dockerfile strips it when building the URL). |
| License | GPL-2.0 (GitHub SPDX `GPL-2.0`). Source: `gh api repos/sismics/docs`. The bake `LICENSE` must be `GPL-2.0-only` or `GPL-2.0` to match the SPDX id; read the upstream `LICENSE` file to confirm the exact form before committing. |
| Source URL | https://github.com/sismics/docs |
| Release asset | `docs-web-1.12.war`: https://github.com/sismics/docs/releases/download/v1.12/docs-web-1.12.war . The release has no `tar.gz` asset; the draft's `v1.11` tarball URL does not apply to 1.12. |
| Checksum source | UNVERIFIED: no checksum asset in the release listing. Compute the sha256 of the WAR once, pin it in the Dockerfile, and say so in the PR. Maven Central publishes Jetty checksums (see step 4). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/sismics/docs/5b39c46/Dockerfile (the draft's commit). `FROM ubuntu:22.04`; ENV `JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/`, `JAVA_OPTIONS=-Dfile.encoding=UTF-8 -Xmx1g`, `JETTY_VERSION=11.0.20`, `JETTY_HOME=/opt/jetty`; apt installs `openjdk-11-jdk`, `ffmpeg`, `mediainfo`, `tesseract-ocr` plus many language packs; downloads Jetty 11.0.20 from Maven Central to `/opt/jetty`; `EXPOSE 8080`; `ADD docs.xml /app/webapps/docs.xml`; `ADD docs-web/target/docs-web-*.war /app/webapps/docs.war`; `WORKDIR /app`; `CMD ["java", "-jar", "/opt/jetty/start.jar"]`. No `USER` (runs as root), no `VOLUME`, no `ENTRYPOINT`. |
| Ports | 8080/tcp (web UI and API). Not published automatically. |
| Env vars | UNVERIFIED for app configuration: the upstream runtime env (database URL, data path) is not in the fetched Dockerfile. The image-level env is `LANG`, `LC_ALL`, `JAVA_HOME`, `JAVA_OPTIONS`, `JETTY_VERSION`, `JETTY_HOME`. Read the upstream docs configuration (not fetched) before adding app env vars. |
| Data path | Draft chart persists `/data` (pvc). UNVERIFIED for upstream: the app's data-directory setting was not fetched. |
| Database | PostgreSQL is required (draft: CloudNativePG in the chart; running without it is not supported). UNVERIFIED: the DB connection keys the app reads. |
| Maven build | The upstream Dockerfile expects `docs-web/target/docs-web-*.war`, built by Maven outside the Dockerfile. This plan takes the published release WAR instead, so no Maven step is needed. UNVERIFIED: that the release WAR is the same artifact the Dockerfile would build. |
| `docs.xml` | Upstream copies `docs.xml` from the repo root into `webapps/`. The file was not fetched at tag `v1.12`. UNVERIFIED: its contents; fetch `https://raw.githubusercontent.com/sismics/docs/v1.12/docs.xml` before writing the Dockerfile. |
| arm64 | UNVERIFIED. The Docker Hub `latest` tag is a multi-arch index (media type OCI index), but only the amd64 entry appears in the tag metadata. Check the index with `docker buildx imagetools inspect sismics/docs:v1.12` before claiming arm64. Jetty and the WAR are arch-neutral; the apt packages (ffmpeg, tesseract) are available on arm64 in Ubuntu. |
| Copy-from images | The draft says `sismics/docs:latest` for amd64. Not used: the image is an upstream Ubuntu 22.04 root image, and the WAR plus Jetty are reused from the release instead. Copy-from amd64 is `no` in practice. |

## 2. Target layout

- `apps/teedy-docs/Dockerfile`
- `apps/teedy-docs/docker-bake.hcl`
- `apps/teedy-docs/settings.yaml`
- `apps/teedy-docs/container-test.yaml`
- `apps/teedy-docs/start.sh`
- `apps/teedy-docs/docs.xml` is not an allowed path in `include/.dockerignore`, so place it in `apps/teedy-docs/etc/` (or `defaults/`) with a reason, and add it to the image with `COPY --chmod=0755 . /` (the allow-list includes `etc/`). Do not add `docs.xml` at the app root.

No `root/` directory. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Runtime base: `ghcr.io/trueforge-org/java11:11.0.29+7` (version from `apps/java11/docker-bake.hcl`, `VERSION = "11.0.29+7"`). The digest is UNVERIFIED: no existing `apps/*/Dockerfile` in this repo uses `java11` as a `FROM` line, so there is no pinned digest to copy. Get it with `docker buildx imagetools inspect ghcr.io/trueforge-org/java11:11.0.29+7` and pin it.

Why it fits: the draft and upstream both use Java 11 (`openjdk-11-jdk` in upstream), and the java11 image ships a Temurin 11 JRE at `/opt/java/openjdk`, which is enough to run a WAR on Jetty. No JDK is needed at runtime (Maven build is not part of this image).

Closest siblings: `apps/java17` consumers (`apps/airsonic-advanced`, `apps/nzbhydra2`) for the Java WAR-on-app-dir pattern. Java 11 is the only difference from them.

## 4. Dockerfile

```dockerfile
FROM ghcr.io/trueforge-org/java11:11.0.29+7@sha256:<UNVERIFIED>

ARG VERSION
ARG TARGETARCH

ENV JETTY_VERSION=11.0.20 \
    JETTY_HOME=/opt/jetty \
    JAVA_OPTIONS="-Dfile.encoding=UTF-8 -Xmx1g" \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

USER root

# runtime packages used by docs (OCR and video thumbnails)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ffmpeg \
      mediainfo \
      tesseract-ocr \
      tesseract-ocr-eng \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/*

# Jetty from Maven Central, checksum-verified (step 4 below)
RUN set -eux; \
    url="https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/${JETTY_VERSION}/jetty-home-${JETTY_VERSION}.tar.gz"; \
    curl -fsSL -o /tmp/jetty.tar.gz "$url"; \
    echo "<JETTY_SHA512>  /tmp/jetty.tar.gz" | sha512sum -c -; \
    tar -xzf /tmp/jetty.tar.gz -C /opt; \
    mv "/opt/jetty-home-${JETTY_VERSION}" /opt/jetty; \
    rm /tmp/jetty.tar.gz; \
    chown -R apps:apps /opt/jetty

# the app WAR and its Jetty context, from the release asset
RUN set -eux; \
    mkdir -p /app/webapps; \
    curl -fsSL -o /app/webapps/docs.war \
      "https://github.com/sismics/docs/releases/download/v${VERSION}/docs-web-${VERSION}.war"; \
    echo "<WAR_SHA256>  /app/webapps/docs.war" | sha256sum -c -; \
    chown -R apps:apps /app; chmod -R 755 /app

USER apps
COPY --chmod=0755 . /
# docs.xml comes from etc/ via the COPY above (see section 2)

WORKDIR /app
EXPOSE 8080
VOLUME /config
```
- `<JETTY_SHA512>` and `<WAR_SHA256>` are placeholders. Maven Central publishes `.sha512` files next to each jar or tar.gz (UNVERIFIED that they exist for `jetty-home-11.0.20.tar.gz`; fetch `${url}.sha512` and check it). Compute the WAR sha256 once and pin it. Do not ship placeholders.
- `chown -R apps:apps /app` is done in the build (root), so `/app` is owned by the app user but not writable at runtime (`chmod 755`). Nothing writes to `/app` at runtime (section 7).
- Jetty reads its modules from `/opt/jetty` at start. The `jetty` user from upstream is not created (ContainerForge runs as `apps`).
- `ffmpeg`, `mediainfo`, `tesseract-ocr` and `tesseract-ocr-eng` are the packages the draft and upstream name. Upstream adds many `tesseract-ocr-*` language packs; this plan ships English only. Add more languages only on request, since each adds image size (draft caveat).
- apt versions are not pinned: the packages are OS packages, not the app, so they are not checked against `VERSION`.
- `EXPOSE 8080`, `VOLUME /config`, and `USER apps` as the final `USER` line, per the Dockerfile rules.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "teedy-docs"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=sismics/docs versioning=semver
  default = "1.12"
}

variable "LICENSE" {
  default = "GPL-2.0-only"  // confirm the exact SPDX id from the upstream LICENSE file
}

variable "SOURCE" {
  default = "https://github.com/sismics/docs"
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
Validate with `docker buildx bake --print`. Add `variable "JETTY_VERSION"` only if it is wired through `ARG`; otherwise keep it inside the Dockerfile.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/sismics/docs"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: UMASK
    default: "002"
    required: false
  - name: JAVA_OPTIONS
    default: "-Dfile.encoding=UTF-8 -Xmx1g"
    required: false
  # UNVERIFIED: database and data-path variables; add them only after reading the upstream config
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql
```
- `dependencies:` lists `postgresql` as a hard dependency. `apps/postgresql` exists in this repo (✅).
- The upstream DB connection variables are not confirmed (section 1). Do not invent them. Add them to `env:` with defaults matching `apps/postgresql` (`POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` defaults are `MYPOSTGRESDB`, `MYPOSTGRESUSER`, `MYPOSTGRESPASSWORD`) only once the upstream keys are known.
- Data path: `/config` is the persistent volume; the draft's `/data` (chart pvc) is remapped (section 9).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data /config/logs

# docs.xml is the Jetty context file; it is seeded only when missing
if [[ ! -f /config/docs.xml ]]; then
  cp /etc/teedy-docs/docs.xml /config/docs.xml
fi

cd /opt/jetty || exit 1
exec java \
  ${JAVA_OPTIONS} \
  -Djava.io.tmpdir=/tmp \
  -Djetty.base=/tmp/jetty-base \
  -jar /opt/jetty/start.jar \
  jetty.http.port=8080
```
- Idempotent: creates `/config/data` and `/config/logs`; seeds only `docs.xml`, and only when missing.
- `/app` is not written to at runtime (WAR is baked in).
- `exec` so `java` gets signals.
- UNVERIFIED: the exact Jetty invocation. The upstream `CMD` runs `start.jar` from `/opt/jetty` with `webapps/` under `/app`. Check that `jetty.base` set to `/tmp` still picks up `/app/webapps/docs.xml`, or set `jetty.base` to a directory under `/tmp` and add the context path explicitly. Test this in step 11.
- Data directory: UNVERIFIED for upstream. If the app reads a data-directory setting, point it at `/config/data`. If it only uses a fixed path, symlink it to `/config/data` at start.
- Binding: Jetty `jetty.http.host` must be `0.0.0.0` for reachability from other containers. Set it explicitly in the start command (`jetty.http.host=0.0.0.0`), since Jetty's default may be all interfaces, but verify with `ss -ltn` rather than assume.
- Database: must be reachable before the app starts. Do not wait in a loop in start.sh; the app should fail its own health if the DB is missing (UNVERIFIED behavior).

## 8. container-test.yaml

This image has a hard DB dependency, so the DB-dependent exception applies only if all three criteria hold (protocol section "Database-dependent apps"). Criterion 2 (will not start without DB) is UNVERIFIED, so decide after running the image with no database. Draft expectation: it will not start without PostgreSQL.

If criterion 2 holds, write the narrowed version:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# narrowed: requires external postgresql; full functional test not feasible in single-container suite
timeoutSeconds: 180
tcp:
- port: '8080'
filePaths:
- /app/webapps/docs.war
- /opt/jetty/start.jar
- /etc/teedy-docs/docs.xml
```

If it starts without the DB, use a full HTTP probe instead:

```yaml
timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/webapps/docs.war
- /opt/jetty/start.jar
```

- `timeoutSeconds: 180` because the WAR unpack and Jetty start are slow (the upstream `HEALTHCHECK` period is not documented; use a sibling Java app of the same family for the final value).
- `filePaths` paths must match the Dockerfile.

## 9. Rootless and read-only-rootfs adaptations

| Upstream or chart path | Adaptation |
| --- | --- |
| Upstream runs as root (no `USER`); chart `runAsUser 0` | Final `USER apps` (UID 568). Upstream's unused `jetty` user is not created. |
| `/app/webapps/docs.war`, `/app/webapps/docs.xml` (upstream `ADD`) | Baked in build; `/app` read-only at runtime. |
| `/data` (chart pvc) | Remapped to `/config/data` (created by `start.sh`). Existing chart users must move their data once the upstream data-directory setting is confirmed. |
| Jetty temp and work (`jetty.base`) | `/tmp` (`-Djetty.base=/tmp/jetty-base`, `-Djava.io.tmpdir=/tmp`). |
| OCR and ffmpeg temp files | `/tmp` (set `java.io.tmpdir`; ffmpeg uses `/tmp` by default). |
| Chart `readOnlyRootFilesystem false` | This image should run with `--read-only --tmpfs /tmp` if the upstream writes only to its data dir and temp. UNVERIFIED until step 11. |
| Chart `privileged: false` | No change. |

## 10. Risks, caveats and open questions

- **DB dependency (hard):** the app needs PostgreSQL. `apps/postgresql` exists. The DB connection keys and the schema-init behavior are UNVERIFIED (not fetched). Without them the `env:` list is incomplete.
- **Jetty base and `docs.xml`:** the upstream `docs.xml` contents at `v1.12` were not fetched. Fetch and check it before writing `etc/docs.xml`. The `jetty.base` change in `start.sh` may hide `/app/webapps`; verify.
- **Release WAR vs Maven build:** the release asset may differ from the build the upstream Dockerfile would make from the repo at the same tag. UNVERIFIED.
- **Checksums:** upstream publishes none for the WAR. Pin sha256 after the first download and say so in the PR. Jetty checksum: fetch the Maven Central `.sha512` (UNVERIFIED that it is published for this file).
- **Image size and first-start time:** ffmpeg and tesseract add size (draft caveat). English-only OCR keeps it smaller.
- **arm64:** not confirmed on Docker Hub (section 1). Do not claim arm64 until built.
- **Digest of java11 base:** UNVERIFIED (section 3).
- **Blockers:** no blocker confirmed for amd64. Hard DB dependency is the main risk. No GPU, no privileged need.

## 11. Build and test steps

```sh
cd apps/teedy-docs
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

# the app needs PostgreSQL to be useful; start it on a shared network first
docker network create teedy-probe-net
docker run --rm -d --name teedy-probe-db --network teedy-probe-net \
  -e POSTGRES_DB=MYPOSTGRESDB -e POSTGRES_USER=MYPOSTGRESUSER -e POSTGRES_PASSWORD=MYPOSTGRESPASSWORD \
  ghcr.io/trueforge-org/postgresql:<VERSION>   # UNVERIFIED image tag: use the postgresql app's bake VERSION

docker run --rm -d --name teedy-probe --network teedy-probe-net --read-only --tmpfs /tmp \
  -v teedy-probe-config:/config teedy-docs:1.12
docker logs -f teedy-probe
docker rm -f teedy-probe teedy-probe-db; docker volume rm teedy-probe-config; docker network rm teedy-probe-net

forgetool containers test --image teedy-docs:1.12 --config ./apps/teedy-docs/container-test.yaml
```

Expected readiness signal: UNVERIFIED. Jetty logs `Started Server` (or the port line) and the WAR deploys (`docs.war`). Record the first line that shows the context is live, and confirm `/config/data` persists across a restart on the same volume.

Also test the no-DB start once, to decide the criterion-2 question in section 8.

## 12. PR checklist

- Branch `feat/add-teedy-docs`, commit `feat(teedy-docs): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes; check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed Contributor License Agreement (https://cla-assistant.io/trueforge-org/containerforge). Tell the user; only they can sign it, and the `license/cla` check shows status.
- Say in the PR what was not tested: the arm64 build and run, the real DB connection (if not run with postgresql), the Jetty context when `jetty.base` is moved, and that the WAR checksum was computed locally.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; the `dependencies:` entry on `postgresql` is in `settings.yaml`.
- Downstream: no `DOWNSTREAM_CHANGES.md` (not a `FROM` base).
