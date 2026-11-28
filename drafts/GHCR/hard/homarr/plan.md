# homarr — implementation plan
> Source: ./draft.md · Target: apps/homarr/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Draft container | `ghcr.io/homarr-labs/homarr:v2.13.1` |
| Upstream Dockerfile | https://raw.githubusercontent.com/homarr-labs/homarr/v2.13.1/Dockerfile (fetched) |
| Upstream base | **Correction:** Debian, not Alpine. Stages: `oven/bun:1.4.4-debian` (bun-tool), `redis:8.8.0-trixie` (redis-tool), `node:24.22.2-trixie-slim` (base), builder, final `debian:trixie-slim` (runner). |
| Upstream apt (runner) | `libstdc++6 libatomic1 libzstd1 zlib1g ca-certificates nginx bash gettext-base util-linux openssl wget`, then `apt-get upgrade -y`. Builder: `ca-certificates python3 make g++`. |
| Upstream entrypoint | `ENTRYPOINT ["/app/entrypoint.sh"]`, `CMD ["sh","run.sh"]`. Root entrypoint drops privileges and starts `redis-server`, `nginx` and node (draft; entrypoint script not fetched: UNVERIFIED). |
| Upstream USER / EXPOSE / VOLUME | No `USER`. `EXPOSE 7575`. `VOLUME /appdata`. |
| Upstream ENV | `DB_URL=/appdata/db/db.sqlite`, `DB_DIALECT=sqlite`, `DB_DRIVER=better-sqlite3`, `AUTH_PROVIDERS=credentials`, `REDIS_IS_EXTERNAL=false`, `NODE_ENV=production`. |
| Latest stable | Tag `v2.13.1`, published 2026-11-14, not a prerelease (GitHub API, `gh api repos/homarr-labs/homarr/releases/tags/v2.13.1`). |
| Release assets | `build-debian-amd64.tar.gz` (sha256:120280ecdbd8af3fbfdeac3626a8f91f3541a0d34ccdb30bd2988f2ecad5157b), `build-debian-arm64.tar.gz` (sha256:b8e73aa11bc87bf4819c376484bfe393da901cd22623dce244a63e7a75f7d4d5), `build-alpine-amd64.tar.gz` (sha256:62a3ec033311bd1f393630130e529112deea0c48ebab223bf0dff5fd4b27a79e), `build-alpine-arm64.tar.gz` (sha256:b30f4c49382eff89ae945a18b70079b98ce8317bc88eaff9c692659c5eeee29b). Download base: `https://github.com/homarr-labs/homarr/releases/download/v2.13.1/<name>`. |
| Download choice | **Correction to the draft:** use the Debian (glibc) tarballs. The draft's "musl-only" caveat does not apply to them. Alpine tarballs are not needed. |
| Checksums | sha256 digests above from the GitHub release API. Verify each download against them. |
| License | Apache-2.0 (GitHub API SPDX, homarr-labs/homarr). |
| Renovate | Proposed `datasource=github-releases depName=homarr-labs/homarr versioning=semver` (tag `v2.13.1`). Not checked against a live config. |
| Ports | `7575/tcp` web UI (EXPOSE). Bundled Redis `6379` is internal (draft; not in Dockerfile, not exposed). |
| Data | `/appdata` (VOLUME, `DB_URL=/appdata/db/db.sqlite`). Encryption key location: draft says `/config`; UNVERIFIED. |
| Source | https://github.com/homarr-labs/homarr |
| Docs | https://homarr.dev/docs/ |

## 2. Target layout

- `apps/homarr/Dockerfile`
- `apps/homarr/docker-bake.hcl`
- `apps/homarr/settings.yaml`
- `apps/homarr/container-test.yaml`
- `apps/homarr/start.sh` (starts redis, nginx and node, and `exec`s the last one; replaces the upstream `entrypoint.sh`)
- `etc/` for an nginx and redis config only if the defaults cannot be passed on the command line. Reason: nginx and redis read config files. Never use `root/`.

