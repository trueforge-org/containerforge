# filebot — implementation plan
> Source: ./draft.md · Target: apps/filebot/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Chart tag today | `ghcr.io/jlesage/filebot:v26.09.2`, GitHub release published 2026-09-22 (https://api.github.com/repos/jlesage/docker-filebot/releases/tags/v26.09.2). Image digests: amd64 `sha256:5abb879b…ed8b5`, arm64 `sha256:2138a3ae…9a36f` (https://hub.docker.com/v2/repositories/jlesage/filebot/tags/v26.09.2). |
| Application version to build | FileBot **5.3.0** (upstream `ARG FILEBOT_VERSION=5.3.0`, https://raw.githubusercontent.com/jlesage/docker-filebot/v26.09.2/Dockerfile). The `v26.09.2` tag is the wrapper's CalVer, not FileBot's version. |
| Upstream image base | `jlesage/baseimage-gui:alpine-3.20-v4.14.0`, Alpine/musl, GUI (X, VNC, noVNC). Same Dockerfile. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/jlesage/docker-filebot/v26.09.2/Dockerfile (multi-stage: unrar, MediaInfoLib 26.05, ZenLib 0.4.41, UnRAR 6.1.7 built from source; `openjdk17-jre`, `chromaprint` (fpcalc), `zenity`, `ttf-dejavu`). |
| Application download | `https://get.filebot.net/filebot/FileBot_5.3.0/FileBot_5.3.0-portable.tar.xz` (31M, JVM build, arch-neutral). Also listed: `FileBot_5.3.0_amd64.deb` (Linux amd64 package). Listing: https://get.filebot.net/filebot/FileBot_5.3.0/ |
| Checksum source | Published per asset: `<asset>.sha256` and `<asset>.asc` in the same listing. Upstream's Dockerfile does **not** verify (it pipes `curl` into `tar`). We verify against the `.sha256` file. Its content for the portable tarball is UNVERIFIED until fetched at build time. |
| arm64 | The upstream image is published for arm64 (digest above). The listing has `FileBot_5.3.0_arm64.pkg`, which is macOS, so it is not usable. Linux arm64 uses the portable tarball, which is arch-neutral. Native libs (MediaInfo, fpcalc, UnRAR) must be built or installed per arch. |
| License | Docker wrapper: MIT (https://raw.githubusercontent.com/jlesage/docker-filebot/master/LICENSE, repo SPDX `MIT`). FileBot itself: UNVERIFIED (draft says commercial with optional key; not confirmed on a fetched page). |
| Renovate | UNVERIFIED: no renovate datasource is known that tracks FileBot 5.3.0. The `github-releases` datasource tracks the wrapper, not FileBot. See section 10. |
| Ports | Upstream GUI base exposes noVNC 5800 and VNC 5900 (from draft; the base image's `EXPOSE` was not fetched, so UNVERIFIED). Headless plan below exposes none. |
| Volumes | Upstream `VOLUME ["/storage"]`, `["/output"]`, `["/watch"]` (same Dockerfile). |
| Env (real, upstream wrapper) | `FILEBOT_GUI=1`, `AMC_ENABLED=1`, `USE_FILEBOT_BETA=0`, `AMC_INTERVAL=1800`, `AMC_INPUT_STABLE_TIME=10`, `AMC_ACTION=test`, `AMC_CONFLICT=auto`, `AMC_MATCH_MODE=opportunistic`, `AMC_ARTWORK=n`, `AMC_LANG=English`, `AMC_PROCESS_MUSIC=y`, `AMC_INPUT_DIR=/watch`, `AMC_OUTPUT_DIR=/output`, `DISABLE_GLX=1`, `FILEBOT_CUSTOM_OPTIONS`, `OPENSUBTITLES_USERNAME`, `OPENSUBTITLES_PASSWORD` (same Dockerfile). **These are read by the wrapper scripts, not by FileBot itself**, so a headless port must implement AMC invocation itself. |
| User | No `USER` in upstream Dockerfile; base image handles it (UNVERIFIED specifics). |
| apt packages on Ubuntu 26.04 | `chromaprint` / fpcalc package name and `libmediainfo` package name: UNVERIFIED (draft said `libmediainfo0v5`, inferred). Check with `apt-cache policy` in the build. |

## 2. Target layout

- `apps/filebot/Dockerfile`
- `apps/filebot/docker-bake.hcl`
- `apps/filebot/settings.yaml`
- `apps/filebot/container-test.yaml`
- `apps/filebot/start.sh`

No `defaults/`, `etc/` or `health/` (no seeded config needed; FileBot writes its own state under `/config`). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

**Decision needed before build (blocker):** GUI (VNC/noVNC desktop, as the chart uses) or headless AMC (a daemon that watches `/watch` and writes to `/output`). This plan assumes **headless AMC**, because `apps/` has no desktop/VNC base and the draft's chart value is `FILEBOT_GUI=1`. A GUI port would need a separate X/VNC stack and is out of scope for this plan.

## 3. Base image

`FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a` (runtime and build stage). Java 17 matches FileBot's `openjdk17-jre` in upstream. Closest sibling: `apps/nzbhydra2` (java17, zip download, jar in `/app/bin`). Final stage must be the same java17 image, so `java` is on `PATH`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends` for what the base does not already have: `xz-utils` (for `.tar.xz`, UNVERIFIED whether present), `libmediainfo` (package name UNVERIFIED), `libchromaprint-tools` for `fpcalc` (name UNVERIFIED), `unzip` only if needed. Then `rm -rf /var/lib/apt/lists/*`.
3. Download and verify:
   ```dockerfile
   RUN curl -fsSL -o /tmp/filebot.tar.xz "https://get.filebot.net/filebot/FileBot_${VERSION}/FileBot_${VERSION}-portable.tar.xz" \
    && curl -fsSL -o /tmp/filebot.tar.xz.sha256 "https://get.filebot.net/filebot/FileBot_${VERSION}/FileBot_${VERSION}-portable.tar.xz.sha256" \
    && (cd /tmp && sha256sum -c filebot.tar.xz.sha256)
   ```
   The `.sha256` filename pattern is inferred from the listing (`<asset>.sha256`). Confirm it at build time (UNVERIFIED until run).
4. Extract: `mkdir -p /app/filebot && tar -xJf /tmp/filebot.tar.xz -C /app/filebot --strip-components=1` (archive layout UNVERIFIED; check with `tar -tJf`).
5. Ship license: copy the tarball's `LICENSE`/notices if present to `/usr/share/licenses/filebot/` (UNVERIFIED that they exist).
6. Clean up: `rm -f /tmp/filebot.tar.xz*`, `chown -R apps:apps /app/filebot`, `chmod -R 755 /app/filebot`.
7. `ENV HOME=/config JAVA_TOOL_OPTIONS=-Djava.io.tmpdir=/tmp` (keeps Java scratch in `/tmp`).
8. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   WORKDIR /config
   VOLUME /config
   ```
   No `EXPOSE` in headless mode.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "filebot" }
variable "VERSION" {
  // renovate: UNVERIFIED datasource (see section 10); FileBot version 5.3.0
  default = "5.3.0"
}
variable "LICENSE" { default = "UNVERIFIED: FileBot license, confirm before build" }
variable "SOURCE" { default = "https://www.filebot.net/" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`. The `Dockerfile` `ARG VERSION` must match `5.3.0`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.filebot.net/"
ports: []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: AMC_INTERVAL
    default: "1800"
    required: false
  - name: AMC_ACTION
    default: "test"
    required: false
  - name: AMC_CONFLICT
    default: "auto"
    required: false
  - name: AMC_LANG
    default: "English"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only env names that `start.sh` reads. Upstream's `AMC_*` names are kept for familiarity (they are verified), but the port must read them itself. `OPENSUBTITLES_*` only if the user needs them. No ports in headless mode. No dependencies (FileBot is standalone).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/logs
export HOME=/config

interval="${AMC_INTERVAL:-1800}"
action="${AMC_ACTION:-test}"
conflict="${AMC_CONFLICT:-auto}"
lang="${AMC_LANG:-English}"
input="${AMC_INPUT_DIR:-/watch}"
output="${AMC_OUTPUT_DIR:-/output}"

cd /app/filebot
exec ./filebot.sh -script fn:amc --output "$output" --action "$action" --conflict "$conflict" --lang "$lang" \
  --log-file /config/logs/amc.log "$input"
```

The AMC command-line options above are UNVERIFIED against the FileBot docs (https://www.filebot.net/getting-started/index.html and the AMC script reference). Confirm with `./filebot.sh -script fn:amc --help` in the build step, and do not ship the line until it is confirmed. As written the script runs AMC once and the container exits, so `AMC_INTERVAL` has no effect: either wrap the call in `while true; do ...; sleep "$interval"; done` (then the last foreground loop replaces `exec`) or use FileBot's own watch mode (UNVERIFIED). Decide before implementing. Idempotent: `mkdir -p` only, no seeding. No writes to `/app`. Ends with `exec` in the single-run form so signals reach FileBot.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
filePaths:
- /app/filebot/filebot.sh
- /app/filebot/lib
- /usr/bin/fpcalc
```

No `tcp` or `http` (no ports). `/usr/bin/fpcalc` path is UNVERIFIED (from the package name). The test runs without env vars, so the default `AMC_*` values exercise the start path. Process liveness is not a forgetool check here, so the readiness signal in section 11 is run by hand.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (wrapper's home and data, `HOME=/config`) | kept, persistent |
| FileBot logs and AMC log | `/config/logs` |
| Java scratch (`java.io.tmpdir`) | `/tmp` via `JAVA_TOOL_OPTIONS` |
| FileBot cache and `~/.filebot` | `HOME=/config` (if persistence is needed) or move to `/tmp` (UNVERIFIED which path FileBot uses) |
| `/watch`, `/output`, `/storage` (media) | user mounts, not in the image. The mounted paths must be writable by UID `apps` (568 per the nzbhydra2 comment) or chowned by the user. Not declared in `settings.yaml` `volumes` (only `/config`). |

Draft expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. This image runs as `apps` with `--read-only --tmpfs /tmp`, which is a stricter target than the chart. Not privileged. Draft's capability `NET_BIND_SERVICE` and `KILL` are not needed in headless mode (no low ports, no GUI); verify.

## 10. Risks, caveats and open questions

- **GUI vs headless** (blocker): the draft's chart is the GUI. This plan is headless AMC. The user must confirm.
- **Renovate** (UNVERIFIED): no datasource tracks FileBot 5.3.0 (the github-releases datasource tracks the wrapper). Options: a custom regex manager against `get.filebot.net`, or manual bumps. Decide before bake.
- **Commercial license** (UNVERIFIED): FileBot may need a key. The wrapper's `OPENSUBTITLES_*` vars are for OpenSubtitles, not FileBot's key. Confirm before setting `LICENSE`.
- **Checksum**: upstream does not verify. We verify against the published `.sha256` (UNVERIFIED that the file exists at that exact path until fetched).
- **AMC CLI** (UNVERIFIED): the `fn:amc` invocation is not confirmed. The wrapper's env vars are not read by FileBot itself.
- **Native libs**: MediaInfo, fpcalc and UnRAR are built or installed per arch. The upstream's musl build does not carry over; the apt names are UNVERIFIED.
- **Media mount ownership**: `/watch` and `/output` must be writable by `apps`, or the start will fail on move.
- **Size**: java17 base plus FileBot is large. No measured size.

## 11. Build and test steps

```sh
cd apps/filebot
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name filebot-probe --read-only --tmpfs /tmp \
  -v filebot-probe-config:/config filebot:5.3.0
docker logs -f filebot-probe
forgetool containers test --image filebot:5.3.0 --config ./apps/filebot/container-test.yaml
docker rm -f filebot-probe; docker volume rm filebot-probe-config
```

Expected readiness signal (UNVERIFIED until run): an AMC start line in `/config/logs/amc.log` and the process still alive after the startup window. No port probe exists in headless mode. arm64 is built separately only if the amd64 build fails for an arch-specific reason.

## 12. PR checklist

- Branch `feat/add-filebot`, commit `feat(filebot): add new container`, PR title matches the commit, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the amd64 build, the arm64 build, the AMC CLI run, the checksum file content, the FileBot license, and any GUI mode.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
