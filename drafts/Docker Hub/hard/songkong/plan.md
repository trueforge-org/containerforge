# songkong — implementation plan
> Source: ./draft.md · Target: apps/songkong/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | SongKong 12.11 "Pinkerton" (download page, available from 2026-11-19). Draft uses `latest` (unpinned). Another search snippet showed 12.7, so the "current" download moves: UNVERIFIED which build a given day serves |
| Renovate | No datasource for jthink.net. UNVERIFIED/none: needs a custom datasource or manual bumps. Use the comment `// renovate: datasource=custom.jthink depName=songkong` only if a matching `customDatasources` entry is added in the repo renovate config (outside `apps/`); otherwise bump by hand |
| License | Proprietary, closed source. Runs in Lite mode without a purchased license; saving changes needs a license. Redistribution terms are not stated on the download page: UNVERIFIED. Use `LicenseRef-Proprietary` |
| Source | https://www.jthink.net/songkong/ |
| Download | `https://www.jthink.net/songkong/downloads/current/songkong-linux-headless-novm.tgz?val=82` (no bundled JVM, needs Java 17+, per install_linux_headless_novm.jsp) and `.../songkong-linux-headless.tgz?val=82` (bundled JVM). The page lists no per-arch (amd64/arm64) Linux builds: UNVERIFIED arm64 |
| Checksum | None published. The URL is unversioned ("current") so a pinned hash would break on the next vendor release |
| Upstream Dockerfile | None public (draft: `-`). Docker Hub `songkong/songkong` has a single tag `latest`, ~186 MB |
| Run | `./songkongremote.sh` starts remote (web) mode; `./songkong.sh` is desktop/CLI mode. Docker Hub run example: `docker run -v /CONFIGFOLDER:/songkong -v /MUSICFOLDER:/music -p 4567:4567 songkong/songkong` |
| Ports | **4567** (web UI). The draft's 8080 is a guess and is wrong |
| Env | Docker Hub page documents none |
| Paths | `/music` (library), `/songkong` (preferences, license, logs, reports, internal database) |
| Dependencies | none |

## 2. Target layout

```
apps/songkong/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No defaults/, etc/ or health/ needed. `root/` is not used. No DOWNSTREAM_CHANGES.md.

## 3. Base image

`FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`. Fits because the `novm` archive needs Java 17+ and the draft chose java17. Closest sibling: `apps/nzbhydra2` (java17 base, downloaded archive, `/config` data). UNVERIFIED: that the java17 base ships a JRE with all modules SongKong needs (bundled-JVM variant is the fallback; then use the ubuntu base).

## 4. Dockerfile

1. `ARG VERSION` (12.11), `ARG TARGETARCH` only if per-arch URLs appear (none known).
2. `USER root` for the install step only. Base already has curl and tar; no extra apt packages expected (add `fontconfig`/`libfreetype6` only if the app logs a missing library: UNVERIFIED).
3. `curl -fsSL -o /tmp/songkong.tgz "https://www.jthink.net/songkong/downloads/current/songkong-linux-headless-novm.tgz"`; no checksum exists (see section 1), so rely on HTTPS and record the limitation in section 10. Extract: `mkdir -p /app && tar xzf /tmp/songkong.tgz -C /app --strip-components=1` (archive extracts to `songkong/` per the vendor install page).
4. Fail the build if the archive's version does not match `VERSION`: read the version from the extracted files (UNVERIFIED where it is stored) so the image contains what it is tagged with.
5. License files: `mkdir -p /usr/share/licenses/songkong` and copy any license/EULA text found in the archive; if none, write a pointer file stating the vendor license URL.
6. `ENV HOME=/config` and `JAVA_TOOL_OPTIONS` left from the base; keep caches in `/tmp` (`-Djava.io.tmpdir=/tmp`).
7. `ln -s /config /songkong` at build time so the upstream image's `/songkong` data path resolves into the persistent volume (UNVERIFIED how SongKong picks its data folder; see section 7).
8. `chown -R apps:apps /app`, remove `/tmp/songkong.tgz`.
9. `USER apps` then `COPY --chmod=0755 . /`, `EXPOSE 4567`, `VOLUME /config`, final `USER apps` (the last user instruction).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "songkong" }
variable "VERSION" {
  // renovate: datasource=custom.jthink depName=songkong
  default = "12.11"
}
variable "LICENSE" { default = "LicenseRef-Proprietary" }
variable "SOURCE" { default = "https://www.jthink.net/songkong/" }
```
Standard targets `docker-metadata-action`, `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (linux/amd64 only until arm64 is verified), `group "default"`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Schema header + `schema_version: 1`, `upstream_env_url: "https://www.jthink.net/songkong/"`.
- ports: `4567` tcp, required true.
- env: `TZ` default `Etc/UTC`, required false (Docker Hub documents no other variables; none are invented).
- volumes: `/config` required true (state, license, database), `/music` required false (library, bind mount).
- dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config /tmp/songkong
export HOME=/config
cd /app
exec ./songkongremote.sh
```
Seeding: nothing is copied; the app creates its database/preferences in the data folder on first start (UNVERIFIED which folder; if it is not `/config` or `/songkong`, find it by running the vendor image once and reading where it writes, then export the relevant `-D` option or relocate via symlink in `/config`). The app must bind to all interfaces: confirm with a connection from outside the container (UNVERIFIED default bind). `songkongremote.sh` ends in a Java launch, so the `exec` hands signals to it (confirm the script itself execs java; if not, copy its java line into start.sh). No DB passwords. No writes to `/app`: logs must be redirected to `/config/logs` or `/tmp` (UNVERIFIED which files the launch script writes).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 240
tcp:
- port: '4567'
http:
- port: '4567'
  path: /