No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` for the Node runtime, or `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` plus a Node install if python-node lacks the Node version needed. Upstream uses Node 24; check the Node version in the python-node base before choosing (UNVERIFIED).

Also needed: `redis-server` and `nginx` from apt in the final image (the upstream copies redis from the redis image, which is not a ContainerForge base). Check `apps/redis-exporter` or the valkey app for redis packaging conventions before choosing (valkey is a Redis fork, not the same binary).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends nginx redis-server` (not in base; check the base before install, and pin against the upstream Redis major if needed).
3. Download `build-debian-${TARGETARCH}.tar.gz` (map `amd64`/`arm64` from `TARGETARCH`), verify the sha256 from the release digest, extract to `/app/homarr`. Confirm the tarball layout (UNVERIFIED: top-level directory names).
4. Ship the license into `/usr/share/licenses/homarr/`.
5. `ENV HOME=/config NODE_ENV=production DB_URL=/config/db/db.sqlite DB_DIALECT=sqlite DB_DRIVER=better-sqlite3 AUTH_PROVIDERS=credentials REDIS_IS_EXTERNAL=false`.
6. `chown -R apps:apps /app/homarr && chmod -R 755 /app/homarr`.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 7575
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "homarr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=homarr-labs/homarr versioning=semver
  default = "2.13.1"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/homarr-labs/homarr"
}
```

Use the `v`-less version in the Dockerfile (`ARG VERSION`) and build the tarball URL with `v${VERSION}`. Add the four standard targets and `default` group from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/homarr-labs/homarr"
ports:
  - port: 7575
    protocol: tcp
    required: false
env:
  - name: AUTH_PROVIDERS
    default: "credentials"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Do not list `6379` (Redis is internal). Only env vars `start.sh` or the app reads; the encryption key variable name is UNVERIFIED. Dependencies: none (Redis and SQLite are bundled).

## 7. start.sh

- Seed `/config` only when missing: create `/config/db`, and create the encryption key only if `start.sh` must generate it (UNVERIFIED: the app may create it).
- Redis: `redis-server --dir /tmp/redis --save "" --appendonly no --bind 127.0.0.1 --port 6379` in the background (Redis data is ephemeral).
- nginx: run with `-p /tmp/nginx` and the `pid` and temp paths under `/tmp`, listening on `7575` in front of node if the app needs nginx (UNVERIFIED: the nginx role in the upstream entrypoint).
- Start the node server with `exec`, binding `0.0.0.0`.
- No writes to `/app`.

Exact commands: UNVERIFIED until the upstream `entrypoint.sh` is fetched and read.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '7575'
http:
- port: '7575'
  path: /
```

Add `filePaths` for the app entry and `/usr/share/licenses/homarr/LICENSE`. Do not probe Redis `6379`: it is internal, and the `tcp` probe runs inside the container. Use a narrowed assertion only if the database-dependency exception applies (it does not: the DB is bundled).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/appdata` (SQLite DB) | `/config/db` via `DB_URL`. |
| Redis data | `/tmp/redis` (ephemeral, no persistence). |
| nginx pid, temp, logs | `/tmp/nginx`. |
| Upstream root entrypoint (drops privileges) | Removed. Run as `apps`. Redis and nginx ports must be unprivileged (7575, 6379 are both above 1024). |
| Chart expectations (root, no read-only rootfs) | Reconcile: the plan runs as `apps` with read-only rootfs. Verify all three helper processes start that way. |

## 10. Risks, caveats and open questions

- **Blocker: multi-process layout.** Node, nginx and Redis in one container, with a root entrypoint that the plan removes. The rework is the main effort.
- **Blocker: encryption key.** If the key is not persisted in `/config`, stored secrets become unreadable after restart (draft caveat, UNVERIFIED for this version).
- The first-run admin account is created in the browser (draft caveat).
- Debian tarballs are the chosen build. Confirm the Debian build runs on `trixie-slim` or ubuntu 26.04 (glibc, UNVERIFIED).
- Redis version differs from the upstream `redis:8.8.0-trixie`; pick the version packaged in the base and verify compatibility.
- arm64 runtime not verified.

## 11. Build and test steps

```sh
cd apps/homarr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name homarr-probe --read-only --tmpfs /tmp \
  -v homarr-probe-config:/config homarr:2.13.1
docker logs -f homarr-probe
forgetool containers test --image homarr:2.13.1 --config ./apps/homarr/container-test.yaml
docker rm -f homarr-probe; docker volume rm homarr-probe-config
```

Expected readiness signal: UNVERIFIED until the upstream entrypoint is read; use the app's startup log line and the port 7575 probe.

## 12. PR checklist

- Branch `feat/add-homarr`, commit `feat(homarr): add new container`.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign it).
- PR description: `🤖 This PR is AI generated.` in Notes, PR template kept.
- State what was not tested: no build or run has happened in this planning step.
- Do not tick "Built container locally" until the image is built.
