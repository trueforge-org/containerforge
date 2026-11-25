# nocodb — implementation plan
> Source: ./draft.md · Target: apps/nocodb/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | The draft pins `0.301.5` (published 2026-03-18, assets verified). Newer releases exist (latest `2026.10.2`, 2026-11-19), but **only releases up to `2026.06.1` carry the `Noco-linux-*` binaries**; `2026.06.2` to `2026.10.2` have no linux assets (checked through the GitHub releases API). Plan: use **`2026.06.1`** (latest with binaries, 2026-06-15); fall back to `0.301.5` if its behaviour is a problem. |
| Renovate | `datasource=github-releases depName=nocodb/nocodb versioning=loose`. Danger: renovate will propose `2026.10.2`, which has no binary, so the build would break. Add a `packageRules` `allowedVersions` cap or pin renovate off for this app (section 10). |
| License | NocoDB's `LICENSE.md` (updated 2026-01-29) is the **Sustainable Use License v1.0** for the `master` and `develop` branches; third-party parts keep their own licenses. It is source-available, not an OSI license, and has no SPDX id (GitHub reports `NOASSERTION`). Use `LICENSE` value `LicenseRef-Sustainable-Use-1.0` (the id is our choice, UNVERIFIED as a registered id). Redistribution terms need review by the maintainers before the image is published (section 10). |
| Source URL | https://github.com/nocodb/nocodb |
| amd64 download | https://github.com/nocodb/nocodb/releases/download/2026.06.1/Noco-linux-x64 (382094806 bytes) |
| arm64 download | https://github.com/nocodb/nocodb/releases/download/2026.06.1/Noco-linux-arm64 (366545735 bytes) |
| Checksums | GitHub release asset digests: x64 `sha256:51e481c9bf84fd71d23740e321caa6d327fa54da3a570a02a733bfff4c1aa3c5`, arm64 `sha256:0bc6c238efbf1c0b0c55af1b5dcbbb1cc749ab1ecbff95f69bc46c18cd476090`. No separate checksum file. (For `0.301.5`: x64 `d374da2e...be957`, arm64 `eb7423c2...b1a`.) |
| Binary type | ELF dynamically linked to glibc (`/lib64/ld-linux-x86-64.so.2` and `/lib/ld-linux-aarch64.so.1`, read from the first bytes). It is a self-contained packaged executable (370 MB), so no Node runtime is needed: `python-node` from the draft is unnecessary. Packaging details: UNVERIFIED. |
| Upstream Dockerfile | None public (the draft says built in private CI). `docker-compose` samples under the repo were not retrievable at the tag (404). Image facts from the docs: in Docker the data dir is `/usr/app/data/`, default port 8080. |
| Env vars (docs: self-hosting/environment-variables) | `NC_DB` (connection URL like `pg://host:5432?u=..&p=..&d=..`; if unset a local SQLite db is created in the root folder), `NC_DB_JSON` and `NC_DB_JSON_FILE` (knex JSON), `NC_AUTH_JWT_SECRET` (random if unset), `PORT` (default 8080), `NC_ADMIN_EMAIL` and `NC_ADMIN_PASSWORD` (min 8 chars, upper, number, special), `NC_APP_DATA_DIR` (metadata and app files; default is the working dir; legacy `NC_TOOL_DIR`), `NC_CACHE_REDIS_URL` (legacy `NC_REDIS_URL`), `NC_SITE_URL` (legacy `NC_PUBLIC_URL`), `NC_DISABLE_TELE`. |
| Draft claims | Port 8080 matches `PORT` default. `/usr/app/data` extra persistence in the chart maps to `/config`. |

## 2. Target layout

