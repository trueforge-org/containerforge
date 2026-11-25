# wekan — implementation plan
> Source: ./draft.md · Target: apps/wekan/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Draft pins `v13.20` (tag exists, published 2026-11-19T21:07:18Z, not a prerelease). Latest stable is `v13.31` (published 2026-11-25T01:09:53Z). This plan keeps `13.20` as the draft asks; bumping to `13.31` is a renovate change, not part of this add. Tag form `v13.20`, `VERSION` form `13.20` (no `v`). |
| Renovate | `// renovate: datasource=github-releases depName=wekan/wekan versioning=semver` (UNVERIFIED that renovate tags map `v`-prefixed releases to `13.20`; the `v` is added in the download URL). |
| License | MIT (GitHub API `license.spdx_id`) |
| Source URL | https://github.com/wekan/wekan |
| Download (amd64) | `https://github.com/wekan/wekan/releases/download/v${VERSION}/wekan-${VERSION}-amd64.zip` (asset confirmed on v13.20) |
| Download (arm64) | `https://github.com/wekan/wekan/releases/download/v${VERSION}/wekan-${VERSION}-arm64.zip` (asset confirmed on v13.20) |
| Checksum source | Per-asset `wekan-${VERSION}-<arch>.zip.sha256sum` on the same release (asset confirmed). The upstream Dockerfile verifies with `sha256sum -c`. |
| Draft binary links | Draft's amd64 `wekan-13.20-amd64-single-file` and arm64 `WeKan-13.20-aarch64-musl.AppImage` both exist, but the arm64 AppImage is a musl build and must NOT be used on glibc Ubuntu. Use the zip bundles above, which the upstream Dockerfile uses. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/wekan/wekan/v13.20/Dockerfile: stage `bundle` on `debian:trixie` downloads the per-arch zip and `.sha256sum`, checks it, verifies `bundle/node` is an ELF for the target CPU, and moves node to `/usr/local/bin/node`; runtime stage `debian:trixie`, `USER wekan`, `WORKDIR /build`, `EXPOSE $PORT` (`PORT=8080`), `CMD ["bash", "/build/wekan-entrypoint.sh"]`, `STOPSIGNAL SIGKILL`, no `VOLUME`. |
| Bundled Node | The release zip ships its own `node` binary. Upstream `NODE_VERSION=v26.13.1` (env). So no separate Node runtime is needed. |
| Env vars (real, from the Dockerfile) | `PORT=8080`, `WRITABLE_PATH=/data`, `DEBUG=false`, `DDP_TRANSPORT=sockjs`, `PASSWORD_LOGIN_ENABLED=true`, `BROWSER_POLICY_ENABLED=true`, `MATOMO_DO_NOT_TRACK=true`, `OAUTH2_ENABLED=false`, `LDAP_ENABLE=false`, `SAML_ENABLED=false`, `CAS_ENABLED=false`, `BIGEVENTS_PATTERN=NONE`, `NOTIFY_ON_ASSIGN=true`, `EMAIL_NOTIFICATION_TIMEOUT=30000`, plus about 200 more (LDAP, OAuth, SAML, logout, retention, inbound email). Upstream has two misspelled names (`ACCOUNTS_LOCKOUT_UNKNOWN_USERS_FAILURES_BERORE`, `LDAP_AUTHENTIFICATION`) that must not be copied into `settings.yaml` as if they were real. |
| Mongo URL env | UNVERIFIED: the MongoDB connection variable (`MONGO_URL`) is not in the fetched Dockerfile excerpt. Confirm in the wekan docs (https://wekan.fi/install/) or the bundle before writing `settings.yaml`. |
| Data path | `WRITABLE_PATH=/data` (env). Upstream creates `/data` owned by `wekan`. |
| Entrypoint | `/build/wekan-entrypoint.sh` (copied from `releases/ferretdb/wekan-entrypoint.sh`). UNVERIFIED: whether the entrypoint starts FerretDB or only uses MongoDB. Read it from the release before writing `start.sh`. |
| apt | Upstream runtime installs `file libatomic1`. Ubuntu package names UNVERIFIED for 26.04. |

## 2. Target layout

- `apps/wekan/Dockerfile`
- `apps/wekan/docker-bake.hcl`
- `apps/wekan/settings.yaml`
- `apps/wekan/container-test.yaml`
- `apps/wekan/start.sh`

No `defaults/` or `etc/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (wekan is not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for both stages.

Reason: the release bundle carries its own Node binary, so `python-node` (the draft's choice) adds nothing. The porter table maps Node to `ubuntu`. Closest sibling: `apps/mongodb` (for the dependency, not the build). For a zip-based bundle pattern, use `apps/adguardhome-sync` (prebuilt archive, `chown -R apps:apps /app`).

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS bundle` with `ARG VERSION` and `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends ca-certificates curl unzip` (curl is in the base; check before adding; `unzip` is needed).
3. Map `TARGETARCH` to the release name: `amd64` -> `amd64`, `arm64` -> `arm64`; fail on any other value.
4. Download and verify:
   `curl -fL -o /tmp/wekan.zip "https://github.com/wekan/wekan/releases/download/v${VERSION}/wekan-${VERSION}-${WEKAN_ARCH}.zip"`
   `curl -fL -o /tmp/wekan.zip.sha256sum "https://github.com/wekan/wekan/releases/download/v${VERSION}/wekan-${VERSION}-${WEKAN_ARCH}.zip.sha256sum"`
   then `cd /tmp && sha256sum -c wekan.zip.sha256sum` (the checksum file names the original asset; rename accordingly).
5. `unzip /tmp/wekan.zip -d /tmp/wekan-bundle`. Check `/tmp/wekan-bundle/bundle/node` is an ELF for the target CPU (same check as upstream).
6. Runtime stage `FROM <ubuntu>`, `USER root`:
   - `useradd` is not needed: the base already runs as `apps`. Do not create the upstream `wekan` user.
   - `apt-get install -y --no-install-recommends file libatomic1` (pin against the Ubuntu archive, verify present in base first).
   - Copy the unpacked bundle from the build stage into `/app/wekan` (read-only at runtime, not `/build`): unpack to `/out/app/wekan` in the build stage, then `COPY --from=bundle /out/app/wekan /app/wekan`. Use `/app/wekan/node` (or `/usr/local/bin/node` if the entrypoint expects it; UNVERIFIED which path it uses).
   - `install -D /tmp/wekan-bundle/LICENSE /usr/share/licenses/wekan/LICENSE` (UNVERIFIED that the zip contains LICENSE; copy the repo LICENSE from the source tarball if not).
   - `chown -R apps:apps /app/wekan && chmod -R 755 /app/wekan`.
   - Remove the upstream `/usr/bin/pebble` deletion step only if the file exists in the base (it is not expected in ubuntu).
   - Clean: `apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/*`.
7. `ENV PORT=8080 WRITABLE_PATH=/config/data DEBUG=false DDP_TRANSPORT=sockjs HOME=/config`. Keep only the env vars that `settings.yaml` lists (see section 6); do not copy all 200.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app/wekan
```

`COPY --chmod=0755 . /` brings `start.sh`, `include`-allowed paths only (`.dockerignore` allow-list).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "wekan" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=wekan/wekan versioning=semver
  default = "13.20"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/wekan/wekan" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print` in `apps/wekan`. `ARG VERSION` in the Dockerfile must equal `13.20`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/wekan/wekan"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "8080"
    required: false
  - name: ROOT_URL
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - mongodb
```

`ROOT_URL` is an assumed Meteor variable, not confirmed (UNVERIFIED; remove it if the fetched bundle does not read it). Port 8080 and `PORT` are confirmed. Add `MONGO_URL` only once it is confirmed (section 1). Do not list the misspelled names. Dependency: `mongodb` exists as `apps/mongodb` (mark ✅ in `draft.md` context). `mongodb` is a hard dependency, so the narrow DB exception in the protocol may apply (section 8).

## 7. start.sh

Plan:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Persistent state under /config. /data is replaced by WRITABLE_PATH.
mkdir -p /config/data
export WRITABLE_PATH="${WRITABLE_PATH:-/config/data}"
export PORT="${PORT:-8080}"

cd /app/wekan
exec bash /app/wekan/wekan-entrypoint.sh
```

- The real command depends on `wekan-entrypoint.sh` (UNVERIFIED: its contents were not read). If the entrypoint starts `node main.js` from `/build`, keep the same relative layout under `/app/wekan` and keep `WORKDIR` consistent.
- Nothing is written to `/app`. The entrypoint must not write into the bundle; if it does, the read-only test will show it.
- Bind to all interfaces: wekan listens on `0.0.0.0` by default in the Meteor bundle (UNVERIFIED); confirm with the readiness log and an external curl (section 11).
- Use `exec` so the process gets signals (upstream `STOPSIGNAL SIGKILL` is kept only if needed).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/wekan/bundle/main.js
```

- The test runs without MongoDB and without env vars. `wekan` has a hard dependency on MongoDB and will likely retry the DB connection, so the database-dependent narrow exception applies only if all three criteria hold (hard dependency, will not start without the DB, not feasible to sidecar). Apply the exception with the required comment, for example `# narrowed: requires external mongodb; full functional test not feasible in single-container suite`, and keep the tcp probe, which should still pass because the Meteor server listens before the DB connects (UNVERIFIED: confirm during the run).
- `filePaths` uses the bundle entry (`/app/wekan/main.js` or the real path; UNVERIFIED, read from the bundle).
- Do not weaken the tcp probe. If the server does not listen without MongoDB, stop and record the blocker, do not remove the probe.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (`WRITABLE_PATH`) | `/config/data` (persistent). Set `WRITABLE_PATH=/config/data` in the Dockerfile `ENV`. |
| `/home/wekan` (upstream user home) | `HOME=/config`, or `/tmp` for scratch. Upstream user `wekan` is not created; the image runs as `apps`. |
| `/build/recovery-bridge.mjs`, `/build/db-ready.mjs`, `/build/nextcloud-exapp-capability.json` | Read-only, kept under `/app/wekan` as part of the bundle. |
| `/opt/ucs-migration` | Only if the feature is used (UNVERIFIED); copy under `/app`, not written at runtime. |
| `/tmp` (node/meteor scratch) | `/tmp` (tmpfs in the probe). |

Draft expectations reconciled: the chart runs as UID 568 (`apps`) with `readOnlyRootFilesystem: true` and `WRITABLE_PATH=/data`. That matches the plan (`/config/data`, read-only rootfs). Chart extra-persistence `/data` maps to `/config/data`; existing data must be moved to `/config/data` (note in PR). Not privileged.

## 10. Risks, caveats and open questions

- Mongo dependency: the app cannot store data without MongoDB. The narrow exception in section 8 is the expected path, but the readiness signal must come from the Meteor server starting.
- arm64: the upstream Docker Hub image is published for amd64 and ppc64le (newest tag listed); arm64 via the zip bundle is confirmed as an asset. Test arm64 separately; the draft's "no arm64 image" claim is UNVERIFIED for v13.20.
- Old Node in the bundle (`v26.13.1` from the Dockerfile) is shipped inside the zip; the base's node is not used.
- Meteor upgrades are fragile (draft caveat). Renovate bumps of `VERSION` need a smoke test.
- Entrypoint may start a FerretDB or DB helper (UNVERIFIED, section 1). If it does, the dependency and narrowing need revisiting.
- Blockers: none confirmed beyond the MongoDB dependency. No musl binary used. No GPU. Not privileged.

## 11. Build and test steps

```sh
cd apps/wekan
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name wekan-probe --read-only --tmpfs /tmp \
  -v wekan-probe-config:/config wekan:13.20
docker logs -f wekan-probe
forgetool containers test --image wekan:13.20 --config ./apps/wekan/container-test.yaml
docker rm -f wekan-probe; docker volume rm wekan-probe-config
```

Readiness signal: the Meteor server "listening" line on port 8080 (exact text UNVERIFIED until run). Run an extra probe with a MongoDB container on a shared network (`docker network create`) and confirm the app connects; this is the functional check the narrowed test does not cover. Confirm `/config/data` is created on first start.

## 12. PR checklist

- Branch `feat/add-wekan`, commit `feat(wekan): add new container`, PR title `feat(wekan): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is needed (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Say what is untested: the build on each arch, the MongoDB functional path, the read-only run, and any arm64 claim.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened; the narrowed DB comment is present.
