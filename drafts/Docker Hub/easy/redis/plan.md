# redis — implementation plan
> Source: ./draft.md · Target: apps/redis/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `8.0.5`: the version of Ubuntu 26.04's apt packages. Latest upstream release is `8.12.0` (GitHub API), so the image will **lag upstream**. Bitnami's build in the draft is `8.10`. |
| apt packages | `redis-server` and `redis-tools`, both `5:8.0.5-1ubuntu0.1` in `resolute-updates`/`-security` (also `5:8.0.5-1` in release), component `universe` (Launchpad API, amd64 and arm64). |
| Renovate | Not usable for the Ubuntu package in this repo today. Copy the comment style of `apps/valkey/docker-bake.hcl` (a NOTE that the version is tied to the base image, and the disabled `repologydepName=ubuntu_26_04/redis` line). UNVERIFIED that the repology project name for Ubuntu 26.04 is `ubuntu_26_04/redis`. |
| License | Redis 8 is tri-licensed: RSALv2, SSPLv1 or AGPLv3 at the user's choice (upstream `LICENSE.txt`; Debian's `copyright` for the 8.0.2 package says the same). SPDX expression for bake: `LicenseRef-RSALv2 OR SSPL-1.0 OR AGPL-3.0-only` (the SPDX license list has no RSAL identifier, so a `LicenseRef-` is used). Be aware that this is not an OSI-only license; the maintainers may prefer `valkey` (BSD-3-Clause, already in `apps/valkey`). |
| Source | https://github.com/redis/redis |
| Download | apt only (`apt:redis-server`), so no per-arch URL and no checksum step; apt verifies signatures. |
| Upstream Dockerfile reviewed | The draft points to the Bitnami Dockerfile (`bitnami/redis/8.10/debian-12`), which is closed/unfetched here (UNVERIFIED), so it was not copied. The real model is `apps/valkey` in this repo. |
| Ports | 6379/tcp |
| Env | The server reads no env vars itself. `start.sh` defines `REDIS_PASSWORD`, `REDIS_PORT`, `REDIS_DATA_DIR`, `REDIS_APPENDONLY` (same names the valkey sibling accepts as fallbacks). |
| Ubuntu package behaviour | The package's default config (`/etc/redis/redis.conf`) binds to localhost, writes to `/var/lib/redis` and `/var/log/redis`, and has `protected-mode yes`. We do not use it; we pass our own arguments. UNVERIFIED: that the package postinst runs cleanly inside a Docker build (the valkey sibling does the same and builds). |

## 2. Target layout

