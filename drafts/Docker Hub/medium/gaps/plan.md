# gaps — implementation plan
> Source: ./draft.md · Target: apps/gaps/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v0.10.4` (GitHub release, 2022-04-01, latest in the release feed). Upstream is inactive since 2022. Chart `x64-v0.10.4` is the Docker Hub tag of the same version. |
| Renovate | `// renovate: datasource=github-releases depName=JasonHHouse/gaps versioning=semver` (the draft's guess of `docker` for Hub is not needed, we build our own image). |
| License | MIT, Copyright 2019 Jason H House (repo `LICENSE`, `https://raw.githubusercontent.com/JasonHHouse/gaps/v0.10.4/LICENSE`). |
| Source URL | https://github.com/JasonHHouse/gaps |
| Download | `https://github.com/JasonHHouse/gaps/releases/download/v0.10.4/GapsAsJar-0.10.4.zip` (release asset, confirmed on the expanded assets page). The asset is an arch-neutral Java jar, so the same zip serves amd64 and arm64. |
| Checksum source | None found. UNVERIFIED whether the release publishes one. Plan: compute `sha256sum` once and pin it as `ARG GAPS_SHA256` in the Dockerfile. |
| Upstream Dockerfile reviewed | `https://raw.githubusercontent.com/JasonHHouse/gaps/v0.10.4/Dockerfile`. Base `eclipse-temurin:11.0.14.1_1-jre`. It builds nothing: it copies a pre-built `GapsWeb/target/GapsWeb-0.10.4.jar` to `/usr/app/gaps.jar`, plus `start.sh` and `movieIds.json` (to `/usr/data`). `mkdir -p /usr/data /usr/app` chmod 777, `WORKDIR /usr/app`, `CMD ./start.sh`, `EXPOSE 8484`, no `USER` line (root). |
| Upstream start.sh reviewed | `java -Xms256m -Xmx2048m -jar -Dspring.profiles.active=<profile> -Dserver.servlet.context-path=$BASE_URL $JAR_FILE`. The profile is chosen from `ENABLE_SSL` and `ENABLE_LOGIN`. The exact profile names are UNVERIFIED (not in the fetched facts; read the file again while implementing). |
| Env vars (real) | `JAR_FILE=gaps.jar`, `ENABLE_SSL=false`, `ENABLE_LOGIN=false`, `BASE_URL=""` (upstream Dockerfile). No others found. |
| Port | `8484` (upstream `EXPOSE 8484`, chart service and target port 8484). The draft's `8080` is wrong. |
| Write paths | Upstream: `/usr/data` (chart persistence `data`, mountPath `/usr/data`). Whether the app writes there at runtime is UNVERIFIED. |
| Dependencies | None (no database). Needs a Plex server or local folders, and a TMDb API key. The TMDb key is not an env var in the facts (UNVERIFIED, configured in the app UI or config). |
| Chart | `charts/stable/gaps`, chart 24.0.0, appVersion 0.10.4, common 32.8.5. `readOnlyRootFilesystem: false`. |
| Docker Hub tags | `x64-v0.10.4` (amd64 only), `arm-v0.10.4` (arm64), `arm32v7-v0.10.4`, `risc-v0.10.4`, `ppc64le-v0.10.4`, `s390x-v0.10.4`, `latest` (multi-arch). The draft's `copy-from arm64: no` is wrong for the image, but we do not copy from it: we use the zip. |

## 2. Target layout

- `apps/gaps/Dockerfile`: fetches the zip, verifies the checksum, installs the jar and license.
- `apps/gaps/docker-bake.hcl`: APP, VERSION, LICENSE, SOURCE and the four standard targets.
- `apps/gaps/settings.yaml`
- `apps/gaps/container-test.yaml`
- `apps/gaps/start.sh`: copied to `/start.sh` by `COPY --chmod=0755 . /`.

