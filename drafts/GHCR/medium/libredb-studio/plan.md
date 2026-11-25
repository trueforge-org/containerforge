# libredb-studio — implementation plan
> Source: ./draft.md · Target: apps/libredb-studio/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 1.3.0 (latest release, published 2026-11-10). Draft container tag `1.3.0` matches. Source: https://api.github.com/repos/libredb/libredb-studio/releases/latest |
| Renovate | `datasource=github-releases depName=libredb/libredb-studio versioning=semver` (UNVERIFIED: confirm against a sibling github-releases app before merge) |
| License | MIT (GitHub SPDX `MIT`). Source: https://api.github.com/repos/libredb/libredb-studio |
| Source URL | https://github.com/libredb/libredb-studio |
| Download | Standalone Next.js bundle per arch: `libredb-studio-standalone-1.3.0-linux-x64.tar.gz` (amd64) and `libredb-studio-standalone-1.3.0-linux-arm64.tar.gz` (arm64). Release: https://github.com/libredb/libredb-studio/releases/tag/1.3.0 |
| Checksums | `SHA256SUMS` published with the release (also per-asset `.sha256`). Hashes read on 2026-11-25: linux-x64 `b1043d2f8c0e5e7201f2855b69273a27c510f55a27e286af0e312ea87fbbc4a8`, linux-arm64 `2d1f395c3f0f8e19181893dd86176775622164a7e7c92bd9b4fde522fba8600c`. Source: https://github.com/libredb/libredb-studio/releases/download/1.3.0/SHA256SUMS |
| Not used | Desktop AppImage, deb, rpm, snap and darwin/win archives: desktop apps, not a server. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/libredb/libredb-studio/58adba536f0283fecb7b761053cb2401dd7187eb/Dockerfile: deps `oven/bun:1.4.4`, builder and runner `node:26.13.0-trixie-slim`. Builder uses Node (not bun) for `next build` because bun's JIT segfaults under QEMU arm64. Runner creates user `nextjs` (1001), installs gosu, runs `docker-entrypoint.sh` as root, then `node server.js`. EXPOSE 3000/tcp, no VOLUME. |
| Port | 3000/tcp (`PORT=3000`, EXPOSE 3000) |
| Env vars (real, from upstream Dockerfile) | `NODE_ENV=production`, `NEXT_TELEMETRY_DISABLED=1`, `NODE_OPTIONS=--max-old-space-size=384`, `WORKFLOW_LOCAL_DATA_DIR=/app/data/workflow`, `PORT=3000`, `HOSTNAME` (empty, so upstream's entrypoint resolves the bind address). Build args `BASE_PATH`, `JWT_SECRET_BUILD`, `ADMIN_PASSWORD_BUILD`, `USER_PASSWORD_BUILD` are copied into `JWT_SECRET`, `ADMIN_PASSWORD`, `USER_PASSWORD` at build time. |
| Data paths (upstream) | `/app/data` (volume per upstream comments), `/app/data/workflow`, `/app/.next` (group-writable). |
| Upstream entrypoint | `docker-entrypoint.sh` is not in the Dockerfile. UNVERIFIED: its exact behaviour; it only fixes `/app/data` permissions and drops to `nextjs` via gosu, which this plan does not need. |
| Arch | amd64 and arm64 bundles both published. |

## 2. Target layout

- `apps/libredb-studio/Dockerfile`
- `apps/libredb-studio/docker-bake.hcl`
- `apps/libredb-studio/settings.yaml`
- `apps/libredb-studio/container-test.yaml`
- `apps/libredb-studio/start.sh` (replaces upstream `docker-entrypoint.sh`, with a reason: the upstream one runs as root, chowns and uses gosu)

No `defaults/`, `etc/`, `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (the app is not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Fits because the app is a Node runtime only. The draft names python-node as runtime, and it provides `/usr/bin/node` on glibc Ubuntu. Closest siblings: `apps/budge` (python-node, Node build plus `USER apps`, `/config` volume) and `apps/changedetection` (python-node, pinned tarball from GitHub releases with fallback to `v${VERSION}`). Node major shipped by `python-node:3.15.2` is UNVERIFIED here (the budge Dockerfile comment hints at Node 24).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`. Set `ENV` for telemetry off (`NEXT_TELEMETRY_DISABLED=1`), `HOSTNAME=0.0.0.0`, `PORT=3000`, `NODE_ENV=production`, `WORKFLOW_LOCAL_DATA_DIR=/config/workflow` (remap of upstream `/app/data/workflow`).
2. Map the arch: `amd64 -> x64`, `arm64 -> arm64`, anything else `exit 1`.
3. Download the bundle and `SHA256SUMS` from `https://github.com/libredb/libredb-studio/releases/download/${VERSION}/`, then verify with `sha256sum -c --ignore-missing` against the one bundle line. Do not verify a bundle without its checksum.
4. Extract to `/app` with `tar xzf ... -C /app --strip-components=1` (layout UNVERIFIED: whether the tarball has a top-level folder; the build must `test -f /app/server.js` and fail otherwise).
5. Remove `/tmp/*` artifacts and `$HOME/.cache` in the same `RUN` layer.
6. Keep the upstream native drivers in the bundle. UNVERIFIED that `better-sqlite3` and `@duckdb` ship prebuilt for glibc arm64 in the standalone bundle: test the module load in the build step (`node -e "require('better-sqlite3')"` run from `/app`).
7. Ship the licence: copy `LICENSE` from the upstream tag archive to `/usr/share/licenses/libredb-studio/LICENSE` (UNVERIFIED that the bundle contains it; fetch from `https://raw.githubusercontent.com/libredb/libredb-studio/${VERSION}/LICENSE` if not present).
8. Data remap: `ln -s /config/data /app/data` in the image (dangling until `start.sh` creates `/config/data`). Works with read-only rootfs because the symlink is created at build time.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /app
```

`WORKDIR /app` so `node server.js` resolves the standalone server. `COPY --chmod=0755 . /` brings in `start.sh` only (allow-list in `include/.dockerignore`).

Do not carry over the upstream build-arg placeholders as `ENV` (see section 9).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "libredb-studio"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=libredb/libredb-studio versioning=semver
  default = "1.3.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/libredb/libredb-studio"
}
```

Then the standard `group "default"` (targets `image-local`), `target "image"` with `args = { VERSION = "${VERSION}" }` and OCI labels (`source`, `licenses`), `image-local` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`) and `image-all` (linux/amd64, linux/arm64), copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` from `apps/libredb-studio`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/libredb/libredb-studio"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "3000"
    required: false
  - name: WORKFLOW_LOCAL_DATA_DIR
    default: "/config/workflow"
    required: false
  - name: NODE_OPTIONS
    default: "--max-old-space-size=384"
    required: false
  - name: JWT_SECRET
    default: ""
    required: false
  - name: ADMIN_PASSWORD
    default: ""
    required: false
  - name: USER_PASSWORD
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `JWT_SECRET`, `ADMIN_PASSWORD`, `USER_PASSWORD`: the names are from the upstream build args, and how the app reads them at runtime is UNVERIFIED. Listed so users can set them; not `required` because `start.sh` generates `JWT_SECRET` on first run (section 7).
- `dependencies`: none (user-supplied external databases are configured in the UI, not containers).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data /config/workflow

if [[ -z "${JWT_SECRET:-}" ]]; then
  if [[ ! -s /config/jwt_secret ]]; then
    umask 077
    openssl rand -hex 32 > /config/jwt_secret
  fi
  JWT_SECRET="$(cat /config/jwt_secret)"
fi
export JWT_SECRET

export PORT="${PORT:-3000}"
export HOSTNAME="${HOSTNAME:-0.0.0.0}"

cd /app || exit 1
exec node server.js
```

- Idempotent: seeds `jwt_secret` only when missing; no overwrite of user state.
- No writes to `/app`. Ephemeral cache goes to `/tmp` (section 9).
- `exec` so `node` is PID 1 and gets signals.
- UNVERIFIED: `openssl` is present in the base image (check with `command -v openssl` in the build step; otherwise read `/dev/urandom` with `od`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/server.js
- /usr/share/licenses/libredb-studio/LICENSE
```

- Port 3000 has both `tcp` and `http` probes (settings lists it).
- UNVERIFIED: whether `/` returns 200 without any env (the app may redirect to a setup page). If not, use the path that returns 200 and record why.
- `filePaths` checks the server entry and the licence. The test runs without env, so the `JWT_SECRET` generation branch in `start.sh` is exercised by the default run. The password path is not a required code path.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data` (volume in upstream) | Build-time symlink `/app/data` -> `/config/data` |
| `/app/data/workflow` (`WORKFLOW_LOCAL_DATA_DIR`) | `WORKFLOW_LOCAL_DATA_DIR=/config/workflow` |
| `/app/.next` (group-writable upstream, Next.js cache) | UNVERIFIED whether `next start` writes `.next/cache` at runtime. If it does, the read-only rootfs fails. Fix options: point the cache elsewhere if the app supports it, or copy the standalone output to `/tmp` in `start.sh` (last resort, documented). Decide after the run in section 11. |
| npm/Node caches during build | `$HOME/.cache` and `/tmp/*` removed in the same layer |
| Upstream build-arg placeholders (`JWT_SECRET_BUILD`, `ADMIN_PASSWORD_BUILD`, `USER_PASSWORD_BUILD`) | Not carried into the image. They would bake placeholder secrets into `ENV`. `start.sh` generates `JWT_SECRET` into `/config` instead. |

Draft security expectations reconciled: chart runs as 568 (`apps` user), read-only rootfs true, not privileged. The image is compatible with `--read-only --tmpfs /tmp` on paper; the `.next` write is the open question. The upstream image runs as root first (entrypoint, gosu): this image does not, so the entrypoint behaviour is dropped on purpose.

## 10. Risks, caveats and open questions

- Standalone tarball layout and entry point (`server.js` at the root) are UNVERIFIED: the build fails fast if `/app/server.js` is missing.
- Native modules (`better-sqlite3`, `@duckdb`, `oracledb`) need to load on glibc amd64 and arm64: test in the build step.
- Build-time secrets: upstream bakes placeholder `JWT_SECRET`/passwords into `ENV`. Not reproduced here, and users must supply real values or accept the generated `JWT_SECRET`. UNVERIFIED how the app uses `ADMIN_PASSWORD` and `USER_PASSWORD` at runtime.
- The app connects to user-supplied databases (sqlite, duckdb, oracle, db2, etc.). Credentials are entered in the UI. No database container dependency.
- The draft's `/app/data` expectation is kept by symlink, so persisted chart data at `/app/data` must be moved to `/config/data` by existing users (UNVERIFIED that the chart's data is only `/app/data`).
- Blockers: none known (not musl-only, no GPU, no privileged needs, arm64 bundle published). The upstream QEMU note about bun is a reason to avoid bun in the build, which this plan does not use (uses the prebuilt bundle).

## 11. Build and test steps

```sh
cd apps/libredb-studio
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name libredb-studio-probe --read-only --tmpfs /tmp \
  -v libredb-studio-probe-config:/config libredb-studio:1.3.0
docker logs -f libredb-studio-probe
forgetool containers test --image libredb-studio:1.3.0 --config ./apps/libredb-studio/container-test.yaml
docker rm -f libredb-studio-probe; docker volume rm libredb-studio-probe-config
```

- Expected readiness signal: Next.js/`node server.js` startup line and a listening log on port 3000 (exact text UNVERIFIED until the run).
- Check that `/config/jwt_secret` is created on first start and is kept on restart.
- Check from outside the container (`-p 3000:3000` and a curl from the host) that the server is not bound to localhost only.
- Run `arm64` only if the amd64 build fails for an arm64-specific reason (per protocol).

## 12. PR checklist

- Branch `feat/add-libredb-studio`, commit and PR title `feat(libredb-studio): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Untested to state honestly: the build on both architectures, the bundle layout, the native module load, the runtime on `--read-only`, the `.next` write behaviour, and the `/` probe status code.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
