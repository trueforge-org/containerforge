# booksonic-air — implementation plan
> Source: ./draft.md · Target: apps/booksonic-air/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v2201.1.0 (published 2022-01-13), the same as the chart image `ghcr.io/linuxserver/booksonic-air:2201.1.0`. Latest tag. Tags: v2201.1.0, v2112.2.0, v2112.1.0, v2009.1.0. |
| Draft tag | Matches (2201.1.0). |
| Renovate | `datasource=github-releases depName=popeen/Booksonic-Air versioning=loose extractVersion=^v(?<version>.+)$` (tags are `vYYMM.x.y`, not strict semver; the `v` is stripped so bake `VERSION` is `2201.1.0` and the Dockerfile adds `v` in the URL; precedent `apps/code-server`) |
| License | GPL-3.0 (GitHub API `license.spdx_id`, popeen/Booksonic-Air) |
| Source URL | https://github.com/popeen/Booksonic-Air (last pushed 2023-03-31, upstream looks stale) |
| Download | `https://github.com/popeen/Booksonic-Air/releases/download/v2201.1.0/booksonic.war`, a single arch-independent JAR/WAR. Same URL for amd64 and arm64. |
| Checksum source | UNVERIFIED: no checksum asset is published with the release. |
| Upstream Dockerfile reviewed | linuxserver `docker-booksonic-air` @ a70824fbf40f6dc16ab7a8e957dda58267c05ed3: `FROM baseimage-alpine:3.20`, apk ffmpeg flac fontconfig lame openjdk11-jre ttf-dejavu, WAR download, `ENV BOOKSONIC_AIR_HOME=/app/booksonic-air BOOKSONIC_AIR_SETTINGS=/config LANG=C.UTF-8`, `EXPOSE 4040`, `VOLUME /config`, no USER, no ENTRYPOINT. |
| Real launch | linuxserver `root/etc/s6-overlay/s6-rc.d/svc-booksonic-air/run`: `cd $BOOKSONIC_AIR_HOME`, then `java -Dairsonic.defaultMusicFolder=/music -Dairsonic.defaultPlaylistFolder=/playlists -Dairsonic.defaultPodcastFolder=/podcasts -Dairsonic.home=$BOOKSONIC_AIR_SETTINGS -Djava.awt.headless=true -Djava.io.tmpdir=/run/tomcat.4040 -Dserver.servlet.contextPath=/$CONTEXT_PATH -Dserver.host=0.0.0.0 -Dserver.port=4040 $JAVA_OPTS -jar booksonic.war` |
| Init | linuxserver `init-booksonic-air-config/run`: create `$BOOKSONIC_AIR_SETTINGS/transcode`, symlink `ffmpeg`, `flac`, `lame` from `/usr/bin` into it, and chown `/config` and `/run/tomcat.4040`. |
| Ports | 4040/tcp (`server.port=4040`) |
| Env vars (real) | `CONTEXT_PATH` (URL base, leading slash stripped), `JAVA_OPTS` (extra JVM args). Music, playlist and podcast folders are fixed to `/music`, `/playlists`, `/podcasts` (not env). |
| Data path | `airsonic.home=/config` (settings and DB), `transcode/` under it |
| Java | linuxserver ships `openjdk11-jre`. Draft base is java17. UNVERIFIED: that `booksonic.war` runs on Java 17 (sibling `airsonic-advanced` runs on java17, which is the closest precedent). |
| Media dependency apt | ffmpeg, flac, lame, fontconfig, ttf-dejavu (upstream). Sibling `apps/airsonic-advanced/Dockerfile` already installs `ffmpeg flac fontconfig lame fonts-dejavu-core` on java17. |
| arm64 | WAR is arch-independent, so both arches are `yes`. linuxserver arm64 image status UNVERIFIED (not needed: copy-from is `no`). |

## 2. Target layout

- `apps/booksonic-air/Dockerfile`
- `apps/booksonic-air/docker-bake.hcl`
- `apps/booksonic-air/settings.yaml`
- `apps/booksonic-air/container-test.yaml`
- `apps/booksonic-air/start.sh`

