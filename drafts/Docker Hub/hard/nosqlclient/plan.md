# nosqlclient — implementation plan
> Source: ./draft.md · Target: apps/nosqlclient/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `4.0.1` (GitHub release 2020-10-08, Docker Hub tag `mongoclient/mongoclient:4.0.1`, same date). The draft uses `latest`, which is the same 2020-10-08 build. The project is effectively dormant: last push to the repo 2023-08-15, no releases since 2020. |
| Renovate | `datasource=docker depName=mongoclient/mongoclient versioning=loose`. It will never propose a new version; the bump is manual and effectively frozen. |
| License | `AGPL-3.0` (GitHub license API; SPDX `AGPL-3.0`, so use `AGPL-3.0-only` only if the repo's `LICENSE` header says "only", UNVERIFIED). |
| Source URL | https://github.com/nosqlclient/nosqlclient |
| Binary | No release artifact for 4.x (the 2017 releases have portable zips, not the current app). The only usable build is the Meteor bundle in `mongoclient/mongoclient:4.0.1`, **amd64 only** (Docker Hub lists only `amd64` for every tag). arm64 is not possible. |
| Image digest | `mongoclient/mongoclient:4.0.1` manifest digest `sha256:885dd82b3db780258d1204850058453e0db7f7010b8a75033fac066062318f04` (read from the registry API). The `latest` tag showed a different manifest digest, `sha256:ca98c95d...927a`, although both are dated 2020-10-08; pin the `4.0.1` digest. |
| Upstream Dockerfile reviewed | `nosqlclient/nosqlclient` `Dockerfile` (master): `FROM debian:jessie`, `NODE_VERSION 12.16.1`, `ENV PORT 3000`, `ROOT_URL http://localhost`, `INSTALL_MONGO true`, `MONGOCLIENT_DEFAULT_CONNECTION_URL ''`, `MONGOCLIENT_CONNECTIONS_FILE_PATH /opt/meteor/dist/predefined_connections.json`, bundle in `/opt/meteor/dist/bundle` (`APP_BUNDLE_DIR=/opt/meteor/dist`), `EXPOSE 3000`, `USER node`, `WORKDIR $APP_BUNDLE_DIR/bundle`, `ENTRYPOINT ["./entrypoint.sh"]`, `CMD ["node","main.js"]`. `build-meteor.sh` moves `entrypoint.sh` into the bundle dir. |
| Node runtime | Node `12.16.1`, linux x64 tarball `https://nodejs.org/dist/v12.16.1/node-v12.16.1-linux-x64.tar.xz` (HTTP 200), checksum from `https://nodejs.org/dist/v12.16.1/SHASUMS256.txt`: `b826753f14df9771609ffb8e7d2cc4cb395247cb704cf0cea0f04132d9cf3505`. Node 12 is long past end of life. |
| Env vars (upstream `entrypoint.sh`) | `MONGO_URL`, `MONGO_SCHEME` (default `mongodb`), `MONGO_USERNAME`, `MONGO_PASSWORD`, `MONGO_ADDRESSES` (default `127.0.0.1:27017`), `MONGO_DATABASE` (default `meteor`), `MONGO_TLS`, `MONGO_OPT_PARAMS`, `MONGOCLIENT_DEFAULT_CONNECTION_URL`, `MONGOCLIENT_USERNAME`, `MONGOCLIENT_PASSWORD`, `STARTUP_DELAY`; each also accepts a `*_FILE` variant. Meteor itself reads `PORT` (default 3000) and `ROOT_URL`. |
| Upstream mongod | If `MONGO_URL` contains `127.0.0.1` and `mongod` exists, the upstream entrypoint starts a local MongoDB (README: bind `/data/db`). |
| copy-from path | `/opt/meteor/dist/bundle` inside the image (from the Dockerfile and `build-meteor.sh`); the draft's "path not verified" is resolved at source level but not by running `docker run`, so UNVERIFIED on the image itself. |

## 2. Target layout

```
apps/nosqlclient/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`: the connection file is optional. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The draft proposes `python-node`, but the bundle needs **Node 12**, while that base ships a current Node; the old Node binary is installed separately under `/usr/local/lib/node12` (not `/app`) and used explicitly. Ubuntu base keeps the image small. The runtime for the bundle is glibc (Debian jessie), so it works on Ubuntu 26.04 for amd64. Closest sibling: `apps/kasmvnc` (copies node assets between stages); for prebuilt tarballs `apps/adguardhome-sync`.

## 4. Dockerfile

1. Stage `src`: `FROM mongoclient/mongoclient:4.0.1@sha256:885dd82b3db780258d1204850058453e0db7f7010b8a75033fac066062318f04 AS src` (the draft's copy-from; upstream Dockerfile compiled it).
2. Final stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. `ARG VERSION`, `ARG NODE_VERSION=12.16.1`, `ARG NODE_SHA256=b826753f14df9771609ffb8e7d2cc4cb395247cb704cf0cea0f04132d9cf3505`, `ARG TARGETARCH`.
3. `USER root`. Fail clearly on arm64: `RUN [ "${TARGETARCH}" = "amd64" ] || (echo "nosqlclient is amd64 only" && exit 1)`. Packages: `xz-utils` (check the base first) to unpack Node, plus `ca-certificates`; pin versions if installed from apt and check them against the Ubuntu 26.04 archive.
4. Node 12: download `node-v${NODE_VERSION}-linux-x64.tar.xz`, `echo "${NODE_SHA256}  /tmp/node.tar.xz" | sha256sum -c -`, extract to `/usr/local/lib/node12` with `--strip-components=1`, link `/usr/local/bin/node12`; copy its `LICENSE` to `/usr/share/licenses/nosqlclient/LICENSE-node`.
5. `COPY --from=src /opt/meteor/dist/bundle /app` (read-only). Remove `/app/entrypoint.sh` (replaced by our `start.sh`). `COPY --from=src` the upstream `LICENSE` if the bundle contains one, otherwise fetch it from the GitHub tag `4.0.1` into `/usr/share/licenses/nosqlclient/LICENSE` (path UNVERIFIED); the bundled `programs/server/npm` tree has third-party licenses, keep it.
6. `chown -R root:root /app && chmod -R a+rX /app`.
7. `ENV HOME=/tmp/home PORT=3000 ROOT_URL=http://localhost NODE_ENV=production`.
8. `USER apps` as the last user line, then `COPY --chmod=0755 . /`, `EXPOSE 3000`, `VOLUME /config`, `WORKDIR /app`, `CMD ["/start.sh"]`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "nosqlclient" }

variable "VERSION" {
  // renovate: datasource=docker depName=mongoclient/mongoclient versioning=loose
  default = "4.0.1"
}

variable "NODE_VERSION" { default = "12.16.1" }
variable "NODE_SHA256" { default = "b826753f14df9771609ffb8e7d2cc4cb395247cb704cf0cea0f04132d9cf3505" }
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/nosqlclient/nosqlclient" }
```

`image` args: `VERSION`, `NODE_VERSION`, `NODE_SHA256`; OCI labels `source` and `licenses`. The stage image in the Dockerfile must use `ARG VERSION` before `FROM` (`ARG VERSION` then `FROM mongoclient/mongoclient:${VERSION}`), and the digest should be an additional pinned value so the tag and digest stay aligned. Targets: `docker-metadata-action`, `image`, `image-local` (`type=docker`, `${APP}:${VERSION}`), `image-all`: **`platforms = ["linux/amd64"]` only**, since there is no arm64 build (deviation from the standard two-platform list, documented in the PR). `group "default"` with `image-local`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/nosqlclient/nosqlclient"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: MONGO_URL
    default: ""
    required: false
  - name: MONGO_SCHEME
    default: "mongodb"
    required: false
  - name: MONGO_ADDRESSES
    default: "127.0.0.1:27017"
    required: false
  - name: MONGO_DATABASE
    default: "meteor"
    required: false
  - name: MONGO_USERNAME
    default: ""
    required: false
  - name: MONGO_PASSWORD
    default: ""
    required: false
  - name: MONGO_TLS
    default: ""
    required: false
  - name: MONGO_OPT_PARAMS
    default: ""
    required: false
  - name: MONGOCLIENT_DEFAULT_CONNECTION_URL
    default: ""
    required: false
  - name: ROOT_URL
    default: "http://localhost"
    required: false
  - name: PORT
    default: "3000"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: mongodb
```

`mongodb` exists in `apps/` (✅). The app stores its own data in MongoDB and also lets users browse other MongoDB servers. The draft's extra persistence `/data/db` (embedded MongoDB) is not carried over (section 9).

## 7. start.sh

Port of the upstream `entrypoint.sh`, without starting a local `mongod`:

1. `set -euo pipefail`; `mkdir -p /tmp/home /config`.
2. Support the `*_FILE` variant for `MONGO_URL`, `MONGO_USERNAME`, `MONGO_PASSWORD` (read the file; error when both are set).
3. When `MONGO_URL` is empty, build it from the parts: scheme, URL-encoded username and password (encode with `python3 -c 'import os,urllib.parse...'` reading the values from the environment, never from argv, so special characters and process lists are safe if python is present; otherwise use a small `node12` one-liner with `encodeURIComponent`), `MONGO_ADDRESSES`, `MONGO_DATABASE`, `?ssl=${MONGO_TLS:-false}`, optional `&${MONGO_OPT_PARAMS}`. Export `MONGO_URL` and, if empty, `MONGOCLIENT_DEFAULT_CONNECTION_URL`.
4. Print a clear warning when the address is `127.0.0.1` ("no MongoDB in this image, set MONGO_URL").
5. If `STARTUP_DELAY` is set, `sleep` it.
6. Seed `MONGOCLIENT_CONNECTIONS_FILE_PATH` only if the user set it; default it to `/config/predefined_connections.json` when that file exists. Never write under `/app`.
7. `cd /app; exec /usr/local/bin/node12 main.js`. The Meteor server binds `0.0.0.0` by default (Meteor listens on all interfaces unless `BIND_IP` is set, UNVERIFIED for this bundle: check `ss -ltn`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
filePaths:
- /app/main.js
- /usr/local/bin/node12
- /usr/share/licenses/nosqlclient/LICENSE-node
```

Port 3000 has a tcp probe. Meteor normally needs a reachable MongoDB at start; the test runs with no env and there is no sidecar. If, in the protocol's run step, the server does not open port 3000 without a database (UNVERIFIED), the app meets all three criteria of the database-dependent exception (hard `dependencies:` entry on `mongodb`, will not start without it, no sidecar in the suite). Then narrow to the `filePaths` assertions plus the log check and add above them: `# narrowed: requires external mongodb; full functional test not feasible in single-container suite`. Only do that if the failure is proven; do not narrow pre-emptively.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/data/db` (embedded mongod, chart persistence) | Dropped: no mongod in the image. Users point `MONGO_URL` at `apps/mongodb`. Existing embedded data must be migrated by the user. |
| `$HOME/.meteor`, npm cache, Node tmp | `HOME=/tmp/home`, `TMPDIR=/tmp`. |
| `/opt/meteor/dist` bundle writes (Meteor may write `programs/*/` caches, UNVERIFIED) | Bundle sits in read-only `/app`; if the run fails, set the offending paths via env or symlink them to `/tmp`. |
| Predefined connections file | `/config/predefined_connections.json` (optional). |
| `USER node` uid 1000 | `USER apps`. |

Draft reconciliation: chart uid 0 and writable rootfs are not needed; read-only is expected to work after the `/tmp` remaps; not privileged; `/data/db` persistence replaced by an external MongoDB, `/config` only keeps the optional connection file.

## 10. Risks, caveats and open questions

- amd64 only (no arm64 image or source build path): a blocker for multi-arch CI. The `image-all` target must be limited to `linux/amd64` or the repo CI matrix must allow it.
- Dormant 2020 Meteor app with Node 12 (end of life, unpatched vulnerabilities). Rebuilding from source (`meteor build`) is not realistic on a modern base. Decide if this image should be published at all; document the risk.
- Needs a reachable MongoDB; it is only useful with a database to browse (draft). Behaviour without one is UNVERIFIED.
- The image bundle path was verified from the upstream Dockerfile, not by inspecting the image layers.
- The `latest` and `4.0.1` manifests differ in digest; confirm they carry the same bundle (`docker run --entrypoint cat ... package.json`) or just use `4.0.1`.
- Renovate cannot help (no new releases); a stale-pin notice in the PR is appropriate.
- AGPL-3.0: ship the license text (section 4 step 5).
- Mongo version compatibility of the old driver with MongoDB 9 (`apps/mongodb`) is UNVERIFIED; the legacy driver may be unable to talk to a recent server.

## 11. Build and test steps

```sh
cd apps/nosqlclient
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name nosqlclient-probe --read-only --tmpfs /tmp \
  -v nosqlclient-probe-config:/config nosqlclient:4.0.1
docker logs -f nosqlclient-probe
forgetool containers test --image nosqlclient:4.0.1 --config ./apps/nosqlclient/container-test.yaml
docker rm -f nosqlclient-probe; docker volume rm nosqlclient-probe-config
```

Then repeat step 3 on a docker network together with the `mongodb` image and `-e MONGO_ADDRESSES=mongodb:27017`. Expected readiness: the Meteor line `=> Starting app on port 3000...` is printed by upstream's entrypoint only (our `start.sh` should print the same line for traceability), port 3000 opens and `curl http://localhost:3000/` serves the UI. Round limit 10; record `unfixable` if Node 12 cannot run on the Ubuntu base.

## 12. PR checklist

- Branch `feat/add-nosqlclient`, commit and PR title `feat(nosqlclient): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice to the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State plainly: amd64 only, Node 12 EOL, copied from a third-party 2020 image, MongoDB required and not bundled.
- Untested until built: the whole image (build, run, read-only), MongoDB 9 compatibility, bind address.
