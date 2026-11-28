# aria2 — implementation plan
> Source: ./draft.md · Target: apps/aria2/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.37.0`. Latest upstream release is `release-1.37.0`, published 2023-11-15. Source: https://api.github.com/repos/aria2/aria2/releases/latest (read via `gh api`), https://github.com/aria2/aria2/releases/tag/release-1.37.0 |
| Draft image tag | Chart uses `ghcr.io/p3terx/aria2-pro:latest`. That is a third-party community image, not the aria2 release. The ContainerForge image builds aria2 from the Ubuntu package. |
| Renovate | `datasource=github-releases depName=aria2/aria2 versioning=loose` (tags are `release-X.Y.Z`; if renovate does not strip the `release-` prefix, add `extractVersion=^release-(?<version>.*)$`; check a sibling with a prefixed tag) |
| Ubuntu package | `aria2 1.37.0+debian-4`, resolute (26.04). Listed on https://packages.ubuntu.com/resolute/aria2 (page shows one version for all arches; amd64 and arm64 both expected, not individually confirmed). |
| License | GPL-2.0 (GitHub license API `spdx_id`: `GPL-2.0`). The `COPYING` file is in the tag. Source: https://api.github.com/repos/aria2/aria2/license |
| Source URL | https://github.com/aria2/aria2 |
| Documentation | https://aria2.github.io/manual/en/html/ (not read in full; options below are from upstream image config only) |
| Download (binary) | Apt package on ubuntu. No prebuilt upstream binary used. Upstream release assets are source tarballs (`aria2-1.37.0.tar.{gz,bz2,xz}`) and Windows/Android zips only. |
| Checksum source | None verified. No checksum file appears in the release asset list. Apt verifies the package signatures. |
| Upstream image reviewed | P3TERX/Aria2-Pro-Docker at commit 4ec58da, https://github.com/P3TERX/Aria2-Pro-Docker/blob/4ec58da/Dockerfile. `FROM p3terx/s6-alpine`, `apk add jq findutils`, `curl -fsSL git.io/aria2c.sh \| bash` (remote script; what it installs is UNVERIFIED), `COPY rootfs /`. |
| Upstream run command | `exec s6-setuidgid p3terx aria2c --conf-path=/config/aria2.conf` (https://api.github.com/repos/P3TERX/Aria2-Pro-Docker/contents/rootfs/etc/services.d/aria2/run?ref=4ec58da) |
| Upstream init | `rootfs/etc/cont-init.d/08-config`: creates `ARIA2_CONF_DIR`, `SCRIPT_DIR`, `DOWNLOAD_DIR`; creates an empty `aria2.session` if missing; downloads profile files and tracker list unless `UPDATE_TRACKERS` is `false`/`disable`. The remote profile URL inside `DOWNLOAD_PROFILE` was not read (UNVERIFIED), and the plan does not copy that behaviour. |
| Ports | 6800 (JSON-RPC, `RPC_PORT`), 6888 TCP and UDP (BitTorrent, `LISTEN_PORT`). From upstream Dockerfile EXPOSE. |
| Env vars (real, upstream) | `RPC_PORT=6800`, `LISTEN_PORT=6888`, `RPC_SECRET` (empty), `UPDATE_TRACKERS=true`, `CUSTOM_TRACKER_URL`, `UMASK_SET`, `PUID`, `PGID`, `DISK_CACHE`, `IPV6_MODE`, `SPECIAL_MODE`, `RCLONE_CONFIG=/config/rclone.conf`. Upstream chart values also show `RPC_SECRET` as a placeholder. |
| Data / config paths (upstream) | `/config` (aria2.conf, aria2.session, dht.dat, dht6.dat, scripts), `/downloads` (VOLUME). |
| Dependencies | None. The AriaNg web front end is a separate container (out of scope). |
| arm64 | Apt package for arm64 on resolute expected; not individually confirmed on the page. |
| Blockers | None found. |

## 2. Target layout

- `apps/aria2/Dockerfile`
- `apps/aria2/docker-bake.hcl`
- `apps/aria2/settings.yaml`
- `apps/aria2/container-test.yaml`
- `apps/aria2/start.sh`
- `apps/aria2/defaults/aria2.conf` (seeded into `/config` only when missing; reason: aria2 needs a config file with RPC and paths; ship it in `defaults/` so `COPY . /` brings it in, which `.dockerignore` allows)

No `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the final stage. Apt has the package on resolute, so the ubuntu base is enough (draft: "Runtime image: none"). Closest sibling: `apps/adguardhome-sync` (ubuntu base, `USER root` for setup, `USER apps` at the end). A sibling with an apt-installed daemon and a config file is the better template; pick one from `apps/` at build time (for example `apps/valkey`, which pins an apt version and uses a health dir, as the rules mention).

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. Install the apt package with a pin that matches `VERSION` (the Dockerfile rule for apt-installed software). The version string is `1.37.0+debian-4`, so `VERSION=1.37.0` is the upstream version and the apt build string is the Ubuntu rebuild:

