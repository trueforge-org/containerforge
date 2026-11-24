# automatic-ripping-machine — implementation plan
> Source: ./draft.md · Target: apps/automatic-ripping-machine/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts
| Item | Value |
|---|---|
| Version | 2.24.4 (GitHub "Latest" release, published 3 Oct; matches chart tag) |
| Renovate | datasource=github-releases, depName=automatic-ripping-machine/automatic-ripping-machine, versioning=semver (tags bare) |
| License | MIT (LICENSE file: Benjamin Bryan 2016, Andrew Sneed 2022). MakeMKV and HandBrake carry their own licenses (see section 10) |
| Source | https://github.com/automatic-ripping-machine/automatic-ripping-machine |
| Download | source tarball https://github.com/automatic-ripping-machine/automatic-ripping-machine/archive/refs/tags/${VERSION}.tar.gz (arch-neutral Python app); native tools via apt/source |
| Checksum | none published: UNVERIFIED |
| Upstream Dockerfile reviewed | @a380622: base `automaticrippingmachine/arm-dependencies:1.8.0` (holds the native toolchain), app copied to /opt/arm, runs as root with `/sbin/my_init` (runit), EXPOSE 8080, creates /home/arm, /home/arm/config, /mnt/dev/sr0..sr20 and fstab entries, udev rules symlinked, services armui + udev |
| Ports | 8080 web UI (default login admin/password per wiki) |
| Env vars (wiki) | ARM_UID, ARM_GID (must match owner of mounted dirs), TZ |
| Paths (wiki) | /home/arm (state, media/{raw,transcode,completed}, music, logs), /etc/arm/config (arm.yaml, apprise.yaml, abcde.conf). Devices `--device /dev/srN`. Wiki run command does not show --privileged |