No `defaults/` (nothing to seed; the app creates its own state). No `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The jar is installed to `/app/gaps/` at build time, which is what `/app` is for.

## 3. Base image

Use `FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a` for the final stage. The FROM line is copied from `apps/nzbhydra2/Dockerfile`.

Decision against the draft (draft said java11): the java11 image is built by `apps/java11`, but no app in `apps/` uses it as a `FROM`, and its digest is not recorded in the repo, so it cannot be pinned from the repo. The java17 base has a pinned digest and is already in use. A jar compiled for Java 11 runs on a Java 17 JVM (the JVM runs older class files). The upstream temurin 11 runtime is therefore not required. If the team wants strict Java 11, the java11 digest must be taken from the built image (UNVERIFIED).

Closest sibling: `apps/nzbhydra2` (Java jar, downloaded from GitHub releases, `/app/bin`, `/config` volume).

## 4. Dockerfile

1. `ARG VERSION` (must equal `docker-bake.hcl` VERSION, `v0.10.4`), `ARG GAPS_SHA256`, `ARG TARGETARCH` (unused, jar is arch-neutral; keep the arg only if a per-arch check is needed).
2. `USER root`.
3. `apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/*`. `curl` is not guaranteed on the java17 base: check it in `apps/java17` before relying on it (UNVERIFIED).
4. Download and verify:

```dockerfile
RUN mkdir -p /app/gaps /tmp/gaps && \
    curl -fsSL -o /tmp/gaps/GapsAsJar.zip \
      "https://github.com/JasonHHouse/gaps/releases/download/${VERSION}/GapsAsJar-${VERSION#v}.zip" && \
    echo "${GAPS_SHA256}  /tmp/gaps/GapsAsJar.zip" | sha256sum -c - && \
    unzip -q /tmp/gaps/GapsAsJar.zip -d /tmp/gaps && \
    cp "$(find /tmp/gaps -name 'GapsWeb-*.jar' | head -n1)" /app/gaps/gaps.jar
```

   Notes: `${VERSION#v}` gives `0.10.4` for the zip name (same pattern as `nzbhydra2`). The jar name inside the zip is UNVERIFIED: list the zip once, then replace the `find` with the exact name. `movieIds.json` from upstream is copied to `/usr/data`; if it is not in the zip, it must come from the source tarball (UNVERIFIED whether the app needs it at runtime).
5. License: `mkdir -p /usr/share/licenses/gaps && curl -fsSL -o /usr/share/licenses/gaps/LICENSE "https://raw.githubusercontent.com/JasonHHouse/gaps/${VERSION}/LICENSE"` (MIT). The jar is only part of the upstream repo, so ship the license.
6. `chown -R root:root /app/gaps && chmod -R 0755 /app/gaps && rm -rf /tmp/gaps`.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

ENV HOME=/config \
    ENABLE_SSL=false \
    ENABLE_LOGIN=false \
    BASE_URL=""

EXPOSE 8484
VOLUME ["/config"]
WORKDIR /config
```

No `/tmp` cache envs are needed (Java has no package cache). `java.io.tmpdir` is `/tmp` by default, which is the tmpfs under `--read-only --tmpfs /tmp`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "gaps"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=JasonHHouse/gaps versioning=semver
  default = "v0.10.4"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/JasonHHouse/gaps"
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

Add `GAPS_SHA256` to `args` (or as a bake variable) so the Dockerfile ARG gets the pinned value. Validate with `docker buildx bake --print` from `apps/gaps`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/JasonHHouse/gaps"
ports:
  - port: 8484
    protocol: tcp
    required: false
env:
  - name: BASE_URL
    default: ""
    required: false
  - name: ENABLE_LOGIN
    default: "false"
    required: false
  - name: ENABLE_SSL
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

The first three env names come from the upstream Dockerfile and are read by upstream `start.sh`. `TZ` is the sibling convention. Do not add a TMDb key env var: none is confirmed. Ports: only 8484 is exposed. The chart's `/usr/data` is not listed because the image writes state to `/config`.

## 7. start.sh

```bash
#!/usr/bin/env bash

ENABLE_SSL="${ENABLE_SSL:-false}"
ENABLE_LOGIN="${ENABLE_LOGIN:-false}"
BASE_URL="${BASE_URL:-}"

# profile selection: copy the upstream mapping of ENABLE_SSL/ENABLE_LOGIN to
# spring profile names (UNVERIFIED names, read upstream start.sh before writing)
profile="..."

cd /config || exit 1

exec java \
  -Xms256m -Xmx2048m \
  -jar \
  -Dspring.profiles.active="${profile}" \
  -Dserver.servlet.context-path="${BASE_URL}" \
  /app/gaps/gaps.jar
```

- Idempotent. Seeds nothing: the app creates its state, and `/config` may be empty.
- No writes to `/app`. Working directory is `/config`.
- `exec` so signals reach java (PID 1 handoff).
- Spring binds all interfaces by default (UNVERIFIED for this build; the probe in section 11 checks reachability from the host).
- Keep `-Xms256m -Xmx2048m` from upstream. They are the tested memory bounds.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8484'
http:
- port: '8484'
  path: /
filePaths:
- /app/gaps/gaps.jar
- /usr/share/licenses/gaps/LICENSE
```

- The test runs with no env vars, so the default path (`ENABLE_SSL=false`, `ENABLE_LOGIN=false`) is what is tested. SSL and login profiles are not tested; they are in the same jar, so add a `filePaths` check only if a profile file is shipped separately (UNVERIFIED).
- The `http` probe path `/` is UNVERIFIED: a Spring app may return a redirect or 404 for `/`. Confirm the status in the probe and use the path that returns 200 if needed. Do not weaken the probe.
- `timeoutSeconds: 180` matches the common sibling value for Java apps.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/usr/app`, `/usr/data` (chmod 777 upstream, root user) | Jar and `movieIds.json` ship under `/app/gaps` at build time (read-only at runtime). Runtime state goes to `/config`. |
| Working directory `/usr/app` | `WORKDIR /config` (`start.sh` also `cd /config`). |
| Java temp (`/tmp`) | Left as is, `/tmp` is the tmpfs under `--read-only --tmpfs /tmp`. |
| Chart PVC `data` at `/usr/data` | Not used. Users with existing data must copy it to `/config` (UNVERIFIED which files the app writes there). |

Draft expectations reconciled: the draft says non-root (chart default 568, no override). The upstream image has no `USER` line, so it runs as root upstream, and our image runs as `apps` (568). Our image runs as `apps` (568) and `readOnlyRootFilesystem` is expected to work because nothing is written under `/app`. Not privileged. No extra capabilities.

## 10. Risks, caveats and open questions

- Upstream is inactive since 2022 (latest release 2022-04-01). Expect no fixes. Java 11 bytecode on Java 17 is accepted, but the app may have dependency issues (UNVERIFIED).
- The jar is built outside the Dockerfile. The build depends on the GitHub release asset staying available. Pinning the checksum (section 4) makes a silent change fail.
- The jar name inside the zip and whether it contains `movieIds.json` are UNVERIFIED. The plan has a list step before the `find`.
- The upstream profile names are UNVERIFIED (not fetched). Do not guess them: copy from upstream `start.sh`.
- The TMDb API key and the Plex or local-folder setup are external and UNVERIFIED as env vars. Do not invent env names. The app is configured after start through its web UI (UNVERIFIED).
- arm64: same zip and a Java base with arm64 support (UNVERIFIED that `ghcr.io/trueforge-org/java17` has an arm64 manifest for the pinned digest). The draft's `copy-from arm64: no` is irrelevant here because we use the zip.
- Renovate: a checksum pin needs a manual update per bump. Note it in the PR.
- No blockers found: not musl-only, no GPU, no privileged mode, no database.

## 11. Build and test steps

```sh
cd /workspaces/containers/apps/gaps
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name gaps-probe --read-only --tmpfs /tmp \
  -v gaps-probe-config:/config gaps:v0.10.4
docker logs -f gaps-probe
forgetool containers test --image gaps:v0.10.4 --config ./apps/gaps/container-test.yaml
docker rm -f gaps-probe; docker volume rm gaps-probe-config
```

Readiness signals (UNVERIFIED wording, check the first real run): a Spring Boot startup banner, then `Tomcat started on port(s): 8484` and `Started ... Application` lines. The container must still be running after startup. Also run once with `-p 8484:8484` and curl from the host, to prove the server is not bound to localhost only. Then restart the container with the same `/config` volume to check the second start.

## 12. PR checklist

- Branch `feat/add-gaps`, commit `feat(gaps): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Untested to state honestly: the build on amd64 and arm64, the probe status code for `/`, SSL and login profiles, the read-only run, and any run against the TMDb API.
- Before the commit: `docker buildx bake --print` passes, `VERSION` in bake equals `ARG VERSION` in the Dockerfile, the checksum is pinned, and no assertion was weakened.