filePaths:
- /start.sh
- /app/songkongremote.sh
```
Probe for the only port (4567) is both tcp and http. `timeoutSeconds: 240` follows the java sibling startup time. The test runs with no env and no license, so Lite mode must start (documented behaviour).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/songkong` (preferences, license, logs, reports, DB) | `/config`, with a build-time symlink `/songkong -> /config` |
| JVM temp files | `/tmp` |
| Install dir (logs, lock files?) | UNVERIFIED; must be proven with `--read-only` |

Draft says root (UID 0), `readOnlyRootFilesystem: false`; the image runs UID 568 read-only. Extra persistence `/songkong` collapses into `/config`; `/music` stays a separate mount owned by the user (the container must be able to read, and write for tagging, so the host path needs UID/GID 568 or a group).

## 10. Risks, caveats and open questions

- BLOCKER to confirm with maintainers: closed-source, proprietary software. Whether it may be redistributed inside a public image on ghcr is not stated anywhere reachable. Contact JThink or have the image fetch the archive at first run instead of build time.
- No version-specific download URL, no checksum, and no renovate datasource: the build is not reproducible, and the tag can drift from the real content ("current" moves).
- Draft guessed port 8080; the real port is 4567.
- arm64: the vendor lists no arm64 Linux build; draft's `arm64: yes` is UNVERIFIED. Ship amd64 only until verified.
- The data folder selection and bind address of remote mode are not documented on the vendor pages: UNVERIFIED.
- Vendor URL availability is a single point of failure.

## 11. Build and test steps

```sh
cd apps/songkong
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name songkong-probe --read-only --tmpfs /tmp -v songkong-probe-config:/config songkong:12.11
docker logs -f songkong-probe
forgetool containers test --image songkong:12.11 --config ./apps/songkong/container-test.yaml
docker rm -f songkong-probe; docker volume rm songkong-probe-config
```
Readiness: a log line that the remote web server started on port 4567, and `curl -I http://127.0.0.1:4567/` succeeds from outside the container.

## 12. PR checklist

- Branch `feat/add-songkong`, commit `feat(songkong): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only the boxes that apply.
- Notes: `🤖 This PR is AI generated.`, plus the redistribution question from section 10.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge ; only the user can sign it.
- Untested: arm64, licensed mode, read-only behaviour of the vendor scripts, music-folder permissions, the data-folder location.
- Pre-completion: `bake --print` passes, `VERSION` matches Dockerfile ARG, final `USER apps`, empty `/config` starts.