No `defaults/`, `etc/` or `health/` needed: the WAR creates its own state under `/config` on first start, and the transcode links are made by `start.sh`. No `root/` (linuxserver s6 tree is replaced). No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`, the runtime image the draft asks for. It is already ubuntu-based, so `ubuntu` is the foundation and needs no separate stage. Closest sibling: `apps/airsonic-advanced` (WAR on java17, same transcode and tmpdir layout). `java25` is not used: the WAR has no Java version named, and java17 matches the sibling.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `ENV BOOKSONIC_AIR_HOME=/app/booksonic-air BOOKSONIC_AIR_SETTINGS=/config LANG=C.UTF-8`.
3. One RUN block:
   - `apt-get update && apt-get install -y --no-install-recommends ffmpeg flac fontconfig lame fonts-dejavu-core` (same as the airsonic-advanced sibling; `vorbis-tools` is not needed by Booksonic).
   - `mkdir -p ${BOOKSONIC_AIR_HOME} /run/tomcat.4040 && chown -R 568:568 /run/tomcat.4040`
   - `curl -fL -o ${BOOKSONIC_AIR_HOME}/booksonic.war https://github.com/popeen/Booksonic-Air/releases/download/v${VERSION}/booksonic.war`
   - `apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*`
4. Upstream also deletes `accessibility.properties` under `/etc` and `/usr`; not reproduced unless the Java 17 run shows a need (UNVERIFIED).
5. License: copy the upstream `LICENSE` (GPL-3.0) to `/usr/share/licenses/booksonic-air/LICENSE`. Fetch it at build time from `https://raw.githubusercontent.com/popeen/Booksonic-Air/v${VERSION}/LICENSE` (UNVERIFIED that the file exists at that tag).
6. `USER apps`, `COPY --chmod=0755 . /`.
7. `EXPOSE 4040`, `VOLUME /config`.

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 4040
VOLUME /config
```

Note: `/run/tomcat.4040` is created at build time as `568:568`, mirroring the sibling. At runtime the app writes its tmpdir to `/tmp` instead (see section 7), so `/run/tomcat.4040` is not needed and can be dropped; keep it only if the build check shows it is required.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "booksonic-air"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=popeen/Booksonic-Air versioning=loose extractVersion=^v(?<version>.+)$
  default = "2201.1.0"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/popeen/Booksonic-Air"
}
```

Then the default group and the four standard targets (`image`, `image-local`, `image-all`) copied from `apps/airsonic-advanced/docker-bake.hcl`. Validate with `docker buildx bake --print` from `apps/booksonic-air`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/popeen/Booksonic-Air"
ports:
  - port: 4040
    protocol: tcp
    required: true
env:
  - name: CONTEXT_PATH
    default: ""
    required: false
  - name: JAVA_OPTS
    default: ""
    required: false
volumes:
  - path: /config
    required: true
  - path: /music
    required: false
  - path: /playlists
    required: false
  - path: /podcasts
    required: false
```

Only the two env vars the run script reads are listed (`TZ` and `UMASK` are base-image behaviour, not read by Booksonic, so omitted). `/music`, `/playlists` and `/podcasts` are read by the app through fixed `-D` flags, so they are listed as optional mounts. Dependencies: none, so no `dependencies:` entry.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p "${BOOKSONIC_AIR_SETTINGS}/transcode"

# link the transcoders once, as the upstream init does
for bin in ffmpeg flac lame; do
  if [[ ! -e "${BOOKSONIC_AIR_SETTINGS}/transcode/${bin}" ]]; then
    ln -sf "/usr/bin/${bin}" "${BOOKSONIC_AIR_SETTINGS}/transcode/"
  fi
done

# strip leading slash from CONTEXT_PATH, then build the URL base
CONTEXT_PATH="${CONTEXT_PATH#/}"
URL_BASE="/${CONTEXT_PATH}"

# extra JVM args
IFS=" " read -r -a RUN_ARRAY <<< "${JAVA_OPTS}"

cd "${BOOKSONIC_AIR_HOME}" || exit 1
exec java \
  -Dairsonic.defaultMusicFolder=/music \
  -Dairsonic.defaultPlaylistFolder=/playlists \
  -Dairsonic.defaultPodcastFolder=/podcasts \
  -Dairsonic.home="${BOOKSONIC_AIR_SETTINGS}" \
  -Djava.awt.headless=true \
  -Djava.io.tmpdir=/tmp \
  -Dserver.servlet.contextPath="${URL_BASE}" \
  -Dserver.host=0.0.0.0 \
  -Dserver.port=4040 \
  "${RUN_ARRAY[@]}" \
  -jar booksonic.war
```

