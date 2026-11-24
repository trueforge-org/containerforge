# hastebin — implementation plan
> Source: ./draft.md · Target: apps/hastebin/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No releases or tags exist upstream. The fork `nzzane/haste-server` is pinned by commit `8c45a370a79cc5caaf446ba0088574dfcb489694` (2021-03-01, "Update Dockerfile"), the same commit the draft links. `package.json` says `0.1.0`. Plan: `VERSION=0.1.0` for the image tag and a second variable `COMMIT` for the source pin. |
| Draft tag | `docker.io/flippinturt/hastebin:latest` (rolling, unversioned). |
| Renovate | `VERSION` has no upstream feed, so it is static and bumped by hand. `COMMIT`: `datasource=git-refs depName=nzzane/haste-server packageName=https://github.com/nzzane/haste-server currentDigest=<sha>`. This is the form `apps/kasmvnc/docker-bake.hcl` uses for `KASM_NOVNC_VERSION`. |
| License | MIT (John Crepezzi, 2011-2012). The repo also bundles jQuery (MIT/GPL) and highlight.js, plus highlightjs-coffeescript (WTFPL). Use `MIT` for `LICENSE`. UNVERIFIED: the exact SPDX of the bundled JS libraries. |
| Source URL | https://github.com/nzzane/haste-server |
| Download | `https://github.com/nzzane/haste-server/archive/<COMMIT>.tar.gz`. It is architecture independent, so there is no per-arch URL. |
| Checksum source | None published for a commit archive. Mitigation: the download is pinned by a full commit SHA, and the Dockerfile may add a `sha256sum -c` against a hash recorded at implementation time. UNVERIFIED: the hash itself. |
| Upstream Dockerfile reviewed | Yes. `FROM node:14.8.0-stretch`, `npm install` plus optional `redis`, `pg`, `memcached`, `aws-sdk` and `rethinkdbdash`. It sets many ENV defaults (`STORAGE_TYPE=file`, `STORAGE_FILEPATH=/app/data`, `HOST=0.0.0.0`, `PORT=7777`). The entrypoint runs `node docker-entrypoint.js > config.js`, then `exec npm start`. |
| Ports | 7777/tcp (http). |
| Config loading | `server.js` reads `config.js` from the working directory, or from argv[2]. The file must contain JSON. `HOST` and `PORT` env vars override the file. |
| Storage | `file` store: `path` option, default `./data`. Each key becomes an MD5-named file. `expire` is not enforced for the file store. `mkdir` runs only on write. |
| Deps (package.json) | busboy, connect, connect-ratelimit, connect-route, pg ^8, redis 0.8.1, redis-url, st, uglify-js 3.1.6, winston ^2. |

Upstream bugs found in `docker-entrypoint.js`. They are why this plan does not reuse it:
- It reads `RATE_LIMITS_*` and `KEY_GENERATOR_KEYSPACE`, but the Dockerfile ENV names are `RATELIMITS_*` and `KEYGENERATOR_KEYSPACE`, so those settings are silently ignored.
- The blacklist `totalRequests` reads the whitelist variable.
- It passes every value as a string, including `port` and `recompressStaticAssets`.
- It writes `./config.js` into the app directory.

## 2. Target layout

```
apps/hastebin/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

- There is no `defaults/`, `etc/` or `health/`, because `start.sh` generates the config at runtime in `/tmp`.
- There is no `root/`.
- There is no `DOWNSTREAM_CHANGES.md`, because nothing uses this image as a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

- It matches the draft: the base provides Node.js and npm, and haste-server needs no Python.
- Verify `node --version` in the base before building. The old upstream pins Node 14, and the dependencies are old (`connect` 3, `winston` 2). UNVERIFIED: that they run on the base's Node.
- Closest sibling: `apps/budge`, which is a python-node base with an npm install under `/app`.
- Fallback if the python-node base is too heavy or too new: plain ubuntu plus a pinned apt `nodejs`. Decide this at implementation time.

## 4. Dockerfile

1. `ARG VERSION`, `ARG COMMIT`, `ARG TARGETARCH`. TARGETARCH is unused because the app is arch-independent. Drop it if unused, or keep it for sibling parity.
2. `USER root` for the install step only.
3. Download: `curl -fsSL -o /tmp/haste.tar.gz https://github.com/nzzane/haste-server/archive/${COMMIT}.tar.gz`. Optionally verify it with `echo "<sha256>  /tmp/haste.tar.gz" | sha256sum -c -`.
4. `mkdir -p /app/haste && tar xf /tmp/haste.tar.gz -C /app/haste --strip-components=1`.
5. `cd /app/haste && npm install --omit=dev --no-audit --no-fund`.
   - The dependencies already include `pg`, which is enough for the file backend and the optional postgres backend.
   - Do not install `redis@0.8.1`, `memcached`, `aws-sdk` or `rethinkdbdash` unless a scope decision adds those backends. Upstream adds them for its env-driven backends.
