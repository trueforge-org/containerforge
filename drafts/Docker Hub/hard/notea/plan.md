# notea — implementation plan
> Source: ./draft.md · Target: apps/notea/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | Notea `0.4.0-alpha` (git tag `v0.4.0-alpha`, the newest tag; `package.json` at the tag says `0.4.0-alpha`). The draft's image `diamkil/notea:latest` is a 2022-08-30 amd64-only repack of `cinwell/notea` (2021 `latest`). `cinwell/notea:main` (2024-02-24, amd64+arm64) is newer than the tag, and `master` has moved on; the plan uses the tag. |
| Project state | README of `QingWei-Li/notea`: "this project is barely maintained anymore"; the maintainer recommends Logseq. No GitHub releases, tags only. |
| Renovate (Notea) | `datasource=github-tags depName=QingWei-Li/notea extractVersion=^v(?<version>.+)$ versioning=loose`. |
| Renovate (MinIO) | `datasource=github-tags depName=minio/minio versioning=loose` for tags of the form `RELEASE.2025-10-15T17-29-55Z` (latest tag seen). |
| License | Notea: `MIT` (GitHub license API, `package.json`). MinIO: `AGPL-3.0` (README: "GNU AGPL v3.0"; use `AGPL-3.0-or-later` only if the license header says so, UNVERIFIED). Image `LICENSE` value: `MIT AND AGPL-3.0-only`. |
| Source URLs | https://github.com/QingWei-Li/notea and https://github.com/minio/minio |
| Notea binary | None. Build from the tag tarball `https://github.com/QingWei-Li/notea/archive/refs/tags/v0.4.0-alpha.tar.gz`: `yarn install --frozen-lockfile`, `yarn build` (`next build`), `yarn install --production --frozen-lockfile`; run with `next start`. Next.js `^12`. The upstream Dockerfile at the tag builds with `node:16-alpine`; its final image copies `public`, `.next`, `node_modules` into `/app`, sets `CONFIG_FILE=/app/config/notea.yml`, `LOG_DIRECTORY=/app/logs`. |
| MinIO binary | **Not downloadable any more.** `https://dl.min.io/server/minio/release/linux-*/minio` and its `.sha256sum` return `410 Gone` ("open-source MinIO Server ... archived and no longer maintained ... no longer served"). The `minio/minio` Docker Hub tags were not obtainable either (empty listing). So the draft's "MinIO binary" must be **built from source** at tag `RELEASE.2025-10-15T17-29-55Z` (`go.mod` says `go 1.24.0`). |
| Checksums | None for the Notea source archive (UNVERIFIED); MinIO source built from a git tag, so no checksum either. |
| Third-party Dockerfile | `diamkil/docker-notea` at `2dd8354`: `FROM node:alpine`, copies `/bin/minio` and the `cinwell/notea` bundle, installs supervisor, `EXPOSE 3000 9000`, supervisor runs `MinIO-Start.sh` (`minio server /data`, `MINIO_ROOT_USER=$STORE_USER`, `MINIO_ROOT_PASSWORD=$STORE_PASSWORD`) and `Notea-Start.sh` (`STORE_ACCESS_KEY=$STORE_USER`, `STORE_SECRET_KEY=$STORE_PASSWORD`, `STORE_BUCKET=notea`, `STORE_END_POINT=http://localhost:9000`, `STORE_FORCE_PATH_STYLE=true`, `COOKIE_SECURE=false`, `DIRECT_RESPONSE_ATTACHMENT=true`, `mkdir -p /data/notea`, `next start`). It is Alpine (musl), so it cannot be copied to Ubuntu: the draft's copy-from `no` is right. |
| Env vars (Notea `libs/server/config.ts` and README) | `PASSWORD`, `DISABLE_PASSWORD`, `CONFIG_FILE` (default `./notea.yml`), `STORE_ACCESS_KEY`, `STORE_SECRET_KEY`, `STORE_BUCKET` (default `notea`), `STORE_END_POINT`, `STORE_REGION` (default `us-east-1`), `STORE_FORCE_PATH_STYLE`; the third-party image adds `COOKIE_SECURE`, `DIRECT_RESPONSE_ATTACHMENT`. **Without `PASSWORD` or `DISABLE_PASSWORD` the app reports a configuration error**, which matters for the env-less container test. `STORE_USER` and `STORE_PASSWORD` are names of the third-party wrapper, not Notea itself. |
| Ports | 3000 (Next.js default; `next start` default port), 9000 (MinIO S3 API). |

## 2. Target layout