```
apps/nocodb/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (the app seeds its own SQLite). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The binary bundles its runtime, glibc is present on Ubuntu, so the draft's `python-node` is not required. Closest sibling: `apps/adguardhome-sync` (single prebuilt binary, per-arch URL).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG NOCO_SHA256_AMD64`, `ARG NOCO_SHA256_ARM64`.
2. `USER root` for the install step only; no apt packages planned (ELF needs `libc6`, `libstdc++6`, `libgcc-s1`, which the base should contain; verify with `ldd /app/Noco` in the build and add only what is missing, pinned if from apt).
3. Download and verify:
   ```dockerfile
   RUN set -eux; \
     case "${TARGETARCH}" in amd64) A=x64; S="${NOCO_SHA256_AMD64}" ;; arm64) A=arm64; S="${NOCO_SHA256_ARM64}" ;; *) exit 1 ;; esac; \
     curl -fsSL -o /app/Noco "https://github.com/nocodb/nocodb/releases/download/${VERSION}/Noco-linux-${A}"; \
     echo "${S}  /app/Noco" | sha256sum -c -; \
     chmod 0755 /app/Noco; chown -R root:root /app
   ```
4. Licenses: the release does not ship license files; fetch `LICENSE.md` of the tag (`mkdir -p /usr/share/licenses/nocodb` first): `curl -fsSL -o /usr/share/licenses/nocodb/LICENSE.md https://raw.githubusercontent.com/nocodb/nocodb/${VERSION}/LICENSE.md` (tag URL UNVERIFIED for `2026.06.1`; fall back to `develop`).
5. `ENV HOME=/tmp/home PORT=8080 NC_APP_DATA_DIR=/config` (caches and the packaged binary's extraction dir go to `/tmp`; data to `/config`).
6. `USER apps` as the last user line, then `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`, `CMD ["/start.sh"]`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "nocodb" }

variable "VERSION" {
  // renovate: datasource=github-releases depName=nocodb/nocodb versioning=loose
  default = "2026.06.1"
}

variable "NOCO_SHA256_AMD64" { default = "51e481c9bf84fd71d23740e321caa6d327fa54da3a570a02a733bfff4c1aa3c5" }
variable "NOCO_SHA256_ARM64" { default = "0bc6c238efbf1c0b0c55af1b5dcbbb1cc749ab1ecbff95f69bc46c18cd476090" }
variable "LICENSE" { default = "LicenseRef-Sustainable-Use-1.0" }
variable "SOURCE" { default = "https://github.com/nocodb/nocodb" }
```

`image` args: `VERSION`, `NOCO_SHA256_AMD64`, `NOCO_SHA256_ARM64`, plus the OCI `source` and `licenses` labels. Targets `docker-metadata-action`, `image`, `image-local` (`type=docker`, `${APP}:${VERSION}`), `image-all` (amd64 and arm64), `group "default"` = `image-local`. Run `docker buildx bake --print`. A version bump needs both sha values updated (manual; renovate cannot).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/nocodb/nocodb"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: NC_DB
    default: ""
    required: false
  - name: NC_AUTH_JWT_SECRET
    default: ""
    required: false
  - name: NC_ADMIN_EMAIL
    default: ""
    required: false
  - name: NC_ADMIN_PASSWORD
    default: ""
    required: false
  - name: NC_CACHE_REDIS_URL
    default: ""
    required: false
  - name: NC_SITE_URL
    default: ""
    required: false
  - name: PORT
    default: "8080"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
  - name: valkey
```

`postgresql` and `valkey` both exist under `apps/` (✅). `NC_AUTH_JWT_SECRET` is not `required: true` because `start.sh` generates and stores one. `NC_DB_JSON` and `NC_DB_JSON_FILE` can be added if you want to expose them; they are real names in the docs but not listed to keep the file small. `NC_REDIS_URL` is the legacy name of `NC_CACHE_REDIS_URL`, so only the current one is listed.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config /tmp/home

# Persist a JWT secret so sessions survive restarts when none is supplied
if [[ -z "${NC_AUTH_JWT_SECRET:-}" ]]; then
  if [[ ! -s /config/.jwt_secret ]]; then
    umask 077
    head -c 48 /dev/urandom | base64 | tr -d '\n=+/' > /config/.jwt_secret
  fi
  NC_AUTH_JWT_SECRET="$(cat /config/.jwt_secret)"
  export NC_AUTH_JWT_SECRET