- Idempotent: `transcode/` and the links are created only when missing. Nothing is seeded (the WAR creates its own settings under `/config`), and nothing is written to `/app`.
- `java.io.tmpdir=/tmp` replaces upstream `/run/tomcat.4040`, which keeps the rootfs read-only. Caches stay in `/tmp`.
- `server.host=0.0.0.0` makes it reachable from other containers.
- `exec java` hands PID 1 to the JVM.
- `${JAVA_OPTS}` is split into an array, never eval'd, to avoid injection from the environment.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '4040'
http:
- port: '4040'
  path: /
filePaths:
- /app/booksonic-air/booksonic.war
- /usr/share/licenses/booksonic-air/LICENSE
```

- Every `settings.yaml` port (4040) has a `tcp` probe. It also has an `http` probe on `/`; UNVERIFIED that `/` returns 200 before setup (the probe may need to accept a redirect, check at run time).
- `timeoutSeconds: 180` is a proposed value (sibling `airsonic-advanced` sets none). Tune it to the measured startup time.
- Test runs without env vars, which is the default path here. No required-env code paths exist.
- No database dependency, so the DB-dependency exception does not apply and the functional probes are full.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (`airsonic.home`, settings, DB, `transcode/`) | Kept: persistent `VOLUME /config`. Empty `/config` works because the WAR creates its own state. |
| `/run/tomcat.4040` (tmpdir in linuxserver) | Moved to `/tmp` via `-Djava.io.tmpdir=/tmp`. |
| `/music`, `/playlists`, `/podcasts` | Read/write media mounts (user-provided), not `/config`. Optional in `settings.yaml`. |
| `/app/booksonic-air` | Read-only at runtime; WAR is baked at build time. |
| `$HOME` caches | Set `HOME`/caches to `/tmp` if the JVM writes there; not expected from the run script (UNVERIFIED). |

Security expectations (draft): non-root yes (`USER apps`, the linuxserver `abc` user is replaced), read-only-rootfs yes (all writes go to `/config`, `/tmp` or media mounts), privileged no, no extra persistence beyond the media folders.

## 10. Risks, caveats and open questions

- Upstream is stale: last release 2022-01-13, repo last pushed 2023-03-31. Security fixes are unlikely. Flag in the PR.
- Java: linuxserver uses openjdk11; this plan uses java17. UNVERIFIED that the WAR runs on Java 17. If it does not, use `java11` (`apps/java11` exists) and record why.
- Checksum: no checksum is published for `booksonic.war`. Download is HTTPS from GitHub, pinned to a tag. Record as "no upstream checksum".
- License file path: `LICENSE` at tag `v2201.1.0` is UNVERIFIED. If missing, `COPY` from the source tarball instead.
- arm64: the WAR is arch-independent, but the image is untested on arm64. Build amd64 only unless the failure is arm64-specific.
- ffmpeg/flac/lame versions on ubuntu 26.04 are whatever the apt archive provides (UNVERIFIED version), as in the airsonic sibling.
- Blockers: none confirmed.

## 11. Build and test steps

```sh
cd apps/booksonic-air
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

# run on a read-only rootfs with a fresh, empty /config
docker volume create booksonic-air-probe-config
docker run --rm -d --name booksonic-air-probe --read-only --tmpfs /tmp \
  -v booksonic-air-probe-config:/config booksonic-air:2201.1.0
docker logs -f booksonic-air-probe   # wait for the readiness signal
docker rm -f booksonic-air-probe; docker volume rm booksonic-air-probe-config

# forgetool
forgetool containers test --image booksonic-air:2201.1.0 --config ./apps/booksonic-air/container-test.yaml
```

- Expected readiness signal: the process stays up and port 4040 accepts TCP. Upstream log line UNVERIFIED, so rely on the port probe plus Spring Boot's startup banner if present.
- Fail signals: `UnsupportedClassVersionError` or `java: command not found` (Java mismatch), `Permission denied` under `/config` (ownership), `Read-only file system` (a path outside `/config` or `/tmp` is still written).

## 12. PR checklist

- Branch: `feat/add-booksonic-air`, from `main`.
- Commit and PR title: `feat(booksonic-air): add new container` (Conventional Commits, app as scope).
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows status.
- PR description: fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and tick only what applies. Put `🤖 This PR is AI generated.` in the Notes section.
- Untested, to state in the PR: arm64 build, Java 17 compatibility (UNVERIFIED), `LICENSE` file path, the `/` http probe status, and any run that was not performed.
- Do not check "Built container locally" unless `image-local` was built and the probe run passed.