```dockerfile
ARG VERSION
ARG APT_VERSION=1.37.0+debian-4
USER root
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends "aria2=${APT_VERSION}"; \
    rm -rf /var/lib/apt/lists/*; \
    aria2c --version | head -1 | grep -q "aria2 version ${VERSION}"
```

The last line checks that the installed binary matches `VERSION`. Pin the Ubuntu rebuild string in `APT_VERSION` and check it against `VERSION` in the same RUN (the rebuild suffix can change; the check fails loudly if Ubuntu moves it).

3. Licence file for the image (the binary is from the Debian package and the upstream COPYING is in the tag):

```dockerfile
RUN set -eux; \
    mkdir -p /usr/share/licenses/aria2; \
    cp /usr/share/doc/aria2/copyright /usr/share/licenses/aria2/copyright
```

Confirm the Debian copyright path with `ls /usr/share/doc/aria2/` during the first build (UNVERIFIED path).

4. Runtime env, moving HOME and temp to ephemeral paths:

```dockerfile
ENV HOME=/config \
    RPC_PORT=6800 \
    LISTEN_PORT=6888
```

`HOME=/config` matches the sibling pattern. No cache goes to `/config`: aria2 keeps no cache. If a cache is added, point it at `/tmp`.

5. Tail:

```dockerfile
RUN install -d -o apps -g apps /config /downloads

USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 6800
EXPOSE 6888
EXPOSE 6888/udp

VOLUME /config
VOLUME /downloads
```

`install -d` creates both directories owned by `apps` (check whether the ubuntu base already creates `/config`; keep the line only if it does not).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "aria2"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=aria2/aria2 versioning=loose extractVersion=^release-(?<version>.*)$
  default = "1.37.0"
}

