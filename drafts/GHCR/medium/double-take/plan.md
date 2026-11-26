# double-take — implementation plan
> Source: ./draft.md · Target: apps/double-take/ · Difficulty: medium (draft) — likely high in practice, see section 10 · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Fork used by the chart: `skrashevich/double-take`, image tag `v1.13.11` (chart values.yaml: `ghcr.io/skrashevich/double-take:v1.13.11@sha256:e91d1d4c144bcf9574cab0f37675cc525e78799706b47fdbee3eb1efa6f7b815`). Tag `v1.13.11` exists in the fork (git ref resolves). Fork's latest GitHub release is `v1.13.11.8`, published 2023-11-20. Upstream (`jakowenko/double-take`) latest release is `v1.13.2`, published 2025-08-18. Which tag the GHCR `latest` points to is UNVERIFIED. |
| Draft difference | Draft links the upstream release `v1.13.2` as the binary and the fork Dockerfile as the build. This plan builds the fork at `v1.13.11`, because the chart runs the fork image. Upstream `v1.13.2` is the fallback if the fork build is not viable. |
| Renovate | `datasource=github-tags depName=skrashevich/double-take versioning=loose` (the fork's release tags do not match its tag names; UNVERIFIED that Renovate sees `v1.13.11` correctly). |
| License | Upstream: MIT (GitHub API). Fork: UNVERIFIED (not fetched). Bake `LICENSE` must match the license of the code built; confirm in the fork's LICENSE before pinning. |
| Source URL | Fork: https://github.com/skrashevich/double-take. Upstream: https://github.com/jakowenko/double-take |
| Download | No prebuilt binary confirmed. Build from the fork's source at tag `v1.13.11` (commit `60c957d` is the Dockerfile the draft cites). Upstream release assets are UNVERIFIED (not listed). |
| Checksum source | None confirmed. Tag-pinned source archive (`archive/refs/tags/v1.13.11.tar.gz`) is the only content check; UNVERIFIED that a checksum is published. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/skrashevich/double-take/60c957d/.build/Dockerfile (multi-stage, see below). Entrypoint: https://raw.githubusercontent.com/skrashevich/double-take/60c957d/.build/entrypoint.sh. |
| Upstream build stages | `alpine:latest` (recognizer models via wget and bzip2); `golang:1.20-buster` (recognizer, go-face/dlib, `TARGETARCH`); `node:16` (better-sqlite3 native build with ccache); `node:16` (canvas native build, cairo/pango); `oven/bun` (Vue frontend); `node:16` (API npm install, copies in better-sqlite3 and the frontend `dist`); final `node:16-slim` with `NODE_ENV=production`, `WORKDIR /double-take`, `EXPOSE 3000`, `ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]`. No `USER` line in the final stage (upstream runs as root). |
| Entrypoint | Starts `/usr/local/bin/recognizer -cnn -port 8888 -models /opt/recognizer/models -storage /.storage -d` (or without `-cnn`), then the Node API. Watches `CONFIG_PATH` or `./.storage/config` (entrypoint.sh). |
| Port | 3000/http (Dockerfile EXPOSE 3000; chart `targetPort: 3000`, service `10200`). Recognizer listens on 8888 internally. |
| Env vars (real) | `CONFIG_PATH` (read by entrypoint.sh). `NODE_ENV=production` (Dockerfile). Other variables in the README are UNVERIFIED (README was not fully parsed). |
| Data / config paths | Upstream: `/.storage` (matches `/.storage/matches`, train `/.storage/train`, latest `/.storage/latest`, config `/.storage/config/config.yml`) (README lines 56, 107, 244–278). Chart mounts `persistence.data` at `/.storage`. Draft says move to `/config`. The recognizer `-storage` flag and the entrypoint watch paths hard-code `/.storage`. |
| Dependencies | None (embedded SQLite through `better-sqlite3`). Needs a camera/NVR source (Frigate MQTT `frigate/+/person/snapshot`) to do useful work (README). |
| Chart facts | values.yaml: probes http `/` (liveness, readiness, startup), service port 10200 to 3000, persistence `data` at `/.storage`. |

## 2. Target layout

- `apps/double-take/Dockerfile` (multi-stage: build stage on the same base, runtime stage on python-node)
- `apps/double-take/docker-bake.hcl`
- `apps/double-take/settings.yaml`
- `apps/double-take/container-test.yaml`
- `apps/double-take/start.sh` (replaces upstream `entrypoint.sh`; keeps the recognizer and API start, with paths remapped)
- `apps/double-take/defaults/` only if a default `config.yml` is seeded (see section 7). Not needed otherwise.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The upstream `.build/` folder is not copied; the repo's `include/.dockerignore` only passes `start.sh`, `defaults/`, `app/`, `etc/` and similar paths, so build sources must come from a build stage that fetches the tagged source.

## 3. Base image

Runtime: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`. Node in the base is 24 (per `apps/budge` comment, UNVERIFIED for the exact version). The fork needs Node 16 for `better-sqlite3` and `canvas`. This is the main risk (section 10). Closest siblings: `apps/budge` (node on python-node), `apps/changedetection`. Build stage: a `FROM` of the same base, or of `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` if a node 16 toolchain is installed from a pinned source. Decide after the spike in section 10.

## 4. Dockerfile

1. Build stage A (recognizer): `FROM golang:1.20-buster AS recognizer` is out of ContainerForge's base set; the Go build goes in its own stage and is copied with `COPY --from=` (dockerfile rule). Build the fork's `recognizer` with dlib (`go-face`) as upstream does, `ARG TARGETARCH`. Pin Go to 1.20 (UNVERIFIED that it still builds on Debian bookworm/trixie).
2. Build stage B (API and frontend): `ARG VERSION`, `USER root`. Fetch `https://github.com/skrashevich/double-take/archive/refs/tags/v${VERSION}.tar.gz` into `/tmp/src`. Install `build-essential`, `python3`, `libcairo2-dev`, `libpango1.0-dev`, `libjpeg-dev`, `libgif-dev`, `librsvg2-dev`, `ccache` only in this stage (exact list UNVERIFIED against `canvas`'s requirements).
3. `npm install` in `/tmp/src/api` with Node 16 for `better-sqlite3` and `canvas` (native modules); the frontend is built with `bun` (or a pinned `npm`/`vite` build if `bun` is not in the base; UNVERIFIED which tool the fork needs).
4. Final stage `FROM python-node`, `USER root`: `apt-get install -y --no-install-recommends libcairo2 libpango-1.0-0 libjpeg62-turbo libgif7 librsvg2-2` (runtime libs only; exact names UNVERIFIED on 26.04), copy the built `/double-take` tree with `COPY --from=`, the recognizer to `/usr/local/bin/recognizer`, and the models to `/opt/recognizer/models`.
5. Models (`recognizer-models` stage) come from upstream's wget step; the source URL is in the fork's Dockerfile (lines 2–11, not fully reviewed; UNVERIFIED checksum).
6. License: `install -D` of the fork's LICENSE to `/usr/share/licenses/double-take/LICENSE` (UNVERIFIED license file).
7. `ENV NODE_ENV=production CONFIG_PATH=/config/storage/config` only after section 7 is confirmed; keep `/app` read-only.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /double-take
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "double-take"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=skrashevich/double-take versioning=loose
  default = "1.13.11"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/skrashevich/double-take"
}
```

`LICENSE` is MIT only if the fork's license is MIT; upstream is MIT, the fork is UNVERIFIED. Then the four standard targets and the default group copied from `apps/budge/docker-bake.hcl`. Validate with `docker buildx bake --print`. The Dockerfile `ARG VERSION` must match.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/skrashevich/double-take"
ports:
  - port: 3000
    protocol: tcp
    required: true
env:
  - name: CONFIG_PATH
    default: "/config/storage/config"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only `CONFIG_PATH` is confirmed as read by `entrypoint.sh`. Do not add more variables until the README or source confirms them (UNVERIFIED). The recognizer's `-storage` path is a flag, not an env var, so it is not listed.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

store="/config/storage"
mkdir -p "${store}/matches" "${store}/train" "${store}/latest" "${store}/config"

# seed a default config only when missing (never overwrite user state)
if [ ! -s "${store}/config/config.yml" ] && [ -f /defaults/config.yml ]; then
  cp /defaults/config.yml "${store}/config/config.yml"
fi

cd /double-take
/usr/local/bin/recognizer -cnn -port 8888 -models /opt/recognizer/models -storage "${store}" -d &

export CONFIG_PATH="${CONFIG_PATH:-${store}/config}"
exec node server.js
```