```
apps/redis/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  health/ping_liveness_local.sh   # copied from the valkey pattern, with redis-cli
```
`health/` is needed for a `healthCommands` probe (as `apps/valkey` does; `health/` is in the `.dockerignore` allow-list). No `root/`. `DOWNSTREAM_CHANGES.md` is not needed unless something later uses this image as `FROM`: `rg "trueforge-org/redis" apps/*/Dockerfile` found no use (re-check at porting time).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Closest sibling: `apps/valkey` (same role, same apt-pin approach; it uses the tag `26.4` with the same digest, which resolves to the same image). `valkey-tools` gives `valkey-cli`; here `redis-tools` gives `redis-cli`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG PACKAGE_VERSION`; `USER root`.
2. One `RUN`, pinning exactly as valkey does, with the epoch handled:
   ```dockerfile
   RUN test "${PACKAGE_VERSION#*:}" != "${PACKAGE_VERSION}" && \
       test "$(echo "${PACKAGE_VERSION#*:}" | sed 's/-.*//')" = "${VERSION}" && \
       apt-get update && \
       apt-get install -y --no-install-recommends \
           "redis-server=${PACKAGE_VERSION}" \
           "redis-tools=${PACKAGE_VERSION}" \
       && apt-get purge -y --auto-remove \
       && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
   ```
   (`5:8.0.5-1ubuntu0.1`: strip the epoch `5:` and the Debian revision to get `8.0.5`; the guard fails the build when `VERSION` and `PACKAGE_VERSION` drift apart.) Add `# hadolint ignore=DL3008,DL3015` as valkey does.
3. No download, no checksum, no arch mapping, no `/app` content (the binary lives in `/usr/bin`, so `/app` stays empty for downstream consumers).
4. License: `mkdir -p /usr/share/licenses/redis && cp /usr/share/doc/redis-server/copyright /usr/share/licenses/redis/` (apt already ships it; UNVERIFIED exact path).
5. `COPY --chmod=0755 health /health` and `COPY --chmod=0755 start.sh /start.sh` (valkey does this before `USER apps`), `ENV REDIS_PORT=6379 HOME=/tmp`.
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 6379`, `VOLUME /config`, `CMD ["/start.sh"]` (as valkey).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "redis" }
variable "VERSION" {
  // NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile
  // TODO: renovate (repology) disabled like apps/valkey; bump VERSION and PACKAGE_VERSION together
  default = "8.0.5"
}
variable "PACKAGE_VERSION" { default = "5:8.0.5-1ubuntu0.1" }
variable "LICENSE" { default = "LicenseRef-RSALv2 OR SSPL-1.0 OR AGPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/redis/redis" }
```
`target "image"` passes `VERSION` and `PACKAGE_VERSION` in `args`; standard `docker-metadata-action`, `image-local` (`${APP}:${VERSION}`), `image-all` (amd64 + arm64), `group "default"`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/redis/redis"
ports:
  - port: 6379
    protocol: tcp
    required: false
env:
  - name: REDIS_PASSWORD
    default: ""
    required: false
  - name: REDIS_PORT
    default: "6379"
    required: false
  - name: REDIS_DATA_DIR
    default: "/config"
    required: false
  - name: REDIS_APPENDONLY
    default: "yes"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
Defaults equal the ones in `start.sh`. Unlike valkey, the password default is empty (no well-known default password).

## 7. start.sh

Modelled on `apps/valkey/start.sh`, with these differences:
- Variables `REDIS_PASSWORD`, `REDIS_PORT` (default 6379), `REDIS_DATA_DIR` (default `/config`), `REDIS_APPENDONLY` (default `yes`); `mkdir -p "$REDIS_DATA_DIR"`.
- Build `args=(--port "$REDIS_PORT" --dir "$REDIS_DATA_DIR" --daemonize no --supervised no --logfile "" --protected-mode yes)`.
- **No password:** bind `127.0.0.1 -::1` only (as two arguments: `--bind 127.0.0.1 -::1`) and print `redis: no REDIS_PASSWORD set, listening on localhost only` (start-script rule for databases without a password).
- **Password set:** `--bind 0.0.0.0`. The password is **not** put on the command line (valkey does, which is visible in the process list). Write `/tmp/redis-auth.conf` with `umask 077`, containing `requirepass "<escaped>"` where `\` and `"` are escaped (`${v//\\/\\\\}`, `${v//\"/\\\"}`), and pass it as the first positional argument: `exec redis-server /tmp/redis-auth.conf "${args[@]}" "$@"`. The password is applied on every start, so changing it works on existing data.
- Keep valkey's AOF handling: if `REDIS_APPENDONLY=yes`, `$DATA/dump.rdb` exists and `$DATA/appendonlydir` does not, start with `--appendonly no` and enable AOF once the server answers `PONG` (`REDISCLI_AUTH` from env), so an existing RDB is not ignored. UNVERIFIED that Redis 8 has the same "ignores RDB when AOF is on and empty" behaviour as Valkey; keep the logic only after testing it, otherwise use `--appendonly "$REDIS_APPENDONLY"` directly.
- Accept `$1 == /start.sh` and shift, as valkey does. Final line: `exec redis-server ...`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

healthCommands:
- command: /health/ping_liveness_local.sh 2
tcp:
- port: '6379'
filePaths:
- /usr/bin/redis-server
- /usr/share/licenses/redis
```
The test has no env, so it runs without a password: the server listens on localhost (the tcp check runs inside the container, so it passes). `health/ping_liveness_local.sh` is the valkey script with `valkey-cli` replaced by `redis-cli` and `REDISCLI_AUTH` taken from `REDIS_PASSWORD`. The password branch is not tested here; run it by hand.

## 9. Rootless and read-only-rootfs adaptations

- Upstream/package write paths: RDB and AOF in the data dir (`--dir`), pid and log files under `/var/run/redis` and `/var/log/redis` (not used: `--logfile ""`, no pidfile, `--daemonize no`), the Ubuntu config under `/etc/redis` (read only, not used). Data goes to `/config`; the auth file and scratch go to `/tmp`.
- Draft/chart: runs with a writable root and data in `/bitnami/redis`, plus `/health` probe scripts from a configmap. The plan: UID 568, read-only root, data in `/config` (mismatch with the chart's mount: migrate by copying `dump.rdb`/`appendonlydir` into `/config`), and `/health` baked into the image.
- Not privileged. Redis may warn about `vm.overcommit_memory` and transparent hugepages; these are host settings and not fatal.

## 10. Risks, caveats and open questions

- **Version lag:** apt gives 8.0.5 while upstream is 8.12.0. Ubuntu 26.04 users get security backports only. If a current Redis is required, a source build would be a different, larger plan (not "easy").
- **Overlap:** `apps/valkey` already fills the role with a permissive license. Ask whether `redis` should exist at all, given Redis' license change (the license field above is a choice among three, not an OSI-only one).
- Draft caveats kept: data is not under `/config` upstream (solved by `--dir`); a non-local bind needs `requirepass` (solved by localhost-only binding when no password is set).
- UNVERIFIED: that `redis-server` from Ubuntu has no loadable modules; the Redis 8 "bundled modules" (JSON, search, ...) are not expected in the Debian build.
- No blockers (no musl, GPU, privilege; both arches in Ubuntu).

## 11. Build and test steps

```sh
cd apps/redis
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create redis-probe-config
docker run --rm -d --name redis-probe --read-only --tmpfs /tmp \
  -v redis-probe-config:/config redis:8.0.5
docker logs -f redis-probe        # expect "Ready to accept connections" and the localhost-only notice
docker exec redis-probe redis-cli ping    # PONG
docker rm -f redis-probe
docker network create redis-probe-net
docker run --rm -d --name redis-probe --network redis-probe-net --read-only --tmpfs /tmp -v redis-probe-config:/config \
  -e REDIS_PASSWORD='p"a\ss word' redis:8.0.5
# connect from another container; --entrypoint is needed, else the base entrypoint runs /start.sh
docker run --rm --network redis-probe-net --entrypoint redis-cli redis:8.0.5 -h redis-probe -a 'p"a\ss word' --no-auth-warning ping
docker rm -f redis-probe; docker volume rm redis-probe-config; docker network rm redis-probe-net
forgetool containers test --image redis:8.0.5 --config ./apps/redis/container-test.yaml
```
Then test restart with an existing `dump.rdb` and `REDIS_APPENDONLY=yes` (data must survive), and confirm `ps` shows no password on the command line.

## 12. PR checklist

- Branch `feat/add-redis`, commit and PR title `feat(redis): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick only what applies; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State untested: arm64, the RDB-to-AOF migration on Redis 8, the apt package inside the build, anything not built locally. Mention the license choice and the lag behind upstream 8.12.0.
- Confirm `bake --print` passes; `VERSION` and `PACKAGE_VERSION` agree with the Dockerfile guard; `ARG`s match bake; no `root/`.
