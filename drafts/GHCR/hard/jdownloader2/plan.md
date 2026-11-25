# jdownloader2 — implementation plan
> Source: ./draft.md · Target: apps/jdownloader2/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Chart image | `ghcr.io/jlesage/jdownloader-2:v26.09.1` (draft; chart values) |
| Latest upstream wrapper release | `v26.09.1`, published 2026-09-22T15:18:09Z (`gh api repos/jlesage/docker-jdownloader-2/releases/latest`) |
| Renovate (wrapper tag, proxy only) | `datasource=github-releases depName=jlesage/docker-jdownloader-2 versioning=loose` (wrapper tags are `vYY.MM.n`, not strict semver) |
| Application | JDownloader 2, a Java Swing download manager. Ships as one JAR, `https://installer.jdownloader.org/JDownloader.jar` (source: upstream Dockerfile below) |
| Version of the JAR | Not versioned. The Dockerfile fetches the latest JAR from the vendor URL with no version in the path (source: upstream Dockerfile). The app also self-updates at runtime (draft caveat, not re-verified here). |
| License of the software in the image | UNVERIFIED: JDownloader's own license was not confirmed on a fetched page. The upstream wrapper is MIT (`gh api repos/jlesage/docker-jdownloader-2`, license `MIT`). The wrapper license does not cover JDownloader, so `LICENSE` must be confirmed before the bake file is written. |
| Source URL | https://github.com/jlesage/docker-jdownloader-2 (wrapper); https://jdownloader.org/ (app website, draft) |
| Upstream Dockerfile reviewed | `https://raw.githubusercontent.com/jlesage/docker-jdownloader-2/v26.09.1/Dockerfile`. Stage 1 `FROM --platform=$BUILDPLATFORM alpine:3.24` downloads the JAR with `curl -# -L -o /defaults/JDownloader.jar ${JDOWNLOADER_URL}`. Stage 2 `FROM jlesage/baseimage-gui:alpine-3.24-v4.14.0`. |
| Upstream packages | apk (Alpine, not apt): java-common, openjdk8-jre, jq, ttf-dejavu, curl, ffmpeg, rtmpdump, moreutils (upstream Dockerfile) |
| Upstream ENV | `MYJDOWNLOADER_EMAIL`, `MYJDOWNLOADER_PASSWORD`, `MYJDOWNLOADER_DEVICE_NAME`, `JDOWNLOADER_HEADLESS=0`, `JDOWNLOADER_MAX_MEM` (upstream Dockerfile) |
| Upstream EXPOSE / VOLUME | `EXPOSE 3129` (commented as MyJDownloader Direct Connection); `VOLUME ["/output"]` (upstream Dockerfile) |
| Upstream USER / ENTRYPOINT | Not set in the Dockerfile; inherited from the GUI base image (UNVERIFIED: base image Dockerfile not fetched) |
| Checksum source | None. The upstream Dockerfile does no checksum or signature check on the JAR. No vendor checksum was found on a fetched page. |
| Per-arch download | The JAR is architecture-independent (Java bytecode). The same URL serves amd64 and arm64. |
| Ports (GUI) | Draft lists 5800/http (noVNC) and 5900/tcp (VNC). UNVERIFIED: not confirmed by the upstream wrapper, which only declares 3129. The base GUI image's ports were not fetched. |
| Data paths | `/output` (upstream VOLUME). App config location under the home directory: UNVERIFIED. |

## 2. Target layout

- `apps/jdownloader2/Dockerfile`
- `apps/jdownloader2/docker-bake.hcl`
- `apps/jdownloader2/settings.yaml`
- `apps/jdownloader2/container-test.yaml`
- `apps/jdownloader2/start.sh`
- `apps/jdownloader2/defaults/` only if a default config is needed (not expected; reason: none identified yet)

No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base). The Alpine GUI stack is not copied into the image (see section 3 and section 10).

## 3. Base image

`FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a` for the final stage. It fits because the app needs only a JRE and the JAR, and java17 already provides `JAVA_HOME=/opt/java/openjdk` on glibc Ubuntu. The upstream image uses openjdk8 on musl; this is a deliberate change, and runtime compatibility on Java 17 is UNVERIFIED.

Closest sibling: `apps/nzbhydra2` (java17 base, JAR downloaded in the Dockerfile, `start.sh` runs `exec java ... -jar`).

Not usable: the upstream `jlesage/baseimage-gui` (Alpine). `copy-from amd64` = no (facts file), so nothing is copied out of the upstream image.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install the GUI and runtime packages the desktop needs (see section 9 for the open decision). Each package must be checked against the ubuntu 26.04 archive (UNVERIFIED for every package name). Do not reinstall packages the java17 base already has.
3. Download the JAR into the app folder, with no checksum available (documented risk):
   ```dockerfile
   RUN mkdir -p /app/jdownloader && \
     curl -fsSL -o /app/jdownloader/JDownloader.jar \
       "https://installer.jdownloader.org/JDownloader.jar"
   ```
   The image is not reproducible: the JAR changes without a tag change.
