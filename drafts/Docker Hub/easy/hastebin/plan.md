# hastebin — implementation plan
> Source: ./draft.md · Target: apps/hastebin/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No releases or tags exist upstream. The fork `nzzane/haste-server` is pinned by commit `8c45a370a79cc5caaf446ba0088574dfcb489694` (2021-03-01, "Update Dockerfile"), the same commit the draft links. `package.json` says `0.1.0`. Plan: `VERSION` is the full commit SHA (the `apps/tvheadend` pattern), so the image tag, the source pin and Renovate stay aligned. The commit is the head of the default branch `master`. |
| Draft tag | `docker.io/flippinturt/hastebin:latest` (rolling, unversioned). |
| Renovate | `datasource=git-refs depName=https://github.com/nzzane/haste-server currentValue=master`, as in `apps/tvheadend/docker-bake.hcl`. |
| License | MIT (John Crepezzi, 2011-2012), stated in the License section of `README.md`; there is no `LICENSE` file at the commit. The README also names jQuery (MIT/GPL), highlight.js and highlightjs-coffeescript (WTFPL). `static/highlight.min.js` is bundled; jQuery is loaded by `index.html` from `ajax.googleapis.com`, not bundled. Use `MIT` for `LICENSE`. UNVERIFIED: the exact SPDX of highlight.js. |
| Source URL | https://github.com/nzzane/haste-server |
| Download | `https://github.com/nzzane/haste-server/archive/<VERSION>.tar.gz`. It is architecture independent, so there is no per-arch URL. |
| Checksum source | None published for a commit archive. Mitigation: the download is pinned by a full commit SHA, and the Dockerfile may add a `sha256sum -c` against a hash recorded at implementation time. UNVERIFIED: the hash itself. |
| Upstream Dockerfile reviewed | Yes. `FROM node:14.8.0-stretch`, `npm install` plus optional `redis`, `pg`, `memcached`, `aws-sdk` and `rethinkdbdash`. It sets many ENV defaults (`STORAGE_TYPE=file`, `STORAGE_FILEPATH=/app/data`, `HOST=0.0.0.0`, `PORT=7777`). The entrypoint runs `node docker-entrypoint.js > config.js`, then `exec npm start`. |
| Ports | 7777/tcp (http). |
| Config loading | `server.js` reads `config.js` from the working directory, or from argv[2]. The file must contain JSON. `HOST` and `PORT` env vars override the file. |
| Storage | `file` store: `path` option, default `./data`. Each key becomes an MD5-named file. `expire` is not enforced for the file store. `mkdir` runs only on write. |
| Static assets | `static/index.html` loads `application.min.js` (a committed file; `recompressStaticAssets` regenerates it from `application.js`). |
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
- Alternative: the plain ubuntu base, which already installs Node (`NODE_VERSION` in `apps/ubuntu/docker-bake.hcl`), so Python and an apt `nodejs` are not needed. Decide this at implementation time.

## 4. Dockerfile

1. `ARG VERSION` (the commit SHA). No `TARGETARCH`: the app is pure JavaScript.
2. `USER root` for the install step only.
3. Download: `curl -fsSL -o /tmp/haste.tar.gz "https://github.com/nzzane/haste-server/archive/${VERSION}.tar.gz"`. Upstream publishes no checksum; the full commit SHA pins the content.
4. `mkdir -p /app/haste && tar xf /tmp/haste.tar.gz -C /app/haste --strip-components=1`.
5. `cd /app/haste && npm install --omit=dev --no-audit --no-fund` (the repo has a `package-lock.json`; try `npm ci --omit=dev` first).
   - The dependencies already include `pg`.
   - Do not install `memcached`, `aws-sdk` or `rethinkdbdash` unless a scope decision adds those backends. Upstream adds them for its env-driven backends.
6. Re-minify static assets at build time, because `/app` is read-only at runtime. `server.js` does `fs.writeFileSync('./static/<name>.min.js')` when `recompressStaticAssets` is true. The Dockerfile runs a small `node -e` step with the installed `uglify-js` over `static/*.js`, skipping `*.min.js`, writing `<name>.min.js` (at this commit that is `application.js`). `recompressStaticAssets=false` at runtime.
7. License: `install -D -m 0644 /app/haste/README.md /usr/share/licenses/hastebin/README.md` (the MIT text is in the README; there is no `LICENSE` file).
8. Cleanup: `npm cache clean --force`, `rm -rf /tmp/*`.
9. `ENV npm_config_cache=/tmp/.npm HOME=/tmp` (the ubuntu base sets `HOME=/config`).
10. `USER apps`, then `COPY --chmod=0755 . /`.
11. `EXPOSE 7777`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "hastebin"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/nzzane/haste-server currentValue=master
  default = "8c45a370a79cc5caaf446ba0088574dfcb489694"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/nzzane/haste-server"
}
```

- `target "image"` passes `args = { VERSION = "${VERSION}" }` plus the OCI source and licenses labels.
- Add `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64 and arm64) and `group "default" { targets = ["image-local"] }`, copied from `apps/tvheadend/docker-bake.hcl`.
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
env:
  - name: PORT
    default: "7777"
    required: false
  - name: KEY_LENGTH
    default: "10"
    required: false
  - name: MAX_LENGTH
    default: "400000"
    required: false
  - name: STATIC_MAX_AGE
    default: "86400"
    required: false
  - name: KEYGENERATOR_TYPE
    default: "phonetic"
    required: false
  - name: KEYGENERATOR_KEYSPACE
    default: ""
    required: false
  - name: LOGGING_LEVEL
    default: "verbose"
    required: false
  - name: RATELIMITS_NORMAL_TOTAL_REQUESTS
    default: "500"
    required: false
  - name: RATELIMITS_NORMAL_EVERY_MILLISECONDS
    default: "60000"
    required: false
  - name: DOCUMENTS
    default: "about=./about.md"
    required: false
  - name: STORAGE_FILEPATH
    default: "/config/data"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Env entries are limited to what `start.sh` (and `server.js` for `PORT`, the C library for `TZ`) reads. The `RATELIMITS_*` and `KEYGENERATOR_*` names are those of the upstream Dockerfile and README, not the broken ones in `docker-entrypoint.js`.
