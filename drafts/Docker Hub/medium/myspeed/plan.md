# myspeed — implementation plan
> Source: ./draft.md · Target: apps/myspeed/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.0.9`: latest GitHub release, published 2024-05-21. No newer release. Chart pins `docker.io/germannewsmaker/myspeed:1.0.9@sha256:3a3e774b...d9a9`. The `development` branch (Hub tag `development`, 2026-08-02, amd64 only) is unreleased; do not pin it. |
| Difference from draft | Draft pins a commit `7290a97522e5fdeca9e541bc3b6048a88ae20f9c` and a Node 18 Dockerfile. Neither is verified (not fetched). The current `development` Dockerfile is Bun-based, not Node 18 (see below). |
| Renovate | `// renovate: datasource=github-releases depName=gnmyt/myspeed versioning=semver` for `VERSION`. The Hub image alternative `datasource=docker depName=docker.io/germannewsmaker/myspeed versioning=semver` is UNVERIFIED against this repo's renovate config. |
| License | MIT (GitHub API `license.spdx_id`). |
| Source URL | https://github.com/gnmyt/myspeed (GitHub API name). Docs: https://docs.myspeed.dev/setup/linux |
| Download | Only release asset for v1.0.9: `https://github.com/gnmyt/myspeed/releases/download/v1.0.9/MySpeed-1.0.9.zip`. Not architecture-specific. The docs mention `linux-x64` / `linux-arm64` pre-compiled binaries, but no such asset is on v1.0.9 (UNVERIFIED for any other release). |
| Checksum source | None on the release. UNVERIFIED for any checksum file. Record the SHA-256 of the zip in the PR. |
| Upstream Dockerfile reviewed | `development` branch `Dockerfile` (https://github.com/gnmyt/MySpeed/blob/development/Dockerfile): `FROM oven/bun:1` for client build (`bun install`, `bun run build`), server build (`bun run generate-migrations`, `bun run generate-integrations`), final stage `oven/bun:1` with `tzdata ca-certificates openssl`, `ENV TZ=Etc/UTC`, `WORKDIR /myspeed`, `VOLUME ["/myspeed/data"]`, `EXPOSE 5216`, `CMD ["bun","run","server/index.js"]`. No `USER` (runs as root). The 1.0.9 Dockerfile is UNVERIFIED. |
| Runtime | Upstream `development` uses Bun, not Node. `package.json` there: `"version": "1.0.9"`, `"type": "module"`, express 5, sequelize 6, mysql2, `@resvg/resvg-js` (native module), no `engines`. Runtime of the 1.0.9 zip is UNVERIFIED. |
| Ports | `5216` (EXPOSE in development Dockerfile, chart `main`). |
| Data path | `/myspeed/data` (VOLUME in upstream, chart `persistence.data`). The 1.0.9 path is UNVERIFIED. |
| Env vars | `TZ` (default `Etc/UTC` in the development Dockerfile; UNVERIFIED for 1.0.9). No others found. |
| Health and metrics | Chart enables a ServiceMonitor at `/api/prometheus` on the main port. The probe path returns UNVERIFIED status before setup. |
| Database | Development `package.json` lists `mysql2` and `pg-hstore`, not sqlite. Whether 1.0.9 stores data in sqlite is UNVERIFIED. |
| arm64 | Hub lists arm64 for tag 1.0.9 (Hub API). Zip is arch-neutral; native-module support is UNVERIFIED. |
| Setup | First run needs a setup wizard in the UI (draft, UNVERIFIED for 1.0.9). |

## 2. Target layout

- `apps/myspeed/Dockerfile`
- `apps/myspeed/docker-bake.hcl`
- `apps/myspeed/settings.yaml`
- `apps/myspeed/start.sh`
- `apps/myspeed/container-test.yaml`

No `defaults/`, `etc/` or `health/` unless step 1 of section 11 shows a seed file is needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5
```

Fits if the app runs on Node. Node version in `python-node` is UNVERIFIED in this repo (check `node --version` in step 2). Bun is not in `python-node`. If the 1.0.9 zip needs Bun, see section 10. Closest sibling: `apps/budge` (python-node, npm install and build in `/app`, `USER apps`, `/config` data).

## 4. Dockerfile

Steps depend on what the zip contains. Section 11 step 0 must confirm this first.

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install only what is missing from the base (`unzip`, if not in the base; check first). No apt packages otherwise.
3. Download, verify and unpack:

   ```sh
   curl -fL -o /tmp/myspeed.zip \
     "https://github.com/gnmyt/myspeed/releases/download/v${VERSION}/MySpeed-${VERSION}.zip" && \
   echo "<sha256>  /tmp/myspeed.zip" | sha256sum -c - && \
   mkdir -p /app/myspeed && unzip -q /tmp/myspeed.zip -d /app/myspeed
   ```

   `<sha256>` is the hash recorded in step 0 of section 11. There is no upstream checksum, so this is a local pin.
4. Build step (UNVERIFIED until the zip is inspected): if the zip has no built client, run `npm ci --omit=dev` and the build script in `/tmp` scratch, then copy the result. Do not run npm caches in `/app`. Set `npm_config_cache=/tmp/npm`.
5. License: `install -D /app/myspeed/LICENSE /usr/share/licenses/myspeed/LICENSE` (check the zip for a `LICENSE` file; if missing, use the MIT text from the GitHub repo and state that in the PR).
6. `chown -R apps:apps /app/myspeed && chmod -R 755 /app/myspeed`, then `rm -rf /tmp/*`.
7. Env and data: `ENV TZ=Etc/UTC HOME=/config`. Link the data path: `ln -s /config/data /app/myspeed/data` (dangling until `start.sh` creates it; same pattern as the fenrus plan).
8. Tail:

   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 5216
   VOLUME /config
   WORKDIR /app/myspeed
   ```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "myspeed"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=gnmyt/myspeed versioning=semver
  default = "1.0.9"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/gnmyt/myspeed"
}
```

Keep the four standard targets and the `default` group from `apps/budge/docker-bake.hcl`. Validate with `docker buildx bake --print`. The Dockerfile reads the same `VERSION` through `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/gnmyt/myspeed"
ports:
  - port: 5216
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `TZ` is set by the upstream development Dockerfile. Confirm it is read in the 1.0.9 build before keeping it.
- No `dependencies`. Speed tests need outbound internet, which is a host concern, not a dependency.
- Do not add env names from the draft or chart without a source.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data

cd /app/myspeed
exec "${MYSPEED_RUN_CMD[@]}"
```

`MYSPEED_RUN_CMD` is a placeholder. The real command is UNVERIFIED for 1.0.9. Use `node <entry>` or `bun run <entry>` as found in the zip's `package.json` `scripts.start` or `main`. Bind to `0.0.0.0` and check the log line for the port (`5216`). Idempotent: create `/config/data` only when missing, seed nothing, never write to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5216'
http:
- port: '5216'
  path: /
filePaths:
- /app/myspeed
- /usr/share/licenses/myspeed/LICENSE
```

- The http path `/` is a guess. Use the path that returns 200 without setup (UNVERIFIED). If none does, keep the tcp probe and note it.
- `timeoutSeconds: 120` is a starting value; no sibling in this batch sets it.
- The test runs with no env. The app must start without setup, so no required-env path is hidden.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/myspeed/data` (DB and settings, VOLUME) | `/config/data` through the symlink in section 4 step 7 |
| Runtime caches and temp files | `/tmp` only (`TMPDIR=/tmp`, `npm_config_cache=/tmp/npm` at build time) |
| `/app/myspeed` | Read only at runtime; nothing is written there (UNVERIFIED for every code path) |

- Chart expectations reconciled: the chart forces UID 0 and sets `readOnlyRootFilesystem: false`. This image runs as `apps` and targets `--read-only --tmpfs /tmp`.
- The chart sets `allowPrivilegeEscalation: true`. This image does not need it; do not set it. Privileged: not needed.
- Upstream runs as root (no `USER`). Our image runs as `apps`, so the data directory must be writable by `apps` (ensured by `start.sh` on `/config`).

## 10. Risks, caveats and open questions

- Blocker: the draft's Node 18 Dockerfile and its pinned commit are unverified, and the current upstream is Bun-based. Decide which runtime 1.0.9 needs by inspecting the zip (`package.json` `engines`, `scripts.start`, `bun.lock` or `package-lock.json`).
- If 1.0.9 needs Bun, `python-node` does not provide it. Options: (a) install a pinned Bun release with its checksum, which is a new download to verify; (b) stop and ask the user. Do not add `oven/bun` as a `FROM` base without a decision.
- Native module `@resvg/resvg-js` (development branch): if the 1.0.9 build has a native module, check that a prebuilt arm64 and amd64 binary exists for glibc. Musl builds do not run on Ubuntu.
- The zip is the only asset. No arch-specific binary (`linux-x64` / `linux-arm64`) is confirmed on the v1.0.9 release. Do not claim one is available.
- The draft's `copy-from` value is `no` because the draft says the upstream image is Alpine (musl). UNVERIFIED for the 1.0.9 image. Keep `no` unless verified.
- The draft's security claim "allowPrivilegeEscalation true" is a chart override, not a requirement. Not needed here.
- Setup wizard: first run needs manual UI setup. The container test does not cover it.

## 11. Build and test steps

```sh
cd apps/myspeed

# 0. Inspect the release zip in a fresh empty directory (untrusted data)
mkdir -p "$SCRATCH/myspeed" && curl -fL -o "$SCRATCH/myspeed/MySpeed-1.0.9.zip" \
  "https://github.com/gnmyt/myspeed/releases/download/v1.0.9/MySpeed-1.0.9.zip"
sha256sum "$SCRATCH/myspeed/MySpeed-1.0.9.zip"
unzip -l "$SCRATCH/myspeed/MySpeed-1.0.9.zip" | head -50
# Read package.json (engines, scripts.start, main) from the zip; do not run anything from it

# 1. Bake
docker buildx bake --print

# 2. Build (amd64 only; arm64 only if the failure is arm64-specific)
docker buildx bake --set image-local.platform=linux/amd64 image-local

# 3. Run on read-only rootfs with an empty /config
docker run --rm -d --name myspeed-probe --read-only --tmpfs /tmp \
  -v myspeed-probe-config:/config -p 5216:5216 myspeed:1.0.9
docker logs -f myspeed-probe

# 4. Test
forgetool containers test --image myspeed:1.0.9 --config ./apps/myspeed/container-test.yaml

# Cleanup
docker rm -f myspeed-probe; docker volume rm myspeed-probe-config
```

- `$SCRATCH` is a placeholder for a fresh empty directory. Do not unzip into `apps/`.
- Readiness signal: UNVERIFIED. Expect a line that names port 5216 once the server listens. Record the exact line after the first run.
- Pass criteria: `.github/instructions/build-test-protocol.instructions.md`.

## 12. PR checklist

- Branch `feat/add-myspeed`, commit and PR title `feat(myspeed): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections. Check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say what was not tested: the Node or Bun version choice (until decided), arm64, the setup wizard, the http probe status, and any path not run on `--read-only`.
- `docker buildx bake --print` passes, and the bake `VERSION` equals the Dockerfile `ARG VERSION`.