4. License file: UNVERIFIED. Ship the JDownloader license to `/usr/share/licenses/jdownloader2/` once it is confirmed.
5. `chown -R root:root /app && chmod -R 755 /app` so the `apps` user can read but not write `/app`.
6. `ENV HOME=/config` and `ENV JAVA_TOOL_OPTIONS="-Xmx..."` (value UNVERIFIED; the upstream heap is set by `JDOWNLOADER_MAX_MEM`, default empty).
7. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   VOLUME /config
   WORKDIR /config
   ```
   `EXPOSE` for the chosen GUI port only after it is verified (section 10).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "jdownloader2"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=jlesage/docker-jdownloader-2 versioning=loose
  default = "v26.09.1"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://jdownloader.org/"
}
```

Do not set `LICENSE` until the JDownloader license is confirmed. `VERSION` is the wrapper tag used for tracking only, because the JAR is not versioned. The four standard targets and the default group are copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://jdownloader.org/"
ports:
  - port: 3129
    protocol: tcp
    required: false
env:
  - name: JDOWNLOADER_MAX_MEM
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Port 3129 is the only port confirmed upstream. GUI ports stay out of this file until verified. `JDOWNLOADER_HEADLESS` and the MyJDownloader variables are listed only if `start.sh` reads them. Defaults match the upstream wrapper.

## 7. start.sh

Draft of the intended behavior; the exact Java flags are UNVERIFIED:

```bash
#!/usr/bin/env bash

mkdir -p /config/jdownloader /config/output

cd /config/jdownloader
exec java -Djava.awt.headless=true -jar /app/jdownloader/JDownloader.jar
```

Rules applied: idempotent; writes only to `/config` and `/tmp`; no writes to `/app`. The JAR self-update step writes into its own folder, so on a read-only `/app` it fails. Either disable self-update (UNVERIFIED how) or copy the JAR into `/config` on first start and run it from there. The final `exec` is kept for signal handling. The headless flag is UNVERIFIED for JDownloader; if the app needs a display, see section 9.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/jdownloader/JDownloader.jar
- /usr/bin/java
runners:
- entrypoint: /usr/bin/java -version
```

The test runs with no env vars. Add a `tcp` probe for every port in `settings.yaml` (3129) only once the app is confirmed to listen on it without MyJDownloader configured (UNVERIFIED). Do not add GUI probes until the GUI stack is decided.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/output` (upstream VOLUME, downloads) | `/config/output` (directory created by `start.sh`) |
| App config and self-update under its install folder | `/config/jdownloader`, with the JAR copied there on first start (see section 7) |
| Java temp and cache | `/tmp` (`-Djava.io.tmpdir=/tmp`) |
| X display sockets (if a GUI is kept) | `/tmp/.X11-unix` on the `--tmpfs /tmp` mount |

Open decision (blocker): JDownloader is a Swing desktop app. Upstream runs it under Xvfb with a VNC or noVNC front end from a GUI base. If headless mode works (UNVERIFIED), the image can drop the whole desktop stack, which is the preferred path. If not, the GUI stack must be rebuilt from ubuntu apt packages, which the draft says is hard. The draft's security expectations are reconciled as follows: the chart runs as UID 0 and not as non-root; ContainerForge runs as `apps` (UID 568) on `--read-only --tmpfs /tmp`; the chart's `readOnlyRootFilesystem: false` is not needed here; not privileged; capabilities `NET_BIND_SERVICE` and `KILL` from the chart are not expected to be needed (UNVERIFIED). The chart's `/output` becomes `/config/output`.

## 10. Risks, caveats and open questions

- License of JDownloader unknown (blocks `LICENSE` in the bake file).
- Desktop/Swing app. Headless mode is UNVERIFIED. This is the main blocker. The app cannot be validated without knowing its headless behavior.
- No version or checksum for the JAR. The image contents change on every rebuild. This conflicts with the rule that the image must contain the version it is tagged with; the tag `v26.09.1` is a wrapper tag, not a JDownloader version.
- Self-update conflicts with a read-only `/app` (section 7).
- Upstream runs Alpine with openjdk8; this plan uses Java 17 on Ubuntu. Runtime compatibility is UNVERIFIED.
- MyJDownloader credentials in env vars would be secrets; they must not be written to files or the process list (section 7 rule). Keep them out of `settings.yaml` defaults.
- Memory: Swing plus Java uses more RAM than a typical service (draft, inferred).
- No arm64 build was verified, but the JAR is architecture-independent. The base java17 image exists for arm64 (UNVERIFIED).
- Blocker status: hard. Not musl-only, not GPU, not privileged, not arm64-blocked, but the desktop requirement is unresolved.

## 11. Build and test steps

```sh
cd apps/jdownloader2
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name jdownloader2-probe --read-only --tmpfs /tmp \
  -v jdownloader2-probe-config:/config jdownloader2:v26.09.1
docker logs -f jdownloader2-probe
forgetool containers test --image jdownloader2:v26.09.1 --config ./apps/jdownloader2/container-test.yaml
docker rm -f jdownloader2-probe; docker volume rm jdownloader2-probe-config
```

Expected readiness signal: UNVERIFIED (JDownloader startup log lines are not confirmed). The check is that the process stays up and no fatal Java error appears. Verify on an empty `/config` volume and again after a restart.

## 12. PR checklist

- Branch `feat/add-jdownloader2`, commit and PR title `feat(jdownloader2): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it. The `license/cla` check shows the status.
- Say in the PR what was not tested: the GUI or headless behavior, self-update, arm64, the MyJDownloader login, and the Java 17 runtime.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; `LICENSE` is set only from a confirmed source.