variable "LICENSE" {
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/aria2/aria2"
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

Notes: aria2 is GPL-2.0 "or later" in some files; confirm the COPYING text before choosing `GPL-2.0-only` versus `GPL-2.0-or-later` (the GitHub API reports `GPL-2.0`, so use the value the license API gives if the COPYING file does not settle it). `APT_VERSION` is not in bake; it is a Dockerfile `ARG` with a default, which keeps the bake file simple. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/aria2/aria2"
ports:
  - port: 6800
    protocol: tcp
    required: false
  - port: 6888
    protocol: tcp
    required: false
  - port: 6888
    protocol: udp
    required: false
env:
  - name: RPC_PORT
    default: "6800"
    required: false
  - name: LISTEN_PORT
    default: "6888"
    required: false
  - name: RPC_SECRET
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: UMASK
    default: "022"
    required: false
volumes:
  - path: /config
    required: true
  - path: /downloads
    required: false
dependencies: []
```

Notes: env names are only those the start script reads (`RPC_PORT`, `LISTEN_PORT`, `RPC_SECRET`, `UMASK` for the umask in `start.sh`). `UPDATE_TRACKERS`, `PUID`, `PGID`, `DISK_CACHE`, `IPV6_MODE`, `SPECIAL_MODE`, `RCLONE_CONFIG` are upstream-image only and are NOT listed unless `start.sh` reads them (do not invent env vars). `UMASK` default `022` mirrors upstream `UMASK_SET:-022`; name it `UMASK` only if `start.sh` reads it. Empty `RPC_SECRET` means no auth; the plan keeps it empty and documents that users should set it (the upstream chart uses a placeholder value).

## 7. start.sh

```bash
#!/usr/bin/env bash

umask "${UMASK:-022}"

mkdir -p /config /downloads

[ -f /config/aria2.conf ] || cp /defaults/aria2.conf /config/aria2.conf
[ -f /config/aria2.session ] || touch /config/aria2.session

args=()
[ -n "${RPC_SECRET:-}" ] && args+=("--rpc-secret=${RPC_SECRET}")

exec aria2c \
    --conf-path=/config/aria2.conf \
    --rpc-listen-port="${RPC_PORT:-6800}" \
    --listen-port="${LISTEN_PORT:-6888}" \
    --dir=/downloads \
    "${args[@]}"
```

Notes:
- `defaults/aria2.conf` must set `rpc-listen-all=true` (aria2 defaults to binding RPC on localhost only, which breaks use from other containers), `enable-rpc=true`, `save-session=/config/aria2.session`, `input-file=/config/aria2.session`, `dht-file-path=/config/dht.dat`, `dht-file-path6=/config/dht6.dat`, `rpc-secret` is not read from env by aria2, so `start.sh` passes `--rpc-secret` only when `RPC_SECRET` is set (the `args` array above; the secret is not written to a file; note it is visible in the process list, UNVERIFIED alternative). Verify each option name against `aria2c --help` in the build.
- Do not run the upstream tracker download or the remote profile step. Trackers are optional; if wanted later, add them to `defaults/` rather than fetching at start.
- `umask` line uses `UMASK` (only if the env is kept; see section 6).
- Seeding only when missing, so user edits in `/config/aria2.conf` survive restarts.
- `exec` so aria2c is PID 1 or under tini.
- Keep the runtime non-root (`apps`). No `s6-setuidgid` needed.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '6800'
- port: '6888'
http:
- port: '6800'
  path: /jsonrpc
filePaths:
- /usr/bin/aria2c
- /defaults/aria2.conf
- /usr/share/licenses/aria2/copyright
```

Notes:
- Every port in `settings.yaml` should have a probe (coverage rule). `6888/udp` cannot be probed by `tcp` or `http` in forgetool; record this as a gap and do not invent a UDP check (UNVERIFIED whether forgetool has a UDP probe type; check the schema at the URL above).
- `/config/aria2.conf` is only present after `start.sh` runs; `filePaths` runs against the image, so use `/defaults/aria2.conf` instead (the seeded file is created at runtime).
- The HTTP probe on `/jsonrpc` may return a non-200 for a GET (JSON-RPC expects POST). Confirm the status code during the first run; if it is not 200, use the tcp probe alone for 6800 and record why (do not weaken to a no-op).
- `timeoutSeconds: 60` is a placeholder; take the value used by the closest sibling.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (aria2.conf, aria2.session, dht.dat, dht6.dat, scripts) | Real persistent volume (`VOLUME /config`). Seeded in `start.sh` only when missing. |
| `/downloads` | Volume, owned by `apps`. Must be writable by the runtime user or downloads fail (draft caveat). |
| `/tmp` | Tmpfs under `--read-only --tmpfs /tmp`; aria2 has no cache. |
| `s6` supervision, `p3terx` user | Removed. Single process as `apps`. |

Read-only rootfs: aria2 writes only to `--dir=/downloads`, `/config` and the session files. The chart's `readOnlyRootFilesystem: false` default is no longer needed. Privileged: no. Rootless: yes (`USER apps`).

Ports below 1024 are not used, so no capability is needed.

## 10. Risks, caveats and open questions

- Apt pin drift: Ubuntu rebuilds change the `+debian-N` suffix; the Dockerfile check guards the version, but a rebuild may fail. This is the expected signal.
- The plan uses aria2 1.37.0 (2023 release). Newer aria2 releases are not published upstream; the Ubuntu package is the only current build path.
- BitTorrent 6888 TCP and UDP need forwarding for peer connectivity (draft caveat). Only a TCP probe is possible in tests.
- `RPC_SECRET` empty means RPC is unauthenticated on 6800. Document, do not change the default silently. Consider a required value in a follow-up.
- Upstream remote-profile and tracker download are not reproduced (UNVERIFIED what they fetched). Tracker updates are a deliberate omission; say so in the PR.
- `rpc-listen-all` must be set in the shipped config so the port binds 0.0.0.0 (network rule).
- AriaNg web UI is a separate container. Out of scope.
- No dependencies, no DB, so the DB-dependent exception does not apply.

## 11. Build and test steps

```sh
cd apps/aria2
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create aria2-probe-config
docker run --rm -d --name aria2-probe --read-only --tmpfs /tmp \
  -v aria2-probe-config:/config aria2:1.37.0
docker logs -f aria2-probe
docker exec aria2-probe aria2c --version
forgetool containers test --image aria2:1.37.0 --config ./apps/aria2/container-test.yaml
docker rm -f aria2-probe; docker volume rm aria2-probe-config
```

Use an empty `/config` volume per round. Readiness: process still running, port 6800 open (`ss -ltn` inside the container), and the aria2 log line that reports the listening port (UNVERIFIED exact text; check `docker logs` on the first run and record it here). Restart the container with the same volume to confirm the session and config persist.

Also run once with `-p 6800:6800 -p 6888:6888` and a curl JSON-RPC `aria2.getVersion` call from the host to prove the RPC is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-aria2`, commit and PR title `feat(aria2): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- DOWNSTREAM_CHANGES.md: not needed.
- Untested to state honestly (unless done): arm64 build and run, the UDP port, the JSON-RPC probe status, the `RPC_SECRET` option path, and the Debian copyright path.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; apt pin checked against `VERSION`; no assertion weakened.