Notes: the recognizer's `-storage` flag is remapped from `/.storage` to `/config/storage`, so the upstream path is not written. Every `/.storage` reference in upstream `entrypoint.sh` must be remapped the same way. `exec` the API so signals reach PID 1; the recognizer runs in the background and needs a supervisor or a check. Confirm the API entry file (`server.js`) and whether `CONFIG_PATH` is a file or a directory (UNVERIFIED). Do not write to `/app`. The seed source is `/defaults/` because `COPY --chmod=0755 . /` places the app's `defaults/` folder at `/defaults`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /double-take/server.js
- /usr/local/bin/recognizer
- /opt/recognizer/models
- /usr/share/licenses/double-take/LICENSE
```

The app is not expected to be fully functional without a camera or detector (section 10). Narrow the test only as the protocol allows: it has no hard DB dependency, so the DB exception does not apply and the test must not be narrowed beyond the port and file checks. Startup time is long (native modules, face model load); 180 s is a starting value, confirm from a real run.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/.storage` (matches, train, latest, config, models cache) | `/config/storage` (set via the recognizer `-storage` flag and the entrypoint paths) |
| `./.storage/config` watch path | `/config/storage/config` |
| `/tmp` (npm and node caches during build) | Build stage only; runtime uses `/tmp` for scratch |
| Upstream runs as root | `USER apps`; the process must be able to read `/double-take` and `/opt/recognizer` (world-readable after `COPY --chmod=0755`) |