6. Pre-minify static assets at build time, because `/app` is read-only at runtime. `server.js` does `fs.writeFileSync('./static/<name>.min.js')` when `recompressStaticAssets` is true. The Dockerfile runs a small `node -e` step with `uglify-js` over `static/*.js`, skipping `*.min.js`, writing `<name>.min.js`. Start with `recompressStaticAssets=false` at runtime.
7. License: `mkdir -p /usr/share/licenses/hastebin && cp /app/haste/LICENSE* /usr/share/licenses/hastebin/`. Also include the bundled third-party licence texts if they exist in the repo. UNVERIFIED: the file name.
8. Cleanup: `npm cache clean --force`, `rm -rf /tmp/* $HOME/.npm $HOME/.cache`.
9. `ENV npm_config_cache=/tmp/.npm HOME=/tmp`. Check the base for an existing HOME setting before overriding it.
10. `USER apps`, then `COPY --chmod=0755 . /`.
11. `EXPOSE 7777`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "hastebin"
}

variable "VERSION" {
  default = "0.1.0"
}

variable "COMMIT" {
  // renovate: datasource=git-refs depName=nzzane/haste-server packageName=https://github.com/nzzane/haste-server currentDigest=8c45a370a79cc5caaf446ba0088574dfcb489694
  default = "8c45a370a79cc5caaf446ba0088574dfcb489694"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/nzzane/haste-server"
}
```

- `target "image"` passes `args = { VERSION = "${VERSION}", COMMIT = "${COMMIT}" }` plus the OCI source and licenses labels.
- Add `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64 and arm64) and `group "default" { targets = ["image-local"] }`, copied from `apps/changedetection`.
- Open question: the brief requires a renovate comment on `VERSION`. `VERSION` is a hand-maintained label with no feed, so either add the comment on `COMMIT` only (as above) or annotate `VERSION` with `datasource=git-tags`, which does not apply because there are no tags. Prefer the first option and document it in the PR.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/nzzane/haste-server"
ports:
  - port: 7777
    protocol: tcp
    required: true
```

- Env entries are limited to what `start.sh` reads. Names use the correct upstream-style names, not the broken ones in `docker-entrypoint.js`.
- Each entry is `required: false`, and its default matches `start.sh`.
  - `PORT` (7777), `KEY_LENGTH` (10), `MAX_LENGTH` (400000), `STATIC_MAX_AGE` (86400).
  - `KEYGENERATOR_TYPE` (phonetic), `KEYGENERATOR_KEYSPACE` (empty).
  - `LOGGING_LEVEL` (verbose).
  - `RATELIMITS_NORMAL_TOTAL_REQUESTS` (500), `RATELIMITS_NORMAL_EVERY_MILLISECONDS` (60000).
  - `DOCUMENTS` (`about=./about.md`).
  - `STORAGE_FILEPATH` (`/config/data`).
  - `TZ` (`Etc/UTC`) only if `start.sh` actually uses it. Otherwise omit it.
- Do not list `HOST`: `start.sh` hardcodes `0.0.0.0` so the container is reachable from other containers.
- Do not list the redis, memcached, aws or rethinkdb storage vars. This plan supports only the file store, plus an optional postgres store only if added later.
- `volumes`: `- path: /config`, `required: true`.
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${STORAGE_FILEPATH:-/config/data}"

# Generate the config as JSON in /tmp so /app stays read-only.
node -e '...' > /tmp/haste-config.json   # builds the object with correct types
cd /app/haste
exec node server.js /tmp/haste-config.json
```

- Generate the config with a small inline node script, or a heredoc, reading env vars with defaults. Cast types properly (numbers for port and limits, boolean `false` for `recompressStaticAssets`).
  - Build `rateLimits.categories.normal` from `RATELIMITS_NORMAL_*`.
  - Build `keyGenerator` from `KEYGENERATOR_TYPE` and `KEYGENERATOR_KEYSPACE`.
  - Build `storage: { type: "file", path: STORAGE_FILEPATH }`.
  - Build `documents` from `DOCUMENTS` (`name=path` pairs, comma separated).
  - Leave `whitelist` and `blacklist` as empty arrays unless explicitly supported.
