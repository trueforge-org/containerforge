# ffmpeg-mkvdts2ac3 — implementation plan
> Source: ./draft.md · Target: apps/ffmpeg-mkvdts2ac3/ · Difficulty: hard (reconstruction, no public source) · Role: main · Verified on 2026-11-24

The Hub image `snoopy86/ffmpeg` has no public source (amd64 only, last pushed 2020-12-20). This plan rebuilds the described behavior from public pieces: Ubuntu `ffmpeg` and `mkvtoolnix` plus the Apache-2.0 `mkvdts2ac3.sh` script and a small `inotifywait` watcher written for this repo. The behavior is therefore a reimplementation, not a copy of the Hub image.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Image content versions: ffmpeg `8.0.1` (Ubuntu 26.04 `resolute` source `ffmpeg 7:8.0.1-3ubuntu2`, from the Launchpad API); `mkvdts2ac3` `1.6.0` (latest tag; tags 1.6.0, 1.5.7, 1.5.6). The Hub image is tagged only `latest` (no version). VERSION for bake = `8.0.1` (the main tool) |
| Renovate | `VERSION` follows the apt package, so there is no clean datasource (`valkey` uses the same Ubuntu-tied approach: comment with repology depName `ubuntu_26_04/ffmpeg`, `versioning=loose`, and a note that the Ubuntu version is tied to the base image). `ARG MKVDTS2AC3_VERSION` `// renovate: datasource=github-tags depName=JakeWharton/mkvdts2ac3` |
| License | `ffmpeg` Debian build: GPL-2.0-or-later or LGPL depending on enabled codecs (UNVERIFIED for the Ubuntu build, check `ffmpeg -version` configuration and `/usr/share/doc/ffmpeg/copyright`). `mkvdts2ac3`: Apache-2.0 (GitHub SPDX). `mkvtoolnix`: GPL-2.0. Use `GPL-2.0-or-later` in bake (the combined work is not relicensed; document in README) |
| Source URL | https://ffmpeg.org (draft) plus https://github.com/JakeWharton/mkvdts2ac3 |
| Per-arch download | apt for amd64 and arm64 (`ffmpeg`, `mkvtoolnix`, `inotify-tools` 4.25.9.0-1 exist for Ubuntu 26.04). `mkvdts2ac3.sh` is a shell script, arch independent: `https://github.com/JakeWharton/mkvdts2ac3/archive/refs/tags/1.6.0.tar.gz` |
| Checksum | No upstream checksum. Pin sha256 of the 1.6.0 tag tarball: `f9f070c00648c1ea062ac772b160c61d1b222ad2b7d30574145bf230e9288982` (computed locally). apt packages are verified by apt signatures |
| Upstream Dockerfile | None public. Docker Hub description (the only documentation): "A Docker container designed to watch a directory and encode media files." Volumes `/config /watch /output /copy`; env `script` (`encode.sh` or `mkvdts2ac3.sh`), `parameters` (ffmpeg parameters, `;`-separated, e.g. `-map 0;-vcodec copy;-scodec copy;-acodec ac3;-b:a 640k`), `output_format` (e.g. `mkv`), `mkvdts2ac3_params` (`;`-separated, e.g. `--compress none;-d;-n;-w /output;--new`) |
| mkvdts2ac3.sh | Needs `mkvmerge`, `mkvextract`, `ffmpeg` (`checkdep` calls), plus `rsync`, `du`, `nice` and `perl` for progress output. Flags confirmed in the script: `--compress MODE`, `-d` (drop DTS), `-n` (no AC3 if present?), `-w` (working dir), `--new` (UNVERIFIED meanings of `-n`, `--new` beyond the Hub example; read `--help` of the script during the build) |
| Ports | None (draft: none). The draft's tcp probe requirement does not apply |

## 2. Target layout

- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`
- `scripts/encode.sh` and `scripts/process-file.sh`: helper scripts used by the watcher (the allow-list copies `scripts/`; installed to `/scripts/`). No `defaults/`, no `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (draft: ubuntu alone is enough; confirmed). Closest siblings: `apps/valkey` (pinned apt version with `PACKAGE_VERSION`, `health/` dir) and `apps/beets`, `apps/bazarr` (ffmpeg via apt). `jq`, `coreutils`, `curl`, `tar`, `xz-utils` are already in the base; `perl-base` is part of Ubuntu minimal; `rsync` and `mkvtoolnix` are not listed in the base: install them.

## 4. Dockerfile

