# owncast — implementation plan
> Source: ./draft.md · Target: apps/owncast/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `0.3.0` (tag `v0.3.0`, Latest, changelog dated 2026-09-03; draft tag `0.3.0`, same) |
| Renovate | `datasource=github-releases depName=owncast/owncast versioning=semver` |
| License | MIT (README: "Distributed under the MIT License"), SPDX `MIT` |
| Source URL | https://github.com/owncast/owncast |
| Docs | https://owncast.online/docs/ |
| amd64 asset | https://github.com/owncast/owncast/releases/download/v0.3.0/owncast-0.3.0-linux-64bit.zip |
| arm64 asset | https://github.com/owncast/owncast/releases/download/v0.3.0/owncast-0.3.0-linux-arm64.zip |
| Other assets (verified) | linux-32bit, linux-arm7, macOS-64bit, macOS-arm64 zips. No checksum file in the asset list. |
| Checksum source | None published; cannot verify the zip (comment it in the Dockerfile). |
| Zip layout | UNVERIFIED (expect the `owncast` binary plus docs/license). Check with `unzip -l`. |
| Upstream Dockerfile reviewed | `v0.3.0/Dockerfile`: build stage `golang:alpine` (CGO on, static link, ldflags version), runtime `alpine:3.24.0` with `ffmpeg ffmpeg-libs ca-certificates`, user `owncast` UID 101, `WORKDIR /app`, `/app/data` created, `EXPOSE 8080 1935`, `ENTRYPOINT ["/app/owncast"]`, no VOLUME. Header says the Dockerfile is a convenience, not tested. |
| Ports | 8080/tcp web + HLS (default `--webserverport`), 1935/tcp RTMP ingest (default `--rtmpport`). Admin at `/admin`. |
| Runtime flags (verified) | `--database` (default `data/owncast.db`), `--webserverport` (8080), `--webserverip` (no default stated), `--rtmpport` (1935), `--backupdir`, `--logdir`, `--adminpassword`, `--streamkey`, `--enableVerboseLogging`, `--restoreDatabase`. Port and IP flags are saved to the database. |
| Env vars | Owncast documents flags, not env vars. None are listed in settings.yaml beyond `TZ`. |
| ffmpeg | Required for transcoding; installed from apt (draft). Exact ubuntu 26.04 package version UNVERIFIED. |

## 2. Target layout