fi

# SQLite fallback lives in /config (working dir and NC_APP_DATA_DIR) when NC_DB is unset
if [[ -z "${NC_DB:-}" && -z "${NC_DB_JSON:-}" && -z "${NC_DB_JSON_FILE:-}" ]]; then
  echo "NC_DB not set: using local SQLite in /config (not suitable for production)"
fi

cd /config
exec /app/Noco
```

Empty-start safe and idempotent; nothing is written to `/app`; secrets are only in files with mode 600 and the environment. The server binds the port from `PORT` (default 8080); the bind interface is UNVERIFIED (check with `ss -ltn` and a connection from another container).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /api/v1/health
filePaths:
- /app/Noco
- /usr/share/licenses/nocodb/LICENSE.md
```

Port 8080 is probed with tcp and http. The health path `/api/v1/health` is UNVERIFIED; confirm against the running image (do not loosen the assertion; if wrong, probe `/` instead). The test runs with no env, so the SQLite path is what is tested; the Postgres, Valkey and JWT-secret path is not covered and is exercised manually in section 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/usr/app/data/` (docker data dir) | `/config` via `NC_APP_DATA_DIR` and working dir. |
| SQLite file in the root folder | working dir `/config`. |
| `$HOME` caches and any packaged-runtime extraction (UNVERIFIED) | `HOME=/tmp/home`. |
| JWT secret | `/config/.jwt_secret`. |

Draft reconciliation: chart runs uid 0 with a writable rootfs; image runs as `apps`, read-only compatible, not privileged; `/usr/app/data` persistence becomes `/config` (migration: copy the old directory contents into the new volume).

## 10. Risks, caveats and open questions

- Binaries disappeared after `2026.06.1` (no linux assets for `2026.06.2` through `2026.10.2`); the image cannot track upstream's latest. The release also has `nocodb.tar.gz` (319 MB) for `2026.06.1`, content unverified; it might be a Node bundle that could be used with a Node base for newer versions, UNVERIFIED.
- Renovate will propose versions with no binary: restrict with a package rule and update the sha variables by hand.
- License is the Sustainable Use License, source-available with use restrictions; check redistribution of a container image with the maintainers and the license text before publishing. Some features need an enterprise license (draft).
- Private CI builds, no public Dockerfile: the image cannot be reproduced from the tag (draft).
- Without `NC_DB` the data lives in SQLite under `/config` (durable only if the volume persists).
- Unknowns: whether the packaged binary writes outside `/config` and `/tmp`, bind address, health path, readiness log text. Settled by the read-only run.
- Binary is 370 MB; arm64 untested.

## 11. Build and test steps

```sh
cd apps/nocodb
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name nocodb-probe --read-only --tmpfs /tmp \
  -v nocodb-probe-config:/config nocodb:2026.06.1
docker logs -f nocodb-probe
forgetool containers test --image nocodb:2026.06.1 --config ./apps/nocodb/container-test.yaml
docker rm -f nocodb-probe; docker volume rm nocodb-probe-config
```

Expected: container stays up, log shows the server listening on 8080 (exact line UNVERIFIED), no stack traces, `curl http://localhost:8080/` serves the UI. Second run on the same volume keeps the same JWT secret. Then run once with `NC_DB=pg://...` against `apps/postgresql` and with `NC_CACHE_REDIS_URL` against `apps/valkey` (not in the automated test). Round limit 10.

## 12. PR checklist

- Branch `feat/add-nocodb`, commit and PR title `feat(nocodb): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice to the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested until built: arm64, Postgres and Valkey wiring, health path, read-only behaviour, bind interface. Do not tick "Built container locally" unless it was built.
- State the version choice (`2026.06.1`, last release with binaries) and the license caveat in the PR description.