```
apps/notea/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Final stage `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, as in the draft: its Node runs `next start`. (The Python part is unused; if you prefer, `ubuntu` plus a pinned apt `nodejs` also works, but `python-node` is the documented Node base.) Build stage 1 for the Notea bundle: the same `python-node` image with `yarn` (enable via `corepack`, UNVERIFIED that it is available). Build stage 2 for MinIO: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` with `golang-go` and `build-essential`, as in `apps/pwndrop`. Closest siblings: `apps/pwndrop` (Go build from source) and `apps/budge` (python-node with Node app).

## 4. Dockerfile

1. Stage `notea` (python-node): `ARG VERSION`; `USER root`; download the tag tarball to `/src`; `NODE_OPTIONS=--openssl-legacy-provider` (Next 12 and webpack 5 fail on modern Node with the default OpenSSL provider; UNVERIFIED for the base's Node); `yarn install --frozen-lockfile && yarn build && yarn install --production --frozen-lockfile`, with `YARN_CACHE_FOLDER=/tmp/yarn`; assemble `/out/notea/{public,.next,node_modules,package.json,next.config.js}`; copy `LICENSE` to `/out/licenses/notea-LICENSE`.
2. Stage `minio` (ubuntu): `ARG MINIO_VERSION`; install `build-essential golang-go ca-certificates git` (pin versions from apt, and check `go version` is at least 1.24, because MinIO's `go.mod` requires 1.24.0; if Ubuntu's Go is older, use an official `golang` image in a build stage instead, which the repo rules allow); `git clone --depth 1 --branch "${MINIO_VERSION}" https://github.com/minio/minio`; `CGO_ENABLED=0 GOCACHE=/tmp/gocache GOFLAGS=-trimpath go build -o /out/minio .`; copy MinIO `LICENSE` and `NOTICE`/`CREDITS` to `/out/licenses/`.
3. Final stage: `ARG VERSION`; `USER root`; `COPY --from=notea /out/notea /app/notea`; `COPY --from=minio /out/minio /usr/local/bin/minio`; licenses to `/usr/share/licenses/notea/`. Symlink `/app/notea/.next/cache` to `/tmp/next-cache` (Next writes its image cache there at run time). `chown -R root:root /app && chmod -R a+rX /app`.
4. No extra apt packages expected (curl is in the base; check). Nothing installed from apt means nothing to pin.
5. `ENV HOME=/tmp/home NODE_ENV=production NODE_OPTIONS=--openssl-legacy-provider CONFIG_FILE=/config/notea.yml NEXT_TELEMETRY_DISABLED=1`.
6. `USER apps` last, then `COPY --chmod=0755 . /`, `EXPOSE 3000 9000`, `VOLUME /config`, `WORKDIR /app/notea`, `CMD ["/start.sh"]`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "notea" }

variable "VERSION" {
  // renovate: datasource=github-tags depName=QingWei-Li/notea extractVersion=^v(?<version>.+)$ versioning=loose
  default = "0.4.0-alpha"
}

variable "MINIO_VERSION" {
  // renovate: datasource=github-tags depName=minio/minio versioning=loose
  default = "RELEASE.2025-10-15T17-29-55Z"
}

variable "LICENSE" { default = "MIT AND AGPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/QingWei-Li/notea" }
```

`image` args: `VERSION`, `MINIO_VERSION`; OCI labels `source` and `licenses`. Targets: `docker-metadata-action`, `image`, `image-local` (`type=docker`, `${APP}:${VERSION}`), `image-all` (amd64 and arm64: both are possible because everything is built from source), `group "default"` with `image-local`. Validate with `docker buildx bake --print`. Renovate may propose no newer MinIO tag (the project is archived): the pin is expected to stay.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/QingWei-Li/notea"
ports:
  - port: 3000
    protocol: tcp
    required: false
  - port: 9000
    protocol: tcp
    required: false
env:
  - name: PASSWORD
    default: ""
    required: false
  - name: DISABLE_PASSWORD
    default: ""
    required: false
  - name: STORE_END_POINT
    default: ""
    required: false
  - name: STORE_ACCESS_KEY
    default: ""
    required: false
  - name: STORE_SECRET_KEY
    default: ""
    required: false
  - name: STORE_BUCKET
    default: "notea"
    required: false
  - name: STORE_REGION
    default: "us-east-1"
    required: false
  - name: COOKIE_SECURE
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`PASSWORD` is not `required: true` because `start.sh` generates one when neither it nor `DISABLE_PASSWORD` is set. If `STORE_END_POINT` is empty the bundled MinIO is used (credentials generated); setting it selects an external S3 and the bundled MinIO is not started. Not listed: `STORE_USER` and `STORE_PASSWORD` (names of the third-party wrapper only, not read by the apps; our `start.sh` uses generated values). No `dependencies:` (none; bundled storage).

## 7. start.sh

1. `set -euo pipefail`; `mkdir -p /config /tmp/home /tmp/next-cache`.
2. **Auth**: if neither `PASSWORD` nor `DISABLE_PASSWORD` is set, read or create `/config/.notea_password` (random 24 chars, mode 600) and export it as `PASSWORD`; print the file path, not the secret.
3. **Storage**: if `STORE_END_POINT` is empty, use bundled MinIO: read or create `/config/.minio_credentials` (access key and secret, mode 600, only created when missing, so restarts keep them); export `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD`; `mkdir -p /config/minio/${STORE_BUCKET:-notea}` (a directory under the data dir is the bucket, same trick as the third-party image); start `minio server /config/minio --address :9000 --console-address 127.0.0.1:9001 &`; wait until port 9000 answers (`/minio/health/live`, UNVERIFIED path for this release); export `STORE_ACCESS_KEY`, `STORE_SECRET_KEY`, `STORE_END_POINT=http://localhost:9000`, `STORE_FORCE_PATH_STYLE=true`, `STORE_BUCKET`. Credentials stay in the environment and mode-600 files, never on the command line.
4. `export COOKIE_SECURE="${COOKIE_SECURE:-false}"`, `STORE_FORCE_PATH_STYLE` defaults to `true` only for bundled MinIO.
5. Trap `SIGTERM`/`SIGINT` to stop both processes. The app is the last process: run `node_modules/.bin/next start -H 0.0.0.0 -p 3000` as a child, `wait -n` on it and MinIO, and exit non-zero when either dies. (A plain `exec` is not possible with two processes.)
6. Nothing is written to `/app`; `.next/cache` goes to `/tmp` through the build-time symlink.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
- port: '9000'
http:
- port: '3000'
  path: /