- `host` is fixed at `0.0.0.0`. `PORT` overrides the config in `server.js` anyway.
- `cd /app/haste` is required because `./static` and `./about.md` are resolved relative to the working directory. The config file is passed explicitly, so nothing is written to `/app`.
- `/config/data` is created only if missing, and existing pastes are never touched. `config.js` is regenerated on every start, which is idempotent and not user state.
- `mkdir -p` is the only write to `/config`. No caches go in `/config`.
- Final command: `exec node server.js /tmp/haste-config.json`.
- Keep secrets out of the process list. There are none in the file-store-only setup.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '7777'
```

- Add an `http` probe on `/` with a 200 status. Mirror the exact `http` syntax of a sibling web app such as `apps/it-tools`, and check the schema before writing it.
- Add `filePaths` for `/app/haste/server.js` and `/usr/share/licenses/hastebin`.
- The test runs with no env vars, so the defaults in `start.sh` must be enough to start.
- `timeoutSeconds: 60` is a guess for a small node app. Compare it with `apps/it-tools`.
- The DB-dependency exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `./config.js`, written by `docker-entrypoint.sh` into `/usr/src/app` | The config is generated at `/tmp/haste-config.json` and passed as argv[2]. |
| `./static/*.min.js`, written by `recompressStaticAssets` | Disabled at runtime and pre-built in the Dockerfile. |
| Paste storage `/app/data` (file store, `mkdir` mode 700) | `/config/data`. This is the draft's `/app/data` PVC; it moves under `/config` because `/app` is read-only. |
| npm and HOME caches | `/tmp`. |

- Draft expectations:
  - The chart runs as UID 0. The image runs as `USER apps`, and the node server needs no root.
  - The chart sets `readOnlyRootFilesystem: false`. The image works with a read-only root filesystem once the writes above are remapped.
  - Privileged: no.
- Migration note: users moving from the TrueCharts chart must relocate data from `/app/data` to `/config/data`, or set `STORAGE_FILEPATH`.

## 10. Risks, caveats and open questions

- The upstream is an unmaintained fork. There is no release, the last commit is from 2021, and its dependencies are old. Renovate will track the commit, but a stale fork may need a switch to the maintained `toptal/haste-server`. This is an open question for the maintainers.
- The draft's rolling `latest` tag is replaced by a pinned commit. The `VERSION` of `0.1.0` is cosmetic and comes from `package.json`.
- The in-memory store mentioned in the draft does not exist in this fork's env path. Only `file`, and the optional backends, are available. Pastes persist under `/config/data`, and the `file` store ignores expiry.
- `recompressStaticAssets` pre-build: UNVERIFIED that the front-end references `*.min.js` files. If it does not, the build step is unnecessary and may be dropped.
- The old node dependencies may not run on the base's Node version, which is a possible blocker. UNVERIFIED.
- Optional storage backends (redis, memcached, postgres, s3, rethinkdb) are out of scope. Upstream supports them via extra npm packages.
- No checksum is published for the source archive.
- Both architectures are supported, because the app is pure JavaScript, but arm64 is not tested here.

## 11. Build and test steps

```sh
cd apps/hastebin
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create hastebin-probe-config
docker run --rm -d --name hastebin-probe --read-only --tmpfs /tmp \
  -v hastebin-probe-config:/config hastebin:0.1.0
docker logs -f hastebin-probe
curl -fsS localhost:7777/    # run from a sibling container, or publish -p 7777:7777
# paste round trip: POST /documents then GET /raw/<key>, to confirm /config/data writes work
docker rm -f hastebin-probe; docker volume rm hastebin-probe-config
forgetool containers test --image hastebin:0.1.0 --config ./apps/hastebin/container-test.yaml
```

- Expected readiness signal: the winston log line `listening on 0.0.0.0:7777`. UNVERIFIED: the exact wording, so check `server.js` logging.
- The container must stay up, with no stack traces.

## 12. PR checklist

- Branch `feat/add-hastebin`, commit `feat(hastebin): add new container`, PR title `feat(hastebin): add hastebin image`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md` and check only the boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it, and the `license/cla` check shows the status.
- Confirm before the PR:
  - `docker buildx bake --print` passes.
  - The `VERSION` and `COMMIT` defaults match the Dockerfile ARGs.
  - The image runs read-only with an empty `/config`.
  - The `tcp` and `http` probes match `settings.yaml`.
- Untested until implementation: the build, the arm64 build, the runtime on the base's Node version, and the paste round trip. The source archive checksum, the SPDX of the bundled libraries, the `*.min.js` pre-build, the readiness log wording and the `forgetool` run are also unverified or untested.