- `KEYGENERATOR_KEYSPACE` only matters for the `random` generator.
- Do not list `HOST`: `start.sh` forces `0.0.0.0` so the container is reachable from other containers.
- Do not list the redis, memcached, aws or rethinkdb storage vars. This plan supports only the file store.
- `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export STORAGE_FILEPATH="${STORAGE_FILEPATH:-/config/data}"
mkdir -p "${STORAGE_FILEPATH}"

# Generate the config as JSON in /tmp so /app stays read-only. node reads the values from the
# environment and JSON.stringify escapes them.
node -e '
const e = process.env;
const num = (v, d) => Number(v || d);
const keyGenerator = { type: e.KEYGENERATOR_TYPE || "phonetic" };
if (e.KEYGENERATOR_KEYSPACE) keyGenerator.keyspace = e.KEYGENERATOR_KEYSPACE;
const documents = {};
for (const item of (e.DOCUMENTS || "about=./about.md").split(",")) {
  const [name, path] = item.trim().split("=");
  if (name && path) documents[name] = path;
}
console.log(JSON.stringify({
  port: num(e.PORT, 7777),
  keyLength: num(e.KEY_LENGTH, 10),
  maxLength: num(e.MAX_LENGTH, 400000),
  staticMaxAge: num(e.STATIC_MAX_AGE, 86400),
  recompressStaticAssets: false,
  logging: [{ level: e.LOGGING_LEVEL || "verbose", type: "Console", colorize: false }],
  keyGenerator,
  rateLimits: { categories: { normal: {
    totalRequests: num(e.RATELIMITS_NORMAL_TOTAL_REQUESTS, 500),
    every: num(e.RATELIMITS_NORMAL_EVERY_MILLISECONDS, 60000) } } },
  storage: { type: "file", path: e.STORAGE_FILEPATH },
  documents
}));
' > /tmp/haste-config.json

# server.js lets the HOST env var override the config file
export HOST=0.0.0.0
cd /app/haste
exec node server.js /tmp/haste-config.json
```

- `cd /app/haste` is required because `./static`, `./lib` stores and `./about.md` are resolved relative to the app directory. The config file is passed explicitly, so nothing is written to `/app`.
- `/config/data` is created only if missing, and existing pastes are never touched. The config is regenerated on every start, which is idempotent and not user state.
- No caches go in `/config`. There are no secrets in the file-store-only setup.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '7777'
http:
- port: '7777'
  path: /
  statusCode: 200
filePaths:
- /app/haste/server.js
- /usr/share/licenses/hastebin/README.md
```

- `filePaths` are checked with `test -f`, so list files, not directories.
- The test runs with no env vars, so the defaults in `start.sh` must be enough to start.
- `180` is the minimum forgetool enforces.
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
- The draft's rolling `latest` tag is replaced by a pinned commit. The image tag is the commit SHA; `0.1.0` from `package.json` is not used.
- The in-memory store mentioned in the draft does not exist in this fork's env path. Only `file`, and the optional backends, are available. Pastes persist under `/config/data`, and the `file` store ignores expiry.
- `index.html` references `application.min.js`, so keep the build-time re-minify. It also loads jQuery from Google's CDN, so browsers need internet access.
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
  -v hastebin-probe-config:/config hastebin:8c45a370a79cc5caaf446ba0088574dfcb489694
docker logs -f hastebin-probe
curl -fsS localhost:7777/    # run from a sibling container, or publish -p 7777:7777
# paste round trip: POST /documents then GET /raw/<key>, to confirm /config/data writes work
docker rm -f hastebin-probe; docker volume rm hastebin-probe-config
forgetool containers test --image hastebin:8c45a370a79cc5caaf446ba0088574dfcb489694 --config ./apps/hastebin/container-test.yaml
```

- Expected readiness signal: the winston log line `listening on 0.0.0.0:7777` (the format string is in `server.js`).
- The container must stay up, with no stack traces.

## 12. PR checklist

- Branch `feat/add-hastebin`, commit `feat(hastebin): add new container`, PR title `feat(hastebin): add hastebin image`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md` and check only the boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it, and the `license/cla` check shows the status.
- Confirm before the PR:
  - `docker buildx bake --print` passes.
  - The `VERSION` default matches the Dockerfile ARG.
  - The image runs read-only with an empty `/config`.
  - The `tcp` and `http` probes match `settings.yaml`.
- Untested until implementation: the build, the arm64 build, the runtime on the base's Node version, and the paste round trip. The SPDX of highlight.js, the re-minify step and the `forgetool` run are also unverified or untested.
