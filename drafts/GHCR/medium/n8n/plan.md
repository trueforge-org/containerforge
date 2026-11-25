# n8n — implementation plan
> Source: ./draft.md · Target: apps/n8n/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest GitHub release `n8n@2.49.6`, published 2026-11-25, not prerelease. https://github.com/n8n-io/n8n/releases/tag/n8n%402.49.6 . The draft's chart tag `ghcr.io/n8n-io/n8n:3.3.0` is NOT confirmed: it is higher than the latest release, so UNVERIFIED which one is current. Decide before bake (see section 10). |
| Renovate | `datasource=github-releases depName=n8n-io/n8n` for the tag, or `datasource=npm depName=n8n` (npm `latest` is 2.49.6). The GitHub release tag is prefixed `n8n@`; strip the prefix in the version. |
| License | Sustainable Use License v1.0 (not OSI, no SPDX id). Files under `.ee.` are under the n8n Enterprise License. https://raw.githubusercontent.com/n8n-io/n8n/master/LICENSE.md . Its terms limit offering the software to others, beyond free non-commercial distribution. See section 10. |
| Source URL | https://github.com/n8n-io/n8n |
| Download | npm package `n8n` (version 2.49.6, `engines.node >=24.0.0`, bin `n8n -> ./bin/n8n`). https://registry.npmjs.org/n8n/latest . No prebuilt release binary. |
| Checksum source | npm registry `dist.integrity` for the package tarball (field not read: UNVERIFIED). No GitHub release asset list was fetched. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/n8n-io/n8n/master/docker/images/n8n/Dockerfile . Stages: `toolchain` (apk python3, make, g++), `native-builder` (compiles isolated-vm, sqlite3, @confluentinc/kafka-javascript), final `FROM ${RUNTIME_IMAGE}`. Final stage copies a prebuilt pnpm `./compiled` tree into `/usr/local/lib/node_modules/n8n`. `ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]`, no CMD, `USER node`, `EXPOSE 5678/tcp`, no VOLUME. ENV `NODE_ENV=production`, `N8N_RELEASE_TYPE`, `SHELL=/bin/sh`, `MAGICK_CODER_STABILITY=PRIMARY`. Base images come from `docker/docker-bake.hcl`: UNVERIFIED (not fetched). |
| Port | 5678/tcp (upstream EXPOSE). |
| Env vars (real) | Only the Dockerfile ENV values above are confirmed. Names such as `N8N_ENCRYPTION_KEY`, `N8N_USER_FOLDER`, `DB_TYPE`, `DB_POSTGRESDB_*` are the draft's and common n8n names but are UNVERIFIED (docs.n8n.io not fetched). |
| Data path | Upstream creates `/home/node/.n8n` (owned by `node`). Draft wants `/config`; chart uses `/data`. Remap needed; which variable moves it is UNVERIFIED. |
| arm64 | npm package is JavaScript, but three native modules are compiled per architecture in the upstream build. Upstream arm64 image status: UNVERIFIED. |
| Dependencies | Optional PostgreSQL and Valkey (draft). Both exist here: `apps/postgresql`, `apps/valkey`. Their use by n8n is UNVERIFIED. |

## 2. Target layout

- `apps/n8n/Dockerfile`
- `apps/n8n/docker-bake.hcl`
- `apps/n8n/settings.yaml`
- `apps/n8n/container-test.yaml`
- `apps/n8n/start.sh`

