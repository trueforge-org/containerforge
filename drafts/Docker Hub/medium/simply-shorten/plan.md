# simply-shorten — implementation plan
> Source: ./draft.md · Target: apps/simply-shorten/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Draft pins container tag `draganczukp/simply-shorten:1.1`. Upstream tags on GitLab are `1.0`, `1.1`, `1.2`, `1.3`; `1.3` is the latest by name (tag `1.3` commit `930dfcc379a1d7289e0fb8225aef81a2a9bd9556`). Source: https://gitlab.com/api/v4/projects/draganczukp%2Fsimply-shorten/repository/tags. Release date of 1.3 is UNVERIFIED (no GitLab release objects exist). |
| Draft differences | Draft says the binary is "yes" for both arches: no prebuilt jar is published (GitLab releases are empty), so we build it. Draft's JDK 14 base is EOL; `java17` replaces it. Upstream EXPOSE is 4567, draft says 8080 (inferred). |
| Renovate | Proposed: `datasource=gitlab-tags depName=draganczukp/simply-shorten versioning=loose`. UNVERIFIED against a live renovate run. |
| License | MIT (https://gitlab.com/draganczukp/simply-shorten/-/raw/master/LICENSE, "MIT License, Copyright (c) 2020 Przemek Dragańczuk") |
| Source URL | https://gitlab.com/draganczukp/simply-shorten |
| Download | None. Source only; the jar is built by Gradle in our build stage. |
| Checksum source | Git tag commit SHA (GitLab API). No sha256 published. |
| Upstream Dockerfile reviewed | https://gitlab.com/draganczukp/simply-shorten/-/raw/1.1/Dockerfile (verbatim): `FROM gradle:jdk14 AS build`, `COPY --chown=gradle:gradle . /home/gradle/src`, `WORKDIR /home/gradle/src`, `RUN gradle build --no-daemon`; `FROM openjdk:14.0-slim`, `EXPOSE 4567`, `RUN mkdir /app`, `COPY --from=build /home/gradle/src/build/libs/*.jar /app/application.jar`, `ENTRYPOINT ["java", "-jar","/app/application.jar"]`. No ENV, VOLUME, USER or CMD. |
| Port | 4567/tcp (upstream `EXPOSE 4567`, confirmed). Draft 8080 is WRONG for upstream. The chart may map a different port (UNVERIFIED). |
| Data path | UNVERIFIED: the upstream app's storage location is not known. Draft says the chart uses `/config/db`. Needs a read of the app source (`src/main/resources`, Java code) before `start.sh`. |
| Env vars | UNVERIFIED: none confirmed. Upstream Dockerfile sets none. |
| arm64 | A Java jar is arch-independent, so arm64 works once the jar is built on an arm64 JDK. The java17 base has an arm64 build (`TARGETARCH` mapping in `apps/java17/Dockerfile`, UNVERIFIED for this app). |
| Dependencies | None documented. |

## 2. Target layout

- `apps/simply-shorten/Dockerfile`
- `apps/simply-shorten/docker-bake.hcl`
- `apps/simply-shorten/settings.yaml`
- `apps/simply-shorten/container-test.yaml`
- `apps/simply-shorten/start.sh`

No `defaults/`, `etc/` or `root/` unless the app needs a default config (UNVERIFIED). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Final stage: `ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a` (from `apps/nzbhydra2/Dockerfile`; the draft names java17 as the replacement for EOL JDK 14).
- Build stage: needs a JDK and Gradle. The java17 base ships a JRE, not a JDK (see `apps/java25/Dockerfile`, JRE from Temurin), so the build stage cannot reuse it for `javac`. Plan: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build` with `apt-get install openjdk-17-jdk-headless` (UNVERIFIED in the 26.04 archive; pin the version against the archive before building).
- Closest sibling: `apps/nzbhydra2` (Java jar on java17 base, `/app` layout).

## 4. Dockerfile

1. `FROM <ubuntu> AS build`, `ARG VERSION`, `USER root`.
2. `apt-get install -y --no-install-recommends openjdk-17-jdk-headless` (version pinned as described in section 3), then `rm -rf /var/lib/apt/lists/*`.
3. `RUN git clone --depth 1 --branch "${VERSION}" https://gitlab.com/draganczukp/simply-shorten /src` (requires `git` in the build stage). Verify the commit equals the tag's expected SHA when bumping (UNVERIFIED design).
4. `RUN cd /src && ./gradlew build --no-daemon` if the repo ships a wrapper (UNVERIFIED: not checked). If not, install Gradle pinned to the version the project uses.
5. Final stage: `FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:...`, `ARG VERSION`, `USER root`.
6. `mkdir -p /app` then `COPY --from=build /src/build/libs/*.jar /app/application.jar` (confirm the jar name; upstream uses the glob, so there is one jar). Use `/app/application.jar` in the entrypoint.
7. License: `COPY --from=build /src/LICENSE /usr/share/licenses/simply-shorten/LICENSE`.
8. `chown -R apps:apps /app && chmod -R 755 /app`.
9. `ENV HOME=/config` (keeps Java and app writes under `/config`).
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 4567
VOLUME /config
WORKDIR /config
```

Use `ENV JAVA_TOOL_OPTIONS="-Xmx256M"` only if the memory limit is confirmed (nzbhydra2 precedent; UNVERIFIED for this app).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "simply-shorten"
}

variable "VERSION" {
  // renovate: datasource=gitlab-tags depName=draganczukp/simply-shorten versioning=loose
  default = "1.3"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://gitlab.com/draganczukp/simply-shorten"
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

`VERSION` is `1.3` (latest tag). Decide 1.3 vs the draft's 1.1 before the first build (section 10); keep `VERSION` equal to the Dockerfile `ARG VERSION`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://gitlab.com/draganczukp/simply-shorten"
ports:
  - port: 4567
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

Port 4567 per upstream `EXPOSE`. Env vars: none confirmed; add entries only after the app's config is read (UNVERIFIED). `dependencies`: none (embedded storage, UNVERIFIED which storage).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/db
cd /app
exec java -jar /app/application.jar
```

Rules: idempotent (`mkdir -p` only), no writes to `/app`, storage under `/config` (path UNVERIFIED; the `/config/db` path is from the draft and must be confirmed in the app config before use), `exec` for signal handling. Bind address must be `0.0.0.0` (confirm the Java server's bind default; Spark-style servers bind all interfaces by default, UNVERIFIED for this app).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '4567'
http:
- port: '4567'
  path: /
filePaths:
- /app/application.jar
- /usr/share/licenses/simply-shorten/LICENSE
```

Both `tcp` and `http` on 4567. The `/` path is a guess until the first run shows what the app returns (UNVERIFIED); if it is not 200, use the documented path and record why. `timeoutSeconds: 120` for JVM startup, matching the other Java apps. No required env code paths are known.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Storage (draft: `/config/db` in chart) | `/config/db`, to confirm against the app config. |
| Java temp files | `/tmp` via `-Djava.io.tmpdir=/tmp` in `JAVA_TOOL_OPTIONS` (UNVERIFIED need). |
| Build caches (Gradle) | Build stage only, under `/tmp`. Not in the final image. |
| Runtime user | Upstream runs as root (no USER). Ours runs as `apps` (568). The chart's runAsUser 0 override is not carried over. |
| Chart `readOnlyRootFilesystem: false` | Image should work with `--read-only --tmpfs /tmp` and a `/config` volume; verify in step 11. |

## 10. Risks, caveats and open questions

- Java 17 instead of upstream's JDK 14: behaviour is untested (draft caveat, accepted).
- Version: `1.3` is the latest tag; the draft uses `1.1`. Choose one before the first build and record why. Release date of `1.3` is UNVERIFIED.
- arm64: the draft's "amd64 only" note refers to the published image. Our build is arch-independent (jar), so arm64 should build from source. Not yet tested.
- The app's storage path and env vars are UNVERIFIED (app source not read). Do not add env entries until read.
- Port 4567 (upstream) versus 8080 (draft inferred): use 4567 unless the app config says otherwise.
- The JDK 17 apt package in the Ubuntu 26.04 archive is UNVERIFIED; if missing, pin a JDK another way and record it.
- Blockers: none confirmed. Gradle wrapper presence is UNVERIFIED.

## 11. Build and test steps

```sh
cd apps/simply-shorten
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name simply-shorten-probe --read-only --tmpfs /tmp \
  -v simply-shorten-probe-config:/config simply-shorten:1.3
docker logs -f simply-shorten-probe
forgetool containers test --image simply-shorten:1.3 --config ./apps/simply-shorten/container-test.yaml
docker rm -f simply-shorten-probe; docker volume rm simply-shorten-probe-config
```

Readiness signal: the Spring or Java server's listening line (UNVERIFIED wording; capture from the first run) and port 4567 open. Run once with a fresh `/config`, then restart on the same volume to confirm storage persists.

## 12. PR checklist

- Branch `feat/add-simply-shorten`, commit and PR title `feat(simply-shorten): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows the status.
- Say what was not tested: the Gradle build on both arches, runtime on Java 17, the storage path, and the chart port.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`.