## 2. Target layout
Dockerfile, docker-bake.hcl, settings.yaml, container-test.yaml, start.sh, defaults/ (arm.yaml, apprise.yaml, abcde.conf seeds taken from the repo's setup/ dir at the tag, copied at build into /defaults). No DOWNSTREAM_CHANGES.md.

## 3. Base image
`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (draft). Python compatibility of ARM's requirements.txt with 3.15 is UNVERIFIED; fallback `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` with apt python3. Closest siblings: apps/bazarr (python), apps/pyload-ng (python plus system tools), apps/unrar. Note: apps/ does not contain handbrake, makemkv or abcde, so all of them are new here.

## 4. Dockerfile
1. `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. apt (check against base first; pin where practical): `handbrake-cli ffmpeg abcde lsdvd eject cd-discid cdparanoia flac imagemagick libdvd-pkg(optional, UNVERIFIED legality) udev(not usable rootless) git curl libudev-dev libcurl4-openssl-dev` (draft's inferred list plus ARM's arm-dependencies image contents, which must be read from its Dockerfile: UNVERIFIED). HandBrake from apt: version not pinned to VERSION (not the app).
3. MakeMKV: built from source in a separate build stage (makemkv-oss and makemkv-bin from makemkv.com forum tarballs; versions and checksums UNVERIFIED). Recommended default: DO NOT bundle MakeMKV in the published image (proprietary makemkv-bin, redistribution terms unclear; see section 10). Ship an optional build stage controlled by `ARG WITH_MAKEMKV=false`.
4. App: download tag tarball to /app/arm; `pip install -r requirements.txt` into a new venv under /app/venv-arm at build (python-runtime rules: never touch /app/venv at runtime; pip cache to /tmp via `PIP_CACHE_DIR=/tmp/pip`).
5. License files to /usr/share/licenses/automatic-ripping-machine/ (ARM MIT, HandBrake GPL notice).
6. ENV `HOME=/config`, `ARM_CONFIG_DIR=/config/arm` (UNVERIFIED: ARM reads paths from arm.yaml, not env; do not declare unless confirmed).
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl
APP=automatic-ripping-machine; VERSION "2.24.4" with `// renovate: datasource=github-releases depName=automatic-ripping-machine/automatic-ripping-machine versioning=semver`; LICENSE "MIT"; SOURCE "https://github.com/automatic-ripping-machine/automatic-ripping-machine". Standard targets + default group; image-all amd64+arm64 (arm64 stays unvalidated if MakeMKV is excluded). `docker buildx bake --print`.

## 6. settings.yaml
Header, schema_version 1, upstream_env_url = SOURCE. ports: 8080/tcp required false. env: TZ; ARM_UID and ARM_GID are consumed by the upstream init (my_init scripts), which this image does not run; do NOT list them unless start.sh implements them (the container runs as the fixed apps UID; mounts must be owned accordingly). volumes: /config required true (single root for arm.yaml, db, logs, media); document optional separate mounts /config/media and /config/music for large output. dependencies: none.

## 7. start.sh
Seed /config/arm/{arm.yaml,apprise.yaml,abcde.conf} from /defaults only when missing; rewrite path keys in the seeded arm.yaml (RAW_PATH, TRANSCODE_PATH, COMPLETED_PATH, LOGPATH, DBFILE, etc., names UNVERIFIED, read arm.yaml) to /config/...; create /config/{media/{raw,transcode,completed},music,logs,db}; cache in /tmp. Launch the Flask UI on 0.0.0.0:8080 (ARM's `armui` runit script is scripts/docker/runsv/armui.sh; read it for the exact command, UNVERIFIED) with `exec`. Disc insertion triggering normally comes from udev rules calling `arm` scripts; udev does not run rootless, so provide a polling fallback (not an upstream feature: needs design, open question) or document manual start.

## 8. container-test.yaml
Header; `timeoutSeconds: 120`; `tcp: - port: '8080'`; `filePaths`: /app/arm/arm/runui.py (UNVERIFIED path), /usr/share/licenses/automatic-ripping-machine/LICENSE; `runners`: `HandBrakeCLI --version`, `ffmpeg -version`, `abcde -v`. No drive is needed for these.

## 9. Rootless and read-only-rootfs adaptations
| Upstream write path | Remap |
|---|---|
| /home/arm (media, music, logs, db) | /config subdirs |
| /etc/arm/config | /config/arm |
| /mnt/dev/srN mount points and fstab edits | not possible read-only/rootless; rip direct from /dev/srN (MakeMKV/HandBrake read raw devices) and drop auto-mount |
| udev rules and my_init/runit | removed; single start.sh |
| git safe.directory, global git config | HOME=/config or skip |
| pip/uv/HandBrake caches | /tmp |
Draft expects root, rw rootfs and device access. Rootless is only partially possible: the apps user needs the device group (e.g. `--group-add` the optical device gid) and `--device /dev/sr0`; no `--privileged`. Eject needs the same access.

## 10. Risks, caveats and open questions
- MakeMKV licensing/redistribution (draft caveat) and no apt package: recommended exclusion; without it, DVD/Blu-ray ripping is reduced (HandBrake plus libdvdcss legality is the user's concern).
- Hardware-bound: ripping cannot be tested in CI; only startup and UI are testable.
- udev-driven auto-start does not work rootless; open design question.
- arm-dependencies image contents, ARM runtime paths, python 3.15 compatibility UNVERIFIED.
- Long, large build if MakeMKV is compiled.
- Default admin/password login must be changed (security note for docs).

## 11. Build and test steps
```sh
cd apps/automatic-ripping-machine
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name automatic-ripping-machine-probe --read-only --tmpfs /tmp -v automatic-ripping-machine-probe-config:/config automatic-ripping-machine:2.24.4
docker logs -f automatic-ripping-machine-probe   # expect Flask/waitress listening on 0.0.0.0:8080, DB created in /config, no permission errors
docker rm -f automatic-ripping-machine-probe; docker volume rm automatic-ripping-machine-probe-config
forgetool containers test --image automatic-ripping-machine:2.24.4 --config ./apps/automatic-ripping-machine/container-test.yaml
```
Manual optical-drive test requires a host drive: not part of the protocol.

## 12. PR checklist
- Branch feat/add-automatic-ripping-machine; commit `feat(automatic-ripping-machine): add new container`; PR template; `🤖 This PR is AI generated.` in Notes.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (user signs).
- Untested: build, rip on real hardware, udev replacement, MakeMKV exclusion, arm64. State this honestly in the PR.
