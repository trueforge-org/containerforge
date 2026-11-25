# tubearchivist-redisjson — implementation plan
> Source: ./draft.md · Target: apps/tubearchivist-redisjson/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Redis `8.12.0` (latest release, published 2026-11-22; https://api.github.com/repos/redis/redis/releases/latest). Redis 8 includes the JSON data type natively. |
| Replaced image | Chart uses `docker.io/redislabs/rejson:latest` (draft). RedisJSON upstream: latest tag `v2.8.19` (2026-04-28, https://api.github.com/repos/RedisJSON/RedisJSON/releases/latest). The RedisJSON README says: "Starting with Redis 8, the JSON data structure is integral to Redis. You don't need to install this module separately. We no longer release standalone versions of RedisJSON." So there is no standalone module binary to fetch. |
| Renovate | `datasource=github-releases depName=redis/redis versioning=semver` (tag `8.12.0`). |
| License | Redis 8 is tri-licensed: "Version 8.0.x and subsequent releases are subject to the tri-license RSALv2/SSPLv1/AGPLv3 at your option" (https://raw.githubusercontent.com/redis/redis/unstable/README.md). GitHub reports `NOASSERTION` for RedisJSON. Planned `LICENSE` value: `AGPL-3.0` (the option ContainerForge can redistribute under). Confirm with the user before merge (section 10). |
| Source URL | https://github.com/redis/redis (engine). https://github.com/RedisJSON/RedisJSON (JSON module, now merged into Redis). |
| Download | No prebuilt binary is published as a release asset. Install from the official Redis apt repository (see section 4). |
| Per-arch | UNVERIFIED: arm64 availability of the Redis apt repository packages for Ubuntu 26.04. Must be checked at build time with `apt-cache policy`. |
| Checksum source | Apt repository signing key (UNVERIFIED: repo and key URL not fetched). |
| Upstream Dockerfile | Chart image was built from https://github.com/RedisJSON/RedisJSON/blob/9ca1c88acd9cadfcbc0e4f805ff3de473bd50b60/Dockerfile (draft). Not needed: we do not compile RedisJSON, because Redis 8 bundles it. |
| Redis install docs | UNVERIFIED: the redis.io install pages and `packages.redis.io` could not be fetched during this run (404 / 403). The writer must read the official Redis apt instructions before writing the Dockerfile. |
| Port | 6379/tcp (Redis default; UNVERIFIED against the chart service). |
| Data path | The chart mounts data at `/data` (draft). Official Redis images use `/data`; apt `redis-server` defaults to `/var/lib/redis` (UNVERIFIED). Plan uses `/config` (section 9). |
| Env vars | None documented in the chart. Plan reads `REDIS_PASSWORD` and `REDIS_PORT`, mirroring `apps/valkey/start.sh`. |

## 2. Target layout

- `apps/tubearchivist-redisjson/Dockerfile`
- `apps/tubearchivist-redisjson/docker-bake.hcl`
- `apps/tubearchivist-redisjson/settings.yaml`
- `apps/tubearchivist-redisjson/container-test.yaml`
- `apps/tubearchivist-redisjson/start.sh`
- `apps/tubearchivist-redisjson/health/` (copy the ping probe pattern from `apps/valkey/health/` only if the writer uses a `healthCommands` probe; the plan uses `tcp` instead, so this folder is optional).

No `defaults/`, `etc/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
Reason: no language runtime is needed. The draft's "ubuntu alone is enough" holds. Closest sibling: `apps/valkey` (same kind of in-memory server, same `start.sh` pattern, apt install from a vendor repo, pinned package version). `apps/valkey` does not ship the JSON module, so it cannot replace this image.

## 4. Dockerfile

1. `# hadolint ignore=DL3007` and `FROM <ubuntu>`, `ARG VERSION`, `ARG PACKAGE_VERSION`, `USER root`.
2. Add the official Redis apt repository. UNVERIFIED: exact keyring path, sources line and package names. The writer confirms these from the Redis install docs before writing the file. Expected form: download the signing key to `/usr/share/keyrings/redis-archive-keyring.gpg`, add one `deb [signed-by=...] <repo URL> <codename> main` line, `apt-get update`.
3. Install a pinned version, following `apps/valkey/Dockerfile`:
   `test "${PACKAGE_VERSION%%-*}" = "${VERSION}"` then `apt-get install -y --no-install-recommends redis-server=${PACKAGE_VERSION} redis-tools=${PACKAGE_VERSION}`.
   `PACKAGE_VERSION` is UNVERIFIED: take the exact `8.12.0-…` string from `apt-cache policy redis-server` at build time.
4. `apt-get purge -y --auto-remove` and `rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*`.
5. `COPY --chmod=0755 start.sh /start.sh`.
6. Verify the module is present in the build: `redis-server --version` must report `8.12.x`, and `redis-cli` with a temporary server must accept `JSON.SET`. Put this check in the Dockerfile `RUN` as `redis-server --version | grep -q "v=${VERSION}"`.
7. Tail, following `apps/valkey/Dockerfile`:

```dockerfile
ENV REDIS_PORT=6379 REDIS_DATA_DIR=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 6379
VOLUME /config
CMD ["/start.sh"]
```

`VOLUME /config` is needed because the server keeps data there.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "tubearchivist-redisjson"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=redis/redis versioning=semver
  default = "8.12.0"
}

variable "PACKAGE_VERSION" {
  default = "8.12.0-UNVERIFIED"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/redis/redis"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
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
  platforms = ["linux/amd64", "linux/arm64"]
}
```

`PACKAGE_VERSION` must be replaced with the verified apt version string (section 4, step 3). `VERSION` must equal the Dockerfile `ARG VERSION` default. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://redis.io"
ports:
  - port: 6379
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
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

`TubeArchivist` reads its own Redis connection variables. Those names are UNVERIFIED for this run, so they are not added here. Add them only when the TubeArchivist app is confirmed.

## 7. start.sh

Follows `apps/valkey/start.sh`, with `redis-server` and the `REDIS_*` names:

```bash
#!/bin/bash
set -euo pipefail

REDIS_PASSWORD="${REDIS_PASSWORD:-}"
REDIS_PORT="${REDIS_PORT:-6379}"
REDIS_DATA_DIR="${REDIS_DATA_DIR:-/config}"
REDIS_APPENDONLY="${REDIS_APPENDONLY:-yes}"

if [[ "${1:-}" == "/start.sh" ]]; then
  shift
fi

mkdir -p "$REDIS_DATA_DIR"

args=(--bind 0.0.0.0 --port "$REDIS_PORT" --dir "$REDIS_DATA_DIR")

# Same dump.rdb / AOF handling as apps/valkey/start.sh: an existing dump.rdb is ignored when the
# server starts with AOF on and no AOF yet, so load the snapshot first and enable AOF once it is up.
if [[ "$REDIS_APPENDONLY" == "yes" && -f "$REDIS_DATA_DIR/dump.rdb" && ! -d "$REDIS_DATA_DIR/appendonlydir" ]]; then
  args+=(--appendonly no)
  (
    export REDISCLI_AUTH="$REDIS_PASSWORD"
    until [[ "$(redis-cli -p "$REDIS_PORT" ping 2>/dev/null)" == "PONG" ]]; do
      sleep 1
    done
    redis-cli -p "$REDIS_PORT" config set appendonly yes >/dev/null
  ) &
else
  args+=(--appendonly "$REDIS_APPENDONLY")
fi

if [[ -n "$REDIS_PASSWORD" ]]; then
  args+=(--requirepass "$REDIS_PASSWORD")
fi

exec redis-server "${args[@]}" "$@"
```

- Seeds nothing: Redis creates its own files in `/config` on first start (the dir is created when missing).
- Idempotent: the snapshot-then-AOF logic from `apps/valkey/start.sh` is included above, so existing RDB data is loaded on the first start with AOF on (UNVERIFIED that Redis 8 shares the valkey behaviour; test with a `dump.rdb` in `/config`).
- Passwords are applied on every start (`--requirepass` from the env). This puts the password in the process list, as `apps/valkey/start.sh` does; UNVERIFIED whether a safer route (config file in `/tmp`) is wanted, since `redis-server` has no password env var.
- Binds `0.0.0.0` so other containers can reach it (ContainerForge rule).
- Writes nothing under `/app`. Caches and temp files go to `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '6379'
filePaths:
- /usr/bin/redis-server
- /usr/bin/redis-cli
```

- One `tcp` probe for port 6379 (coverage minimum). A `healthCommands` probe with `redis-cli ping` is also possible, but the schema must accept it; the plan uses the `tcp` probe.
- The test runs with no `REDIS_PASSWORD`, so the password code path is not covered by the test. Add the password path as a manual check (section 11).
- The JSON command check (`JSON.SET`) is not in forgetool primitives, so it is covered by the build-time `redis-server --version` check and the manual run.

## 9. Rootless and read-only-rootfs adaptations

| Upstream / chart behaviour | Adaptation |
| --- | --- |
| Chart mounts data at `/data` (pvc) | Data lives in `/config`. Users with existing data mount their old `/data` contents into `/config` (document in the PR). |
| Old image runs as root (`runAsUser 0`) | Runs as `apps`. Redis needs no root to listen on 6379. |
| Chart `readOnlyRootFilesystem: false` | Image works with `--read-only --tmpfs /tmp`: Redis writes only to `--dir` (`/config`). |
| Redis temp files (`/tmp`) | Covered by `--tmpfs /tmp`. |
| `/app` read-only | Nothing is written there. |

## 10. Risks, caveats and open questions

- **Redis apt repository** (section 4) is UNVERIFIED: repo URL, keyring path, package names and `arm64` availability were not confirmed. This is a blocker until the writer reads the official install docs.
- **Licensing**: Redis 8 is tri-licensed (RSALv2 / SSPLv1 / AGPLv3). `LICENSE` is set to `AGPL-3.0` in section 5 as a planning choice. Confirm before merge, because the `LICENSE` value must match the software in the image.
- **Data migration**: the old image is Redis 6.2 with the rejson and redisearch modules. Loading an existing 6.2 RDB into Redis 8 is UNVERIFIED. Document this in the PR, and say that a backup is needed.
- **Behaviour change**: the module set changes (Redis 8 bundles JSON and the query engine). Clients that used `redisearch` commands from the old image should be checked.
- **arm64**: the old image is amd64 only. The new build is untested on arm64, so `image-all` is not validated.
- **`/data` vs `/config`** (draft caveat): the chart expects `/data`. This plan uses `/config`, per the ContainerForge rule. The chart must be updated, or the mount path reconciled, or data goes to the wrong place.
- **Blockers**: section 4 (apt repo unverified) only. No GPU, no privileged need, not musl-only.

## 11. Build and test steps

```sh
cd apps/tubearchivist-redisjson
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name tubearchivist-redisjson-probe --read-only --tmpfs /tmp \
  -v tubearchivist-redisjson-probe-config:/config -p 6379:6379 \
  tubearchivist-redisjson:8.12.0
docker logs -f tubearchivist-redisjson-probe
docker exec tubearchivist-redisjson-probe redis-cli JSON.SET doc '$' '{"a":1}'
docker exec tubearchivist-redisjson-probe redis-cli JSON.GET doc
forgetool containers test --image tubearchivist-redisjson:8.12.0 --config ./apps/tubearchivist-redisjson/container-test.yaml
docker rm -f tubearchivist-redisjson-probe; docker volume rm tubearchivist-redisjson-probe-config
```

- Readiness signal: the log line `Ready to accept connections` and no `FATAL` lines.
- Password path: run once with `-e REDIS_PASSWORD=test`, and check `redis-cli PING` fails without `-a` and succeeds with it.
- Restart test: keep the `/config` volume, restart, and confirm the JSON document is still there.

## 12. PR checklist

- Branch `feat/add-tubearchivist-redisjson`, commit and PR title `feat(tubearchivist-redisjson): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it, and the `license/cla` check shows the status.
- Say what was not tested: arm64, data migration from the 6.2 image, the Redis apt repository steps if they could not be confirmed, and the TubeArchivist client itself.
- `docker buildx bake --print` passes, and `VERSION` and `PACKAGE_VERSION` match the Dockerfile.