```
apps/owncast/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (owncast creates its own data/DB on first start). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: Go release zip plus ffmpeg from apt, nothing else. `unzip`, `curl`, `ca-certificates` are already in the base, so apt adds only `ffmpeg`. Closest siblings: `apps/adguardhome-sync` (release archive) and `apps/airsonic-advanced` / `apps/bazarr` (ffmpeg from apt, left unpinned there). The base is glibc, so the upstream musl/alpine note does not apply; the release zip is built by upstream CI and its libc linkage is UNVERIFIED (check with `ldd`/`file` in round 1; if it only runs on musl, fall back to a Go build stage per `go-runtime.instructions.md`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`.
2. `RUN set -eux; apt-get update; apt-get install -y --no-install-recommends ffmpeg; rm -rf /var/lib/apt/lists/*`. Not version-pinned: ffmpeg is a helper package whose version is not tied to `VERSION` (siblings do the same). Add `# hadolint ignore=DL3008`.
3. `RUN set -eux`:
   - `case "${TARGETARCH}" in amd64) A=64bit;; arm64) A=arm64;; *) echo unsupported >&2; exit 1;; esac`
   - `curl -fsSL -o /tmp/owncast.zip "https://github.com/owncast/owncast/releases/download/v${VERSION}/owncast-${VERSION}-linux-${A}.zip"` (no checksum available; comment that).
   - `mkdir -p /tmp/owncast && unzip -q /tmp/owncast.zip -d /tmp/owncast`; copy the whole extracted tree to `/app/` (`cp -r /tmp/owncast/. /app/`) because the zip may carry assets besides the binary (UNVERIFIED); `chmod 0755 /app/owncast`.
   - License: copy `LICENSE*` from the zip to `/usr/share/licenses/owncast/` if present, otherwise `curl` `https://raw.githubusercontent.com/owncast/owncast/v${VERSION}/LICENSE`.
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/*`.
4. `USER apps`; `COPY --chmod=0755 . /`; `WORKDIR /config`.
5. `EXPOSE 8080 1935`; `VOLUME /config`.

## 5. docker-bake.hcl

`APP=owncast`; `VERSION` with `// renovate: datasource=github-releases depName=owncast/owncast versioning=semver` default `"0.3.0"`; `LICENSE="MIT"`; `SOURCE="https://github.com/owncast/owncast"`. Standard four targets plus `group "default"` per `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/owncast/owncast"
ports:
  - port: 8080
    protocol: tcp
    required: false
  - port: 1935
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Ports and RTMP/web values are changed through the admin UI or `--webserverport`/`--rtmpport` flags, not env, so no invented env vars. Admin password and stream key are intentionally not exposed as env (the flags would put secrets on the process list). `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# Owncast keeps its database, HLS output and backups relative to the working directory.
cd /config
mkdir -p /config/data

exec /app/owncast
```

Idempotent; empty `/config` works because owncast creates `data/owncast.db` itself (UNVERIFIED, check in round 1). Nothing is written to `/app`. Open item: HLS segments are written to `hls/` under the working dir; to keep high-write ephemeral data off the persistent volume, evaluate `ln -sfn /tmp/hls /config/hls` with `mkdir -p /tmp/hls` (UNVERIFIED that owncast tolerates a symlink or does not recreate the directory). Servers must bind all interfaces: the `--webserverip` default is not stated, so verify from outside the container that 8080 and 1935 are reachable (not only localhost).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
- port: '1935'
http:
- port: '8080'
  path: /
filePaths:
- /app/owncast
- /usr/bin/ffmpeg
- /usr/share/licenses/owncast
```

Both ports declared in settings.yaml are probed. The `timeoutSeconds` value is a guess from siblings with similar Go servers (UNVERIFIED; adjust after measuring startup). The test passes no env; owncast needs none. A `/api/status` probe is plausible but UNVERIFIED, so `/` is used.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: `data/` (SQLite DB, uploads), `hls/` (stream segments), backups and logs, all relative to the working dir. Remapped by running with cwd `/config`. Draft's `/app/data` PVC becomes `/config/data` (the chart's mount must change). ffmpeg writes temp files to `/tmp` (tmpfs).
- Draft says chart runs UID 0 and writable rootfs: not needed. Run as `apps` (568), read-only rootfs OK given `/config` and `/tmp` are writable. Ports 8080 and 1935 are unprivileged.
- No privileged mode, no GPU. RTMP is TCP only.

## 10. Risks, caveats and open questions

- Draft caveats: RTMP 1935 must be reachable by the streaming software; change the default admin credentials on first login (upstream default admin credentials are not verified here, so do not state them in docs). HLS transcoding is CPU heavy and wants fast disk; GPU acceleration needs extra setup and is out of scope.
- No upstream checksum for the zip; integrity relies on HTTPS and pinned version.
- Zip layout, libc linkage, ffmpeg PATH discovery (upstream docs mention an FFmpeg path setting in Server Setup), data dir behavior are all UNVERIFIED.
- `ffmpeg` apt version is unpinned; document the ubuntu 26.04 version once seen.
- Streaming latency/IO on `/config`; consider the `/tmp/hls` symlink (read-only rootfs tmpfs size limits matter for HLS).
- No hard blockers: both arches available.

## 11. Build and test steps

```sh
cd apps/owncast
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name owncast-probe --read-only --tmpfs /tmp \
  -v owncast-probe-config:/config owncast:0.3.0
docker logs -f owncast-probe
docker exec owncast-probe ls -la /config /config/data
# from outside: curl -fsS http://<container-ip>:8080/ ; nc -zv <container-ip> 1935
forgetool containers test --image owncast:0.3.0 --config ./apps/owncast/container-test.yaml
docker rm -f owncast-probe; docker volume rm owncast-probe-config
```

Expected readiness signal: the Owncast startup log announcing the web server on 8080 and RTMP server on 1935 (exact wording UNVERIFIED), no ffmpeg-not-found errors, process alive. Restart on the same volume to confirm the DB is reused. Optional manual extra: push a test RTMP stream with ffmpeg and check `/hls`.

## 12. PR checklist

- Branch `feat/add-owncast`, commit/PR title `feat(owncast): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes; check only applicable boxes.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Confirm VERSION alignment, `bake --print`, `USER apps`, license shipped, 8080 and 1935 probed.
- Untested at planning time: docker build, arm64, zip layout and libc linkage, ffmpeg detection, read-only rootfs behavior, real streaming through RTMP/HLS.
