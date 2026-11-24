# post-recording — implementation plan
> Source: ./draft.md · Target: apps/post-recording/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | Comskip `V0.83` (GitHub release, published 2025-02-28). Draft tag `chacawaca/post-recording:latest` is unversioned, so the Comskip tag is the image version. |
| Renovate | `datasource=github-releases depName=erikkaashoek/Comskip versioning=loose` (tag has a capital `V`) |
| License | Comskip: GPL (check `LICENSE` in the tarball; use `GPL-2.0-or-later` only after confirming). UNVERIFIED: GitHub licence page not read. The wrapper repo `chacawaca/docker-post-recording` shows no licence. |
| Source URL | https://github.com/erikkaashoek/Comskip/ |
| Download URLs | Source tarball, same for both arches (it is compiled): `https://github.com/erikkaashoek/Comskip/archive/refs/tags/V${VERSION}.tar.gz`. The release has NO binary assets (assets list is empty). |
| Checksum source | None published upstream. UNVERIFIED: compute `sha256sum` of the tarball when porting and pin it as an `ARG` in the Dockerfile. |
| Upstream Dockerfile | Reviewed: `chacawaca/docker-post-recording` @971031f. `FROM ubuntu:20.04`; clones Comskip and BrettSheleski/comchap from default branch (unpinned); copies `ccextractor` from `gizmotronic/ccextractor` and ffmpeg from `chacawaca/ffmpeg`; installs s6-overlay v2.2.0.1 and `ENTRYPOINT ["/init"]`. |
| Upstream env | `DELETE_TS` (0 delete, 1 keep, 2 move to /backup; Dockerfile default 1), `SUBTITLES` (0 extract .srt, 1 don't; default 0), `CONVERSION_FORMAT` (default mp4), `SOURCE_EXT` (default ts), `POST_PROCESS` (`comchap` default, or `comcut`), `SOURCE_STABLE_TIME=10`, `SOURCE_MIN_DURATION=10`, `UMASK`, `PUID`/`PGID`. |
| Upstream paths | `/config` (config, logs), `/watch` (input), `/backup` (only with DELETE_TS=2), `/output` created, `/scripts/custom.sh`, `/hooks`, `/comskip/comskip.ini`. |
| Ports | None. Pure file-watching worker. |
| Not verified | The `rootfs/` s6 scripts (watch loop, conversion command line) were not readable. UNVERIFIED: exact ffmpeg/comchap invocation. Read `rootfs/` on the upstream repo before writing `start.sh`. |

## 2. Target layout

```
apps/post-recording/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh            # replaces s6-overlay: watch loop + conversion
  defaults/comskip.ini   # seeded into /config when missing (copy from upstream rootfs/ after review)
  scripts/convert.sh     # per-file conversion, called by start.sh (keeps start.sh small)
```
No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits: compiled native tools plus ffmpeg, no interpreted runtime, and it replaces the end-of-life Ubuntu 20.04 upstream. Use a separate build stage (same base) for compiling, so build tools do not ship. Closest sibling: `apps/xvfb` (apt tools on ubuntu) and `apps/steamcmd` (helper binaries under `/usr/local`).

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS build`: `ARG VERSION`, `USER root`, apt install `build-essential autoconf automake libtool-bin pkg-config git ca-certificates curl libargtable2-dev libavutil-dev libavformat-dev libavcodec-dev libsdl1.2-dev` (UNVERIFIED: names on 26.04, e.g. libsdl1.2 may need `libsdl1.2-compat-dev`; confirm with `apt-cache`).
2. Download tarball `V${VERSION}.tar.gz`, verify `echo "${COMSKIP_SHA256}  file" | sha256sum -c -`, extract, `./autogen.sh && ./configure --prefix=/usr/local && make -j"$(nproc)" && make DESTDIR=/out install`.
3. comchap: `git clone` BrettSheleski/comchap and `git checkout <pinned commit>` (UNVERIFIED commit; upstream is unpinned), install `comchap`/`comcut` scripts to `/out/usr/local/bin`.
4. Final stage `FROM <ubuntu>`; `ARG VERSION`; `ARG TARGETARCH` (not needed for downloads, tarball is source; keep only if used). `USER root`.
5. apt (pin not required for runtime helpers, but verify they exist on 26.04): `ffmpeg mediainfo expect tcl inotify-tools ccextractor libargtable2-0 libsdl1.2-compat` (UNVERIFIED: `ccextractor` in Ubuntu archive; fallback is building it from `CCExtractor/ccextractor` in the build stage). Do not re-install `curl`/`bash` if the base has them. `apt-get clean && rm -rf /var/lib/apt/lists/*`.
6. `COPY --from=build /out/usr/local/ /usr/local/`.
7. License files: `mkdir -p /usr/share/licenses/post-recording` and copy Comskip `COPYING`/`LICENSE` from the build stage.
8. `ENV HOME=/config TMPDIR=/tmp`.
9. `mkdir -p /watch /backup` only if the base allows; otherwise they are mounts and `start.sh` must tolerate absence.
10. `USER apps`
11. `COPY --chmod=0755 . /`
12. `VOLUME /config` (also document `/watch` and `/backup` in settings.yaml). No `EXPOSE`.
13. `CMD ["/start.sh"]` only if sibling apps do; `apps/valkey` uses it. `start.sh` ends with `exec`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP"     { default = "post-recording" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=erikkaashoek/Comskip versioning=loose
  default = "0.83"   // if Renovate returns "V0.83", keep the Dockerfile URL as V${VERSION#V}; decide when building
}
variable "LICENSE" { default = "GPL-2.0-or-later" }   // UNVERIFIED, confirm from LICENSE file
variable "SOURCE"  { default = "https://github.com/erikkaashoek/Comskip/" }
```
Plus `group "default"`, `target "image"` (args VERSION, labels source/licenses), `target "image-local"` (`type=docker`, tag `${APP}:${VERSION}`), `target "image-all"` (amd64+arm64), copied from `apps/adguardhome-sync`. Add `COMSKIP_SHA256` variable only if passed as arg. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/erikkaashoek/Comskip/"
ports: []
env: TZ(Etc/UTC), DELETE_TS(1), SUBTITLES(0), CONVERSION_FORMAT(mp4), SOURCE_EXT(ts), POST_PROCESS(comchap), SOURCE_STABLE_TIME(10), SOURCE_MIN_DURATION(10), UMASK(022) - all required: false
volumes: /config (required true), /watch (required true), /backup (required false)
dependencies: none
```
Write the `env` block as proper `- name/default/required` entries. Drop `PUID`/`PGID`/`UMASK=000` from upstream: the image is rootless (see section 9); document that choice. `ports: []` is allowed only if siblings use it; otherwise omit the key. UNVERIFIED: schema accepts empty ports.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`. `umask "${UMASK:-022}"`.
- Seed `/config/comskip.ini` from `/defaults/comskip.ini` only if missing; `mkdir -p /config/logs`.
- Verify `/watch` exists and is writable; log a clear error and exit 1 if not.
- Loop (replace s6): `inotifywait -m -r -e close_write,moved_to --format '%w%f' /watch` piped to a reader that, per file matching `*.${SOURCE_EXT}`, waits `SOURCE_STABLE_TIME` seconds of unchanged size, skips files shorter than `SOURCE_MIN_DURATION` (ffprobe), then runs `/scripts/convert.sh`. Also do one startup sweep so existing files get processed.
- `convert.sh`: ffmpeg copy-remux to `${CONVERSION_FORMAT}`, optional `ccextractor` for `.srt` when `SUBTITLES=0`, then `${POST_PROCESS}` (`comchap` or `comcut`), then apply `DELETE_TS` (0 delete, 1 keep, 2 move to `/backup`). Temp files under `/tmp`, never `/config`.
- Honour `/config/custom.sh` and `/hooks` only if they exist (upstream feature; confirm semantics from `rootfs/`).
- Final line: `exec` the watch loop function (use `exec inotifywait ... | while ...` is not possible; instead run the loop in the foreground of the script with `trap 'kill 0' TERM INT`).

## 8. container-test.yaml

The app has no ports, so there is no tcp/http probe to add (settings.yaml `ports` is empty).
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /start.sh
- /scripts/convert.sh
- /usr/local/bin/comskip
- /usr/local/bin/comchap
- /usr/bin/ffmpeg
- /usr/share/licenses/post-recording
```
Tests run with no env and no `/watch` mount: `start.sh` must not exit if `/watch` is missing in the test run (create `/tmp/watch` fallback, or log and `sleep infinity`-style idle). UNVERIFIED: how forgetool treats a container without ports; confirm against a sibling with no port (`apps/steamcmd`, `apps/irqbalance`).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
|---|---|
| s6-overlay needs root (`/init`, `/run`, PUID/PGID chown) | Dropped. Plain bash loop as UID `apps`. |
| user `abc` home `/config` | `HOME=/config`. |
| `/etc/nginx` (nginx installed upstream) | Not installed; no web UI. UNVERIFIED that nginx is actually used; check `rootfs/`. |
| `/output` | Not used; output is written next to the source in `/watch`. UNVERIFIED. |
| comskip temp/logs | `/config/logs` for logs, `/tmp` for scratch. |

Draft expected root, UID 0, `readOnlyRootFilesystem: false`, extra `/backup` and `/watch` PVCs. Decision: run as `apps`, read-only rootfs compatible; `/watch` and `/backup` must be mounted writable and owned by the `apps` UID (document in PR; Kubernetes uses `fsGroup`). Upstream GPU hooks (`50-gid-video`, NVIDIA vars) are dropped; no hardware transcoding in v1.

## 10. Risks, caveats and open questions

- Upstream `rootfs/` not reviewed: the plan reimplements the watch loop, so behaviour may differ. Read it first.
- Ubuntu 20.04 upstream is EOL; this plan uses the 26.04 base and distro ffmpeg, so output may differ from the `chacawaca/ffmpeg` build.
- comchap and ccextractor have no pinned release, so Renovate cannot track them. Pin commits manually.
- Library names on Ubuntu 26.04 (libsdl1.2, libargtable2, ccextractor) are UNVERIFIED.
- Redistribution/licence of the chacawaca wrapper scripts is unknown; do not copy them verbatim, rewrite.
- No GPU/VAAPI/NVENC support; no arm64-specific blocker (all source builds).
- UNVERIFIED count: 9.

## 11. Build and test steps

```sh
cd apps/post-recording
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create post-recording-probe-config
docker run --rm -d --name post-recording-probe --read-only --tmpfs /tmp \
  -v post-recording-probe-config:/config -v "$PWD/_watch":/watch post-recording:<version>
docker logs -f post-recording-probe     # expect a "watching /watch" readiness line, no stack traces
# drop a sample .ts into _watch and confirm the converted output and chapters file appear
docker rm -f post-recording-probe; docker volume rm post-recording-probe-config
forgetool containers test --image post-recording:<version> --config ./apps/post-recording/container-test.yaml
```
Also run a second pass with an empty `/watch` mount and with `DELETE_TS=2` plus `/backup`.

## 12. PR checklist

- Branch `feat/add-post-recording`; commit and PR title `feat(post-recording): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Bake `--print` run; not checked until actually run: image build, arm64 build, empty-`/config` run, forgetool test, real `.ts` conversion, licence confirmation. State anything not run as untested.