filePaths:
- /app/notea/node_modules/.bin/next
- /usr/local/bin/minio
- /usr/share/licenses/notea/notea-LICENSE
```

Every port in `settings.yaml` (3000, 9000) has a tcp probe. The test runs with no env vars: because of step 2 and 3 of `start.sh` it still starts, so a generated password and bundled MinIO are exercised. `/` may redirect to a login page; if the HTTP status is not 200, assert the real status that the running image returns (do not drop the check).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/data/notea`, `/data` (MinIO data and bucket directory, chart has no persistence) | `/config/minio/notea` on the `/config` volume (adds the persistence the chart lacked). |
| `.next/cache` | symlink to `/tmp/next-cache`. |
| `LOG_DIRECTORY=/app/logs` in the repo Dockerfile | not set; logs go to stdout. |
| `~/.minio`, `~/.cache`, `~/.config` | `HOME=/tmp/home`; MinIO config dir `--config-dir /tmp/minio-config` if it insists on writing one (UNVERIFIED). |
| Notea config file | `CONFIG_FILE=/config/notea.yml` (optional). |
| supervisor running as root | removed; `start.sh` supervises as `apps`. |

Draft reconciliation: chart uid 0 and writable rootfs are not needed; read-only is expected after the remaps; not privileged; the draft's "extra-persistence none" becomes `/config` (otherwise notes vanish on restart, as the draft warns).

## 10. Risks, caveats and open questions

- **MinIO is archived and its release binaries are gone** (410 Gone). Building it from the last source tag is possible but ships an unmaintained, unpatched AGPL object store. Alternatives: require an external S3 endpoint (drop bundled MinIO), or depend on another ContainerForge storage app (none exists in `apps/` for S3). Decide before porting.
- Notea itself is unmaintained, alpha, Next 12: expect vulnerable dependencies.
- The `v0.4.0-alpha` tag differs from the 2021 image used today, and from `cinwell/notea:main`; behaviour (config handling, env names) may differ from the current chart, in particular `PASSWORD` handling and `COOKIE_SECURE`.
- Next 12 on the base's current Node may need `--openssl-legacy-provider` or an older Node, UNVERIFIED; if the build fails, use Node 16 via a pinned nodejs binary as in `nosqlclient`'s plan.
- Two processes in one container, so both must be healthy (draft). Bundled MinIO listens on `0.0.0.0:9000` with generated credentials so that other containers and browsers can reach attachments; for external S3 set `STORE_END_POINT` and nothing is exposed on 9000.
- Go version in Ubuntu 26.04 must be at least 1.24, UNVERIFIED.
- Generated first-run password: users need to read `/config/.notea_password` (or set `PASSWORD`).
- arm64 untested.

## 11. Build and test steps

```sh
cd apps/notea
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name notea-probe --read-only --tmpfs /tmp \
  -v notea-probe-config:/config notea:0.4.0-alpha
docker logs -f notea-probe
forgetool containers test --image notea:0.4.0-alpha --config ./apps/notea/container-test.yaml
docker rm -f notea-probe; docker volume rm notea-probe-config
```

Expected readiness: MinIO reports it is online on port 9000 (exact banner UNVERIFIED), Next prints `ready - started server on 0.0.0.0:3000` (Next 12 wording, UNVERIFIED), no `exited` or configuration error lines, ports 3000 and 9000 open. Create a note through the UI and restart the container on the same volume to prove persistence. Round limit 10.

## 12. PR checklist

- Branch `feat/add-notea`, commit and PR title `feat(notea): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice to the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State plainly: MinIO built from an archived tag, Notea unmaintained, two services in one container, data now persisted in `/config`.
- Untested until built: everything (build, run, read-only, arm64, Node/openssl behaviour, MinIO health path).
