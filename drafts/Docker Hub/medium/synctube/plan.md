# synctube — implementation plan
> Source: ./draft.md · Target: apps/synctube/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No tagged release: `gh api repos/RblSb/SyncTube/releases/latest` returns 404. Pin a commit SHA. The draft's Dockerfile reference is commit `d22d837`; the head of `master` is `d22d837ae76abe6df3d1dbce3eae0a52297a461b` (committed 2026-10-31, checked with `gh api repos/RblSb/SyncTube/commits/master`), so the draft's commit is the newest. Use that full SHA as `VERSION` and note it in the PR. Source: `gh api repos/RblSb/SyncTube`. |
| Docker Hub tag | `littlestache/synctube:latest` only, last pushed 2021-12-04, amd64 only. The draft's container is a 2021 build and is not a usable reference for the current source. Source: https://hub.docker.com/v2/repositories/littlestache/synctube/tags?page_size=3 |
| Renovate | UNVERIFIED: no release tags. Use `datasource=git-refs depName=https://github.com/RblSb/SyncTube currentValue=master` (the pattern in `apps/tvheadend`, also used in the fenrus plan). |
| License | MIT (GitHub SPDX `MIT`). Source: `gh api repos/RblSb/SyncTube`. |
| Source URL | https://github.com/RblSb/SyncTube |
| Download | Source archive by commit: `https://github.com/RblSb/SyncTube/archive/${VERSION}.tar.gz`. The draft lists `master.zip`; a commit-pinned tarball is preferred for reproducibility. |
| Checksum source | None published upstream. The tarball is pinned by commit SHA (content-addressed). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/RblSb/SyncTube/d22d837/Dockerfile: `FROM haxe:4.3-alpine3.22`; `apk add nodejs npm git`; creates user and group `app` (UID/GID 1000) and `/app`; `USER 0` for setup; `npm ci`; `haxelib setup /app`, `haxelib install all --always`, `haxe build-all.hxml` in one `RUN`; `USER 1000`; `ENTRYPOINT [ "node", "build/server.js" ]`. No `CMD`, `EXPOSE`, `VOLUME`, `ENV`, or `WORKDIR` defined. |
| Ports | The upstream Dockerfile has no `EXPOSE`, but upstream `default-config.json` sets `"port": 4200`, which confirms the draft's 4200 (the listen address was not checked). |
| Env vars | UNVERIFIED: none fetched. Read the upstream config and README before listing any. |
| Data and config paths | UNVERIFIED for upstream. The draft's `/usr/src/app/user` is a chart path (pvc), not an upstream path. The upstream Dockerfile does not set a data directory. |
| arm64 | The Haxe output is JavaScript (arch-neutral), and the Node runtime is per arch from the `python-node` base, so arm64 is expected to work. UNVERIFIED: no arm64 build has been run. |
| Copy-from images | `no` for both arches: upstream's image is a 2021 amd64 build on alpine (musl). Not usable on glibc Ubuntu. |

## 2. Target layout

- `apps/synctube/Dockerfile`
- `apps/synctube/docker-bake.hcl`
- `apps/synctube/settings.yaml`
- `apps/synctube/container-test.yaml`
- `apps/synctube/start.sh`

No `defaults/` unless the upstream config needs seeding (decide after reading the config, section 7). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Runtime stage: `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (the `FROM` line used by 11 existing apps, including `apps/budge`; `apps/changedetection` uses the older `python-node:3.14.8` tag). It provides Node, which is what the upstream runs.

Build stage: `haxe:4.3-alpine3.22`, the same image upstream uses. Its output is JavaScript, so the build stage's musl libc does not reach the final image. The build stage needs a digest: UNVERIFIED (not fetched; `docker buildx imagetools inspect haxe:4.3-alpine3.22` gives it). Do not invent one.

Closest siblings: `apps/changedetection` and `apps/budge` (python-node with a Node app). Build-stage-then-runtime pattern: `apps/pwndrop` (both stages on ubuntu).

## 4. Dockerfile

```dockerfile
# build stage: upstream toolchain (musl alpine), output is arch-neutral JavaScript
FROM haxe:4.3-alpine3.22@sha256:<UNVERIFIED> AS build
ARG VERSION
ARG SOURCE_URL
RUN apk add --no-cache nodejs npm git ca-certificates wget
WORKDIR /src
RUN wget -qO- "https://github.com/RblSb/SyncTube/archive/${VERSION}.tar.gz" | tar -xz --strip-components=1 -C /src
RUN npm ci
RUN haxelib setup /src/haxelib && haxelib install all --always && haxe build-all.hxml
# keep only what the runtime needs
RUN rm -rf /src/.git