1. `ARG VERSION`, `ARG PACKAGE_VERSION`, `ARG MKVDTS2AC3_VERSION`, `ARG MKVDTS2AC3_SHA256`, `ARG TARGETARCH`; `USER root`.
2. Version guard like `apps/valkey`, adjusted for the apt epoch: `p="${PACKAGE_VERSION#*:}"; test "${p%%-*}" = "${VERSION}"` (PACKAGE_VERSION `7:8.0.1-3ubuntu2`).
3. `apt-get update && apt-get install -y --no-install-recommends "ffmpeg=${PACKAGE_VERSION}" mkvtoolnix inotify-tools rsync` then `rm -rf /var/lib/apt/lists/*`. Do not pin mkvtoolnix and inotify-tools (they are not the tagged version). If the pinned ffmpeg no longer exists in the archive when building (security update), the build fails on purpose; Renovate must bump `PACKAGE_VERSION`.
4. Download `mkvdts2ac3` tarball, verify `echo "${MKVDTS2AC3_SHA256}  /tmp/m.tar.gz" | sha256sum -c -`, extract only `mkvdts2ac3.sh` and `LICENSE.txt`: `tar xzf /tmp/m.tar.gz -C /tmp --strip-components=1 --wildcards '*/mkvdts2ac3.sh' '*/LICENSE.txt'`; `install -m 0755 /tmp/mkvdts2ac3.sh /app/mkvdts2ac3.sh`; `mkdir -p /usr/share/licenses/ffmpeg-mkvdts2ac3 && cp /tmp/LICENSE.txt /usr/share/licenses/ffmpeg-mkvdts2ac3/mkvdts2ac3-LICENSE.txt` (Apache license text must ship because only part of the archive is extracted). Also copy `/usr/share/doc/ffmpeg/copyright` and `/usr/share/doc/mkvtoolnix/copyright` references (Ubuntu already ships them under `/usr/share/doc`; no extra copy needed).
5. `chown -R apps:apps /app`, `rm -rf /tmp/*`.
6. `ENV HOME=/config TMPDIR=/tmp`; `USER apps`; `COPY --chmod=0755 . /`; no `EXPOSE` (no ports); `VOLUME /config`; `WORKDIR /config`. Declare `VOLUME` only for `/config`: `/watch`, `/output`, `/copy` are user mounts documented in settings.yaml (they are created with `mkdir -p` if absent but writable only when mounted).

## 5. docker-bake.hcl

`APP="ffmpeg-mkvdts2ac3"`; `VERSION` default `8.0.1` preceded by the comment `// NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile` and `// renovate: datasource=repology depName=ubuntu_26_04/ffmpeg versioning=loose` (copy the way `apps/valkey/docker-bake.hcl` handles it, including its disabled-Repology TODO if still present); `PACKAGE_VERSION` default `7:8.0.1-3ubuntu2`; `MKVDTS2AC3_VERSION` default `1.6.0` (comment `// renovate: datasource=github-tags depName=JakeWharton/mkvdts2ac3`); `MKVDTS2AC3_SHA256`; `LICENSE="GPL-2.0-or-later"` (UNVERIFIED; see section 1); `SOURCE="https://ffmpeg.org"`. Targets: `docker-metadata-action`, `image` (args VERSION, PACKAGE_VERSION, MKVDTS2AC3_VERSION, MKVDTS2AC3_SHA256; OCI labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64, arm64), `group "default"`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Header and `schema_version: 1`; `upstream_env_url: "https://ffmpeg.org"` (equal to `SOURCE`).
- ports: none, so write `ports: []`. UNVERIFIED that the schema accepts an empty list: check a sibling without ports (for example `apps/irqbalance`, `apps/lvm-disk-watcher`).
- env (names kept lowercase as on the Hub image for drop-in compatibility; defaults match `start.sh`):
  - `script` default `mkvdts2ac3.sh` (`encode.sh` or `mkvdts2ac3.sh`), required false
  - `parameters` default `""`, required false (ffmpeg parameters separated by `;`)
  - `output_format` default `mkv`, required false
  - `mkvdts2ac3_params` default `""`, required false (separated by `;`)
  - `TZ` default `Etc/UTC`, required false
- volumes: `/config` required true; `/watch`, `/output`, `/copy` required false.
- dependencies: none.

## 7. start.sh