No `defaults/`, `etc/` or `health/` (n8n creates its own state). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Runtime image is `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, the same digest `apps/budge` uses. It provides Node, which the draft's reason depends on. Closest sibling: `apps/budge` (python-node). Node version inside the base is UNVERIFIED against n8n's `>=24.0.0`; check with `docker run --rm <base> node --version` before the build. If it is below 24, this is a blocker (section 10).

Build stage: use the same python-node base. Do not use the upstream Alpine image (musl does not run on glibc Ubuntu, and `copy-from` is therefore not used).

## 4. Dockerfile

1. Build stage `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e04... AS build`, `ARG VERSION`, `USER root`.
2. Install build tools for native modules only if the base lacks them: `apt-get install -y --no-install-recommends build-essential python3 make g++` (check first, the base may already have them; UNVERIFIED). Pin nothing from apt unless the package is kept in the final stage.
3. `ENV npm_config_cache=/tmp/npm-cache HOME=/tmp/home` for the build (caches go to `/tmp`, never `/config` or `/app`).
4. Install into a prefix under `/app`: `npm install -g --prefix /app/n8n n8n@${VERSION}` (or `npm install --prefix /app/n8n n8n@${VERSION}`). Use `--omit=dev` if the package lock allows it. Build-time writes to `/app` are fine; runtime writes are not.
5. Drop what is not needed at runtime: `rm -rf /tmp/*` and `npm cache clean --force`.
6. License: `mkdir -p /usr/share/licenses/n8n && cp /app/n8n/lib/node_modules/n8n/LICENSE.md /usr/share/licenses/n8n/` (path inside the npm tree is UNVERIFIED; locate it in the build with `find`).
7. Final stage `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build` is the build stage, `FROM` the same image for the final stage, `ARG VERSION`, `USER root`.
8. `COPY --from=build /app/n8n /app/n8n` and `COPY --from=build /usr/share/licenses/n8n /usr/share/licenses/n8n`, then `chown -R apps:apps /app && chmod -R 755 /app`.
9. `ENV HOME=/config N8N_RELEASE_TYPE=dev SHELL=/bin/sh NODE_ENV=production`. Set `HOME=/config` the same way `apps/adguardhome-sync` does, so n8n's `~/.n8n` lands in `/config/.n8n` (UNVERIFIED that this matches n8n's user folder logic; the user-folder variable is the alternative).
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 5678
VOLUME /config
```

`ARG VERSION` in the Dockerfile must equal `VERSION` in `docker-bake.hcl` (section 5).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "n8n"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=n8n-io/n8n versioning=loose
  default = "2.49.6"
}

variable "LICENSE" {
  default = "Sustainable Use License 1.0"
}

variable "SOURCE" {
  default = "https://github.com/n8n-io/n8n"
}
```

Then the `group "default"`, `target "image"`, `target "image-local"` and `target "image-all"` blocks copied verbatim from `apps/adguardhome-sync/docker-bake.hcl`. `VERSION` is `2.49.6` (from the latest release) unless the maintainer confirms `3.3.0`. Note: the release tag is `n8n@<version>`, so `versioning=loose` is needed because the tag has a prefix (UNVERIFIED that renovate strips it; a `extractVersion` may be needed). Validate with `docker buildx bake --print` from `apps/n8n`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/n8n-io/n8n"
ports:
  - port: 5678
    protocol: tcp
    required: false
env:
  - name: N8N_PORT
    default: "5678"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - postgresql
  - valkey
```

Only `N8N_PORT` and `TZ` are listed. `N8N_PORT` is UNVERIFIED as an n8n variable name: confirm it on docs.n8n.io before adding it, and remove it if the app ignores it (the schema rule: do not invent env vars). `N8N_ENCRYPTION_KEY` must NOT get a default. If it is added, mark it `required: false` and generate it in `start.sh` on first run into `/config` (see section 7). Check whether `opt_dependencies` is the schema key the forgetool schema accepts: UNVERIFIED (use the key sibling apps with optional deps use, if different).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/.n8n

export HOME=/config
cd /config
exec /app/n8n/bin/n8n start
```

Points to check before it is final:
- The npm bin path inside `/app/n8n` (`/app/n8n/bin/n8n` or `/app/n8n/node_modules/.bin/n8n`) depends on the install prefix in step 4: UNVERIFIED, confirm by listing the build output.
- `n8n start` is the documented command (UNVERIFIED against the docs). The upstream image uses `tini -- /docker-entrypoint.sh` with no CMD; if `start.sh` must mimic it, copy the upstream `docker-entrypoint.sh` logic (not fetched: UNVERIFIED).
- Encryption key: if the app generates one on first start, it lands in `/config`, which is correct. If the key is only read from env, `start.sh` generates and stores it once in `/config/encryption-key` and never overwrites it (idempotent). Do not print it to the log.
- No writes to `/app`. Caches go to `/tmp` (`N8N_*CACHE*` or `npm_config_cache` are UNVERIFIED names; set `XDG_CACHE_HOME=/tmp` as a fallback).
- Use `exec` so the process gets signals. Listen on all interfaces: n8n's `N8N_LISTEN_ADDRESS` default is UNVERIFIED; check it binds `0.0.0.0`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '5678'
filePaths:
- /app/n8n
- /usr/share/licenses/n8n
```

`timeoutSeconds` is a placeholder: copy the value from `apps/budge/container-test.yaml` (it has no timeout line; use the python-node family default from `apps/changedetection/container-test.yaml`, UNVERIFIED value). An `http` probe on `/` is planned after confirming the path returns 200 on an empty `/config` (UNVERIFIED). No env var is set by the test; n8n must start without `N8N_ENCRYPTION_KEY`, so the first-run key path is covered by `filePaths` only.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/home/node/.n8n` (user folder: config, encryption key, sqlite db) | `HOME=/config` makes it `/config/.n8n` (UNVERIFIED that n8n uses `$HOME/.n8n`). |
| npm / node caches | `/tmp`. |
| Build-time install into `/app/n8n` | Read-only at runtime, fine. |
| Upstream runs as `node` (UID 1000) | This image runs as `apps` (568). Chart runs as UID 0 (`runAsUser: 0`); ContainerForge drops root. |
| Chart `readOnlyRootFilesystem` | false in the chart; this image should be compatible with `--read-only --tmpfs /tmp`, to be proven in section 11. |
| Chart `extra-persistence: /data` (pvc) | Not used here: the draft says `/config`. Existing users must move `/data` content into `/config/.n8n` (UNVERIFIED that the path matches). |

Reconciling draft expectations: non-root `no` in the chart, but ContainerForge runs `apps`. `privileged` `no`. No other security settings.

## 10. Risks, caveats and open questions

- **Version mismatch (decision needed):** the draft's chart tag `3.3.0` is above the latest release `2.49.6`. Confirm the target version before the bake file is written. This plan uses `2.49.6`.
- **License (decision needed):** the Sustainable Use License restricts offering the software to others beyond free non-commercial distribution. ContainerForge distributes images, so the maintainers must confirm this is acceptable before a PR. Not an SPDX license: the bake `LICENSE` label uses the name, not an SPDX id.
- **Node version (blocker if unmet):** n8n needs Node `>=24.0.0`. The python-node base's Node version is UNVERIFIED. If it is lower, a Node-24 base or a separate Node install is needed, and that decision is open.
- Large npm install with native modules: build needs RAM and time (draft, inferred). Build may be slow on arm64.
- `N8N_ENCRYPTION_KEY` losing it makes stored credentials unreadable (draft, inferred): document it in the PR; never log it.
- Env var names, data-folder variable, bin path and the release-tag prefix for renovate are all UNVERIFIED (section 1).
- Optional dependencies (postgresql, valkey) are not needed for a first start (SQLite default is UNVERIFIED). No database exception applies: no hard dependency.
- Not blocked by musl (the upstream Alpine build is not reused). No GPU, no privileged needs.

## 11. Build and test steps

```sh
cd apps/n8n
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name n8n-probe --read-only --tmpfs /tmp \
  -v n8n-probe-config:/config n8n:2.49.6
docker logs -f n8n-probe
forgetool containers test --image n8n:2.49.6 --config ./apps/n8n/container-test.yaml
docker rm -f n8n-probe; docker volume rm n8n-probe-config
```

Expected readiness signal: the n8n editor URL line (`Editor is now accessible via` or the `n8n ready` message; UNVERIFIED wording) and a listening socket on 5678. Restart with the same `/config` volume to confirm idempotence. Check the arm64 build separately only if the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-n8n`, commit and PR title `feat(n8n): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- CLA notice: the contribution needs a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say in the PR what is not tested: arm64 build, the empty-`/config` start on `--read-only`, the encryption key path, the optional database use.
- Resolve the version and license decisions in section 10 before opening the PR.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