# runtime stage
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5
ARG VERSION
ARG TARGETARCH
USER root
RUN mkdir -p /app /config && chown -R apps:apps /app /config && chmod -R 755 /app
COPY --from=build --chown=apps:apps /src/build /app/build
COPY --from=build --chown=apps:apps /src/node_modules /app/node_modules
COPY --from=build --chown=apps:apps /src/package.json /app/package.json
COPY --from=build --chown=apps:apps /src/res /app/res
COPY --from=build --chown=apps:apps /src/default-config.json /app/default-config.json
# ... plus any other runtime folders the server reads (UNVERIFIED: list from the source tree)
USER apps
COPY --chmod=0755 . /
EXPOSE 4200/tcp
VOLUME /config
```
- The `ARG VERSION` must equal the bake default (section 5).
- The Haxe build writes `build/` (JavaScript), which is what `node build/server.js` runs. The directory names copied above are UNVERIFIED against the source tree; check them after the first download.
- Native modules: if `node_modules` contains compiled addons, they were built on musl and will fail on glibc. UNVERIFIED. If so, run `npm ci --omit=dev` in the final stage (as root in `/tmp`-based cache, then `chown`), not in the alpine stage. Decide after the `npm ci` output is read.
- `haxelib` writes under `/src/haxelib` in the build stage, so nothing is written to `/app` at runtime.
- `EXPOSE` value and any `WORKDIR` come from section 1 once the port is verified.
- Final `USER apps` (UID 568), per the Dockerfile rules; upstream uses UID 1000 (`app`), which is not the ContainerForge convention.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "synctube"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/RblSb/SyncTube currentValue=master
  default = "d22d837ae76abe6df3d1dbce3eae0a52297a461b"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/RblSb/SyncTube"
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
Validate with `docker buildx bake --print` in `apps/synctube/`. The `VERSION` must be a commit SHA, so the tag is long; consider a short prefix and note it.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/RblSb/SyncTube"
ports:
  - port: 4200             # upstream default-config.json
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: UMASK
    default: "002"
    required: false
volumes:
  - path: /config
    required: true
```
- The env list stays minimal: no upstream env var is confirmed (section 1). Add only those the upstream config or code reads.
- `dependencies:` omitted (no database or other container).
- Keep the port list to what the server actually binds. Replace `4200` once confirmed; do not ship the placeholder.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/user

# seed the config only when missing (UNVERIFIED: which upstream config file is read; check the source)
# if the server writes user data relative to its working directory, link it to /config
cd /app || exit 1
exec node build/server.js
```
- Idempotent: creates `/config/user`, seeds nothing until the upstream config file is confirmed.
- Nothing is written under `/app` at runtime. If the server writes under `/app` (for example a `user/` directory next to `build/`), symlink that directory to `/config/user` at start, and check the link resolves.
- `exec` so `node` is PID 1's child with signals passed through.
- The web UI and websocket share one port, so reverse proxies must forward websocket upgrades (draft caveat, inferred). Document in the PR notes.
- Binding: the server must listen on `0.0.0.0`, not `127.0.0.1`. UNVERIFIED: check the listen call in the upstream source.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '4200'
http:
- port: '4200'
  path: /
filePaths:
- /app/build/server.js
- /app/package.json
```
- `4200` is the verified port (section 1 and 6). Do not ship the placeholder.
- The `http` probe path `/` must return 200 on a fresh `/config`; confirm the status in the first run.
- No env vars are needed to start (test runs with none), so no required-env code path exists.

## 9. Rootless and read-only-rootfs adaptations

| Item | Adaptation |
| --- | --- |
| Upstream user | `USER 1000` (`app`), and `USER 0` during setup. Here: final `USER apps` (UID 568), as the ContainerForge convention. |
| Chart security | Draft says `runAsUser 0`, `runAsNonRoot false`, `readOnlyRootFilesystem false`. This image needs none of those overrides, provided the server writes only to `/config` and `/tmp`. |
| `/app` | Read-only at runtime. Built in the build stage; the server must not write there (or the write path is symlinked, section 7). |
| `/config` | Persistent: user data (draft chart pvc `/usr/src/app/user`, remapped to `/config/user`). |
| `/tmp` | Ephemeral scratch. npm and haxelib caches live in the build stage, not the final image. |
| Runtime npm cache | If `npm ci` runs in the final stage, set `npm_config_cache=/tmp/npm` so the cache is not in `/config` or `/app`. |
| Privileged | No. |

## 10. Risks, caveats and open questions

- **Version pin:** no release tags. Renovate will follow `master`; decide whether to pin a commit (section 5).
- **Haxe musl build vs glibc runtime:** the build is musl; its output is JavaScript, but native npm modules would break (section 4). Check `node_modules` for `.node` files.
- **Port:** the draft's 4200 is inferred. Confirm from the source before writing `settings.yaml` and `container-test.yaml`.
- **Writes outside `/config`:** the upstream write path for user data is unknown. Confirm on the first run with `--read-only --tmpfs /tmp`.
- **Websocket:** the single port serves both HTTP and websocket; any reverse proxy must forward the upgrade (draft caveat, inferred).
- **Build digest:** the `haxe:4.3-alpine3.22` digest is not in this repo and was not fetched. Do not invent it.
- **Blockers:** none confirmed. No GPU, no privileged need, arm64 expected (not built).

## 11. Build and test steps

```sh
cd apps/synctube
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name synctube-probe --read-only --tmpfs /tmp \
  -v synctube-probe-config:/config synctube:<VERSION>
docker logs -f synctube-probe
curl -fsS http://127.0.0.1:4200/ -o /dev/null -w '%{http_code}\n'   # run from the host after -p mapping, or via docker exec
docker rm -f synctube-probe; docker volume rm synctube-probe-config

forgetool containers test --image synctube:<VERSION> --config ./apps/synctube/container-test.yaml
```

Expected readiness signal: UNVERIFIED (the server's startup line is not in the fetched material). Use the first line that names the port or says the server started, and record it in the PR.

Run a second start on the same `/config` volume to confirm idempotence.

## 12. PR checklist

- Branch `feat/add-synctube`, commit `feat(synctube): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes; check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed Contributor License Agreement (https://cla-assistant.io/trueforge-org/containerforge). Tell the user; only they can sign it, and the `license/cla` check shows status.
- Say in the PR what was not tested: the arm64 build and run, the websocket path through a reverse proxy, and the read-only run if not done.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; the pinned commit is named in the PR.
- Downstream: no `DOWNSTREAM_CHANGES.md` (not a `FROM` base).
