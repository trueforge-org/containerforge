# navidrome — implementation plan
> Source: ./draft.md · Target: apps/navidrome/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.64.2 (published 2026-09-24T23:26:20Z). Matches the draft. Source: https://api.github.com/repos/navidrome/navidrome/releases/latest |
| Chart image | Draft: `ghcr.io/navidrome/navidrome:0.64.2`. We build from the release assets instead. |
| Renovate | `datasource=github-releases depName=navidrome/navidrome versioning=semver` (tags carry the `v` prefix, so `VERSION = "v0.64.2"`) |
| License | GPL-3.0 (https://raw.githubusercontent.com/navidrome/navidrome/master/LICENSE: "GNU GENERAL PUBLIC LICENSE Version 3 (GPL-3.0)") |
| Source URL | https://github.com/navidrome/navidrome |
| Documentation | https://www.navidrome.org/docs (not read in this run) |
| Download amd64 (tar.gz, preferred) | https://github.com/navidrome/navidrome/releases/download/v0.64.2/navidrome_0.64.2_linux_amd64.tar.gz |
| Download arm64 (tar.gz, preferred) | https://github.com/navidrome/navidrome/releases/download/v0.64.2/navidrome_0.64.2_linux_arm64.tar.gz |
| Download amd64 (deb, draft) | https://github.com/navidrome/navidrome/releases/download/v0.64.2/navidrome_0.64.2_linux_amd64.deb |
| Download arm64 (deb, draft) | https://github.com/navidrome/navidrome/releases/download/v0.64.2/navidrome_0.64.2_linux_arm64.deb |
| Checksum source | `https://github.com/navidrome/navidrome/releases/download/v0.64.2/navidrome_checksums.txt`. amd64 deb `b9ecb35eb6e042d6b019d504c0df40fa676f9a5a18db6513f551e124af7085e3`, arm64 deb `42d635a28d04c2753a68d503b937cfee1bb6c660ea50a14dd92140331ce2e100`. tar.gz hashes are in the same file (not fetched in this run: read them from the file at build time). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/navidrome/navidrome/master/Dockerfile (summary via WebFetch). Final stage `alpine:3.22` with ffmpeg, mpv, sqlite, libwebp; binary copied to `/app/`; `ENV ND_MUSICFOLDER=/music ND_DATAFOLDER=/data ND_CONFIGFILE=/data/navidrome.toml ND_PORT=4533`; `EXPOSE ${ND_PORT}`; `VOLUME ["/data","/music"]`; no `USER` (runs as root); `ENTRYPOINT ["/app/navidrome"]`; no `CMD`. |
| Ports | 4533/http (EXPOSE and `ND_PORT`, confirmed) |
| Env vars (real, confirmed in Dockerfile) | `ND_MUSICFOLDER`, `ND_DATAFOLDER`, `ND_CONFIGFILE`, `ND_PORT` |
| Data / config write paths | Upstream `/data` (`ND_DATAFOLDER`), config file `/data/navidrome.toml` (`ND_CONFIGFILE`). Music `/music` (read). |
| arm64 | Yes (deb and tar.gz confirmed). |
| Dependencies | None required. Upstream image bundles ffmpeg and mpv for transcoding; not a dependency container. |

## 2. Target layout

- `apps/navidrome/Dockerfile`
- `apps/navidrome/docker-bake.hcl`
- `apps/navidrome/settings.yaml`
- `apps/navidrome/container-test.yaml`
- `apps/navidrome/start.sh`

Not needed: `defaults/` (Navidrome creates its database on first start, UNVERIFIED), `etc/`, `health/`, `root/` (never used), `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The upstream final stage is alpine, but the release binary is a static glibc build (upstream's final build stage verifies `xx-verify --static`), so it runs on Ubuntu. Closest sibling: `apps/adguardhome-sync` (Go binary in `/app`, port 8080).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`. Buildx `amd64`/`arm64` match the tar.gz asset names directly.
2. `USER root` for the download step, then `USER apps` at the end. No `apt-get`: the tar.gz route does not need dpkg. (If the deb route is used instead, `dpkg-deb -x` needs no extra packages in the base, but it is more moving parts.)
3. Download, verify, extract in `/tmp`:
   ```sh
   curl -fsSL -o /tmp/navidrome.tar.gz "https://github.com/navidrome/navidrome/releases/download/${VERSION}/navidrome_${VERSION#v}_linux_${TARGETARCH}.tar.gz"
   curl -fsSL -o /tmp/navidrome_checksums.txt "https://github.com/navidrome/navidrome/releases/download/${VERSION}/navidrome_checksums.txt"
   awk -v f="navidrome_${VERSION#v}_linux_${TARGETARCH}.tar.gz" '$2==f {print $1"  /tmp/navidrome.tar.gz"}' /tmp/navidrome_checksums.txt | sha256sum -c -
   ```
   Add a `test -s` guard on the awk output so an empty match fails the build (`sha256sum -c` on empty input exits 0).
4. Extract the binary only: `tar xzf /tmp/navidrome.tar.gz -C /app navidrome` (member name UNVERIFIED: confirm with `tar tzf` at build time; the deb path has the same unknown). Then `chmod 0755 /app/navidrome` and `chown apps:apps /app/navidrome`.
5. License: `mkdir -p /usr/share/licenses/navidrome && curl -fsSL -o /usr/share/licenses/navidrome/LICENSE https://raw.githubusercontent.com/navidrome/navidrome/${VERSION}/LICENSE`. Use the tag path so the license matches the binary. If the archive ships its own LICENSE, prefer that copy (UNVERIFIED).
6. `rm -f /tmp/navidrome.tar.gz /tmp/navidrome_checksums.txt`.
7. Environment (no `HOME` change needed; data lives in `/config`):
   ```dockerfile
   ENV ND_MUSICFOLDER=/music \
       ND_DATAFOLDER=/config \
       ND_CONFIGFILE=/config/navidrome.toml \
       ND_PORT=4533
   ```
   `ND_CACHEFOLDER` / cache location: UNVERIFIED env name and default. Set it to `/tmp/navidrome-cache` only after confirming the name in the upstream docs. Otherwise rely on the `--read-only --tmpfs /tmp` run to surface any write to the root filesystem.
8. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 4533
   VOLUME ["/config", "/music"]
   ```
   `COPY --chmod=0755 . /` is required and must stay. `/music` is a read-only mount in practice.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "navidrome"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=navidrome/navidrome versioning=semver
  default = "v0.64.2"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/navidrome/navidrome"
}
```

Then the default group and the `image`, `image-local` and `image-all` targets copied from `apps/adguardhome-sync/docker-bake.hcl`. `LICENSE` should be `GPL-3.0-only` only if the SPDX identifier is confirmed from the repo header; the fetched text says "GPL-3.0" without the suffix, so `GPL-3.0` is the safer value. Run `docker buildx bake --print` in `apps/navidrome`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/navidrome/navidrome"
ports:
  - port: 4533
    protocol: tcp
    required: true
env:
  - name: ND_MUSICFOLDER
    default: "/music"
    required: false
  - name: ND_DATAFOLDER
    default: "/config"
    required: false
  - name: ND_CONFIGFILE
    default: "/config/navidrome.toml"
    required: false
  - name: ND_PORT
    default: "4533"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /music
    required: false
dependencies:
  []
```

- The four `ND_*` names are confirmed from the upstream Dockerfile. Defaults match the Dockerfile except `ND_DATAFOLDER` and `ND_CONFIGFILE`, which are remapped from `/data` to `/config`.
- `TZ` is a common default, not confirmed as read by Navidrome; keep it only if sibling apps list it (they do).
- `/music` is listed as optional: the app starts without a library, it just has nothing to scan.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

cd /app
exec /app/navidrome
```

- Idempotent: `mkdir -p /config` on an empty volume. Navidrome creates `navidrome.db` and its config defaults on first start (UNVERIFIED for file names; check the first-run log).
- No writes to `/app`.
- The `ND_*` variables are read by the binary directly, so start.sh does not need to pass flags.
- Binds: Navidrome listens on `ND_PORT` on all interfaces by default (UNVERIFIED for the bind address; confirm with the run step, as the guidance requires `0.0.0.0`).
- `exec` hands PID 1 to the binary.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '4533'
http:
- port: '4533'
  path: /ping
filePaths:
- /app/navidrome
- /usr/share/licenses/navidrome/LICENSE
```

- Every port in `settings.yaml` (4533) has a `tcp` probe, plus an `http` probe. `/ping` is UNVERIFIED as an upstream endpoint (not fetched); replace it with the path confirmed at the run step before merging. Do not use an always-true check.
- No env var is required to start, so there is no required-env code path to add to `filePaths`.
- `timeoutSeconds: 180`: sibling `apps/babybuddy` uses 180; Navidrome's first start scans nothing without `/music`, so 180 is enough.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (`ND_DATAFOLDER`: database, cache, artwork) | `/config` |
| `/data/navidrome.toml` (`ND_CONFIGFILE`) | `/config/navidrome.toml` |
| Transcoding and cache scratch | `/tmp` (UNVERIFIED env name; see section 4) |
| `/music` (library, read only) | Volume mount, not written by the app |
| Runtime user | Upstream runs as root; this image runs as `apps` (568). Volume ownership of `/config` must allow `apps` to write. |
| `/app` | Read-only at runtime; binary only. |

Draft expectations reconciled: `runAsNonRoot` yes and `readOnlyRootFilesystem` yes match this plan. Not privileged, no host mounts, no extra persistence beyond `/config` and `/music`.

## 10. Risks, caveats and open questions

- **Music library required for use.** The chart mounts `/music`. Without it Navidrome starts but has nothing to scan (draft caveat).
- **Deb vs tar.gz.** The draft lists .deb assets; the plan uses tar.gz to avoid dpkg. Confirm the tar member layout at build time (UNVERIFIED).
- **Transcoding scratch.** Transcoding and cache need space; `/tmp` on `--tmpfs` may be small. Draft caveat, inferred. The cache env name is UNVERIFIED, so the default location may write under `/config` (check the run).
- **Upstream ships ffmpeg and mpv.** This image does not install them. Transcoding will not work unless ffmpeg is added (UNVERIFIED whether the release binary needs it at runtime; the upstream image installs it for transcoding). Decide before the PR.
- **Health endpoint.** `/ping` is UNVERIFIED; confirm.
- **License suffix.** `GPL-3.0` vs `GPL-3.0-only` not confirmed.
- No blockers: static Go binary, arm64 assets present, no dependency containers, no GPU, no privileged need.

## 11. Build and test steps

```sh
cd apps/navidrome
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name navidrome-probe --read-only --tmpfs /tmp \
  -v navidrome-probe-config:/config navidrome:v0.64.2
docker logs -f navidrome-probe
docker rm -f navidrome-probe; docker volume rm navidrome-probe-config
forgetool containers test --image navidrome:v0.64.2 --config ./apps/navidrome/container-test.yaml
```

Also run once with a music folder mounted (`-v /some/music:/music:ro`) to confirm the scan starts. Expected readiness signal: a "listening" or "server started" line on port 4533 (exact text UNVERIFIED; take it from the first run). The process stays up on an empty `/config` and on a restart with the same volume.

## 12. PR checklist

- [ ] Branch `feat/add-navidrome`, commit `feat(navidrome): add new container`, PR title the same.
- [ ] Notes section contains `🤖 This PR is AI generated.`
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; `license/cla` check shows status).
- [ ] PR template `.github/PULL_REQUEST_TEMPLATE.md` kept; only applicable boxes checked.
- [ ] Not tested: arm64 build, forgetool test run, transcoding (ffmpeg not installed), `/ping` path. Say so in the PR unless done.
- [ ] `docker buildx bake --print` run for the bake and Dockerfile changes.