Draft expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. This image aims for `apps` and `--read-only --tmpfs /tmp`, which is only possible if every write goes to `/config` (above). Privileged not needed. The chart's persistence `data` at `/.storage` is replaced by `/config`; existing users must move their data to `/config/storage`.

## 10. Risks, caveats and open questions

- Node 16 vs the python-node base (Node 24): `better-sqlite3` and `canvas` compile against Node 16 ABI. Running them on Node 24 is UNVERIFIED and may fail. A spike is needed: build with Node 16 in a build stage, then copy the built `node_modules` to the runtime stage. Rebuild on arm64 too (native modules).
- `canvas` needs cairo and pango at build and runtime. arm64 may compile from source (draft caveat); build time can be long.
- `go-face` needs dlib built from source; this is the largest build cost and the biggest failure risk. Pin the Go and dlib versions. UNVERIFIED that the fork's `recognizer` builds today on Debian bookworm.
- The fork's latest release (`v1.13.11.8`, 2023) and the GHCR `latest` tag may not match the `v1.13.11` tag used by the chart. Confirm which build the chart runs before pinning.
- Upstream binary `v1.13.2` is a source release from `jakowenko/double-take` (not a prebuilt binary, UNVERIFIED assets). Using it would change the app identity; the chart uses the fork.
- Needs a camera or detector feed to produce any results (inferred). Container tests cover startup only.
- Draft difficulty `medium` looks low: 4+ native builds plus Node 16 pinning. Consider `hard` if the spike fails.
- Blockers: none confirmed, but Node 16 on the python-node base and dlib are unresolved. Not musl-only (upstream uses Debian images).

## 11. Build and test steps

```sh
cd apps/double-take
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name double-take-probe --read-only --tmpfs /tmp \
  -v double-take-probe-config:/config double-take:1.13.11
docker logs -f double-take-probe
forgetool containers test --image double-take:1.13.11 --config ./apps/double-take/container-test.yaml
docker rm -f double-take-probe; docker volume rm double-take-probe-config
```

Expected readiness signal: the recognizer and API start without fatal errors, and port 3000 answers `/` (UNVERIFIED exact log line; read it from the upstream `server.js` or the first run). Check that `/config/storage/config` is created on first start and that a restart keeps it. Also test `-p 3000:3000` from the host.

## 12. PR checklist

- Branch `feat/add-double-take`, commit and PR title `feat(double-take): add new container`, target `main`.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; `license/cla` shows the status).
- PR Notes section includes `🤖 This PR is AI generated.`
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Say what is untested: the Node 16 native builds, the dlib recognizer on arm64, the runtime on `--read-only`, camera-driven behaviour, the fork's license.
- `docker buildx bake --print` must pass; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