Own implementation (the Hub scripts are not public). Contract, to be documented in the comments:

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config /watch /output /copy /tmp/work
script="${script:-mkvdts2ac3.sh}"; fmt="${output_format:-mkv}"
# split ';' separated option strings into arrays (never eval them)
IFS=';' read -r -a ff_params <<< "${parameters:-}"
IFS=';' read -r -a mk_params <<< "${mkvdts2ac3_params:-}"
export script fmt   # used by /scripts/process-file.sh; arrays are re-read from env there
process() { /scripts/process-file.sh "$1" || echo "failed: $1" >&2; }
# process files already present (idempotent restart)
find /watch -type f \( -iname '*.mkv' -o -iname '*.avi' -o -iname '*.mp4' \) -print0 | while IFS= read -r -d '' f; do process "$f"; done
exec inotifywait -m -r -e close_write -e moved_to --format '%w%f' /watch | while IFS= read -r f; do process "$f"; done
```
`process-file.sh` behavior (design; the Hub image's exact semantics are UNVERIFIED): for `encode.sh` run `ffmpeg -nostdin -i "$f" "${ff_params[@]}" "/output/${name}.${fmt}"`; for `mkvdts2ac3.sh` run `/app/mkvdts2ac3.sh "${mk_params[@]}" "$f"` with the working directory `-w /tmp/work` unless the user supplied `-w`; on success move the original to `/copy` (if mounted) and write results to `/output`; on failure leave the file and log the error. Rules: no writes to `/app`; scratch in `/tmp` (large temp files, see section 10); no secrets involved; quote every variable; parameters are never `eval`'d, so special characters survive. `exec` is used for the long-running watcher (final pipeline process); for correct signal handling replace the final pipeline by `exec inotifywait ... > /tmp/events.fifo` plus a reader loop if the pipeline form does not stop on SIGTERM (decide while testing). Because the script starts with no mounted `/watch`, it simply idles.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
# Note: app exposes no ports (directory watcher); minimal smoke test via binaries and scripts.
filePaths:
- /usr/bin/ffmpeg
- /usr/bin/mkvmerge
- /usr/bin/inotifywait
- /app/mkvdts2ac3.sh
- /start.sh
runners:
- entrypoint: ffmpeg -version
- entrypoint: mkvmerge --version
```
Port probes are not applicable (settings.yaml lists no ports). The `runners` form copies `apps/bookstack/container-test.yaml`; verify the schema key names (`runners`, `entrypoint`, `mainRunner`) against the forgetool schema before use. The DB exception does not apply (no DB).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/config` (Hub volume, contents UNVERIFIED) | `/config` (ffmpeg and mkvtoolnix write nothing there by default; kept for compatibility) |
| `/watch`, `/output`, `/copy` | User mounts; must be writable by UID 568 (document `fsGroup`/chown on the host, TrueCharts used root) |
| mkvdts2ac3 working files (`-w`) | `/tmp/work` (tmpfs) unless the user overrides; very large files can exhaust tmpfs, so document mounting an emptyDir or volume on `/tmp` |
| ffmpeg stats, `~/.cache` | `HOME=/config` (no cache is written) |

Draft: TrueCharts runs as root. We run as UID 568; files created in `/output` and `/copy` are owned by 568 (differs from the root-owned files of the old chart). Not privileged. `readOnlyRootFilesystem` is fine as long as `/tmp` and the three mounts are writable.

## 10. Risks, caveats and open questions

- No public source: behavior is reconstructed from the Hub README; exact semantics of `/copy`, `encode.sh` output naming and `--new` are UNVERIFIED. Confirm with the user before treating this as a drop-in replacement.
- The Hub image is single-maintainer and amd64 only (last push 2020-12-20); this plan produces an arm64 build as well because apt packages exist for it (UNVERIFIED on arm64).
- `mkvdts2ac3` last release 2021-08 (Apache-2.0, unmaintained); depends on `mkvmerge -V` output parsing, which may break with MKVToolNix 97.0 (Ubuntu 26.04, `97.0-1build1`). Test with a real DTS sample.
- DTS to AC3 conversion needs an ffmpeg with the `ac3` encoder and a `dca` decoder: both are in the Ubuntu build normally (UNVERIFIED, check `ffmpeg -encoders | grep ac3`).
- apt pin of `ffmpeg` can break builds when Ubuntu publishes a security revision; Renovate cannot see it reliably (repology note in `apps/valkey`).
- License: GPL status depends on the Ubuntu ffmpeg build; confirm.
- Transcoding needs CPU, RAM and a large `/tmp` area.
- The draft's "HTTP health checks will not work" is correct; only file and process checks are used.

## 11. Build and test steps

```sh
cd apps/ffmpeg-mkvdts2ac3 && docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ffmpeg-mkvdts2ac3-probe --read-only --tmpfs /tmp \
  -v ffmpeg-mkvdts2ac3-probe-config:/config -v /tmp/fm-watch:/watch -v /tmp/fm-out:/output -v /tmp/fm-copy:/copy ffmpeg-mkvdts2ac3:8.0.1
docker logs -f ffmpeg-mkvdts2ac3-probe
forgetool containers test --image ffmpeg-mkvdts2ac3:8.0.1 --config ./apps/ffmpeg-mkvdts2ac3/container-test.yaml
docker rm -f ffmpeg-mkvdts2ac3-probe; docker volume rm ffmpeg-mkvdts2ac3-probe-config
```
Expected readiness signal: the container stays running and `inotifywait` reports `Watches established` (printed by `-m` on stderr). Functional check by hand: drop a short MKV with a DTS track into `/watch` and confirm an AC3 track appears (`mkvmerge -i` on the result) and the original lands in `/copy`. Also run the empty-`/config` case (default) and one with `script=encode.sh output_format=mkv parameters="-map 0;-c copy"`.

## 12. PR checklist

- Branch `feat/add-ffmpeg-mkvdts2ac3`; commit and PR title `feat(ffmpeg-mkvdts2ac3): add new container`.
- PR template filled in; Notes include `🤖 This PR is AI generated.` and a statement that this is a reimplementation.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Check: `PACKAGE_VERSION` matches `VERSION`, renovate comments, `USER apps`, `COPY --chmod=0755 . /`, empty `/config`, read-only rootfs.
- Untested until built: everything below the plan: the apt pin, arm64, DTS conversion on MKVToolNix 97, graceful shutdown of the watcher, compatibility of env names with the old Hub image.
